import '../common/result.dart';
import '../models/project_model.dart';

class ProjectRulesService {
  Result<ProjectModel> criarProjeto({
    required String nome,
    required String caminhoImagemOriginal,
  }) {
    final nomeValidado = nome.trim();

    if (nomeValidado.isEmpty) {
      return const Result.failure('O nome do projeto não pode ficar vazio.');
    }

    if (caminhoImagemOriginal.trim().isEmpty) {
      return const Result.failure('Nenhuma imagem foi selecionada.');
    }

    final agora = DateTime.now();

    final projeto = ProjectModel(
      id: _gerarId(agora),
      name: nomeValidado,
      originalImagePath: caminhoImagemOriginal,
      editedImagePath: null,
      thumbnailPath: caminhoImagemOriginal,
      createdAt: agora,
      updatedAt: agora,
    );

    return Result.success(projeto);
  }

  String gerarNomeSugerido(int quantidadeProjetos) {
    return 'Projeto ${quantidadeProjetos + 1}';
  }

  String _gerarId(DateTime data) {
    return data.microsecondsSinceEpoch.toString();
  }
}
