import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../models/project_model.dart';
import '../services/file_storage_service.dart';

class EditorViewModel extends ChangeNotifier {
  final FileStorageService _fileStorageService;

  EditorViewModel(this._fileStorageService);

  String? _projectId;
  String? _projectName;
  String? _originalImagePath;
  String? _editedImagePath;

  Uint8List? _imagemEditadaBytes;

  bool _possuiAlteracoesNaoSalvas = false;
  bool _modoEdicaoAtivo = false;
  int _previewVersion = 0;

  String? get projectId => _projectId;
  String? get projectName => _projectName;
  String? get originalImagePath => _originalImagePath;
  String? get editedImagePath => _editedImagePath;

  Uint8List? get imagemEditadaBytes => _imagemEditadaBytes;

  int get previewVersion => _previewVersion;

  bool get possuiProjetoAberto => _projectId != null;
  bool get possuiAlteracoesNaoSalvas => _possuiAlteracoesNaoSalvas;
  bool get modoEdicaoAtivo => _modoEdicaoAtivo;

  bool get possuiImagemEditadaEmMemoria => _imagemEditadaBytes != null;

  bool get possuiImagemEditadaSalva {
    return _editedImagePath != null && _editedImagePath!.trim().isNotEmpty;
  }

  String? get currentImagePath {
    if (_editedImagePath != null && _editedImagePath!.trim().isNotEmpty) {
      return _editedImagePath;
    }

    if (_originalImagePath != null && _originalImagePath!.trim().isNotEmpty) {
      return _originalImagePath;
    }

    return null;
  }

  bool get possuiImagemAtual {
    return currentImagePath != null;
  }

  bool get podeEditarImagem {
    return possuiProjetoAberto && possuiImagemAtual;
  }

  bool get podeCompartilharImagem {
    return possuiProjetoAberto && possuiImagemAtual && !_modoEdicaoAtivo;
  }

  void carregarProjeto(ProjectModel projeto) {
    _projectId = projeto.id;
    _projectName = projeto.name;
    _originalImagePath = projeto.originalImagePath;
    _editedImagePath = projeto.editedImagePath;

    _limparEstadoTemporarioDeEdicao();
    _previewVersion++;

    notifyListeners();
  }

  void fecharProjeto() {
    _projectId = null;
    _projectName = null;
    _originalImagePath = null;
    _editedImagePath = null;

    _limparEstadoTemporarioDeEdicao();
    _previewVersion++;

    notifyListeners();
  }

  void iniciarModoEdicao() {
    if (_modoEdicaoAtivo || !podeEditarImagem) {
      return;
    }

    _modoEdicaoAtivo = true;
    notifyListeners();
  }

  void fecharModoEdicao() {
    if (!_modoEdicaoAtivo) {
      return;
    }

    _modoEdicaoAtivo = false;
    notifyListeners();
  }

  void definirImagemEditada(Uint8List bytes) {
    _imagemEditadaBytes = bytes;
    _possuiAlteracoesNaoSalvas = true;
    _previewVersion++;

    notifyListeners();
  }

  Future<String?> salvarImagemEditadaEmArquivo({
    required bool createNewFile,
  }) async {
    final projectId = _projectId;
    final bytes = _imagemEditadaBytes;

    if (projectId == null || bytes == null) {
      return null;
    }

    final editedPath = await _fileStorageService.salvarImagemEditada(
      projectId: projectId,
      bytes: bytes,
      createNewFile: createNewFile,
    );

    return editedPath;
  }

  void marcarImagemEditadaComoSalva(String editedImagePath) {
    final imageProvider = FileImage(File(editedImagePath));

    imageProvider.evict();

    _editedImagePath = editedImagePath;
    _limparEstadoTemporarioDeEdicao();
    _previewVersion++;

    notifyListeners();
  }

  void marcarComoSalvo() {
    _possuiAlteracoesNaoSalvas = false;

    notifyListeners();
  }

  void _limparEstadoTemporarioDeEdicao() {
    _imagemEditadaBytes = null;
    _possuiAlteracoesNaoSalvas = false;
    _modoEdicaoAtivo = false;
  }
}
