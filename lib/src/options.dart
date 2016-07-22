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
