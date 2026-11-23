import 'package:flutter/material.dart';

/// Goes to Home and clears everything above it, so "الرئيسية" no longer stacks
/// another Home on top of the history (back used to walk through every screen
/// visited, and audio on removed screens kept playing).
void goHome(BuildContext context) {
  Navigator.of(context).pushNamedAndRemoveUntil('Home', (route) => false);
}
