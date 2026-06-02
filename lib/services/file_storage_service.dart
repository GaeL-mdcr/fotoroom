import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';

class FileStorageService {
  Future _obterDiretorioBase() async {
    return getApplicationDocumentsDirectory();
  }

  Future _obterDiretorioDoFotoRoom() async {
    final baseDirectory = await _obterDiretorioBase();

    final directory = Directory('${baseDirectory.path}/fotoroom');

    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }

    return directory;
  }

  Future _obterDiretorioDoProjeto(String projectId) async {
    final fotoroomDirectory = await _obterDiretorioDoFotoRoom();

    final projectDirectory = Directory(
      '${fotoroomDirectory.path}/projects/$projectId',
    );

    if (!await projectDirectory.exists()) {
      await projectDirectory.create(recursive: true);
    }

    return projectDirectory;
  }

  Future _obterDiretorioDeExportacoes() async {
    final fotoroomDirectory = await _obterDiretorioDoFotoRoom();

    final exportsDirectory = Directory(
      '${fotoroomDirectory.path}/exports',
    );

    if (!await exportsDirectory.exists()) {
      await exportsDirectory.create(recursive: true);
    }

    return exportsDirectory;
  }

  Future salvarImagemEditada({
    required String projectId,
    required Uint8List bytes,
    required bool createNewFile,
  }) async {
    final projectDirectory = await _obterDiretorioDoProjeto(projectId);

    final fileName = createNewFile
        ? 'edited_${DateTime.now().millisecondsSinceEpoch}.jpg'
        : 'edited.jpg';

    final file = File('${projectDirectory.path}/$fileName');

    await file.writeAsBytes(
      bytes,
      flush: true,
    );

    return file.path;
  }

  Future exportarImagemJpg({
    required String imagePath,
  }) async {
    final sourceFile = File(imagePath);

    if (!await sourceFile.exists()) {
      throw Exception('Arquivo de imagem não encontrado.');
    }

    final exportsDirectory = await _obterDiretorioDeExportacoes();

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final exportedFile = File(
      '${exportsDirectory.path}/fotoroom_export_$timestamp.jpg',
    );

    await sourceFile.copy(exportedFile.path);

    return exportedFile.path;
  }

  Future salvarArquivoInterno({
    required String nomeArquivo,
    required String conteudo,
  }) async {
    final directory = await _obterDiretorioDoFotoRoom();
    final file = File('${directory.path}/$nomeArquivo');

    await file.writeAsString(conteudo);

    return file.path;
  }

  Future lerArquivoInterno(String nomeArquivo) async {
    final directory = await _obterDiretorioDoFotoRoom();
    final file = File('${directory.path}/$nomeArquivo');

    if (!await file.exists()) {
      return null;
    }

    return file.readAsString();
  }

  Future excluirArquivoInterno(String nomeArquivo) async {
    final directory = await _obterDiretorioDoFotoRoom();
    final file = File('${directory.path}/$nomeArquivo');

    if (!await file.exists()) {
      return;
    }

    await file.delete();
  }

  Future excluirDiretorioDoProjeto(String projectId) async {
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
