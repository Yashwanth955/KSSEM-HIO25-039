// lib/pose_analyzer.dart
import 'dart:math';
import 'dart:ui';

import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

/// Abstract base class for all pose analyzers
abstract class PoseAnalyzer {
  int get repCount;
  List<String> getFeedback();
  bool get formIsCorrect;
  int get wrongRepCount;

  void processPose(Pose pose, Size imageSize);
  void reset();
}

/// ---------- Helpers ----------
Offset? _lmPos(Pose pose, PoseLandmarkType type) {
  try {
    final lm = pose.landmarks[type];
    if (lm == null) return null;
    return Offset(lm.x.toDouble(), lm.y.toDouble());
  } catch (e) {
    return null;
  }
}

/// Returns the angle (degrees) at point b formed by points a-b-c
double _angleBetween(Offset a, Offset b, Offset c) {
  final ab = Offset(a.dx - b.dx, a.dy - b.dy);
  final cb = Offset(c.dx - b.dx, c.dy - b.dy);

  final dot = ab.dx * cb.dx + ab.dy * cb.dy;
  final magAB = sqrt(ab.dx * ab.dx + ab.dy * ab.dy);
  final magCB = sqrt(cb.dx * cb.dx + cb.dy * cb.dy);

  if (magAB == 0 || magCB == 0) return 0.0;
  var cosAngle = dot / (magAB * magCB);
  cosAngle = cosAngle.clamp(-1.0, 1.0);
  return acos(cosAngle) * 180 / pi;
}

/// A small utility: average of two angles (handles NaN)
double _avg(double a, double b) => (a + b) / 2;

/// Horizontal distance in normalized coordinates (x / imageWidth)
double _normDx(Offset a, Offset b, Size imageSize) =>
    (a.dx - b.dx).abs() / (imageSize.width == 0 ? 1 : imageSize.width);

/// Vertical distance normalized
double _normDy(Offset a, Offset b, Size imageSize) =>
    (a.dy - b.dy).abs() / (imageSize.height == 0 ? 1 : imageSize.height);

/// ---------- No-AI Analyzer ----------
class NoAIAnalyzer extends PoseAnalyzer {
  @override
  int get repCount => 0;

  @override
  List<String> getFeedback() => ["This test is manually recorded."];

  @override
  bool get formIsCorrect => true;

  @override
  int get wrongRepCount => 0;

  @override
  void processPose(Pose pose, Size imageSize) {
    // No-op
  }

  @override
  void reset() {}
}

/// ---------- Sit & Reach (Flexibility) ----------
class SitAndReachAnalyzer extends PoseAnalyzer {
  double _reachDistanceNorm = 0.0;
  bool _measured = false;

  @override
  int get repCount => 0;

  @override
  List<String> getFeedback() {
    if (!_measured) return ['Move forward and hold the reach position.'];
    if (_reachDistanceNorm > 0.15) {
      return ['Excellent reach distance. Maintain straight legs.'];
    } else if (_reachDistanceNorm > 0.08) {
      return ['Good reach, a bit more reach would help.'];
    } else {
      return ['Work on hamstring flexibility and lean forward more.'];
    }
  }

  @override
  bool get formIsCorrect => _measured && _reachDistanceNorm > 0.05;

  @override
  int get wrongRepCount => 0;

  @override
  void processPose(Pose pose, Size imageSize) {
    // We'll estimate reach by horizontal distance of fingertips to toes/ankle
    final lHand = _lmPos(pose, PoseLandmarkType.leftIndex);
    final rHand = _lmPos(pose, PoseLandmarkType.rightIndex);
    final lFoot = _lmPos(pose, PoseLandmarkType.leftAnkle);
    final rFoot = _lmPos(pose, PoseLandmarkType.rightAnkle);

    if (lHand == null || rHand == null || lFoot == null || rFoot == null) return;

    // Use nearest foot
    final handsX = (lHand.dx + rHand.dx) / 2;
    final feetX = (lFoot.dx + rFoot.dx) / 2;

    _reachDistanceNorm = ((handsX - feetX).abs()) / (imageSize.width == 0 ? 1 : imageSize.width);
    _measured = true;
  }

  @override
  void reset() {
    _reachDistanceNorm = 0.0;
    _measured = false;
  }
}

/// ---------- Push-Up Analyzer ----------
class PushUpAnalyzer extends PoseAnalyzer {
  int _reps = 0;
  int _hipDropCount = 0;
  int _elbowFlareCount = 0;

