class Result<T> {
  final T? data;
  final String? error;

  const Result.success(this.data) : error = null;

  const Result.failure(String message) : data = null, error = message;

  bool get isSuccess => error == null;

  bool get isFailure => error != null;

  T get dataOrThrow {
    final value = data;

    if (value == null) {
      throw StateError('Resultado não possui dados.');
    }

    return value;
  }

  String get errorOrDefault {
    return error ?? 'Erro desconhecido.';
  }
}
