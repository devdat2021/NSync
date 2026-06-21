import '../models/result_model.dart';

List<SubjectResult> parseSubjectResults(Map<String, dynamic> data) {
  final results = <SubjectResult>[];

  data.forEach((rawSubjectKey, components) {
    // "Linear Algebra and Its Applications [MA2005-1]"
    final match = RegExp(r'^(.+?)\s*\[(.+?)\]$').firstMatch(rawSubjectKey);
    final name = match?.group(1)?.trim() ?? rawSubjectKey;
    final code = match?.group(2)?.trim() ?? '';

    int? see;
    int? cie;
    bool isPractical = false;

    (components as Map<String, dynamic>).forEach((compCode, comp) {
      final c = comp as Map<String, dynamic>;
      final marks = int.tryParse(c['m']?.toString() ?? '');
      final status = c['s'] as String?;
      final thpr = c['thpr'] as String?;

      if (thpr == 'Pr.') isPractical = true;

      if (status == 'SEE' || status == 'PR') {
        see = marks;
      } else if (status == 'CIE') {
        cie = marks;
      }
    });

    results.add(
      SubjectResult(
        subjectName: name,
        subjectCode: code,
        seeMarks: see,
        cieMarks: cie,
        isPractical: isPractical,
      ),
    );
  });

  return results;
}
