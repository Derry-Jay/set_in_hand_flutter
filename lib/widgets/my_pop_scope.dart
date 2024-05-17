import 'package:flutter/material.dart';

class MyPopScope extends WillPopScope {
  final Widget inner;
  final Future<bool> Function()? onPop;
  const MyPopScope({Key? key, this.onPop, required this.inner})
      : super(child: inner, onWillPop: onPop, key: key);
}
