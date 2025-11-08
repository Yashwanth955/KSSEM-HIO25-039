import 'dart:ui';
import 'dart:math';
import 'pose_analyzer.dart';

// This processor works with any pose object (from ML Kit or a custom representation).
// Use `dynamic` for pose/detection types to avoid tight coupling to a single SDK here.

class PersonTracker {
  final int id;
  dynamic latestPose;
  Rect latestBbox; // normalized [0..1] coords
  int lastSeenFrame = 0;
  int seenConsecutive = 0;
  final PoseAnalyzer analyzer;
  bool paused = false;
  bool isLocked = false;
  bool fraudDetected = false;

  // Fraud detection helpers
  Offset lockCentroid; // centroid when lock happened (normalized)
  int lockFrame = 0;
  int intrusionFrames = 0;
  int displacementViolationFrames = 0;
  int occlusionFrames = 0;

  // Evidence (optional): keep N last bboxes/poses for report
  final List<Map<String, dynamic>> recentEvidence = [];

  PersonTracker({
    required this.id,
    required this.analyzer,
    required this.latestPose,
    required this.latestBbox,
    required this.lockCentroid,
    required this.lockFrame,
  });
}

class EnhancedPoseProcessor {
  final PoseAnalyzer Function() analyzerFactory;
  final int lockFramesThreshold;
  final int releaseFrames;

  // Fraud thresholds (tuneable)
  final double intrusionIoUThreshold = 0.25;
  final int intrusionPersistFrames = 5;
  final double maxFrameDisplacement = 0.08;
  final double maxTotalDisplacement = 0.25;
  final int displacementPersistFrames = 3;
  final int occlusionPersistFrames = 6;
  final double visibilityThreshold = 0.35;

  final Map<int, PersonTracker> trackers = {};
  int _frameCounter = 0;

  // callback to notify UI or report system
  void Function(PersonTracker tracker)? onFraudDetected;

  EnhancedPoseProcessor({
    required this.analyzerFactory,
    this.lockFramesThreshold = 3,
    this.releaseFrames = 10,
  });

