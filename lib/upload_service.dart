import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class UploadService {
  final SupabaseClient _sb = Supabase.instance.client;

  Future<String> _uploadToBucket({
    required File file,
    required String bucket,
    required String path, // e.g., "athleteId/1710000000.mp4"
  }) async {
    final storage = _sb.storage.from(bucket);
    await storage.upload(path, file, fileOptions: const FileOptions(upsert: true));
    // Signed URL valid for 7 days
    final signed = await storage.createSignedUrl(path, 60 * 60 * 24 * 7);
    return signed;
  }

  /// Uploads (optionally) video & pdf to storage, then inserts a test row.
  Future<void> uploadResult({
    required String athleteId,       // from your existing table / auth user id
    required String testName,
    required double score,
    double? formScore,
    File? videoFile,                 // optional
    File? pdfFile,                   // optional
    DateTime? takenAt,
  }) async {
    String? videoUrl;
    String? pdfUrl;

    if (videoFile != null) {
      final videoPath = '$athleteId/${DateTime.now().millisecondsSinceEpoch}.mp4';
      videoUrl = await _uploadToBucket(file: videoFile, bucket: 'videos', path: videoPath);
    }

    if (pdfFile != null) {
      final pdfPath = '$athleteId/${DateTime.now().millisecondsSinceEpoch}.pdf';
      pdfUrl = await _uploadToBucket(file: pdfFile, bucket: 'reports', path: pdfPath);
    }

    final payload = {
      'athlete_id': athleteId,
      'test_name' : testName,
      'score'     : score,
      'form_score': formScore,
      'video_url' : videoUrl,
      'pdf_url'   : pdfUrl,
      'taken_at'  : (takenAt ?? DateTime.now()).toIso8601String(),
    };

    final res = await _sb.from('test_results').insert(payload);
    if (res is PostgrestException) {
      throw res.message;
    }
  }
}
