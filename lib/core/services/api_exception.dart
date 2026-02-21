class ApiException implements Exception {
  final String message;
  final String prefix;

  ApiException({required this.message, required this.prefix});

  @override
  String toString() {
    return "$prefix$message";
  }
}

class FetchDataException extends ApiException {
  FetchDataException([String? msg])
    : super(
        message: msg ?? 'No message provided',
        prefix: 'Error During Communication:',
      );
}
