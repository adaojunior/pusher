import 'response.dart';

class PusherException implements Exception {

}

class ResponseException extends PusherException {

  Response _response;

  ResponseException(this._response);

  Response get response => _response;

  int get code => response.status;
}