  // internal FSM
  bool _wasDown = false;
  bool _wasUp = true;

  // thresholds (tune for your camera / subject)
  final double _elbowDownAngle = 90; // elbow angle less than this considered down
  final double _elbowUpAngle = 160; // elbow angle greater than this considered up
  final double _hipDropThresholdNorm = 0.08; // normalized (relative) vertical offset between shoulders/hips

  @override
  int get repCount => _reps;

  @override
  List<String> getFeedback() {
    final feedback = <String>[];
    if (_elbowFlareCount > 2) {
      feedback.add('Elbows flared on $_elbowFlareCount reps — keep elbows closer to body.');
    }
    if (_hipDropCount > 0) {
      feedback.add('Hips dropped $_hipDropCount times — brace your core.');
    }
    if (feedback.isEmpty) feedback.add('Good push-up control.');
    return feedback;
  }

  @override
  bool get formIsCorrect => _hipDropCount == 0 && _elbowFlareCount == 0;

  @override
  int get wrongRepCount => _hipDropCount + _elbowFlareCount;

  @override
  void processPose(Pose pose, Size imageSize) {
    // required landmarks
    final lShoulder = _lmPos(pose, PoseLandmarkType.leftShoulder);
    final rShoulder = _lmPos(pose, PoseLandmarkType.rightShoulder);
    final lElbow = _lmPos(pose, PoseLandmarkType.leftElbow);
    final rElbow = _lmPos(pose, PoseLandmarkType.rightElbow);
    final lWrist = _lmPos(pose, PoseLandmarkType.leftWrist);
    final rWrist = _lmPos(pose, PoseLandmarkType.rightWrist);
    final lHip = _lmPos(pose, PoseLandmarkType.leftHip);
    final rHip = _lmPos(pose, PoseLandmarkType.rightHip);

    if ([lShoulder, rShoulder, lElbow, rElbow, lWrist, rWrist, lHip, rHip].contains(null)) {
      // missing data
      return;
    }

    // elbow angle (average of left and right)
    final leftElbowAngle = _angleBetween(lShoulder!, lElbow!, lWrist!);
    final rightElbowAngle = _angleBetween(rShoulder!, rElbow!, rWrist!);
    final elbowAngle = _avg(leftElbowAngle, rightElbowAngle);

    // hip line vertical deviation: compare shoulders' y to hips' y
    final shoulderY = (lShoulder.dy + rShoulder.dy) / 2;
    final hipY = (lHip!.dy + rHip!.dy) / 2;

    // if hip is sagging relative to shoulders (normalized)
    final hipSagNorm = (hipY - shoulderY).abs() / (imageSize.height == 0 ? 1 : imageSize.height);

    // elbow flare detection: angle shoulder-elbow-wrist projected horizontally
    // approximate flare by shoulder->elbow vector angle with vertical
    final leftShoulderElbowVec = Offset(lElbow.dx - lShoulder.dx, lElbow.dy - lShoulder.dy);
    final rightShoulderElbowVec = Offset(rElbow.dx - rShoulder.dx, rElbow.dy - rShoulder.dy);
    final leftShoulderElbowAngleFromVertical = (atan2(leftShoulderElbowVec.dx.abs(), leftShoulderElbowVec.dy.abs()) * 180 / pi);
    final rightShoulderElbowAngleFromVertical = (atan2(rightShoulderElbowVec.dx.abs(), rightShoulderElbowVec.dy.abs()) * 180 / pi);
    final flareAngle = _avg(leftShoulderElbowAngleFromVertical, rightShoulderElbowAngleFromVertical);

    // FSM: detect down -> up transition
    final isDown = elbowAngle < _elbowDownAngle;
    final isUp = elbowAngle > _elbowUpAngle;

    if (isDown) _wasDown = true;
    if (_wasDown && isUp) {
      _reps++;
      _wasDown = false;
      // form checks at rep completion
      if (hipSagNorm > _hipDropThresholdNorm) _hipDropCount++;
      if (flareAngle > 35) _elbowFlareCount++;
      _wasUp = true;
    }

    // keep last states consistent
    if (!isDown && !isUp) {
      // in-between; don't flip states
    }
  }

  @override
  void reset() {
    _reps = 0;
    _hipDropCount = 0;
    _elbowFlareCount = 0;
    _wasDown = false;
    _wasUp = true;
  }
}

