import '../helpers/helper.dart';
import 'package:flutter/material.dart';

class LogoWidget extends StatelessWidget {
  final BoxFit? fit;
  final double? heightFactor, widthFactor;
  const LogoWidget({Key? key, this.heightFactor, this.widthFactor, this.fit})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final hp = Helper.of(context);
    return GestureDetector(
        onTap: () {
          try {
            hp.route?.settings.name == '/dashboard'
                ? doNothing()
                : hp.goBackForeverTo('/dashboard');
          } catch (e) {
            sendAppLog(e);
          }
        },
        child: Container(
            width: hp.width / 4,
            height: hp.height / 13.1072,
            alignment: Alignment.center,
            margin: EdgeInsets.only(left: hp.width / 13.1072),
            decoration: BoxDecoration(
                color: Colors.white,
                image: DecorationImage(
                    fit: BoxFit.contain,
                    image: AssetImage('${assetImagePath}logo.jpg')),
                borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(hp.radius / 50)),
                border: Border.all(
                    width: 1,
                    color: Colors.blueGrey,
                    style: BorderStyle.solid))));
  }
}
