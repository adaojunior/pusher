part of pusher;

/// Result of a resource request
// todo(): call it Response
class Result {

  final int _status;
  final String _message;

  Result(this._status,this._message);

  /// HttpStatus.
  int get status => this._status;

  /// Request Body.
  String get message => this._message;

  /// Request body.
  String toString() => this.message;
}
