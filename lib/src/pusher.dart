library pusher;

import 'package:crypto/crypto.dart' show HMAC, SHA256, MD5, CryptoUtils;
import 'package:http/http.dart' show Request, StreamedResponse;
import 'dart:convert' show JSON, UTF8;
import 'dart:async' show Future;
import 'dart:collection' show SplayTreeMap;

part 'validation.dart';
part 'result.dart';
part 'trigger.dart';
part 'utils.dart';

const String DEFAULT_HOST = "api.pusherapp.com";
const int DEFAULT_HTTPS_PORT = 443;
const int DEFAULT_HTTP_PORT = 80;

/// Options to be set on the [Pusher] instance.
class PusherOptions {
  /// Defines a value indicating whether call to the API are over HTTP or HTTPS.
  bool _encrypted;

  int _port = DEFAULT_HTTP_PORT;

  PusherOptions({bool encrypted: false, int port}) {
    this._encrypted = encrypted;

    if (port != null) this._port = port;

    if (encrypted && port == null) this._port = DEFAULT_HTTPS_PORT;
  }

  /// Indicates whether calls to the Pusher REST API are over HTTP or HTTPS.
  get encrypted => _encrypted;

  /// port that the HTTP calls will be made to.
  get port => _port;
}

/// Information about a user who is subscribing to a presence channel.
class User {
  /// A unique user identifier for the user witin the application.
  /// Pusher uses this to uniquely identify a user. So, if multiple users are given the same [id]
  /// the second of these users will be ignored and won't be represented on the presence channel.
  final String id;

  /// Arbitrary additional information about the user.
  final Map<String, String> info;

  User(this.id, [this.info]);

  Map toMap(){
    Map map = new Map();
    map['user_id'] = this.id;
    if(this.info != null){
      map['user_info'] = this.info;
    }
    return map;
  }
}

/// Provides access to functionality within the Pusher service such as Trigger to trigger events
/// and authenticating subscription requests to private and presence channels.
class Pusher {
  String _id;

  String _key;

  String _secret;

  PusherOptions _options;

  Pusher(String id, String key, String secret, [PusherOptions options]) {
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

  /// Authenticates the subscription request for a presence channel.
  ///
  /// Pusher provides a mechanism for authenticating a user's access to a channel at the point of subscription.
  ///
  /// This can be used both to restrict access to private channels,
  /// and in the case of presence channels notify subscribers of who else is also subscribed via presence events.
  ///
  /// This library provides a mechanism for generating an authentication signature to send back to the client and authorize them.
  ///
  /// For more information see [docs](https://pusher.com/docs/authenticating_users).
  ///
  /// ## Private channels
  ///
  ///      String socketId = '74124.3251944';
  ///      String auth = pusher.authenticate('test_channel',socketId);
  /// ##  Authenticating presence channels
  ///
  /// Using presence channels is similar to private channels, but in order to identify a user,
  /// clients are sent a user_id and, optionally, custom data.
  ///      String socketId = '74124.3251944';
  ///      User user = new User('1',{'name':'Adao'});
  ///      String auth = pusher.authenticate('presence-test_channel',socketId,user);
  String authenticate(String channel, String socketId, [User user]) {
    validateChannelName(channel);
    validateSocketId(socketId);
    String signature;
    String token;

    if (user == null) {
      signature = "${socketId}:${channel}";
      token = "${this._key}:${HMAC256(_secret, signature)}";
      return JSON.encode({'auth': token});
    } else {
      String data = JSON.encode(user.toMap());
      signature = "${socketId}:${channel}:${data}";
      token = "${this._key}:${HMAC256(_secret, signature)}";
      return JSON.encode({'auth': token, 'channel_data': user.toMap()});
    }
  }

  /// Allows you to query Pusher API to retrieve information about your application's channels,
  /// their individual properties, and, for presence-channels, the users currently subscribed to them.
  ///
  /// ## List channels
  /// You can get a list of channels that are present within your application:
  ///      Result result = await pusher.get("/channels");
  /// You can provide additional parameters to filter the list of channels that is returned.
  ///      Result result = await pusher.get("/channels", new { filter_by_prefix = "presence-" } );
  /// ## Fetch channel information
  /// Retrive information about a single channel:
  ///      Result result = await pusher.get("/channels/my_channel");
  /// ## Fetch a list of users on a presence channel
  /// Retrive a list of users that are on a presence channel:
  ///      Result result = await pusher.get('/channels/presence-channel/users');
  Future<Result> get(String resource, [Map<String, String> parameters]) async {
    parameters = (parameters != null) ? parameters : new Map<String, String>();
    Request request = _createAuthenticatedRequest('GET', resource, parameters, null);
    StreamedResponse response = await request.send();
    return new Result(response.statusCode, await response.stream.bytesToString());
  }

  /// Triggers an event on one or more channels.
  ///
  /// Channel names can contain only characters which are alphanumeric, _ or -`. Event name can be at most 200 characters long too.
  ///
  /// ## Triggering events
  ///      Result response = await pusher.trigger(['test_channel'],'my_event',data);
  Future<Result> trigger(List<String> channels, String event, Map data, [TriggerOptions options]) {
    options = options == null ? new TriggerOptions() : options;
    validateListOfChannelNames(channels);
    validateSocketId(options.socketId);
    TriggerBody body = new TriggerBody(
        name: event, data: data.toString(), channels: channels, socketId: options.socketId);
    return _executeTrigger(channels, event, body);
  }

  Future<Result> _executeTrigger(List<String> channels, String event, TriggerBody body) async {
    Request request = _createAuthenticatedRequest('POST', "/events", null, body);
    StreamedResponse response = await request.send();
    return new Result(response.statusCode, await response.stream.bytesToString());
  }

  int _secondsSinceEpoch() {
    return (new DateTime.now().toUtc().millisecondsSinceEpoch * 0.001).toInt();
  }

  String _mapToQueryString(Map<String, String> params) {
    List values = [];
    params.forEach((k, v) {
      values.add("${k}=${v}");
    });
    return values.join('&');
  }

  /// todo(): refactor
  Request _createAuthenticatedRequest(
      String method, String resource, Map<String, String> parameters, TriggerBody body) {
    parameters = parameters == null ? new SplayTreeMap() : new SplayTreeMap.from(parameters);
    parameters['auth_key'] = this._key;
    parameters['auth_timestamp'] = _secondsSinceEpoch().toString();
    parameters['auth_version'] = '1.0';

    if (body != null) {
      parameters['body_md5'] = body.toMD5();
    }

    if (resource.startsWith('/')) {
      resource = resource.substring(1);
    }

    String queryString = _mapToQueryString(parameters);
    String path = "/apps/${this._id}/${resource}";
    String toSign = "${method}\n${path}\n${queryString}";

    String authSignature = HMAC256(this._secret, toSign);

    Uri uri =
        Uri.parse("${this._getBaseUrl()}${path}?${queryString}&auth_signature=${authSignature}");
    Request request = new Request(method, uri);
    request.headers['Content-Type'] = 'application/json';
    if (body != null) {
      request.body = body.toJson();
    }
    return request;
  }
}
