import '../common/result.dart';
import '../models/project_model.dart';

/// Serviço responsável por validar regras de criação e renomeação de projetos.
///
/// As regras ficam fora da tela e fora do repositório, mantendo melhor coesão.
class ProjectRulesService {
  Result<String> validarNomeProjeto(String nome) {
    final nomeValidado = nome.trim();

    if (nomeValidado.isEmpty) {
      return const Result.failure('O nome do projeto não pode ficar vazio.');
    }

    return Result.success(nomeValidado);
  }

  Result<ProjectModel> criarProjeto({
    required String nome,
    required String caminhoImagemOriginal,
  }) {
    final resultadoNome = validarNomeProjeto(nome);

    if (resultadoNome.isFailure) {
      return Result.failure(resultadoNome.error!);
    }

    final nomeValidado = resultadoNome.dataOrThrow;

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
      isPinned: false,
      pinnedIndex: 0,
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
