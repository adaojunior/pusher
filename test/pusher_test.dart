// Copyright (c) 2015, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

library pusher.test;

import 'package:pusher/pusher.dart';
import 'package:test/test.dart';

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

}
