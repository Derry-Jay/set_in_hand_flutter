import '../back_end/api.dart';
import '../helpers/helper.dart';
import 'package:flutter/material.dart';

class QRImageScreen extends StatelessWidget {
  const QRImageScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            appBar: AppBar(),
            body: ValueListenableBuilder<List<int>?>(
                valueListenable: bytes, builder: imageFromBytesBuilder)));
  }
}
