import 'package:flutter/material.dart';

class CustomSnackbars {
  errorSnackbar({required String message, required BuildContext context}) {
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  successSnackbar({required String message, required BuildContext context}) {
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  infoSnackbar({required String message, required BuildContext context}) {
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.blue),
    );
  }

  warningSnackbar({required String message, required BuildContext context}) {
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.orange),
    );
  }

  customSnackbar({
    required String message,
    required BuildContext context,
    required Color color,
    required Duration duration,
  }) {
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: duration,
      ),
    );
  }
}
