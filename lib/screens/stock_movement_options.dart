import '../helpers/helper.dart';
import '../widgets/my_app_bar.dart';
import '../widgets/logo_widget.dart';
import 'package:flutter/material.dart';
import '../widgets/bottom_widget.dart';
import '../widgets/chat_list_widget.dart';

class StockMovementOptions extends StatefulWidget {
  const StockMovementOptions({Key? key}) : super(key: key);

  @override
  State<StockMovementOptions> createState() => _StockMovementOptionsState();
}

class _StockMovementOptionsState extends State<StockMovementOptions> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Helper get hp => Helper.of(context);

  void goodsInMovement() async {
    hp.goTo('/goodsInMovement');
  }

  void stockMovement() async {
    hp.goTo('/stockMovementsScan');
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    hp.getConnectStatus();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: hp.backButtonOverride,
        child: SafeArea(
          child: Scaffold(
            bottomNavigationBar: BottomWidget(
              heightFactor: 30,
              widthFactor: MediaQuery.of(context).size.width,
            ),
            // backgroundColor: Color(0xffFFDBD9D9),
            key: _scaffoldKey,
            endDrawer: const Drawer(child: ChatListWidget()),
            body: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    MyAppBar(hp, _scaffoldKey,
                        leading: IconButton(
                            onPressed: hp.goBack,
                            icon: const Icon(Icons.arrow_back_ios_new))),
                    const LogoWidget()
                  ],
                ),
                const SizedBox(
                  height: 75,
                ),
                Flexible(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //    const SizedBox(height: 75,),
                      TextButton(
                          onPressed: stockMovement,
                          style: TextButton.styleFrom(
                              primary: Colors.white,
                              backgroundColor: hp.theme.hintColor,
                              alignment: Alignment.center,
                              textStyle: const TextStyle(
                                  fontSize: 48, fontWeight: FontWeight.normal),
                              fixedSize: const Size(300, 300),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              shape: const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(25.0)),
                              )),
                          child: const Text(
                            'Stock Movement',
                            textAlign: TextAlign.center,
                          )),
                      const SizedBox(
                        width: 100,
                      ),
                      TextButton(
                          onPressed: goodsInMovement,
                          style: TextButton.styleFrom(
                              primary: Colors.white,
                              backgroundColor: const Color(0xff7fc449),
                              alignment: Alignment.center,
                              textStyle: const TextStyle(
                                  fontSize: 48, fontWeight: FontWeight.normal),
                              fixedSize: const Size(300, 300),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              shape: const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(25.0)),
                              )),
                          child: const Text(
                            'Goods-In Movement',
                            textAlign: TextAlign.center,
                          )),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
