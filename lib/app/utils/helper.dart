import 'package:flutter/material.dart';

class Helper {
  Helper._();

  static void hideKeyboard(BuildContext context) {
    FocusScope.of(context).unfocus();
  }
}
