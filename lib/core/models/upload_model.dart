class UploadModel {
  final String id;
  final String url;
  final String path;
  final String fileName;
  final DateTime uploadedAt;
  final String fileType;
  final int fileSize;
  final String? thumbnailUrl;

  UploadModel({
    required this.id,
    required this.url,
    required this.path,
    required this.fileName,
    required this.uploadedAt,
    required this.fileType,
    required this.fileSize,
    this.thumbnailUrl,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'url': url,
    'path': path,
    'fileName': fileName,
    'uploadedAt': uploadedAt.toIso8601String(),
    'fileType': fileType,
    'fileSize': fileSize,
    'thumbnailUrl': thumbnailUrl,
  };

  factory UploadModel.fromJson(Map<String, dynamic> json) => UploadModel(
    id: json['id'] ?? '',
    url: json['url'] ?? '',
    path: json['path'] ?? '',
    fileName: json['fileName'] ?? '',
    uploadedAt: DateTime.parse(json['uploadedAt'] ?? DateTime.now().toIso8601String()),
    fileType: json['fileType'] ?? '',
    fileSize: json['fileSize'] ?? 0,
    thumbnailUrl: json['thumbnailUrl'],
  );
}