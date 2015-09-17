# Pusher HTTP Dart Library

The Dart library for interacting with the Pusher HTTP API.

This package lets you trigger events to your client and query the state of your Pusher channels. When used with a server, you can authenticate private- or presence-channels.

In order to use this library, you need to have a free account on <http://pusher.com>. After registering, you will need the application credentials for your app.

## Installation

```dart
dependencies:
  pusher: "^0.1.0"
```

## Getting Started

```dart

import 'package:pusher/pusher.dart';

main() async {
  Pusher pusher = new Pusher('PUSHER_APP_ID','PUSHER_APP_KEY','PUSHER_APP_SECRET');
  Map data = {'message':'Hello world'};
  Result response = await pusher.trigger(['test_channel'],'my_event',data);
}

```

## Configuration

There easiest way to configure the library is by creating a new `Pusher` instance:

```dart
Pusher pusher = new Pusher(
    'PUSHER_APP_ID',
    'PUSHER_APP_KEY',
    'PUSHER_APP_SECRET'
);
```

## Usage

### Triggering events

It is possible to trigger an event on one or more channels. Channel names can contain only characters which are alphanumeric, `_` or `-``. Event name can be at most 200 characters long too.

```dart
 Result response = await pusher.trigger(['test_channel'],'my_event',data);
```

### Authenticating Channels

Pusher provides a mechanism for authenticating a user's access to a channel at the point of subscription.

This can be used both to restrict access to private channels, and in the case of presence channels notify subscribers of who else is also subscribed via presence events.

This library provides a mechanism for generating an authentication signature to send back to the client and authorize them.

For more information see [docs](http://pusher.com/docs/authenticating_users).

#### Private channels

```dart
 String socketId = '74124.3251944';
 String auth = pusher.authenticate('test_channel',socketId);
```

#### Authenticating presence channels

Using presence channels is similar to private channels, but in order to identify a user, clients are sent a user_id and, optionally, custom data.

```dart
 String socketId = '74124.3251944';
 User user = new User('1',{'name':'Adao'});
 String auth = pusher.authenticate('presence-test_channel',socketId,user);
```
