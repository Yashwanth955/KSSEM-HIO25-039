// lib/report_models.dart

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

// A single metric for the breakdown/analysis sections
class ReportMetric {
  final String label;
  final String value;

  ReportMetric({required this.label, required this.value});
}

// A tip for the "Coach Mode" section
class CoachTip {
  final IconData icon;
  final String title;
  final String description;

  CoachTip({
    required this.icon,
    required this.title,
    required this.description,
  });
}

// The main data model for the entire report screen
class TestReport {
  final String testTitle;
  final String imageUrl;
  final String headlineResult;
  final String resultSummary;
  final List<ReportMetric> breakdownMetrics;
  final List<ReportMetric> comparisonMetrics;
  final List<CoachTip> coachTips;
  final String progressTitle;
  final String progressValue;
  final String progressPeriod;
  final String progressTrend;
  final List<FlSpot> progressChartData;
  final XFile? videoFile;

  TestReport({
    required this.testTitle,
    required this.imageUrl,
    required this.headlineResult,
    required this.resultSummary,
    required this.breakdownMetrics,
    required this.comparisonMetrics,
    required this.coachTips,
    required this.progressTitle,
    required this.progressValue,
    required this.progressPeriod,
    required this.progressTrend,
    required this.progressChartData,
    this.videoFile,
  });

  TestReport copyWith({
    String? testTitle,
    String? imageUrl,
    String? headlineResult,
    String? resultSummary,
    List<ReportMetric>? breakdownMetrics,
    List<ReportMetric>? comparisonMetrics,
    List<CoachTip>? coachTips,
    String? progressTitle,
    String? progressValue,
    String? progressPeriod,
    String? progressTrend,
    List<FlSpot>? progressChartData,
    XFile? videoFile,
  }) {
    return TestReport(
      testTitle: testTitle ?? this.testTitle,
      imageUrl: imageUrl ?? this.imageUrl,
      headlineResult: headlineResult ?? this.headlineResult,
      resultSummary: resultSummary ?? this.resultSummary,
      breakdownMetrics: breakdownMetrics ?? this.breakdownMetrics,
      comparisonMetrics: comparisonMetrics ?? this.comparisonMetrics,
      coachTips: coachTips ?? this.coachTips,
      progressTitle: progressTitle ?? this.progressTitle,
      progressValue: progressValue ?? this.progressValue,
      progressPeriod: progressPeriod ?? this.progressPeriod,
      progressTrend: progressTrend ?? this.progressTrend,
      progressChartData: progressChartData ?? this.progressChartData,
      videoFile: videoFile ?? this.videoFile,
    );
  }
}
