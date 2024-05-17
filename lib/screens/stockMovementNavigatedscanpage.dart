import '../helpers/helper.dart';
import '../widgets/my_app_bar.dart';
import '../widgets/logo_widget.dart';
import '../models/warehousedata.dart';
import '../widgets/loader_widget.dart';
import 'package:flutter/material.dart';
import '../widgets/bottom_widget.dart';
import '../models/route_argument.dart';
import '../widgets/custom_button.dart';
import 'package:flutter/cupertino.dart';
import '../widgets/chat_list_widget.dart';
import '../models/getqrcodeiddetails.dart';
import '../widgets/custom_labelled_button.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class StockMovementFinalPage extends StatefulWidget {
  final RouteArgument rar;

  const StockMovementFinalPage({Key? key, required this.rar}) : super(key: key);

  @override
  State<StockMovementFinalPage> createState() => _StockMovementFinalPage();
}

class _StockMovementFinalPage extends State<StockMovementFinalPage> {
  List<GetStockItemWareHouse>? getData;
  List<Map<String, dynamic>> newData = <Map<String, dynamic>>[];
  GetQrCodeIdDetails? codeDetails;
  WarehouseIdGet? warehouseSet;
  String? code;
  bool pressed = false, isMoveButtonActive = false, moveSelected = false;
  ScrollController scon = ScrollController();
  Helper get hp => Helper.of(qrKey.currentContext ?? context);
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void setScanMode() {
    if (mounted) setState(setScanValue);
  }

  void setScanValue() {
    pressed = !pressed;
  }

  void setData() async {
    getData = await api.warehouseDataAPI(widget.rar.id.toString(), hp);
    if (mounted) setState(() {});
  }

  void completeMovement(int warehouseid) async {
    if (newData.isEmpty &&
        await hp.showSimplePopup('Okay', () {
          moveSelected = false;
          hp.goBack(result: true);
        },
            action: 'There is no items scanned to move the location',
            title: 'Tap To Move',
            type: AlertType.cupertino)) {
      // showCupertinoDialog(
      //   context: context,
      //   builder: (context) {
      //     return CupertinoAlertDialog(
      //       title: const Text('Tap To Move'),
      //       content:
      //           const Text('There is no items scanned to move the location'),
      //       actions: [
      //         CupertinoDialogAction(
      //             child: const Text('Okay'),
      //             onPressed: () {
      //               moveSelected = false;
      //               Navigator.of(context).pop();
      //             }),
      //       ],
      //     );
      //   },
      // );
    } else {
      List<int> intArr = [];

      for (var item in newData) {
        log(item['qrcodeId']);
        intArr.add(item['qrcodeId']);
      }
      log(intArr);
      final res = await api.moveStocksAPI(warehouseid.toString(), intArr, hp);
      final p = await hp.revealToast(res.message);
      if (res.success && p) {
        final r = await hp.revealDialogBox([
          'OK'
        ], [
          () {
            hp.goBack(result: true);
          }
        ],
            action: 'Stocks Moved Successfully',
            title: 'Setinhand',
            type: AlertType.cupertino);
        if (r) {
          moveSelected = false;
          // didUpdateWidget(widget);
          hp.goBack(result: false);
        }
      }
    }
  }

