import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';

class FileStorageService {
  static const String _appDirectoryName = 'fotoroom';
  static const String _projectsDirectoryName = 'projects';
  static const String _exportsDirectoryName = 'exports';

  static const String _projectsFileName = 'projects.json';
  static const String _settingsFileName = 'settings.json';

  static const String _originalImageFileName = 'original.jpg';
  static const String _editedImageFileName = 'edited.jpg';
  static const String _sharedImageFileName = 'fotoroom_compartilhamento.jpg';

  String get projectsFileName => _projectsFileName;
  String get settingsFileName => _settingsFileName;

  Future<Directory> _obterDiretorioBase() async {
    return getApplicationDocumentsDirectory();
  }

  Future<Directory> _obterDiretorioDoFotoRoom() async {
    final baseDirectory = await _obterDiretorioBase();

    final directory = Directory('${baseDirectory.path}/$_appDirectoryName');

    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }

    return directory;
  }

  Future<Directory> _obterDiretorioDoProjeto(String projectId) async {
    final fotoroomDirectory = await _obterDiretorioDoFotoRoom();

    final projectDirectory = Directory(
      '${fotoroomDirectory.path}/$_projectsDirectoryName/$projectId',
    );

    if (!await projectDirectory.exists()) {
      await projectDirectory.create(recursive: true);
    }

    return projectDirectory;
  }

  Future<Directory> _obterDiretorioDeExportacoes() async {
    final fotoroomDirectory = await _obterDiretorioDoFotoRoom();

    final exportsDirectory = Directory(
      '${fotoroomDirectory.path}/$_exportsDirectoryName',
    );

    if (!await exportsDirectory.exists()) {
      await exportsDirectory.create(recursive: true);
    }

    return exportsDirectory;
  }

  Future<String> salvarImagemOriginal({
    required String projectId,
    required String sourceImagePath,
  }) async {
    final sourceFile = File(sourceImagePath);

    if (!await sourceFile.exists()) {
      throw Exception('Imagem original não encontrada.');
    }

    final projectDirectory = await _obterDiretorioDoProjeto(projectId);

    final extension = _obterExtensaoArquivo(sourceImagePath);
    final originalImageFileName = _originalImageFileName.replaceFirst(
      '.jpg',
      '.$extension',
    );
    final destinationFile = File(
      '${projectDirectory.path}/$originalImageFileName',
    );

    await sourceFile.copy(destinationFile.path);

    return destinationFile.path;
  }

  Future<String> salvarImagemEditada({
    required String projectId,
    required Uint8List bytes,
  }) async {
    final projectDirectory = await _obterDiretorioDoProjeto(projectId);

    final file = File('${projectDirectory.path}/$_editedImageFileName');

    await file.writeAsBytes(bytes, flush: true);

    return file.path;
  }

  Future<String> exportarImagemJpg({required String imagePath}) async {
    final sourceFile = File(imagePath);

    if (!await sourceFile.exists()) {
      throw Exception('Arquivo de imagem não encontrado.');
    }

    final exportsDirectory = await _obterDiretorioDeExportacoes();

    final exportedFile = File('${exportsDirectory.path}/$_sharedImageFileName');

    if (await exportedFile.exists()) {
      await exportedFile.delete();
    }

    await sourceFile.copy(exportedFile.path);

    return exportedFile.path;
  }

  Future<String> salvarArquivoInterno({
    required String nomeArquivo,
    required String conteudo,
  }) async {
    final directory = await _obterDiretorioDoFotoRoom();
    final file = File('${directory.path}/$nomeArquivo');

    await file.writeAsString(conteudo);

    return file.path;
  }

  Future<String?> lerArquivoInterno(String nomeArquivo) async {
    final directory = await _obterDiretorioDoFotoRoom();
    final file = File('${directory.path}/$nomeArquivo');

    if (!await file.exists()) {
      return null;
    }

    return file.readAsString();
  }

  Future<void> excluirArquivoInterno(String nomeArquivo) async {
    final directory = await _obterDiretorioDoFotoRoom();
    final file = File('${directory.path}/$nomeArquivo');

    if (!await file.exists()) {
      return;
    }

    await file.delete();
  }

  Future<void> excluirDiretorioDoProjeto(String projectId) async {
    final fotoroomDirectory = await _obterDiretorioDoFotoRoom();

    final projectDirectory = Directory(
      '${fotoroomDirectory.path}/$_projectsDirectoryName/$projectId',
    );

    if (!await projectDirectory.exists()) {
      return;
    }

    await projectDirectory.delete(recursive: true);
  }

  String _obterExtensaoArquivo(String filePath) {
    final cleanPath = filePath.split('?').first;
    final parts = cleanPath.split('.');

    if (parts.length < 2) return 'jpg';

    final ext = parts.last.trim().toLowerCase();

    if (ext.isEmpty) return 'jpg';

    return ext;
  }
}
