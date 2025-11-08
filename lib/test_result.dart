// lib/test_result.dart

class TestResult {
  int? id;

  String testTitle;
  String resultValue;
  DateTime date;
  String? videoPath;

  // New fields
  int? wrongRepCount;
  bool? formCorrect;
  String? feedback;

  TestResult({
    this.id,
    required this.testTitle,
    required this.resultValue,
    required this.date,
    this.videoPath,
    this.wrongRepCount,
    this.formCorrect,
    this.feedback,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'testTitle': testTitle,
    'resultValue': resultValue,
    'date': date.toIso8601String(),
    'videoPath': videoPath,
    'wrongRepCount': wrongRepCount,
    'formCorrect': formCorrect == true ? 1 : 0,
    'feedback': feedback,
  };

  factory TestResult.fromMap(Map<String, dynamic> m) => TestResult(
    id: m['id'] as int?,
    testTitle: m['testTitle'] as String,
    resultValue: m['resultValue'] as String,
    date: DateTime.parse(m['date'] as String),
    videoPath: m['videoPath'] as String?,
    wrongRepCount: m['wrongRepCount'] as int?,
    formCorrect: (m['formCorrect'] as int?) == 1,
    feedback: m['feedback'] as String?,
  );
}