/// ---------- Sit-Up Analyzer ----------
class SitUpAnalyzer extends PoseAnalyzer {
  int _reps = 0;
  int _formErrorCount = 0;

  // FSM
  bool _wasDown = true;
  bool _wasUp = false;

  // thresholds
  final double _upTorsoAngle = 40.0; // angle shoulder-hip-knee > this => up
  final double _downTorsoAngle = 20.0; // below this => down
  final double _feetLiftNormThreshold = 0.05; // normalized vertical movement of ankles

  Offset? _initialLeftAnkle;
  Offset? _initialRightAnkle;

  @override
  int get repCount => _reps;

  @override
  List<String> getFeedback() {
    final feedback = <String>[];
    if (_formErrorCount > 1) {
      feedback.add('Keep feet down and avoid using momentum.');
    } else {
      feedback.add('Good sit-up control.');
    }
    return feedback;
  }

  @override
  bool get formIsCorrect => _formErrorCount == 0;

  @override
  int get wrongRepCount => _formErrorCount;

  @override
  void processPose(Pose pose, Size imageSize) {
    final lShoulder = _lmPos(pose, PoseLandmarkType.leftShoulder);
    final rShoulder = _lmPos(pose, PoseLandmarkType.rightShoulder);
    final lHip = _lmPos(pose, PoseLandmarkType.leftHip);
    final rHip = _lmPos(pose, PoseLandmarkType.rightHip);
    final lKnee = _lmPos(pose, PoseLandmarkType.leftKnee);
    final rKnee = _lmPos(pose, PoseLandmarkType.rightKnee);
    final lAnkle = _lmPos(pose, PoseLandmarkType.leftAnkle);
    final rAnkle = _lmPos(pose, PoseLandmarkType.rightAnkle);

    if ([lShoulder, rShoulder, lHip, rHip, lKnee].contains(null)) return;

    // torso angle: use shoulder - hip - knee
    final shoulder = Offset((lShoulder!.dx + rShoulder!.dx) / 2, (lShoulder.dy + rShoulder.dy) / 2);
    final hip = Offset((lHip!.dx + rHip!.dx) / 2, (lHip.dy + rHip.dy) / 2);
    final knee = Offset((lKnee!.dx + rKnee!.dx) / 2, (lKnee.dy + rKnee.dy) / 2);

    final torsoAngle = _angleBetween(shoulder, hip, knee);

    // set initial ankles for feet lift detection
    if (_initialLeftAnkle == null && lAnkle != null) _initialLeftAnkle = lAnkle;
    if (_initialRightAnkle == null && rAnkle != null) _initialRightAnkle = rAnkle;

    final ankleLifted = (lAnkle != null && _initialLeftAnkle != null && (lAnkle.dy - _initialLeftAnkle!.dy).abs() / (imageSize.height == 0 ? 1 : imageSize.height) > _feetLiftNormThreshold) ||
        (rAnkle != null && _initialRightAnkle != null && (rAnkle.dy - _initialRightAnkle!.dy).abs() / (imageSize.height == 0 ? 1 : imageSize.height) > _feetLiftNormThreshold);

    final isUp = torsoAngle > _upTorsoAngle;
    final isDown = torsoAngle < _downTorsoAngle;

    if (isDown) _wasDown = true;
    if (_wasDown && isUp) {
      _reps++;
      _wasDown = false;
      if (ankleLifted) _formErrorCount++;
      _wasUp = true;
    }
  }

  @override
  void reset() {
    _reps = 0;
    _formErrorCount = 0;
    _wasDown = true;
    _wasUp = false;
    _initialLeftAnkle = null;
    _initialRightAnkle = null;
  }
}

/// ---------- Squat Analyzer ----------
class SquatAnalyzer extends PoseAnalyzer {
  int _reps = 0;
  int _formErrorCount = 0;

  bool _wasDown = false;
  bool _wasUp = true;

  final double _kneeDownAngle = 100.0; // knee angle < this means deep enough
  final double _kneeUpAngle = 160.0;
  final double _kneeValgusThreshold = 15.0; // degrees - knee caving in

  @override
  int get repCount => _reps;

  @override
  List<String> getFeedback() {
    final feedback = <String>[];
    if (_formErrorCount > 0) feedback.add('Watch knee alignment and keep chest up.');
    if (feedback.isEmpty) feedback.add('Solid squat technique.');
    return feedback;
  }

