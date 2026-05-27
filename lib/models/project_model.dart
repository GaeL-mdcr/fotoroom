import 'editor_state_model.dart';

class ProjectModel {
  final String id;
  final String name;
  final String originalImagePath;
  final String? thumbnailPath;
  final EditorStateModel editorState;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ProjectModel({
    required this.id,
    required this.name,
    required this.originalImagePath,
    this.thumbnailPath,
    required this.editorState,
    required this.createdAt,
    required this.updatedAt,
  });

  ProjectModel copyWith({
    String? id,
    String? name,
    String? originalImagePath,
    String? thumbnailPath,
    EditorStateModel? editorState,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProjectModel(
      id: id ?? this.id,
      name: name ?? this.name,
      originalImagePath: originalImagePath ?? this.originalImagePath,
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
      'thumbnailPath': thumbnailPath,
      'editorState': editorState.toMap(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory ProjectModel.fromMap(Map<String, dynamic> map) {
    return ProjectModel(
      id: map['id'] as String,
      name: map['name'] as String,
      originalImagePath: map['originalImagePath'] as String,
      thumbnailPath: map['thumbnailPath'] as String?,
      editorState: EditorStateModel.fromMap(
        map['editorState'] as Map<String, dynamic>,
      ),
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }
}
