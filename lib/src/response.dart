/// Base class for all request results
class RequestResult {
  /// HttpStatus
  final int status;

  /// Request body.
  final String body;

  RequestResult(this.status, this.body);

  /// Request body.
  @override
  String toString() => this.body;
}
