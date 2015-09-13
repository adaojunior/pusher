
library pusher.validate;

final RegExp SOCKET_ID_REGEX = new RegExp("\A\d+\.\d+\z");

/// Validate a socket_id value
void validateSocketId(String socketId){
  if(socketId.isEmpty ||  SOCKET_ID_REGEX.hasMatch(socketId) == false)
    throw new FormatException("socket_id ${socketId} was not in the form: ${SOCKET_ID_REGEX.toString()}");
}
