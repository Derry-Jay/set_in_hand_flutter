import 'package:flutter/material.dart';

import '../helpers/helper.dart';

class BottomWidget extends StatelessWidget {
  final double? heightFactor, widthFactor;
  const BottomWidget({Key? key, this.heightFactor, this.widthFactor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final hp = Helper.of(context);
    return Container(
        height: heightFactor,
        color: hp.theme.primaryColor,
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: const [
              //  SizedBox(width: 15,),
              Text(
                '    Simia - Set in Hand \u00a9 2018 All rights reserved',
                style: TextStyle(color: Colors.white, fontSize: 15),
              ),
              Text(
                'System Version 1.9.6    ',
                style: TextStyle(color: Colors.white, fontSize: 15),
              ),
              // SizedBox(width: 15,),
            ]));
  }
}
