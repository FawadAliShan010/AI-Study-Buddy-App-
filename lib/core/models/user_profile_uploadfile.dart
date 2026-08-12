import 'upload_model.dart';

class UserProfile {
  final String id;
  final String? displayName;
  final String? email;
  final String? photoURL;
  final String? photoPath;
  final DateTime? updatedAt;
  final List<UploadModel> files;

  UserProfile({
    required this.id,
    this.displayName,
    this.email,
    this.photoURL,
    this.photoPath,
    this.updatedAt,
    this.files = const [],
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'displayName': displayName,
    'email': email,
    'photoURL': photoURL,
    'photoPath': photoPath,
    'updatedAt': updatedAt?.toIso8601String(),
    'files': files.map((f) => f.toJson()).toList(),
  };

  factory UserProfile.fromJson(String id, Map<String, dynamic> json) => UserProfile(
    id: id,
    displayName: json['displayName'],
    email: json['email'],
    photoURL: json['photoURL'],
    photoPath: json['photoPath'],
    updatedAt: json['updatedAt'] != null
        ? DateTime.parse(json['updatedAt'])
        : null,
    files: (json['files'] as List?)
        ?.map((f) => UploadModel.fromJson(f as Map<String, dynamic>))
        .toList() ?? [],
  );
}