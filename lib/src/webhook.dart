import 'dart:convert';

import 'utils.dart';

bool _isEmpty(String str) => str == null || str.isEmpty;

const String emptySignature =
    'The supplied signature to check was null or empty. A signature to check must be provided.';
const String emptyBody =
    'The supplied body to check was null or empty. A body to check must be provided.';
const String invalidSignature = 'The signature did not validate';
const String invalidJson = 'Exception occurred parsing the body as JSON';

///  Used to parse and authenticate WebHooks
class Webhook {
  final String _secret;
  final String _signature;
  final String _body;
  final List<String> _errors = [];
  Map<String, dynamic> _data;

  Webhook(this._secret, this._signature, this._body) {
    _validateParams();
    if (errors.isEmpty) _data = _parseBody();
    if (errors.isEmpty) _valideSignature();
  }

  List<String> get errors => _errors;

  bool get isValid => errors.isEmpty;

  bool get isNotValid => errors.isNotEmpty;

  List<Map> get events => _data['events'] as List<Map>;

  DateTime get datetime =>
      new DateTime.fromMillisecondsSinceEpoch(_data['time_ms'], isUtc: true);

  Map<String, dynamic> _parseBody() {
    try {
      return JSON.decode(_body) as Map<String, dynamic>;
    } on Exception {
      _errors.add(invalidJson);
    }
  }

  void _valideSignature() {
    if (HMAC256(_secret, _body) != _signature) _errors.add(invalidSignature);
  }

  void _validateParams() {
    if (_isEmpty(_secret)) throw new ArgumentError.notNull('secret');
    if (_isEmpty(_signature)) _errors.add(emptySignature);
    if (_isEmpty(_body)) _errors.add(emptyBody);
  }
}
