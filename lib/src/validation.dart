final RegExp SOCKET_ID_REGEX = new RegExp(r'^\d+\.\d+$');

/// A regular expression to check that a channel name is in a format allowed and accepted by Pusher.
final RegExp CHANNEL_NAME_REGEX = new RegExp(r'^[A-Za-z0-9_\-=@,.;]+$');

final int CHANNEL_NAME_MAX_LENGTH = 164;

/// Validate a socket_id value
void validateSocketId(String socketId) {
  if (socketId != null && SOCKET_ID_REGEX.hasMatch(socketId) == false)
    throw new FormatException(
        "socket_id $socketId was not in the form: ${SOCKET_ID_REGEX.toString()}");
}

/// Validate a single channel name is in the allowed format.
void validateChannelName(String name) {
  if (name.length > CHANNEL_NAME_MAX_LENGTH)
    throw new ArgumentError(
        "The length of the channel name was greater than the allowed $CHANNEL_NAME_MAX_LENGTH characters");
  else if (CHANNEL_NAME_REGEX.hasMatch(name) == false)
    throw new FormatException(
        "channel name $name was not in the form: ${CHANNEL_NAME_REGEX.toString()}");
}

/// Validate a list of channel names
void validateListOfChannelNames(List<String> names) {
  names.forEach(validateChannelName);
}
