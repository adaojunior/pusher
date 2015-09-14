
library pusher;

import 'package:pusher/helper.dart';
import 'package:pusher/validate.dart';
import 'package:http/http.dart' show Request,StreamedResponse;
import 'dart:convert' show JSON;
import 'dart:async';

const String DEFAULT_HOST = "api.pusherapp.com";
const int DEFAULT_HTTPS_PORT = 443;
const int DEFAULT_HTTP_PORT = 80;

/// Options to be set on the [Pusher] instance.
class PusherOptions {

  /// Defines a value indicating whether call to the API are over HTTP or HTTPS.
  bool _encrypted;

  int _port = DEFAULT_HTTP_PORT;

  PusherOptions({bool encrypted:false,int port}){
    this._encrypted = encrypted;

    if(port != null) this._port = port;

    if(encrypted && port == null) this._port = DEFAULT_HTTPS_PORT;
  }

  /// Indicates whether calls to the Pusher REST API are over HTTP or HTTPS.
  get encrypted => _encrypted;

  /// Get REST API port that the HTTP calls will be made to.
  get port => _port;
}

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

/// Provides access to functionality within the Pusher service such as Trigger to trigger events
/// and authenticating subscription requests to private and presence channels.
class Pusher {

  String _id;

  String _key;

  String _secret;

  PusherOptions _options;

  Pusher(String id, String key, String secret,[PusherOptions options]){

    this._id = id;
    this._secret = secret;
    this._key = key;
    this._options = options == null ? new PusherOptions() : options;
  }

  _getBaseUrl() {
    String schema = _options.encrypted ? 'https' : 'http';
    String port = _options.port == 80 ? '' : ":${_options.port}";
    return "${schema}://${DEFAULT_HOST}${port}";
  }

  get(String resource,[Map<String,String> parameters]) async{

    parameters = (parameters != null) ? parameters : new Map<String,String>();
    Request request =_createAuthenticatedRequest('GET', resource, parameters, null);
    StreamedResponse response =  await request.send();
    print(await response.stream.bytesToString());
  }

  Future<TriggerResponse> trigger(List<String> channels,String event, Map data,[TriggerOptions options]) {
    options = options == null ? new TriggerOptions() : options;
    validateListOfChannelNames(channels);
    validateSocketId(options.socketId);
    TriggerBody body = new TriggerBody(name:event,data:data.toString(),channels:channels,socketId:options.socketId);
    return _executeTrigger(channels,event,body);
  }

  Future<TriggerResponse> _executeTrigger(List<String> channels,String event,TriggerBody body) async {
    Request request = _createAuthenticatedRequest('POST',"/events",null,body);
    StreamedResponse response =  await request.send();
    return new TriggerResponse(await response.stream.bytesToString(), response.statusCode);
  }

  int _secondsSinceEpoch(){
    return (new DateTime.now().toUtc().millisecondsSinceEpoch * 0.001).toInt();
  }

  String _mapToQueryString(Map<String,String> params){
    List values = [];
    params.forEach((k,v){
      values.add("${k}=${v}");
    });
    return values.join('&');
  }

  /// todo(): refactor
  Request _createAuthenticatedRequest(String method,String resource,Map<String,String> parameters,TriggerBody body){

    parameters = parameters == null ? new Map<String,String>() : parameters;
    parameters['auth_key'] = this._key;
    parameters['auth_timestamp'] = _secondsSinceEpoch().toString();
    parameters['auth_version'] = '1.0';

    if(body != null){
      parameters['body_md5'] = body.toMD5();
    }

    if(resource.startsWith('/')){
      resource = resource.substring(1);
    }

    String queryString = _mapToQueryString(parameters);
    String path = "/apps/${this._id}/${resource}";
    String toSign = "${method}\n${path}\n${queryString}";

    String authSignature = getHmac256(this._secret,toSign);

    Uri uri = Uri.parse("${this._getBaseUrl()}${path}?${queryString}&auth_signature=${authSignature}");
    Request request = new Request(method,uri);
    request.headers['Content-Type'] = 'application/json';
    request.body = body.toJson();
    return request;
  }
}
