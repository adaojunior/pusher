// Copyright (c) 2015, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.
import 'dart:convert';

import 'package:pusher/pusher.dart';
import 'package:pusher/src/webhook.dart';
import 'package:pusher/src/utils.dart' show HMAC256;
import 'package:test/test.dart';

void main() {
  group('Webhook', () {
    String validBody;
    String validSignature;
    String secret;
    DateTime now;

    setUp(() {
      secret = "some_crazy_secret";
      now = new DateTime.now().toUtc();
      validBody = JSON.encode({
        "time_ms": now.millisecondsSinceEpoch,
        "events": [
          {"name": "channel_occupied", "channel": "test_channel"}
        ]
      });

      validSignature = HMAC256(secret, validBody);
    });

    test('The WebHook will be valid if all params are as expected', () {
      Webhook webhook = new Webhook(secret, validSignature, validBody);
      expect(webhook.errors.isEmpty, equals(true));
      expect(webhook.isValid, equals(true));
      expect(webhook.isNotValid, equals(false));
      expect(
          webhook.events,
          equals([
            {"name": "channel_occupied", "channel": "test_channel"}
          ]));
    });

    test('secret must be provided', () {
      expect(() => new Webhook(null, null, null), throwsArgumentError);
    });

    test('signature must be provided', () {
      Webhook webhook = new Webhook("secret", null, "{}");
      expect(webhook.errors, equals([emptySignature]));
      expect(webhook.isNotValid, equals(true));
      expect(webhook.isValid, equals(false));
    });

    test('body must be provided', () {
      Webhook webhook = new Webhook("secret", "signature", null);
      expect(webhook.errors, equals([emptyBody]));
      expect(webhook.isNotValid, equals(true));
      expect(webhook.isValid, equals(false));
    });

    test('body must be a valid JSON', () {
      Webhook webhook = new Webhook(secret, validSignature, "{Hello World}");
      expect(webhook.errors, equals([invalidJson]));
      expect(webhook.isNotValid, equals(true));
      expect(webhook.isValid, equals(false));
    });
  });
}
