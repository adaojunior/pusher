# Pusher HTTP Dart Library

The Dart library for interacting with the Pusher HTTP API.

This package lets you trigger events to your client and query the state of your Pusher channels. When used with a server, you can authenticate private- or presence-channels.

In order to use this library, you need to have a free account on <http://pusher.com>. After registering, you will need the application credentials for your app.

*Please note that this package is still a work in progress.*

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
### Additional options
```dart
PusherOptions options = new PusherOptions(encrypted: true);
Pusher pusher = new Pusher(
    'PUSHER_APP_ID',
    'PUSHER_APP_KEY',
    'PUSHER_APP_SECRET',
    options
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
It is possible to query the state of your Pusher application using the generic `pusher.get( resource )` method and overloads.

For full details see: <http://pusher.com/docs/rest_api>

### Application state

This library allows you to query our API to retrieve information about your application's channels, their individual properties, and, for presence-channels, the users currently subscribed to them.

#### List channels

You can get a list of channels that are present within your application:

```dart
Result result = await pusher.get("/channels");
```
You can provide additional parameters to filter the list of channels that is returned.

```dart
Result result = await pusher.get("/channels", new { filter_by_prefix = "presence-" } );
```

#### Fetch channel information

Retrive information about a single channel:

```dart
Result result = await pusher.get("/channels/my_channel");
```
#### Fetch a list of users on a presence channel

Retrive a list of users that are on a presence channel:

```dart
Result result = await pusher.get('/channels/presence-channel/users');
```
## License

This code is free to use under the terms of the MIT license.