  @override
  bool get formIsCorrect => _formErrorCount == 0;

  @override
  int get wrongRepCount => _formErrorCount;

  @override
  void processPose(Pose pose, Size imageSize) {
    final lHip = _lmPos(pose, PoseLandmarkType.leftHip);
    final rHip = _lmPos(pose, PoseLandmarkType.rightHip);
    final lKnee = _lmPos(pose, PoseLandmarkType.leftKnee);
    final rKnee = _lmPos(pose, PoseLandmarkType.rightKnee);
    final lAnkle = _lmPos(pose, PoseLandmarkType.leftAnkle);
    final rAnkle = _lmPos(pose, PoseLandmarkType.rightAnkle);

    if ([lHip, rHip, lKnee, rKnee, lAnkle, rAnkle].contains(null)) return;

    final leftKneeAngle = _angleBetween(lHip!, lKnee!, lAnkle!);
    final rightKneeAngle = _angleBetween(rHip!, rKnee!, rAnkle!);
    final kneeAngle = _avg(leftKneeAngle, rightKneeAngle);

    // valgus detection: angle difference between hip-knee-ankle on two sides
    final valgus = (leftKneeAngle - rightKneeAngle).abs();

    final isDown = kneeAngle < _kneeDownAngle;
    final isUp = kneeAngle > _kneeUpAngle;

    if (isDown) _wasDown = true;
    if (_wasDown && isUp) {
      _reps++;
      _wasDown = false;
      if (valgus > _kneeValgusThreshold) _formErrorCount++;
    }
  }

  @override
  void reset() {
    _reps = 0;
    _formErrorCount = 0;
    _wasDown = false;
    _wasUp = true;
  }
}

/// ---------- Standing Broad Jump Analyzer ----------
class StandingBroadJumpAnalyzer extends PoseAnalyzer {
  // we track starting hip x and landing hip x to approximate distance in normalized image coords
  double _startHipX = double.nan;
  double _endHipX = double.nan;
  bool _isJumping = false;
  double _bestDistanceNorm = 0.0;

  @override
  int get repCount => 0;

  @override
  List<String> getFeedback() {
    if (_bestDistanceNorm > 0.2) return ['Good power and landing.'];
    if (_bestDistanceNorm > 0.1) return ['Average distance — more leg drive.'];
    return ['Try to swing arms and drive through hips for distance.'];
  }

  @override
  bool get formIsCorrect => _bestDistanceNorm > 0.05;

  @override
  int get wrongRepCount => 0;

  @override
  void processPose(Pose pose, Size imageSize) {
    // We'll use hip x coordinate movement to estimate horizontal travel across frames
    final lHip = _lmPos(pose, PoseLandmarkType.leftHip);
    final rHip = _lmPos(pose, PoseLandmarkType.rightHip);
    if (lHip == null || rHip == null) return;

    final hip = Offset((lHip.dx + rHip.dx) / 2, (lHip.dy + rHip.dy) / 2);
    final hipNormX = hip.dx / (imageSize.width == 0 ? 1 : imageSize.width);
    final hipNormY = hip.dy / (imageSize.height == 0 ? 1 : imageSize.height);

    // simple heuristic: when hip y increases (crouch) then quickly decreases (takeoff),
    // and later hip x changes significantly -> we mark a jump
    if (!_isJumping) {
      // start of trial: set startHipX
      if (_startHipX.isNaN) _startHipX = hipNormX;
      // detect takeoff if hip rises (y decreases) quickly relative to baseline
      // (we won't do complex velocity calc here; assume user triggers by moving forward)
      if (hipNormY < 0.6) {
        _isJumping = true;
      }
    } else {
      // while jumping, update endHipX with last seen hip position when hip becomes low again (landed)
      // landing is approximate: hipNormY increases again
      if (hipNormY > 0.6) {
        _endHipX = hipNormX;
        final dist = (_endHipX - (_startHipX.isNaN ? hipNormX : _startHipX)).abs();
        if (dist > _bestDistanceNorm) _bestDistanceNorm = dist;
        // reset for next detection
        _isJumping = false;
        _startHipX = double.nan;
        _endHipX = double.nan;
      }
    }
  }

  @override
  void reset() {
    _startHipX = double.nan;
    _endHipX = double.nan;
    _isJumping = false;
    _bestDistanceNorm = 0.0;
  }
}

