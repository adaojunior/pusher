/// Base class for all request results
class RequestResult {
  final int _status;
  final String _body;

  RequestResult(int status, String message)
      : _status = status,
        _body = message;

  /// HttpStatus.
  int get status => this._status;

  /// Request Body.
  String get body => this._body;

  /// Request body.
  @override
  String toString() => this.body;
}
