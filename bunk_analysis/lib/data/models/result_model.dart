class SemesterSummary {
  final String examNo; // "D-2026-1"
  final String examName; // "Fourth Semester"
  final String examDate; // "MAY 2026"
  final String resultDate;
  final String overallClass; // "Pass"

  const SemesterSummary({
    required this.examNo,
    required this.examName,
    required this.examDate,
    required this.resultDate,
    required this.overallClass,
  });

  factory SemesterSummary.fromJson(Map<String, dynamic> json) {
    final examNameRaw = (json['examname'] as String? ?? '').replaceAll(
      '<br>',
      ' — ',
    );
    return SemesterSummary(
      examNo: json['year'] ?? '',
      examName: examNameRaw,
      examDate: json['examdate'] ?? '',
      resultDate: json['resultdate'] ?? '',
      overallClass: json['class'] ?? '',
    );
  }
}

class SubjectResult {
  final String subjectName;
  final String subjectCode;
  final int? seeMarks;
  final int? cieMarks;
  final bool isPractical;

  const SubjectResult({
    required this.subjectName,
    required this.subjectCode,
    this.seeMarks,
    this.cieMarks,
    required this.isPractical,
  });

  int get total => (seeMarks ?? 0) + (cieMarks ?? 0);
}
