part of pusher;

class Result {

  final int _status;
  final String _message;

  Result(this._status,this._message);

  get status => this._status;

  get message => this._message;
}