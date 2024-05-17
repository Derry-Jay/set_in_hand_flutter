import '../back_end/api.dart';
import '../helpers/helper.dart';
import '/extensions/extension.dart';
import '../widgets/my_app_bar.dart';
import '../widgets/logo_widget.dart';
import '../widgets/loader_widget.dart';
import '../widgets/custom_button.dart';
import '../widgets/bottom_widget.dart';
import 'package:flutter/material.dart';
import '../models/route_argument.dart';
import '../models/readnotification.dart';
import '../widgets/chat_list_widget.dart';
import '../widgets/custom_labelled_button.dart';
import '../models/GetCompletedDeliveriesDetails.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import '../widgets/goods_in_movement_table_widget.dart';

class GoodsInMovementScanPage extends StatefulWidget {
  final RouteArgument rar;

  const GoodsInMovementScanPage({Key? key, required this.rar})
      : super(key: key);

  @override
  GoodsInMovementScanPageState createState() => GoodsInMovementScanPageState();
}

class GoodsInMovementScanPageState extends State<GoodsInMovementScanPage> {
  bool pressed = false;
  String? code, location;
  bool scanMode = false, isLoading = false;
  late String customer_name, customer_deliveryID;
  Helper get hp => Helper.of(qrKey.currentContext ?? context);
  List<String> scanSelected = <String>[], scanSelectedDeliveryIDs = <String>[];

  bool sendLocationFlag = false;

  ReadNotification? sendLocationValue;
  ScrollController scrollController = ScrollController();

  final topics = ['Delivery ID', 'Customer'];
  List<String>? topics2;
  final topics3 = ['Stock Items', 'QR Code'];

  Widget buttonBuilder(BuildContext context, int value, Widget? child) {
    final hpb = Helper.of(context);
    return GestureDetector(
        child: Container(
            color: value == 0
                ? hpb.theme.disabledColor
                : hpb.theme.selectedRowColor,
            padding: EdgeInsets.symmetric(
                vertical: hpb.height / 32, horizontal: hpb.width / 20),
            child: Text('SEND $value TO LOCATION',
                style: const TextStyle(color: Colors.white, fontSize: 16))),
        onTap: () async {
          if (value > 0) {
            sendLocationFlag = true;
            setScanMode();
          } else if (await hpb.revealDialogBox([
            'OK'
          ], [
            () {
              hpb.goBack(result: false);
            }
          ],
              title: 'Setinhand',
              action: 'Please Select an Item by Scanning',
              type: AlertType.cupertino)) {
          } else {
            log(value);
          }
        });
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void onQRViewCreated(QRViewController con) async {
    bool scanned = false;
    void onData(Barcode event) async {
      await con.pauseCamera();
      if (!scanned) {
        scanned = true;
        if ((event.code?.isNotEmpty ?? false) && mounted) {
          log(event.code);
          setState(() {
            code = event.code;
          });
          qrCodeScanValue(event.code ?? '', con);
        } else {
          showDialogEmpty(
              context, 'Qr code is empty or invalid. Please scan proper code');
        }
      } else {
        log('my1');
      }
      await con.resumeCamera();
    }

    void onError(Object val, StackTrace trace) async {
      await con.stopCamera();
      log(val);
      log(trace);
    }

    if (!css.contains(con.scannedDataStream)) {
      css.add(con.scannedDataStream);
    }
    final cs = con.scannedDataStream.listen(onData, onError: onError);
    if (!scs.contains(cs)) {
      scs.add(cs);
    }
  }

  void qrCodeScanValue(String qrText, QRViewController controller) async {
    if (qrText.trim().isNotEmpty) {
      if (sendLocationFlag && scanSelected.isNotEmpty) {
        for (String item in scanSelected) {
          final val =
              data.value?.where((element) => element.qrcodetext == item);
          log(val?.length);
          if (val?.isNotEmpty ?? true) {
            for (var i in val!) {
              log(i.qrcodetext);
              scanSelectedDeliveryIDs.add(i.qrcodetext.toString());
            }
          }
        }
        sendToLocation(qrText, scanSelectedDeliveryIDs,
            (data.value!.first.customerId ?? 0).toString());
      } else {
        scanSelected.add(qrText);
        count.value = data.value!.where(predCon).length;
        log(scanSelected);
        hp.notifyGoods();
        hp.notifyMoveCount();
        setScanMode();
      }
    } else {
      log(qrText);
    }
  }

  void setScanMode() {
    if (mounted) {
      setState(setScanValue);
    }
  }

  void setScanValue() {
    scanMode = !scanMode;
  }

  void sendToLocation(
      String scanedcode, List<String> deliveryId, String customerid) async {
    setState(() {
      sendLocationFlag = false;
      isLoading = true;
    });
    log(scanedcode);
    log(customerid);
    log(deliveryId);
    final ids = deliveryId.toSet().toList();
    log(ids);
    final rp = await api.assignPalletsLocations(scanedcode, ids, customerid);
    setState(() {
      isLoading = false;
    });
    final p = await hp.showSimplePopup('OK', () {
      setScanMode();
      hp.goBack(result: true);
    }, type: AlertType.cupertino, title: 'Setinhand', action: rp.message);
    if (p && rp.success) {
      hp.goBack();
    }
  }

  bool predCon(GetCompletedDeliveriesDetailDeliveryDatum item) {
    return scanSelected.contains(item.qrcodetext);
  }

  Widget expandsValue() {
    return const Expanded(child: GoodsInMovementTableWidget());
  }

  Widget scrollDownButton() {
    return Container(
      height: 60,
      width: double.infinity,
      padding: const EdgeInsets.only(bottom: 15, left: 0, right: 0),
      child: TextButton(
        style: ButtonStyle(
          foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
          backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
        ),
        onPressed: () {
          // setState(() {
          //   // _messages.insert(0, new Text("message ${_messages.length}"));
          //   getLocations?.insert(0, new Text("message ${getLocations.length}"));
          // });
          scrollController.animateTo(
            scrollController.position.maxScrollExtent,
            curve: Curves.bounceInOut,
            duration: const Duration(milliseconds: 1500),
          );
        },
        child: const Text(
          'Scroll Down',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.normal),
        ),
      ),
    );
  }

