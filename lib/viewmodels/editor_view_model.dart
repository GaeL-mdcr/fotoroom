import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../models/project_model.dart';
import '../services/file_storage_service.dart';

/// ViewModel responsável pelo estado do projeto aberto no editor.
///
/// Ele informa qual imagem está ativa e delega o salvamento de arquivos ao
/// FileStorageService.
///
/// No MVVM, mantém o estado consumido pela tela de edição; no GRASP, coordena
/// as ações de abertura, fechamento e atualização do projeto editado.
class EditorViewModel extends ChangeNotifier {
  final FileStorageService _fileStorageService;

  EditorViewModel(this._fileStorageService);

  String? _projectId;
  String? _projectName;
  String? _originalImagePath;
  String? _editedImagePath;

  String? get projectId => _projectId;
  String? get projectName => _projectName;
  String? get originalImagePath => _originalImagePath;
  String? get editedImagePath => _editedImagePath;

  bool get possuiProjetoAberto => _projectId != null;

  String? get currentImagePath {
    final editedPath = _editedImagePath;

    if (editedPath != null && editedPath.trim().isNotEmpty) {
      return editedPath;
    }

    final originalPath = _originalImagePath;

    if (originalPath != null && originalPath.trim().isNotEmpty) {
      return originalPath;
    }

    return null;
  }

  void carregarProjeto(ProjectModel projeto) {
    _projectId = projeto.id;
    _projectName = projeto.name;
    _originalImagePath = projeto.originalImagePath;
    _editedImagePath = projeto.editedImagePath;

    notifyListeners();
  }

  void fecharProjeto() {
    _projectId = null;
    _projectName = null;
    _originalImagePath = null;
    _editedImagePath = null;

    notifyListeners();
  }

  Future<String?> salvarImagemEditada(Uint8List bytes) async {
    final projectId = _projectId;

    if (projectId == null) {
      return null;
    }

    return _fileStorageService.salvarImagemEditada(
      projectId: projectId,
      bytes: bytes,
    );
  }

  void marcarImagemEditadaComoSalva(String editedImagePath) {
    FileImage(File(editedImagePath)).evict();

    _editedImagePath = editedImagePath;

    notifyListeners();
  }
}
