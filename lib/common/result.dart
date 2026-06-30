/// Retorno padronizado para operações que podem resultar em sucesso ou falha.
///
/// Essa classe permite que services e regras de domínio comuniquem dados ou
/// mensagens de erro sem depender diretamente de widgets ou exceções para o
/// fluxo esperado da aplicação.
class Result<T> {
  final T? data;
  final String? error;

  const Result.success(this.data) : error = null;

  const Result.failure(String message) : data = null, error = message;

  bool get isFailure => error != null;

  T get dataOrThrow {
    final value = data;

    if (value == null) {
      throw StateError('Resultado não possui dados.');
    }

    return value;
  }
}
