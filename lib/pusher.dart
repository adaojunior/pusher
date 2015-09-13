
library pusher;

import 'package:pusher/helper.dart';
import 'package:http/http.dart' show Request,StreamedResponse;

const String DEFAULT_HOST = "api.pusherapp.com";
const int DEFAULT_HTTPS_PORT = 443;
const int DEFAULT_HTTP_PORT = 80;

/// Options to be set on the [Pusher] instance.
class PusherOptions {

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
  Request _createAuthenticatedRequest(String method,String resource,Map<String,String> parameters,body){

    parameters['auth_key'] = this._key;
    parameters['auth_timestamp'] = _secondsSinceEpoch().toString();
    parameters['auth_version'] = '1.0';

    if(body != null){
      throw new Exception("Not implemented");
    }

    if(resource.startsWith('/')){
      resource = resource.substring(1);
    }

    String queryString = _mapToQueryString(parameters);
    String path = "/apps/${this._id}/${resource}";
    String toSign = "${method}\n${path}\n${queryString}";

    String authSignature = getHmac256(this._secret,toSign);

    Uri uri = Uri.parse(
        "${this._getBaseUrl()}${path}?${queryString}&auth_signature=${authSignature}"
    );
    Request request = new Request(method,uri);

    return request;
  }
}
