// lib/services/supabase_upload_service.dart
// Handles uploading PDF reports to Supabase Storage and inserting metadata rows.

import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../pdf_generator.dart';
import '../report_models.dart';
import 'app_config.dart';
import '../isar_service.dart';
import '../test_result.dart';

class SupabaseUploadService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<String?> uploadSingleReport({
    required String athleteUid,
    required TestReport report,
    List<String>? tags,
  }) async {
    final bytes = await PdfGenerator.buildSingleReportPdfBytes(report);
    final fileName = _fileName(report.testTitle);
    final storage = _client.storage.from('reports');
    try {
      await storage.uploadBinary(
        fileName,
        bytes,
        fileOptions: const FileOptions(contentType: 'application/pdf'),
      );
    } catch (e) {
      return null;
    }
    final publicUrl = storage.getPublicUrl(fileName);
    await _insertMetadata(
      athleteUid: athleteUid,
      report: report,
      pdfUrl: publicUrl,
      tags: tags,
    );
    return publicUrl;
  }

  Future<String?> uploadAllReports({
    required String athleteUid,
    List<String>? tags,
  }) async {
    final bytes = await PdfGenerator.buildAllReportsPdfBytes();
    final fileName = _fileName('All_Tests_Report');
    final storage = _client.storage.from('reports');
    try {
      await storage.uploadBinary(
        fileName,
        bytes,
        fileOptions: const FileOptions(contentType: 'application/pdf'),
      );
    } catch (e) {
      return null;
    }
    final publicUrl = storage.getPublicUrl(fileName);
    await _client.from('coach_reports').insert({
      'athlete_uid': athleteUid,
      'test_title': 'ALL',
      'headline': 'Consolidated Performance Report',
      'pdf_url': publicUrl,
      'generated_at': DateTime.now().toIso8601String(),
      'tags': (tags ?? ['all']).join(','),
      'primary_metric': null,
      'raw_json': null,
    });
    return publicUrl;
  }

  Future<void> _insertMetadata({
    required String athleteUid,
    required TestReport report,
    required String pdfUrl,
    List<String>? tags,
  }) async {
    final metric = _extractNumeric(report.headlineResult);
    await _client.from('coach_reports').insert({
      'athlete_uid': athleteUid,
      'test_title': report.testTitle,
      'headline': report.headlineResult,
      'pdf_url': pdfUrl,
      'generated_at': DateTime.now().toIso8601String(),
      'tags': (tags ?? ['single']).join(','),
      'primary_metric': metric,
      'raw_json': {
        'summary': report.resultSummary,
        'breakdown': report.breakdownMetrics
            .map((m) => {'label': m.label, 'value': m.value})
            .toList(),
        'comparison': report.comparisonMetrics
            .map((m) => {'label': m.label, 'value': m.value})
            .toList(),
      },
    });
  }

  String _fileName(String base) {
    final sanitized = base.replaceAll(' ', '_');
    return '${sanitized}_${DateTime.now().millisecondsSinceEpoch}.pdf';
  }

  double? _extractNumeric(String raw) {
    final match = RegExp(r'(\d+(?:\.\d+)?)').firstMatch(raw);
    return match != null ? double.tryParse(match.group(1)!) : null;
  }
}
