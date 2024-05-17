import 'package:flutter/material.dart';
import 'package:set_in_hand/helpers/helper.dart';

class RouteErrorScreen extends StatelessWidget {
  final bool flag;
  const RouteErrorScreen({Key? key, required this.flag}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final hp = Helper.of(context);
    return SafeArea(
        child: Scaffold(
            body: Center(
                child: Text(flag ? 'Route Error' : '',
                    style: hp.textTheme.bodyText1))));
  }
}
