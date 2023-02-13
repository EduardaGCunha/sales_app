bool checkBool(value) {
  if (value is num) {
    return value == 1 ? true : false;
  } else if (value is bool) {
    return value;
  } else {
    return value == '1' ? true : false;
  }
}

num boolToSql(value) {
  if (value is bool) {
    return value == true ? 1 : 0;
  } else if (value == '1' || value == 'true') {
    return 1;
  } else if (value == '0' || value == 'false') {
    return 0;
  } else {
    return value;
  }
}