  void qrCodeScanValue(String qrText, QRViewController controller) async {
    log(moveSelected);
    log('goyla enga iruka ne');
    final q = await hp.showPleaseWait();
    if (q) {
      if (moveSelected) {
        final p = await api.scanStockMovement(qrText, hp);
        // final wid =
        final warehouseId =
            int.tryParse(p.data == null ? '0' : p.data.toString()) ?? 0;
        final fromID = getData?.first.uniqueId ?? '';
        final toID = qrText;
        final count = newData.length;
        if (warehouseId != 0) {
          final p = await hp.revealDialogBox([
            'No',
            'Yes'
          ], [
            () {
              hp.goBack(result: false);
            },
            () {
              hp.goBack(result: true);
            }
          ],
              title: 'Confirm',
              action:
                  'You are moving $count items from location($fromID) to location ($toID) is this correct?',
              type: AlertType.cupertino);
          if (p) {
            // final r = await showCupertinoDialog<bool>(
            //       context: context,
            //       builder: (context) {
            //         return CupertinoAlertDialog(
            //           title: const Text('Confirm'),
            //           content: Text('Stocks Moved Successfully'
            //               ),
            //           actions: [
            //             CupertinoDialogAction(
            //                 child: const Text('No'),
            //                 onPressed: () {
            //                   hp.goBack(result: false);
            //                 }),
            //             CupertinoDialogAction(
            //                 child: const Text('Yes',
            //                     style: TextStyle(fontWeight: FontWeight.bold)),
            //                 onPressed: () {
            //                   // completeMovement();
            //                   hp.goBack(result: true);
            //                 })
            //           ],
            //         );
            //       },
            //     ) ??
            //     false;
            // if (r) {
            //   moveSelected = false;
            //   // didUpdateWidget(widget);
            //   hp.goBack(result: false);
            // }
            completeMovement(warehouseId);
          }
        } else if (await showCupertinoDialog<bool>(
              context: context,
              builder: (context) {
                return CupertinoAlertDialog(
                  title: const Text(''),
                  content: Text(warehouseSet?.message ?? ''),
                  actions: [
                    CupertinoDialogAction(
                        child: const Text('Ok'),
                        onPressed: () {
                          hp.goBack(result: true);
                          setState(() {
                            moveSelected = false;
                            pressed = false;
                          });
                        }),
                  ],
                );
              },
            ) ??
            false) {}
      } else {
        final val = await api.moveStocksQrcodeAPI(qrText, hp);
        final id = val.id;
        if (getData != null && getData!.isNotEmpty) {
          for (GetStockItemWareHouse item in getData!) {
            log(item.toMap());
          }
        }
        // log('HII');
        List<GetStockItemWareHouse>? filtered =
            getData?.where((i) => i.qrcodeId == id).toList();
        Map<String, dynamic> newDataMapping;
        if (filtered?.isNotEmpty ?? false) {
          var duplicate = false;
          if (newData.isNotEmpty) {
            for (var item in newData) {
              if (item['qrcodeId'] == filtered?.first.qrcodeId) {
                duplicate = true;
              } else {
                duplicate = false;
              }
            }
            log(duplicate);
            if (duplicate == false) {
              newDataMapping = {
                'warehouse_id': filtered?.first.warehouseId,
                'stock_item_id': filtered?.first.stockItemId,
                'qrcodetext': filtered?.first.qrcodetext,
                'qrcodeId': filtered?.first.qrcodeId
              };
              newData.add(newDataMapping);
            }
          } else {
            newDataMapping = {
              'warehouse_id': filtered?.first.warehouseId,
              'stock_item_id': filtered?.first.stockItemId,
              'qrcodetext': filtered?.first.qrcodetext,
              'qrcodeId': filtered?.first.qrcodeId
            };
            newData.add(newDataMapping);
          }
        } else if (await showCupertinoDialog<bool>(
              context: context,
              builder: (context) {
                return CupertinoAlertDialog(
                  title: const Text('Scanning Process'),
                  content: const Text(
                      'Scanned Item is not available in this Location'),
                  actions: [
                    CupertinoDialogAction(
                        child: const Text('Ok'),
                        onPressed: () {
                          hp.goBack(result: true);
                          setState(() {
                            moveSelected = false;
                            pressed = false;
                            scannedToMove();
                          });
                        }),
                  ],
                );
              },
            ) ??
            false) {
          // log('Hi');
        }

        log(newData);
        setState(() {
          pressed = false;
          scannedToMove();
        });
      }
    } else {}
  }

