class ProjectModel {
  final String id;
  final String name;
  final String originalImagePath;
  final String? editedImagePath;
  final String? thumbnailPath;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isPinned;
  final int pinnedIndex;

  const ProjectModel({
    required this.id,
    required this.name,
    required this.originalImagePath,
    this.editedImagePath,
    this.thumbnailPath,
    required this.createdAt,
    required this.updatedAt,
    required this.isPinned,
    required this.pinnedIndex,
  });

  String get currentImagePath {
    final editedPath = editedImagePath;

    if (editedPath != null && editedPath.trim().isNotEmpty) {
      return editedPath;
    }

    return originalImagePath;
  }

  bool get hasEditedImage {
    return editedImagePath != null && editedImagePath!.trim().isNotEmpty;
  }

  ProjectModel copyWith({
    String? id,
    String? name,
    String? originalImagePath,
    String? editedImagePath,
    String? thumbnailPath,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isPinned,
    int? pinnedIndex,
  }) {
    return ProjectModel(
      id: id ?? this.id,
      name: name ?? this.name,
      originalImagePath: originalImagePath ?? this.originalImagePath,
      editedImagePath: editedImagePath ?? this.editedImagePath,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isPinned: isPinned ?? this.isPinned,
      pinnedIndex: pinnedIndex ?? this.pinnedIndex,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'originalImagePath': originalImagePath,
      'editedImagePath': editedImagePath,
      'thumbnailPath': thumbnailPath,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isPinned': isPinned,
      'pinnedIndex': pinnedIndex,
    };
  }

  factory ProjectModel.fromMap(Map<String, dynamic> map) {
    return ProjectModel(
      id: map['id'] as String,
      name: map['name'] as String,
      originalImagePath: map['originalImagePath'] as String,
      editedImagePath: map['editedImagePath'] as String?,
      thumbnailPath: map['thumbnailPath'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
      isPinned: map['isPinned'] as bool? ?? false,
      pinnedIndex: map['pinnedIndex'] as int? ?? 0,
    );
  }
}
