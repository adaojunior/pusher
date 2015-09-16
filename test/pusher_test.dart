// Copyright (c) 2015, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

library pusher.test;

import 'package:pusher/pusher.dart';
import 'package:test/test.dart';
import 'dart:convert' show JSON;

void main() {

  group('PusherOptions', () {

    test('Test default values', () {
      PusherOptions options = new PusherOptions();
      expect(options.encrypted,false);
      expect(options.port,DEFAULT_HTTP_PORT);
    });

    test('Should use HTTPS if encrypted is `true` and port if `null`', () {
      PusherOptions options = new PusherOptions(encrypted:true);
      expect(options.port,DEFAULT_HTTPS_PORT);
    });

    test('Constructor #1',(){
      PusherOptions options = new PusherOptions(encrypted:true,port:1000);
      expect(options.encrypted,true);
      expect(options.port,1000);
    });

  });

  group('TriggerOptions',(){

    TriggerOptions options;
    String socketId;

    setUp((){
      socketId = '444.444';
      options = new TriggerOptions(socketId:socketId);
    });

    test('Should get `socketId`',(){
      expect(options.socketId,socketId);
    });

  });

  group('TriggerBody',(){

    TriggerBody body;
    String name;
    String data;
    List<String> channels;
    String socketId;

    setUp((){
      name = 'my-event';
      data = 'Hello World';
      channels = ['my-channel'];
      socketId = '444.444';
      body = new TriggerBody(name:name,data:data,channels:channels,socketId:socketId);
    });

    test('Should get `name`',(){
      expect(body.name,name);
    });

    test('Should get `data`',(){
      expect(body.data,data);
    });

    test('Should get `channels`',(){
      expect(body.channels,channels);
    });

    test('Should get `socketId`',(){
      expect(body.socketId,socketId);
    });

    test('Should get a body Map',(){
      expect(body.toMap(),{
        'name':name,
        'data':data,
        'channels':channels,
        'socketId':socketId
      });
    });

    test('Should get a JSON encoded body',(){
      expect(body.toJson(),JSON.encode({
        'name':name,
        'data':data,
        'channels':channels,
        'socketId':socketId
      }));
    });

    test('Should get a MD5 encoded body',(){
      expect(body.toMD5(),'641c5a9f422d824e5ee6070df4cd3f1e');
    });
  });

  group('Result',(){
    Result result;
    int status;
    String message;

    setUp((){
      status = 200;
      message = '{}';
      result = new Result(status,message);
    });

    test('Should get `status`',(){
      expect(result.status,status);
    });

    test('Should get `message`',(){
      expect(result.message,message);
    });

  });

}
