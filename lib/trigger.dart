part of pusher;

/// Options to be set on the trigger method.
class TriggerOptions {

  /// Socket id to be excluded from receiving event.
  String _socketId = null;

  TriggerOptions({String socketId}){
    this._socketId = socketId;
  }

  /// Returns the socket id
  get socketId => _socketId;
}

/// Represents the payload to be sent when triggering events
class TriggerBody {

  /// The name of the event
  final String name;

  /// The event data
  final String data;

  /// The channels the event should be triggered on.
  final List<String> channels;

  /// The id of a socket to be excluded from receiving the event.
  final String socketId;

  TriggerBody({this.name,this.data,this.channels,this.socketId}){
    validateListOfChannelNames(this.channels);
    validateSocketId(this.socketId);
  }

  /// Gets a Map version of the body
  Map<String,dynamic> toMap(){
    return {
      'name':this.name,
      'data':this.data,
      'channels':this.channels,
      'socketId':this.socketId
    };
  }

  /// Gets the JSON enconded body.
  toJson(){
    return JSON.encode(toMap());
  }

  /// Gets the MD5 encoded body
  String toMD5(){
    return getMd5Hash(toJson());
  }
}

class TriggerResponse {

  final String body;

  final int statusCode;

  TriggerResponse(this.body,this.statusCode);

  String toString() => this.body;
}
