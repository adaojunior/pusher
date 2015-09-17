part of pusher;

// todo(): call it Response
class Result {

  final int _status;
  final String _message;

  Result(this._status,this._message);

  int get status => this._status;

  String get message => this._message;

  String toString() => this.message;
}
