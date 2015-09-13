
library pusher.helper;

import 'package:crypto/crypto.dart';
import 'dart:convert';

String getHmac256(String secret, String toSign){
  List<int> secretBytes = UTF8.encode(secret);
  List<int> messageBytes = UTF8.encode(toSign);
  var hmac = new HMAC(new SHA256(), secretBytes);
  hmac.add(messageBytes);
  var digest = hmac.close();
  return CryptoUtils.bytesToHex(digest);
}
