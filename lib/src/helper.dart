
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

String getMd5Hash(String data){
  var md5 = new MD5();
  md5.add(UTF8.encode(data));
  var digest = md5.close();
  return CryptoUtils.bytesToHex(digest);
}