/// Error controlado proveniente de la comunicación con la API.
///
/// La interfaz usa [message] para mostrar información entendible y conserva
/// [statusCode] para que las capas superiores puedan distinguir 400/401/404/500.
class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}
