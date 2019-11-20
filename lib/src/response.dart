import 'dart:convert';

import 'utils.dart' show isSuccessStatusCode;

/// Base class for all request results
class RequestResult {
  /// HttpStatus
  final int status;

  /// Request body.
  final String body;

  RequestResult(this.status, this.body);

  /// Request body.
  @override
  String toString() => this.body;
}

class GetResult<T> extends RequestResult {
  T _data;

  GetResult(int status, String body) : super(status, body) {
    if (isSuccessStatusCode(status)) {
      _data = json.decode(body) as T;
    }
  }

  /// Gets the data deserialised from body
  T get data => _data;
}