/// ---------- Standing Vertical Jump Analyzer ----------
class StandingVerticalJumpAnalyzer extends PoseAnalyzer {
  double _baselineAnkleY = double.nan;
  double _peakAnkleY = double.nan; // smaller value = higher jump (image y increases downward)
  bool _inAir = false;
  double _bestJumpNorm = 0.0;

  @override
  int get repCount => 0;

  @override
  List<String> getFeedback() {
    if (_bestJumpNorm > 0.15) return ['Great vertical leap!'];
    if (_bestJumpNorm > 0.08) return ['Good jumping power.'];
    return ['Work on explosive leg drive and arm swing.'];
  }

  @override
  bool get formIsCorrect => _bestJumpNorm > 0.05;

  @override
  int get wrongRepCount => 0;

  @override
  void processPose(Pose pose, Size imageSize) {
    final lAnkle = _lmPos(pose, PoseLandmarkType.leftAnkle);
    final rAnkle = _lmPos(pose, PoseLandmarkType.rightAnkle);
    if (lAnkle == null || rAnkle == null) return;

    final ankle = Offset((lAnkle.dx + rAnkle.dx) / 2, (lAnkle.dy + rAnkle.dy) / 2);
    final normY = ankle.dy / (imageSize.height == 0 ? 1 : imageSize.height);

    if (_baselineAnkleY.isNaN) {
      _baselineAnkleY = normY;
      _peakAnkleY = normY;
    }

    if (!_inAir) {
      // detect takeoff: ankle moves upward (y decreases) significantly
      if (normY < _baselineAnkleY - 0.02) {
        _inAir = true;
        _peakAnkleY = normY;
      }
    } else {
      // while in air track peak (minimum normY)
      if (normY < _peakAnkleY) _peakAnkleY = normY;
      // detect landing: ankle returns close to baseline
      if (normY > _baselineAnkleY - 0.01) {
        // compute jump height normalized
        final jumpNorm = (_baselineAnkleY - _peakAnkleY).abs();
        if (jumpNorm > _bestJumpNorm) _bestJumpNorm = jumpNorm;
        // reset for next attempt
        _inAir = false;
        _baselineAnkleY = normY;
        _peakAnkleY = normY;
      }
    }
  }

  @override
  void reset() {
    _baselineAnkleY = double.nan;
    _peakAnkleY = double.nan;
    _inAir = false;
    _bestJumpNorm = 0.0;
  }
}

/// ---------- Medicine Ball Throw Analyzer ----------
class MedicineBallThrowAnalyzer extends PoseAnalyzer {
  // We'll track nose/hip x movement to estimate forward displacement and explosive movement
  double _startHipX = double.nan;
  double _endHipX = double.nan;
  bool _throwing = false;
  double _bestForwardNorm = 0.0;

  @override
  int get repCount => 0;

  @override
  List<String> getFeedback() {
    if (_bestForwardNorm > 0.12) return ['Great explosive throw, legs and core engaged.'];
    if (_bestForwardNorm > 0.06) return ['Good throw, add more hip drive.'];
    return ['Work on generating power from legs and rotation.'];
  }

  @override
  bool get formIsCorrect => _bestForwardNorm > 0.05;

  @override
  int get wrongRepCount => 0;

  @override
  void processPose(Pose pose, Size imageSize) {
    final lHip = _lmPos(pose, PoseLandmarkType.leftHip);
    final rHip = _lmPos(pose, PoseLandmarkType.rightHip);
    final nose = _lmPos(pose, PoseLandmarkType.nose);
    if (lHip == null || rHip == null || nose == null) return;

    final hip = Offset((lHip.dx + rHip.dx) / 2, (lHip.dy + rHip.dy) / 2);
    final hipNormX = hip.dx / (imageSize.width == 0 ? 1 : imageSize.width);
    final noseNormX = nose.dx / (imageSize.width == 0 ? 1 : imageSize.width);

    if (_startHipX.isNaN) _startHipX = hipNormX;

    // detect forward explosive phase by nose forward displacement
    if (!_throwing) {
      if (noseNormX - _startHipX > 0.02) {
        _throwing = true;
      }
    } else {
      // after throwing we expect landing/finish where hip X is forward of start
      if (hipNormX - _startHipX > 0.02) {
        _endHipX = hipNormX;
        final forward = (_endHipX - _startHipX).abs();
        if (forward > _bestForwardNorm) _bestForwardNorm = forward;
        // reset
        _throwing = false;
        _startHipX = double.nan;
        _endHipX = double.nan;
      }
    }
  }

