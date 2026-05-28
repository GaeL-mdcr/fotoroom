import 'editor_state_model.dart';

class ProjectModel {
  final String id;
  final String name;
  final String originalImagePath;
  final String? editedImagePath;
  final String? thumbnailPath;
  final EditorStateModel editorState;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ProjectModel({
    required this.id,
    required this.name,
    required this.originalImagePath,
    this.editedImagePath,
    this.thumbnailPath,
    required this.editorState,
    required this.createdAt,
    required this.updatedAt,
  });

  String get currentImagePath {
    return editedImagePath ?? originalImagePath;
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
    EditorStateModel? editorState,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProjectModel(
      id: id ?? this.id,
      name: name ?? this.name,
      originalImagePath: originalImagePath ?? this.originalImagePath,
      editedImagePath: editedImagePath ?? this.editedImagePath,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      editorState: editorState ?? this.editorState,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'originalImagePath': originalImagePath,
      'editedImagePath': editedImagePath,
      'thumbnailPath': thumbnailPath,
      'editorState': editorState.toMap(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory ProjectModel.fromMap(Map<String, dynamic> map) {
    final editorStateMap = map['editorState'];

    return ProjectModel(
      id: map['id'] as String,
      name: map['name'] as String,
      originalImagePath: map['originalImagePath'] as String,
      editedImagePath: map['editedImagePath'] as String?,
      thumbnailPath: map['thumbnailPath'] as String?,
      editorState: editorStateMap is Map
          ? EditorStateModel.fromMap(
              Map<String, dynamic>.from(editorStateMap),
            )
          : const EditorStateModel(),
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }
}
