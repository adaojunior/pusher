const String defaultHost = "api.pusherapp.com";
const int defaultHttpsPort = 443;
const int defaultHttpPort = 80;

/// Options to be set on the [Pusher] instance.
class PusherOptions {
  /// Defines a value indicating whether call to the API are over HTTP or HTTPS.
  bool _encrypted;

  int _port = defaultHttpPort;

  PusherOptions({bool encrypted: false, int port}) {
    this._encrypted = encrypted;

    if (port != null) this._port = port;

    if (encrypted && port == null) this._port = defaultHttpsPort;
  }

  /// Indicates whether calls to the Pusher REST API are over HTTP or HTTPS.
  bool get encrypted => _encrypted;

  /// port that the HTTP calls will be made to.
  int get port => _port;
}