  ListView listValid(
      List<GetCompletedDeliveriesDetailDeliveryDatum>? deliveryData) {
    return ListView.builder(
        controller: scrollController,
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        physics: deliveryData!.length <= 10
            ? const NeverScrollableScrollPhysics()
            : const AlwaysScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          final item = deliveryData[index];
          return Row(
            children: <Widget>[
              const SizedBox(width: 1),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(0.5),
                  child: Container(
                    padding: const EdgeInsets.only(
                        top: 15, bottom: 15, left: 10, right: 5),
                    alignment: Alignment.topLeft,
                    color: scanSelected.isEmpty
                        ? hp.theme.highlightColor
                        : (scanSelected.contains(item.qrcodetext)
                            ? hp.theme.hintColor
                            : hp.theme.highlightColor),
                    // width: 240,
                    height: 50,

                    child: Text(deliveryData[index].stockItemId ?? '',
                        textAlign: TextAlign.left,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 15)),
                  ),
                ),
              ),
              const SizedBox(
                width: 1,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(0.5),
                  child: Container(
                    padding: const EdgeInsets.only(
                        top: 15, bottom: 15, left: 10, right: 5),
                    alignment: Alignment.topLeft,
                    color: scanSelected.isEmpty
                        ? hp.theme.highlightColor
                        : (scanSelected.contains(item.qrcodetext)
                            ? hp.theme.hintColor
                            : hp.theme.highlightColor),
                    // width: 240,
                    height: 50,

                    child: Text(deliveryData[index].qrcodetext ?? '',
                        textAlign: TextAlign.left,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 15)),
                  ),
                ),
              )
            ],
          );
        },
        itemCount: deliveryData.length);
  }

  Widget pageBuilder(BuildContext context, Orientation screenLayout) {
    final hpp = Helper.of(context);
    log(code);
    return WillPopScope(
        onWillPop: hp.backButtonOverride,
        child: SafeArea(
          child: Scaffold(
              bottomNavigationBar:
                  BottomWidget(heightFactor: 30, widthFactor: hpp.width),
              key: _scaffoldKey,
              endDrawer: const Drawer(child: ChatListWidget()),
              // backgroundColor: Color(0xffFFDBD9D9),
              body: !isLoading
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          children: [
                            MyAppBar(hpp, _scaffoldKey,
                                leading: IconButton(
                                    onPressed: () {
                                      try {
                                        count.value = 0;
                                        hpp.onChange();
                                        hpp.goBack();
                                      } catch (e) {
                                        sendAppLog(e);
                                        if (_scaffoldKey.currentContext !=
                                            null) {
                                          count.value = 0;
                                          Helper.of(
                                              _scaffoldKey.currentContext ??
                                                  context)
                                            ..onChange()
                                            ..goBack();
                                        }
                                      }
                                    },
                                    icon:
                                        const Icon(Icons.arrow_back_ios_new))),
                            const LogoWidget()
                          ],
                        ),
                        Flexible(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                  flex: 6,
                                  child: Container(
                                    padding: const EdgeInsets.all(25),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 35),
                                        Row(
                                          children: [
                                            Column(
                                              children: [
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                Container(
                                                  width: 130.0,
                                                  height: 50.0,
                                                  color: hpp.theme.focusColor,
                                                  padding:
                                                      const EdgeInsets.all(15),
                                                  child: Text('Delivery ID',
                                                      style: TextStyle(
                                                          color: hpp.theme
                                                              .secondaryHeaderColor,
                                                          fontSize: 17)),
                                                ),
                                                const SizedBox(
                                                  height: 3,
                                                ),
                                                Container(
                                                  width: 130.0,
                                                  height: 50.0,
                                                  color: hpp.theme.hoverColor,
                                                  padding:
                                                      const EdgeInsets.all(15),
                                                  child: Text(
                                                      customer_deliveryID,
                                                      style: TextStyle(
                                                          color: hpp.theme
                                                              .secondaryHeaderColor,
                                                          fontSize: 17)),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(
                                              width: 3,
                                            ),
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                Container(
                                                  width: 130.0,
                                                  height: 50.0,
                                                  color: hpp.theme.focusColor,
                                                  padding:
                                                      const EdgeInsets.all(15),
                                                  child: Text('Customer',
                                                      style: TextStyle(
                                                          color: hpp.theme
                                                              .secondaryHeaderColor,
                                                          fontSize: 17)),
                                                ),
                                                const SizedBox(
                                                  height: 3,
                                                ),
                                                Container(
                                                  width: 130.0,
                                                  height: 50.0,
                                                  color: hpp.theme.hoverColor,
                                                  padding:
                                                      const EdgeInsets.all(10),
                                                  child: Text(customer_name,
                                                      style: TextStyle(
                                                          color: hpp.theme
                                                              .secondaryHeaderColor,
                                                          fontSize: 16)),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(
                                              width: 20,
                                            ),
                                            Column(
                                              children: [
                                                ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    primary: hpp.theme
                                                        .hintColor, // background
                                                    onPrimary: Colors.white,
                                                    fixedSize: const Size(
                                                        150, 50), // foreground
                                                  ),
                                                  onPressed: () {
                                                    if (count.value > 0) {
                                                      scanSelected = <String>[];
                                                      count.value = 0;
                                                      hpp.onChange();
                                                      setState(() {
                                                        expandsValue();
                                                      });
                                                    }
                                                  },
                                                  child: const Text(
                                                      'DeSelect All'),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 100),
                                        expandsValue(),
                                        const SizedBox(height: 50),
                                        //  Expanded(flex : 1,child: scrollDownButton())
                                        //  scrollDownButton()
                                      ],
                                    ),
                                  )),
                              Expanded(
                                  flex: 3,
                                  child: Container(
                                    color: hpp.theme.unselectedWidgetColor,
                                    child: Column(
                                      children: [
                                        Visibility(
                                            visible: !scanMode,
                                            child: SizedBox(
                                                width: double
                                                    .infinity, // <-- match_parent, // <-- match-parent
                                                child: CustomButton(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            vertical:
                                                                hpp.height /
                                                                    100),
                                                    buttonColor: hpp
                                                        .theme.selectedRowColor,
                                                    labelColor: hpp.theme
                                                        .scaffoldBackgroundColor,
                                                    type: ButtonType.raised,
                                                    onPressed: setScanMode,
                                                    child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: const [
                                                          Icon(
                                                              Icons
                                                                  .qr_code_scanner,
                                                              color:
                                                                  Colors.white),
                                                          Text('Scan Code',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .white))
                                                        ])))),
                                        scanMode
                                            ? Visibility(
                                                visible: scanMode,
                                                child: Container(
                                                    alignment:
                                                        Alignment.topLeft,
                                                    height: hpp.height /
                                                        (screenLayout ==
                                                                Orientation
                                                                    .landscape
                                                            ? 2.56
                                                            : 4),
                                                    width: screenLayout ==
                                                            Orientation
                                                                .landscape
                                                        ? hpp.width / 2.56
                                                        : null,
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal:
                                                                hpp.width / 80),
                                                    child: Stack(
                                                      alignment: Alignment
                                                          .bottomCenter,
                                                      children: <Widget>[
                                                        QRView(
                                                            overlay: QrScannerOverlayShape(
                                                                cutOutHeight:
                                                                    hpp.height /
                                                                        1.6,
                                                                cutOutWidth:
                                                                    hpp.width),
                                                            key: qrKey,
                                                            onQRViewCreated:
                                                                onQRViewCreated),
                                                        Positioned(
                                                            left: hpp.width / 8,
                                                            top: hpp.height /
                                                                (screenLayout == Orientation.landscape
                                                                    ? 3.2768
                                                                    : 5.24288),
                                                            child: CustomLabelledButton(
                                                                labelColor: hpp
                                                                    .theme
                                                                    .scaffoldBackgroundColor,
                                                                buttonColor: hpp
                                                                    .theme
                                                                    .errorColor,
                                                                label: 'Cancel',
                                                                onPressed:
                                                                    setScanMode,
                                                                type: ButtonType
                                                                    .text))
                                                      ],
                                                    )))
                                            : Container(
                                                decoration: const BoxDecoration(
                                                    color: Colors.black),
                                                margin: EdgeInsets.symmetric(
                                                    vertical: hpp.height / 40,
                                                    horizontal: hpp.width / 25),
                                                padding: EdgeInsets.symmetric(
                                                    vertical: hpp.height / 8)),
                                        SizedBox(
                                            height: 60,
                                            width: hpp.width,
                                            child: Visibility(
                                                visible: code != null &&
                                                    code!.isNotEmpty,
                                                child: Padding(
                                                    padding: EdgeInsets.only(
                                                        left: hpp.width / 80),
                                                    child: Text(
                                                        'Scanned Code is: ${code ?? ''}')))),
                                        SizedBox(
                                            width: double
                                                .infinity, // <-- match_parent, // <-- match-parent
                                            child: ValueListenableBuilder<int>(
                                                builder: buttonBuilder,
                                                valueListenable: count)),
                                      ],
                                    ),
                                  )),
                            ],
                          ),
                        ),
                      ],
                    )
                  : const LoaderWidget()),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(builder: pageBuilder);
  }

  @override
  void didUpdateWidget(covariant GoodsInMovementScanPage oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
    hp.onChange();
  }

  @override
  void initState() {
    super.initState();
    hp.getConnectStatus();
    api.fetchGetCompletedDeliveriesDetails(widget.rar.content ?? '', hp);
    customer_name = widget.rar.tag ?? '';
    customer_deliveryID = widget.rar.content ?? '';
    topics2 = [customer_deliveryID, customer_name];
  }
}
