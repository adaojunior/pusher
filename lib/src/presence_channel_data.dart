import 'dart:convert';

/// Information about a user who is subscribing to a presence channel.
class PresenceChannelData {
  /// A unique user identifier for the user within the application.
  /// Pusher uses this to uniquely identify a user. So, if multiple users are given the same [id]
  /// the second of these users will be ignored and won't be represented on the presence channel.
  final String id;

  /// Arbitrary additional information about the user.
  final Map<String, dynamic> info;

  PresenceChannelData(this.id, [this.info]);

  get hasInfo => this.info != null;

  Map toMap() => {'user_id': id, ...(hasInfo ? {'user_info': info} : {})};

  String toJson() => json.encode(toMap());
}
