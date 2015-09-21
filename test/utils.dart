library test.utils;

String str_repeat(String piece, int multiplier) {
  return new List<String>.filled(multiplier, 'a').join('');
}

List listOfInvalidSocketId() {
  return [
    ':444.444', //SocketId cannot contain colon prefix
    '444.444:', //SocketId cannot contain colon sufix
    '444.444a', //socket_id_cannot_contain_letters_suffix
    '444', // socket_id_must_contain_a_period_point
    '\n444.444', //socket_id_must_not_contain_newline_prefix
    '444.444\n', //socket_id_must_not_contain_newline_suffix
    '', //socket_id_must_not_be_empty_string
  ];
}
