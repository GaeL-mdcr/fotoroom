import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';

class FileStorageService {
  Future<Directory> _obterDiretorioBase() async {
    return getApplicationDocumentsDirectory();
  }

  Future<Directory> _obterDiretorioDoFotoRoom() async {
    final baseDirectory = await _obterDiretorioBase();

    final directory = Directory('${baseDirectory.path}/fotoroom');

    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }

    return directory;
  }

  Future<Directory> _obterDiretorioDoProjeto(String projectId) async {
    final fotoroomDirectory = await _obterDiretorioDoFotoRoom();

    final projectDirectory = Directory(
      '${fotoroomDirectory.path}/projects/$projectId',
    );

    if (!await projectDirectory.exists()) {
      await projectDirectory.create(recursive: true);
    }

    return projectDirectory;
  }

  Future<String> salvarImagemEditada({
    required String projectId,
    required Uint8List bytes,
    required bool createNewFile,
  }) async {
    final projectDirectory = await _obterDiretorioDoProjeto(projectId);

    final fileName = createNewFile
        ? 'edited_${DateTime.now().millisecondsSinceEpoch}.jpg'
        : 'edited.jpg';

    final file = File('${projectDirectory.path}/$fileName');

    await file.writeAsBytes(bytes, flush: true);

    return file.path;
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

    final existe = await file.exists();

    if (!existe) {
      return null;
    }

    return file.readAsString();
  }

  Future<void> excluirArquivoInterno(String nomeArquivo) async {
    final directory = await _obterDiretorioDoFotoRoom();
    final file = File('${directory.path}/$nomeArquivo');

    final existe = await file.exists();

    if (!existe) {
      return;
    }

    await file.delete();
  }

  Future<void> excluirDiretorioDoProjeto(String projectId) async {
    final fotoroomDirectory = await _obterDiretorioDoFotoRoom();

    final projectDirectory = Directory(
      '${fotoroomDirectory.path}/projects/$projectId',
    );

    if (!await projectDirectory.exists()) {
      return;
    }

    await projectDirectory.delete(recursive: true);
  }
}
