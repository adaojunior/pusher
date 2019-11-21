import 'dart:convert';

import 'package:meta/meta.dart';

import 'presence_channel_data.dart';
import 'utils.dart';
import 'validation.dart';

class AuthenticationData {
  String _key;
  String _secret;
  String _channel;
  String _socketId;
  PresenceChannelData _presenceData;

  AuthenticationData(
      {@required String key,
      @required String secret,
      @required String channel,
      @required String socketId,
      PresenceChannelData presenceData}) {
    validateChannelName(channel);
    validateSocketId(socketId);

    _key = key;
    _secret = secret;
    _channel = channel;
    _socketId = socketId;
    _presenceData = presenceData;
  }

  bool get hasPresenceData => _presenceData != null;

  String get channelData => hasPresenceData ? _presenceData.toJson() : null;

  String get auth {
    String toSign = "$_socketId:$_channel";

    if (hasPresenceData) {
      toSign = "$toSign:$channelData";
    }

    return "$_key:${hmac256(_secret, toSign)}";
  }

  Map toMap() {
    Map data = hasPresenceData ? {'channel_data': channelData} : {};
    return {'auth': auth, ...data};
  }

  String toJson() => json.encode(toMap());

  @override
  String toString() => toJson();
}