  void processFrame(List<dynamic> detections, Size imageSize) {
    _frameCounter++;
    // (matching / creating trackers omitted — same as earlier)
    // ... after trackers updated and target selected ...
    // For each tracker, run fraud checks:
    trackers.forEach((id, t) {
      // store evidence
      t.recentEvidence.add({
        'frame': _frameCounter,
        'bbox': t.latestBbox,
        'pose': t.latestPose,
      });
      if (t.recentEvidence.length > 50) {
        t.recentEvidence.removeAt(0);
      }

      // compute centroid of latestBbox
      final centroid = Offset(
        t.latestBbox.left + t.latestBbox.width / 2,
        t.latestBbox.top + t.latestBbox.height / 2,
      );

      // 1) If locked, check displacement
      if (t.isLocked && !t.fraudDetected) {
        final dx = (centroid.dx - t.lockCentroid.dx).abs();
        final dy = (centroid.dy - t.lockCentroid.dy).abs();
        final totalDisp = sqrt(dx * dx + dy * dy);

        // frame-to-frame displacement
        // (assume t.latestPose has prevCentroid if you tracked it; else store last centroid locally)
        final prev = _getPrevCentroidForTracker(t) ?? centroid;
        final frameDx = (centroid.dx - prev.dx).abs();
        final frameDy = (centroid.dy - prev.dy).abs();
        final frameDisp = sqrt(frameDx * frameDx + frameDy * frameDy);

        // 2) Occlusion/visibility check
        final vis = _computeVisibilityScore(t.latestPose); // 0..1
        if (vis < visibilityThreshold) {
          t.occlusionFrames++;
        } else {
          t.occlusionFrames = 0;
        }

        // 3) Intrusion check (if another tracker overlaps)
        bool intruded = false;
        for (final other in trackers.values) {
          if (other.id == t.id) continue;
          final iou = _iou(t.latestBbox, other.latestBbox);
          if (iou > intrusionIoUThreshold) {
            intruded = true;
            break;
          }
        }
        if (intruded) {
          t.intrusionFrames++;
        } else {
          t.intrusionFrames = 0;
        }

        // 4) Displacement violations
        if (frameDisp > maxFrameDisplacement) {
          t.displacementViolationFrames++;
        } else {
          t.displacementViolationFrames = 0;
        }

        // 5) Evaluate fraud conditions (combine or single condition)
        final bool fraudByOcclusion =
            t.occlusionFrames >= occlusionPersistFrames;
        final bool fraudByIntrusion =
            t.intrusionFrames >= intrusionPersistFrames;
        final bool fraudByDisplacement =
            (t.displacementViolationFrames >= displacementPersistFrames) ||
            (totalDisp > maxTotalDisplacement);

        if (fraudByOcclusion || fraudByIntrusion || fraudByDisplacement) {
          // declare fraud
          t.fraudDetected = true;
          // tell analyzer to stop counting (pass allowCounting=false) and optionally set state
          try {
            // call analyzer callback if present (dynamic to avoid tight typing)
            (t.analyzer as dynamic).onFraudDetected?.call();
          } catch (_) {}
          // notify UI / recording
          if (onFraudDetected != null) onFraudDetected!(t);
        }
      } // end locked checks
    });

    // feeding analyzer: only allow counting for locked & not-fraud trackers & not paused
    trackers.forEach((id, t) {
      final allowCounting = t.isLocked && !t.fraudDetected && !t.paused;
      final vis = _computeVisibilityScore(t.latestPose);
      try {
        if (vis >= visibilityThreshold) {
          // call via dynamic to avoid static type mismatches between pose types
          (t.analyzer as dynamic).analyze(
            t.latestPose,
            imageSize,
            allowCounting: allowCounting,
          );
        } else {
          (t.analyzer as dynamic).analyze(
            t.latestPose,
            imageSize,
            allowCounting: false,
          );
        }
      } catch (_) {
        // analyzer may not implement analyze with this signature; ignore to keep processor decoupled
      }
    });

    // rest of cleanups ...
  }

  double _computeVisibilityScore(dynamic p) {
    // compute average landmark confidence if available
    try {
      double sum = 0.0;
      int count = 0;
      // try common shapes: if landmarks is an Iterable or Map
      final landmarks = (p.landmarks is Iterable)
          ? p.landmarks
          : (p.landmarks is Map ? (p.landmarks as Map).values : null);
      if (landmarks != null) {
        for (final lm in landmarks) {
          try {
            final vis =
                (lm as dynamic).visibility ??
                (lm as dynamic).inFrameLikelihood ??
                (lm as dynamic).score;
            if (vis is num) {
              sum += vis.toDouble();
              count++;
            }
          } catch (_) {
            // ignore per-landmark access errors
          }
        }
      }
      if (count > 0) {
        return sum / count;
      }
      return 0.0;
    } catch (_) {
      // fallback: compute area-based visibility proxy (large bbox => visible)
      try {
        final bbox = (p.bbox ?? (p as dynamic).boundingBox);
        if (bbox is Rect) {
          return (bbox.width * bbox.height).clamp(0.0, 1.0).toDouble();
        }
      } catch (_) {}
      return 0.0;
    }
  }

  Offset? _getPrevCentroidForTracker(PersonTracker t) {
    // extract last evidence centroid if exists
    if (t.recentEvidence.length >= 2) {
      final e = t.recentEvidence[t.recentEvidence.length - 2];
      final bbox = e['bbox'] as Rect;
      return Offset(bbox.left + bbox.width / 2, bbox.top + bbox.height / 2);
    }
    return null;
  }

  double _iou(Rect a, Rect b) {
    final inter = a.intersect(b);
    if (inter.width <= 0 || inter.height <= 0) return 0.0;
    final interArea = inter.width * inter.height;
    final union = a.width * a.height + b.width * b.height - interArea;
    return interArea / union;
  }
}
