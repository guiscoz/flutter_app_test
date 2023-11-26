import 'package:flutter/material.dart';

void handleApiError(BuildContext context, String error) {
  final snackBar = SnackBar(
    content: Text(error),
    backgroundColor: Colors.red,
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}