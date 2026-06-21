// lib/presentation/screens/resources_view.dart

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/resources.dart';
import '../../data/repositories/notes.dart';
import '../../data/models/course_attendance.dart';
import 'pdf_viewer_screen.dart';

class ResourcesView extends StatefulWidget {
  final List<String> courseNames;
  const ResourcesView({super.key, required this.courseNames});

  @override
  State<ResourcesView> createState() => _ResourcesViewState();
}

class _ResourcesViewState extends State<ResourcesView> {
  List<ResourceData> _resources = [];
  bool _loading = true;
  String? _openingId;
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final resources = await ResourceService.fetchForAllCourses(
      widget.courseNames,
    );
    if (!mounted) return;
    setState(() {
      _resources = resources;
      _loading = false;
    });
  }

  // Future<void> _open(ResourceData r) async {
  //   setState(() => _openingId = r.id);
  //   final url = await ResourceService.getSignedUrl(r.filePath);
  //   if (!mounted) return;
  //   setState(() => _openingId = null);

  //   if (url == null) {
  //     ScaffoldMessenger.of(
  //       context,
  //     ).showSnackBar(const SnackBar(content: Text('Could not open file')));
  //     return;
  //   }

  //   final uri = Uri.parse(url);
  //   if (await canLaunchUrl(uri)) {
  //     await launchUrl(uri, mode: LaunchMode.externalApplication);
  //   }
  // }
  Future<void> _open(ResourceData r) async {
    setState(() => _openingId = r.id);
    final url = await ResourceService.getSignedUrl(r.filePath);
    if (!mounted) return;
    setState(() => _openingId = null);

    if (url == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Could not open file')));
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PdfViewerScreen(url: url, title: r.title),
      ),
    );
  }

  // Search filter in ResourcesView:
  List<ResourceData> get _filtered {
    if (_query.isEmpty) return _resources;
    return _resources
        .where(
          (r) =>
              r.title.toLowerCase().contains(_query.toLowerCase()) ||
              r.courseCode.toLowerCase().contains(_query.toLowerCase()),
        )
        .toList();
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
          'Resources',
          style: AppTextStyles.appBarTitle.copyWith(color: c.textPrimary),
        ),
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator(color: c.accentGreen))
          : Column(
              children: [
                // Search bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (v) => setState(() => _query = v),
                    style: TextStyle(color: c.textPrimary, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Search notes...',
                      hintStyle: TextStyle(color: c.textSubtle, fontSize: 13),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        size: 18,
                        color: c.textMuted,
                      ),
                      filled: true,
                      fillColor: c.surfaceBg,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                        borderSide: BorderSide(color: c.surfaceBorder),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                        borderSide: BorderSide(color: c.surfaceBorder),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                        borderSide: BorderSide(
                          color: c.accentGreen,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),

                // List
                Expanded(
                  child: _filtered.isEmpty
                      ? Center(
                          child: Text(
                            _resources.isEmpty
                                ? 'No notes available yet for your courses.'
                                : 'No matches found.',
                            style: AppTextStyles.statLabel.copyWith(
                              color: c.textMuted,
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                          itemCount: _filtered.length,
                          itemBuilder: (context, index) {
                            final r = _filtered[index];
                            return _ResourceTile(
                              resource: r,
                              isOpening: _openingId == r.id,
                              onTap: () => _open(r),
                              c: c,
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}

// ─── Resource tile ────────────────────────────────────────────────────────────

class _ResourceTile extends StatelessWidget {
  final ResourceData resource;
  final bool isOpening;
  final VoidCallback onTap;
  final AppColorSchemeExt c;

  const _ResourceTile({
    required this.resource,
    required this.isOpening,
    required this.onTap,
    required this.c,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: c.surfaceBg,
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        child: InkWell(
          onTap: isOpening ? null : onTap,
          borderRadius: BorderRadius.circular(AppDimens.radiusLg),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppDimens.radiusLg),
              border: Border.all(color: c.surfaceBorder),
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: c.accentRed.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                  ),
                  child: Icon(
                    Icons.picture_as_pdf_rounded,
                    size: 18,
                    color: c.accentRed,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        resource.title,
                        style: AppTextStyles.courseName.copyWith(
                          color: c.textPrimary,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      // Text(
                      //   resource.courseCode,
                      //   style: AppTextStyles.statLabel.copyWith(
                      //     color: c.textMuted,
                      //   ),
                      //   maxLines: 1,
                      //   overflow: TextOverflow.ellipsis,
                      // ),
                    ],
                  ),
                ),
                // isOpening
                //     ? SizedBox(
                //         width: 18,
                //         height: 18,
                //         child: CircularProgressIndicator(
                //           strokeWidth: 2,
                //           color: c.accentGreen,
                //         ),
                //       )
                //     : Icon(
                //         Icons.open_in_new_rounded,
                //         size: 18,
                //         color: c.textMuted,
                //       ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