  Expanded scannedToMove() {
    return Expanded(
      flex: 4,
      child: ListView.builder(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics()),
          itemBuilder: (context, index) {
            return Container(
              margin: const EdgeInsets.only(top: 1),
              padding: const EdgeInsets.all(10),
              alignment: Alignment.topLeft,
              color: Colors.green,
              child: Text(newData[index]['stock_item_id'] ?? '',
                  style: const TextStyle(color: Colors.white, fontSize: 17)),
            );
          },
          itemCount: newData.length),
    );
  }

  void onQRViewCreated(QRViewController con) async {
    bool scanned = false;

    void onData(Barcode event) async {
      if (!scanned) {
        scanned = true;
        con.pauseCamera();
        if (event.code?.isNotEmpty ?? false) {
          log(event.code);
          qrCodeScanValue(event.code ?? '', con);
        } else if (await hp.showSimplePopup('OK', () {
          hp.goBack(result: true);
        },
            action: 'Qr code is empty. please scan proper code',
            title: 'Setinhand',
            type: AlertType.cupertino)) {
          await con.resumeCamera();
          // showDialogEmpty(context, 'Please Scan an appropriate Code');
        } else {}
      }
    }

    void onError(Object val, StackTrace trace) async {
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

  Widget pageBuilder(BuildContext context, Orientation screenLayout) {
    final hpp = Helper.of(context);
    log(screenLayout);
    return WillPopScope(
        onWillPop: hpp.backButtonOverride,
        child: SafeArea(
          child: Scaffold(
            key: _scaffoldKey,
            bottomNavigationBar:
                BottomWidget(heightFactor: 30, widthFactor: hpp.width),
            backgroundColor: const Color(0xffdbd9d9),
            endDrawer: const Drawer(child: ChatListWidget()),
            body: getData == null
                ? const LoaderWidget()
                : Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          MyAppBar(hpp, _scaffoldKey,
                              leading: IconButton(
                                  onPressed: () {
                                    try {
                                      if (mounted) {
                                        hpp.goBack();
                                        log(widget.rar.id);
                                      }
                                    } catch (e) {
                                      sendAppLog(e);
                                    }
                                  },
                                  icon: const Icon(Icons.arrow_back_ios_new))),
                          const LogoWidget()
                        ],
                      ),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Flexible(
                                flex: 3,
                                child: Container(
                                    padding: const EdgeInsets.only(
                                        top: 20, right: 10, left: 10),
                                    color: Colors.white,
                                    width: double.infinity,
                                    child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                              width: double
                                                  .infinity, // <-- match_parent, // <-- match-parent
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                      flex: 4,
                                                      child: Container(
                                                          height: 50.0,
                                                          color: const Color(
                                                              0xFFe2e4ef),
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(15),
                                                          child: const Text(
                                                              'Task',
                                                              style: TextStyle(
                                                                  color: Color(
                                                                      0xFF404040),
                                                                  fontSize:
                                                                      17)))),
                                                  const SizedBox(width: 3),
                                                  Expanded(
                                                    flex: 4,
                                                    child: Container(
                                                      height: 50.0,
                                                      color: const Color(
                                                          0xFFe2e4ef),
                                                      padding:
                                                          const EdgeInsets.all(
                                                              15),
                                                      child: const Text(
                                                          'Location',
                                                          style: TextStyle(
                                                              color: Color(
                                                                  0xFF404040),
                                                              fontSize: 17)),
                                                    ),
                                                  ),
                                                  const Expanded(
                                                    flex: 4,
                                                    child: SizedBox(
                                                      width: 3,
                                                    ),
                                                  ),
                                                  const Expanded(
                                                    flex: 4,
                                                    child: SizedBox(
                                                      width: 3,
                                                    ),
                                                  ),
                                                ],
                                              )),
                                          const SizedBox(
                                            width: 3,
                                            height: 3,
                                          ),
                                          SizedBox(
                                              width: double
                                                  .infinity, // <-- match_parent, // <-- match-parent
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    flex: 4,
                                                    child: Container(
                                                      color: const Color(
                                                          0xFFe2e4ef),
                                                      padding:
                                                          const EdgeInsets.all(
                                                              15),
                                                      child: const Text(
                                                          'Stock Movement',
                                                          style: TextStyle(
                                                              color: Color(
                                                                  0xFF404040),
                                                              fontSize: 17)),
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    width: 3,
                                                  ),
                                                  Expanded(
                                                    flex: 4,
                                                    child: Container(
                                                      color: const Color(
                                                          0xFFe2e4ef),
                                                      padding:
                                                          const EdgeInsets.all(
                                                              15),
                                                      child: Text(
                                                          getData?.first
                                                                  .uniqueId ??
                                                              '',
                                                          style: const TextStyle(
                                                              color: Color(
                                                                  0xFF404040),
                                                              fontSize: 17)),
                                                    ),
                                                  ),
                                                  const Expanded(
                                                    flex: 4,
                                                    child: SizedBox(
                                                      width: 3,
                                                    ),
                                                  ),
                                                  const Expanded(
                                                    flex: 4,
                                                    child: SizedBox(
                                                      width: 3,
                                                    ),
                                                  ),
                                                ],
                                              )),
                                          const SizedBox(
                                            width: 3,
                                            height: 40,
                                          ),
                                          SizedBox(
                                            width: double
                                                .infinity, // <-- match_parent, // <-- match-parent
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  flex: 4,
                                                  child: Container(
                                                    height: 60.0,
                                                    color:
                                                        const Color(0xFFe2e4ef),
                                                    padding:
                                                        const EdgeInsets.all(
                                                            10),
                                                    child: const Text(
                                                        'Stock Items in this location',
                                                        style: TextStyle(
                                                            color: Color(
                                                                0xFF404040),
                                                            fontSize: 17)),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: 3,
                                                ),
                                                Expanded(
                                                  flex: 4,
                                                  child: Container(
                                                    height: 60.0,
                                                    color:
                                                        const Color(0xFFe2e4ef),
                                                    padding:
                                                        const EdgeInsets.all(
                                                            15),
                                                    alignment: Alignment.center,
                                                    child: const Text(
                                                        'Scanned to Move',
                                                        style: TextStyle(
                                                            color: Color(
                                                                0xFF404040),
                                                            fontSize: 17)),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 3, height: 2),
                                          Expanded(
                                            flex: 10,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Expanded(
                                                    flex: 4,
                                                    child: ListView.builder(
                                                        scrollDirection:
                                                            Axis.vertical,
                                                        shrinkWrap: true,
                                                        physics:
                                                            const BouncingScrollPhysics(
                                                                parent:
                                                                    AlwaysScrollableScrollPhysics()),
                                                        itemBuilder:
                                                            (context, index) {
                                                          log(getData?[index]
                                                              .qrcodetext);
                                                          return Container(
                                                            margin:
                                                                const EdgeInsets
                                                                        .only(
                                                                    top: 1),
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(10),
                                                            alignment: Alignment
                                                                .topLeft,
                                                            color: Colors
                                                                .orangeAccent,
                                                            child: Text(
                                                                getData?[index]
                                                                        .stockItemId ??
                                                                    '',
                                                                style: const TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontSize:
                                                                        17)),
                                                          );
                                                        },
                                                        itemCount:
                                                            getData?.length ??
                                                                0,
                                                        controller: scon)),
                                                const SizedBox(width: 3),
                                                scannedToMove()
                                              ],
                                            ),
                                          ),
                                          Flexible(
                                              child: CustomLabelledButton(
                                                  buttonColor: Colors.blue,
                                                  type: ButtonType.raised,
                                                  label: 'Scroll Down',
                                                  onPressed: () async {
                                                    await scon.animateTo(
                                                        scon.position
                                                            .maxScrollExtent,
                                                        curve:
                                                            Curves.easeOutCirc,
                                                        duration:
                                                            const Duration(
                                                                milliseconds:
                                                                    1500));
                                                  }))
                                        ]))),
                            Flexible(
                              flex: 2,
                              child: Column(
                                children: [
                                  Visibility(
                                      visible: !pressed,
                                      child: SizedBox(
                                          width: double
                                              .infinity, // <-- match_parent, // <-- match-parent
                                          child: CustomButton(
                                              padding: EdgeInsets.symmetric(
                                                  vertical: hpp.height / 100),
                                              buttonColor:
                                                  hpp.theme.selectedRowColor,
                                              labelColor: hpp.theme
                                                  .scaffoldBackgroundColor,
                                              type: ButtonType.raised,
                                              onPressed: setScanMode,
                                              child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: const [
                                                    Icon(Icons.qr_code_scanner,
                                                        color: Colors.white),
                                                    Text('Scan Code',
                                                        style: TextStyle(
                                                            color:
                                                                Colors.white))
                                                  ])))),
                                  pressed
                                      ? Visibility(
                                          visible: pressed,
                                          child: Container(
                                              alignment: Alignment.topLeft,
                                              height: hpp.height /
                                                  (screenLayout ==
                                                          Orientation.landscape
                                                      ? 2.56
                                                      : 3.5184372088832),
                                              width: screenLayout ==
                                                      Orientation.landscape
                                                  ? hpp.width / 2.56
                                                  : null,
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: hpp.width / 80),
                                              child: Stack(
                                                alignment:
                                                    Alignment.bottomCenter,
                                                children: <Widget>[
                                                  QRView(
                                                      overlay:
                                                          QrScannerOverlayShape(
                                                              cutOutHeight:
                                                                  hpp.height /
                                                                      1.6,
                                                              cutOutWidth:
                                                                  hpp.width),
                                                      key: qrKey,
                                                      onQRViewCreated:
                                                          onQRViewCreated),
                                                  Positioned(
                                                      left: hpp.width /
                                                          (screenLayout ==
                                                                  Orientation
                                                                      .landscape
                                                              ? 6.4
                                                              : 6.5536),
                                                      top: hpp.height /
                                                          (screenLayout ==
                                                                  Orientation
                                                                      .landscape
                                                              ? 4
                                                              : 5.24288),
                                                      child: CustomLabelledButton(
                                                          labelColor: hpp.theme
                                                              .scaffoldBackgroundColor,
                                                          buttonColor: hpp
                                                              .theme.errorColor,
                                                          label: 'Cancel',
                                                          onPressed:
                                                              setScanMode,
                                                          type:
                                                              ButtonType.text))
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
                                  Visibility(
                                      visible: !(code == null || code!.isEmpty),
                                      child: Text(
                                          'Scanned Code is: ${code ?? ''}')),
                                  GestureDetector(
                                      child: Container(
                                          margin: EdgeInsets.symmetric(
                                              vertical: hpp.height / 40),
                                          color: newData.isEmpty
                                              ? hpp.theme.disabledColor
                                              : Colors.green,
                                          padding: EdgeInsets.symmetric(
                                              vertical: hpp.height / 32,
                                              horizontal: hpp.width / 8),
                                          child: const Text('TAP TO MOVE',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16))),
                                      onTap: () async {
                                        final p = await hpp.revealDialogBox([
                                          'OK'
                                        ], [
                                          () {
                                            hpp.goBack(result: true);
                                          }
                                        ],
                                            title: 'Setinhand',
                                            action: newData.isEmpty
                                                ? 'Please select a stock to move'
                                                : 'Scan the location where you want to move',
                                            type: AlertType.cupertino);
                                        if (newData.isNotEmpty && p) {
                                          setState(() {
                                            moveSelected = true;
                                            pressed = true;
                                          });
                                        }
                                      })
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
        ));
  }

  @override
  void initState() {
    super.initState();
    setData();
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(builder: pageBuilder);
  }
}
