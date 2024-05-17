import 'package:flutter/material.dart';
import 'package:set_in_hand/helpers/helper.dart';

class LoaderWidget extends StatelessWidget {
  final BoxFit? fit;
  const LoaderWidget({Key? key, this.fit}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final hp = Helper.of(context);
    return SafeArea(
        child: Scaffold(
            backgroundColor: Colors.grey.withOpacity(0.5),
            body: Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                  Image.asset('${assetImagePath}puzzle_128.gif',
                      height: hp.height / (hp.factor * 10)),
                  SizedBox(height: hp.factor * 2),
                  const Text('Retrieving Data, Please \n wait...',
                      style: TextStyle(color: Colors.white, fontSize: 18))
                ]))));
  }
}
