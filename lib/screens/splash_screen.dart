import '../back_end/api.dart';
import '../helpers/helper.dart';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class SplashScreen extends StatefulWidget {
  final ConnectivityResult connectionStatus;
  const SplashScreen({Key? key, required this.connectionStatus})
      : super(key: key);

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  bool opened = false, connected = true;
  Helper get hp => Helper.of(context);

  Widget getImageFromPath(String e) => Center(
      child: Image.asset(assetImagePath + e,
          errorBuilder: errorBuilder, alignment: Alignment.centerRight));

  void carryOn() async {
    await Future.delayed(const Duration(seconds: 5), proceed);
  }

  void proceed() async {
    connected = widget.connectionStatus != ConnectivityResult.none;
    log(opened);
    if (mounted) {
      connected
          ? hp.gotoForever(
              '/${currentUser.value.isEmpty ? 'login' : 'dashboard'}')
          : (opened ? doNothing() : hp.getConnectStatus(vcb: proceed));
      setState(() {
        opened = widget.connectionStatus == ConnectivityResult.none;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    carryOn();
  }

  @override
  void didUpdateWidget(covariant SplashScreen oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
    if (oldWidget != widget && mounted) {
      carryOn();
    }
  }

  @override
  Widget build(BuildContext context) {
    didUpdateWidget(widget);
    return SafeArea(
        child: Scaffold(
            body: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: splashScreenItems
                    .map<Widget>(getImageFromPath)
                    .toList())));
  }
}