  @override
  void reset() {
    _startHipX = double.nan;
    _endHipX = double.nan;
    _throwing = false;
    _bestForwardNorm = 0.0;
  }
}

/// ---------- Sprint Analyzer (basic stride detection) ----------
class SprintAnalyzer extends PoseAnalyzer {
  int _stepCount = 0;
  Offset? _prevLeftAnkle;
  Offset? _prevRightAnkle;

  @override
  int get repCount => 0;

  @override
  List<String> getFeedback() => ['Maintain forward lean and drive knees.'];

  @override
  bool get formIsCorrect => true;

  @override
  int get wrongRepCount => 0;

  @override
  void processPose(Pose pose, Size imageSize) {
    final lAnkle = _lmPos(pose, PoseLandmarkType.leftAnkle);
    final rAnkle = _lmPos(pose, PoseLandmarkType.rightAnkle);
    if (lAnkle == null || rAnkle == null) return;

    // detect steps as alternation in ankle y positions (simple heuristic)
    if (_prevLeftAnkle != null && _prevRightAnkle != null) {
      final leftDy = (lAnkle.dy - _prevLeftAnkle!.dy).abs();
      final rightDy = (rAnkle.dy - _prevRightAnkle!.dy).abs();
      if (leftDy > 10 || rightDy > 10) {
        _stepCount++;
      }
    }
    _prevLeftAnkle = lAnkle;
    _prevRightAnkle = rAnkle;
  }

  @override
  void reset() {
    _stepCount = 0;
    _prevLeftAnkle = null;
    _prevRightAnkle = null;
  }
}

/// ---------- Shuttle Run Analyzer ----------
class ShuttleRunAnalyzer extends PoseAnalyzer {
  // Shuttle run is usually timed; as a basic detection we count direction changes by nose x
  int _directionChanges = 0;
  double? _lastNoseX;
  bool? _lastDirRight;

  @override
  int get repCount => 0;

  @override
  List<String> getFeedback() => ['Stay low on turns and push off quickly.'];

  @override
  bool get formIsCorrect => true;

  @override
  int get wrongRepCount => 0;

  @override
  void processPose(Pose pose, Size imageSize) {
    final nose = _lmPos(pose, PoseLandmarkType.nose);
    if (nose == null) return;
    final noseNormX = nose.dx / (imageSize.width == 0 ? 1 : imageSize.width);

    if (_lastNoseX == null) {
      _lastNoseX = noseNormX;
      return;
    }

    final dirRight = noseNormX > _lastNoseX!;
    _lastDirRight ??= dirRight;

    if (dirRight != _lastDirRight) {
      _directionChanges++;
      _lastDirRight = dirRight;
    }
    _lastNoseX = noseNormX;
  }

  @override
  void reset() {
    _directionChanges = 0;
    _lastNoseX = null;
    _lastDirRight = null;
  }
}

/// ---------- Endurance Run Analyzer ----------
class EnduranceRunAnalyzer extends PoseAnalyzer {
  // Basic cadence estimation by counting steps per period
  int _stepCount = 0;
  Offset? _prevLeftAnkle;
  Offset? _prevRightAnkle;

  @override
  int get repCount => 0;

  @override
  List<String> getFeedback() => ['Hold steady pace and control breathing.'];

  @override
  bool get formIsCorrect => true;

  @override
  int get wrongRepCount => 0;

  @override
  void processPose(Pose pose, Size imageSize) {
    final lAnkle = _lmPos(pose, PoseLandmarkType.leftAnkle);
    final rAnkle = _lmPos(pose, PoseLandmarkType.rightAnkle);
    if (lAnkle == null || rAnkle == null) return;

    if (_prevLeftAnkle != null && _prevRightAnkle != null) {
      final leftDy = (lAnkle.dy - _prevLeftAnkle!.dy).abs();
      final rightDy = (rAnkle.dy - _prevRightAnkle!.dy).abs();
      if (leftDy > 8 || rightDy > 8) _stepCount++;
    }
    _prevLeftAnkle = lAnkle;
    _prevRightAnkle = rAnkle;
  }

  @override
  void reset() {
    _stepCount = 0;
    _prevLeftAnkle = null;
    _prevRightAnkle = null;
  }
}
