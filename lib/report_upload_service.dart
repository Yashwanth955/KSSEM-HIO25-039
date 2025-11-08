// lib/report_upload_service.dart
// Simple service to upload generated PDF reports to a backend server.
// Assumptions:
// - Backend exposes a POST /upload endpoint that accepts multipart/form-data
// - Field name for file is `file` and optional metadata as text fields
// - If you require auth, pass a bearer token in the headers

import 'dart:async';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class ReportUploadService {
  ReportUploadService({required this.baseUrl, this.authToken});

  final String baseUrl; // e.g. https://api.example.com
  final String? authToken;

  Uri get _uploadUri => Uri.parse('$baseUrl/upload');

  Future<UploadResult> uploadPdfBytes({
    required Uint8List pdfBytes,
    String filename = 'report.pdf',
    Map<String, String>? fields,
    Map<String, String>? headers,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    final request = http.MultipartRequest('POST', _uploadUri);

    // Add auth if provided
    if (authToken != null && authToken!.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $authToken';
    }
    if (headers != null) {
      request.headers.addAll(headers);
    }

    // Attach fields
    if (fields != null) {
      request.fields.addAll(fields);
    }

    // Attach the PDF as a multipart file
    request.files.add(
      http.MultipartFile.fromBytes(
        'file',
        pdfBytes,
        filename: filename,
        contentType: MediaType('application', 'pdf'),
      ),
    );

    try {
      final streamed = await request.send().timeout(timeout);
      final resp = await http.Response.fromStream(streamed);
      final ok = resp.statusCode >= 200 && resp.statusCode < 300;
      return UploadResult(ok: ok, statusCode: resp.statusCode, body: resp.body);
    } on TimeoutException {
      return UploadResult(ok: false, statusCode: 408, body: 'Request timeout');
    } catch (e) {
      return UploadResult(ok: false, statusCode: 0, body: e.toString());
    }
  }
}

class UploadResult {
  final bool ok;
  final int statusCode;
  final String body;
  UploadResult({
    required this.ok,
    required this.statusCode,
    required this.body,
  });
}
