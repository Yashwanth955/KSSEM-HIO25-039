// lib/services/sync_service.dart
// Upload TestResult rows from SQLite to the backend /results endpoint.

import 'dart:convert';

import 'package:http/http.dart' as http;

import '../isar_service.dart';
import '../test_result.dart';
import 'app_config.dart';

class SyncService {
  final String baseUrl;
  final String? authToken;

  SyncService({String? baseUrl, this.authToken})
    : baseUrl = baseUrl ?? AppConfig.backendBaseUrl;

  Uri get _resultsUri => Uri.parse('$baseUrl/results');

  Future<SyncSummary> uploadAllResults({IsarService? isar}) async {
    final isarService = isar ?? IsarService();
    final results = await isarService.getAllTestResults();
    if (results.isEmpty) {
      return SyncSummary(total: 0, success: 0, failed: 0);
    }

    var ok = 0;
    var fail = 0;

    for (final r in results) {
      final resp = await _postResult(r);
      if (resp)
        ok++;
      else
        fail++;
    }
    return SyncSummary(total: results.length, success: ok, failed: fail);
  }

  Future<bool> _postResult(TestResult r) async {
    final body = {
      'testTitle': r.testTitle,
      'resultValue': r.resultValue,
      'date': r.date.toIso8601String(),
      if (r.videoPath != null) 'videoPath': r.videoPath,
      if (r.wrongRepCount != null) 'wrongRepCount': r.wrongRepCount,
      if (r.formCorrect != null) 'formCorrect': r.formCorrect,
      if (r.feedback != null) 'feedback': r.feedback,
    };

    final headers = <String, String>{'Content-Type': 'application/json'};
    if (authToken != null && authToken!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $authToken';
    }

    try {
      final resp = await http
          .post(_resultsUri, headers: headers, body: jsonEncode(body))
          .timeout(const Duration(seconds: 20));
      return resp.statusCode >= 200 && resp.statusCode < 300;
    } catch (_) {
      return false;
    }
  }
}

class SyncSummary {
  final int total;
  final int success;
  final int failed;
  const SyncSummary({
    required this.total,
    required this.success,
    required this.failed,
  });
}
