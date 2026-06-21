class ResourceData {
  final String id;
  final String title;
  final String courseCode;
  final String filePath;
  final String? fileUrl;

  const ResourceData({
    required this.id,
    required this.title,
    required this.courseCode,
    required this.filePath,
    this.fileUrl,
  });

  factory ResourceData.fromJson(Map<String, dynamic> json) {
    return ResourceData(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      courseCode: json['course_code'] ?? '',
      filePath: json['file_path'] ?? '',
      fileUrl: json['file_url'],
    );
  }
}
