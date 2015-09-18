// Copyright (c) 2015, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

library pusher.test;

import 'package:pusher/pusher.dart';
import 'package:pusher/src/pusher.dart' show TriggerBody, DEFAULT_HTTP_PORT, DEFAULT_HTTPS_PORT;
import 'package:test/test.dart';
import 'dart:convert' show JSON;
import 'dart:io' show Platform;

final PUSHER_APP_ID = Platform.environment['PUSHER_APP_ID'];
final PUSHER_APP_KEY = Platform.environment['PUSHER_APP_KEY'];
final PUSHER_APP_SECRET = Platform.environment['PUSHER_APP_SECRET'];

void main() {
  group('PusherOptions', () {
    test('Test default values', () {
      PusherOptions options = new PusherOptions();
      expect(options.encrypted, false);
      expect(options.port, DEFAULT_HTTP_PORT);
    });

    test('Should use HTTPS if encrypted is `true` and port if `null`', () {
      PusherOptions options = new PusherOptions(encrypted: true);
      expect(options.port, DEFAULT_HTTPS_PORT);
    });

    test('Constructor #1', () {
      PusherOptions options = new PusherOptions(encrypted: true, port: 1000);
      expect(options.encrypted, true);
      expect(options.port, 1000);
    });
  });

  group('TriggerOptions', () {
    TriggerOptions options;
    String socketId;

    setUp(() {
      socketId = '444.444';
      options = new TriggerOptions(socketId: socketId);
    });

    test('Should get `socketId`', () {
      expect(options.socketId, socketId);
    });
  });

  group('TriggerBody', () {
    TriggerBody body;
    String name;
    String data;
    List<String> channels;
    String socketId;

    setUp(() {
      name = 'my-event';
      data = 'Hello World';
      channels = ['my-channel'];
      socketId = '444.444';
      body = new TriggerBody(name: name, data: data, channels: channels, socketId: socketId);
    });

    test('Should get `name`', () {
      expect(body.name, name);
    });

    test('Should get `data`', () {
      expect(body.data, data);
    });

    test('Should get `channels`', () {
      expect(body.channels, channels);
    });

    test('Should get `socketId`', () {
      expect(body.socketId, socketId);
    });

    test('Should get a body Map', () {
      expect(
          body.toMap(), {'name': name, 'data': data, 'channels': channels, 'socketId': socketId});
    });

    test('Should get a JSON encoded body', () {
      expect(body.toJson(),
          JSON.encode({'name': name, 'data': data, 'channels': channels, 'socketId': socketId}));
    });

    test('Should get a MD5 encoded body', () {
      expect(body.toMD5(), '641c5a9f422d824e5ee6070df4cd3f1e');
    });
  });

  group('Result', () {
    Result result;
    int status;
    String message;

    setUp(() {
      status = 200;
      message = '{}';
      result = new Result(status, message);
    });

    test('Should get `status`', () {
      expect(result.status, status);
    });

    test('Should get `message`', () {
      expect(result.message, message);
    });
  });

  group('Pusher', () {
    Pusher pusher;

    setUp(() {
      pusher = new Pusher(PUSHER_APP_ID, PUSHER_APP_KEY, PUSHER_APP_SECRET);
    });

    test('Should get `/channels`', () async {
      Result result = await pusher.get('/channels');
      expect(result.status, 200);
    });

    test('Should trigger events', () async {
      Result respose =
          await pusher.trigger(['channel-test'], 'event-test', {'message': 'Hello World!'});
      expect(respose.status, 200);
    });

    test('Should authenticate socketId', () {
      String key = 'thisisaauthkey';
      Pusher instance = new Pusher('1', key, 'thisisasecret');
      String auth = instance.authenticate('test_channel', '74124.3251944');
      String expected =
          '{"auth":"${key}:f8390ffe4df18cc755d3191b9db75182c71354e0b3ad7be1d186ac86f3c0fc4b"}';
      expect(auth, expected);
    });

    test('Should authenticate presence', () {
      String key = 'thisisaauthkey';
      Pusher instance = new Pusher('1', key, 'thisisasecret');
      String auth = instance.authenticate(
          'presence-test_channel', '74124.3251944', new User('1', {'name': 'Adao'}));
      String expected =
          '{"auth":"${key}:ca6b9a5d11a7b5909eef43f49cba4c64a083c9298c9b1dc75c4073c0f4e7d2e2","channel_data":"{\\\"user_id\\\":\\\"1\\\",\\\"user_info\\\":{\\\"name\\\":\\\"Adao\\\"}}"}';
      expect(auth, expected);
    });
  });
}
