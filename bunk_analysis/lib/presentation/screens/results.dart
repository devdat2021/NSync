// lib/presentation/screens/results_screen.dart

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/result_model.dart';
import '../../data/providers/portal_scrapper.dart';
import '../../core/security/credential_vault.dart';
import '../../data/repositories/attendance_data.dart';

class ResultsScreen extends StatefulWidget {
  const ResultsScreen({super.key});

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  List<SemesterSummary> _semesters = [];
  Map<String, List<SubjectResult>> _detailsCache = {};
  String? _expandedExamNo;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final api = PortalApi();
    final reg = await CredentialVault.getRegno();
    final pass = await CredentialVault.getPassword();
    List<SemesterSummary> semesters = [];
    bool success = false;
    try {
      success = await api.login(regno: reg ?? '', password: pass ?? '');
    } catch (e) {
      success = false;
    }
    if (success) {
      semesters = await api.fetchAllResults();
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Error fetching results')));
    }
    if (!mounted) return;
    setState(() {
      _semesters = semesters;
      _loading = false;
    });
  }

  Future<void> _toggleExpand(SemesterSummary sem) async {
    if (_expandedExamNo == sem.examNo) {
      setState(() => _expandedExamNo = null);
      return;
    }

    setState(() => _expandedExamNo = sem.examNo);

    if (!_detailsCache.containsKey(sem.examNo)) {
      // final regno = await CredentialVault.getRegno();
      final usn = await LocalCache.getUSN();
      final reg = await CredentialVault.getRegno();
      final pass = await CredentialVault.getPassword();
      List<SubjectResult> details = [];

      final api = PortalApi();
      bool success = false;
      try {
        success = await api.login(regno: reg ?? '', password: pass ?? '');
      } catch (e) {
        success = false;
      }
      if (success) {
        details = await api.fetchSemesterDetail(sem.examNo, usn);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Error fetching results')));
      }
      if (!mounted) return;
      setState(() => _detailsCache[sem.examNo] = details);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColorSchemeExt.of(context);

    return Scaffold(
      backgroundColor: c.pageBg,
      appBar: AppBar(
        backgroundColor: c.pageBg,
        foregroundColor: c.textPrimary,
        elevation: 0,
        title: Text(
          'Results',
          style: AppTextStyles.appBarTitle.copyWith(color: c.textPrimary),
        ),
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator(color: c.accentGreen))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _semesters.length,
              itemBuilder: (context, index) {
                final sem = _semesters[index];
                final isExpanded = _expandedExamNo == sem.examNo;
                final details = _detailsCache[sem.examNo];

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _SemesterCard(
                    semester: sem,
                    isExpanded: isExpanded,
                    details: details,
                    onTap: () => _toggleExpand(sem),
                    c: c,
                  ),
                );
              },
            ),
    );
  }
}

// ─── Semester card ────────────────────────────────────────────────────────────

class _SemesterCard extends StatelessWidget {
  final SemesterSummary semester;
  final bool isExpanded;
  final List<SubjectResult>? details;
  final VoidCallback onTap;
  final AppColorSchemeExt c;

  const _SemesterCard({
    required this.semester,
    required this.isExpanded,
    required this.details,
    required this.onTap,
    required this.c,
  });

  @override
  Widget build(BuildContext context) {
    final isPass = semester.overallClass.toLowerCase() == 'pass';

    return Material(
      color: c.surfaceBg,
      borderRadius: BorderRadius.circular(AppDimens.radiusLg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimens.radiusLg),
            border: Border.all(color: c.surfaceBorder),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: (isPass ? c.accentGreen : c.accentRed)
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                      ),
                      child: Icon(
                        isPass
                            ? Icons.check_circle_outline_rounded
                            : Icons.error_outline_rounded,
                        size: 18,
                        color: isPass ? c.accentGreen : c.accentRed,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            semester.examName,
                            style: AppTextStyles.courseName.copyWith(
                              color: c.textPrimary,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${semester.examDate} · Result: ${semester.resultDate}',
                            style: AppTextStyles.statLabel.copyWith(
                              color: c.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      size: 20,
                      color: c.textMuted,
                    ),
                  ],
                ),
              ),

              if (isExpanded)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: details == null
                      ? Padding(
                          padding: const EdgeInsets.all(20),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: c.accentGreen,
                              strokeWidth: 2,
                            ),
                          ),
                        )
                      : Column(
                          children: details!
                              .map((s) => _SubjectRow(subject: s, c: c))
                              .toList(),
                        ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SubjectRow extends StatelessWidget {
  final SubjectResult subject;
  final AppColorSchemeExt c;

  const _SubjectRow({required this.subject, required this.c});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: c.pageBg,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        border: Border.all(color: c.surfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Subject name + code ─────────────────────────────────────
          Text(
            subject.subjectName,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: c.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            subject.subjectCode,
            style: TextStyle(
              fontSize: 10,
              color: c.textMuted,
              fontFamily: 'monospace',
            ),
          ),

          const SizedBox(height: 10),
          Divider(height: 1, color: c.divider),
          const SizedBox(height: 10),

          // ── Marks row ─────────────────────────────────────────────────
          Row(
            children: [
              if (subject.cieMarks != null)
                _MarksColumn(label: 'CIE', value: subject.cieMarks!, c: c),
              if (subject.cieMarks != null) const SizedBox(width: 20),
              if (subject.seeMarks != null)
                _MarksColumn(
                  label: subject.isPractical ? 'PRACTICAL' : 'SEE',
                  value: subject.seeMarks!,
                  c: c,
                ),
              const Spacer(),
              // Total — visually separated as the "result"
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'TOTAL',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.8,
                      color: c.textSubtle,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${subject.total}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: c.accentGreen,
                      height: 1.0,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MarksColumn extends StatelessWidget {
  final String label;
  final int value;
  final AppColorSchemeExt c;

  const _MarksColumn({
    required this.label,
    required this.value,
    required this.c,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
            color: c.textSubtle,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '$value',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: c.textPrimary,
          ),
        ),
      ],
    );
  }
}
