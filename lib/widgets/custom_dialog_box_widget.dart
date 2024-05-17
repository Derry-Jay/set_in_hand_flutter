import 'package:flutter/material.dart';

class CustomDialogBoxWidget extends StatelessWidget {
  final Widget? child;
  final Duration? duration;
  const CustomDialogBoxWidget({Key? key, this.child, this.duration})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
        opacity: 0.8,
        duration: duration ?? const Duration(milliseconds: 600),
        child: AnimatedContainer(
            duration: duration ?? const Duration(milliseconds: 600),
            child: child));
  }
}
