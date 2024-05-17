import '../models/task.dart';
import '../models/reply.dart';
import '../back_end/api.dart';
import '../helpers/helper.dart';
import '../models/misc_data.dart';
import '../widgets/my_app_bar.dart';
import '../widgets/logo_widget.dart';
import '../widgets/empty_widget.dart';
import '../widgets/loader_widget.dart';
import '../widgets/custom_button.dart';
import '../widgets/bottom_widget.dart';
import '../models/stockitemModel.dart';
import 'package:flutter/material.dart';
import '../widgets/chat_list_widget.dart';
import '../widgets/custom_labelled_button.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:multi_value_listenable_builder/multi_value_listenable_builder.dart';

class PullListScreen extends StatefulWidget {
  final Task task;

  const PullListScreen({Key? key, required this.task}) : super(key: key);

  @override
  PullListScreenState createState() => PullListScreenState();
}

class PullListScreenState extends State<PullListScreen> {
  String stockCode = '';
  StockItem? selectedItem;
  int? expected, wareHouseID;
  List<StockItem>? selectedItems;
  bool scanMode = false, flag = false, fs = false;
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  Helper get hp => Helper.of(qrKey.currentContext ?? context);

  void customDispose() async {
    try {
      stockItems.value = null;
      stocks.value = <StockItem>[];
      hp.onChange();
      if (css.isNotEmpty && css.remove(css.last)) {
        log('dispose');
      }
      qrKey.currentState?.dispose();
      if (scs.isEmpty) {
        log('Empty');
      } else {
        final q = await scs.last.asFuture();
        await scs.last.cancel();
        log(q);
      }
    } catch (e) {
      sendAppLog(e);
    }
  }

  void setScanMode() {
    if (flag) {
      if (selectedItem != null && mounted) {
        setState(setScanValue);
      }
    } else {
      if (mounted) setState(setScanValue);
    }
  }

  void setScanValue() {
    scanMode = !scanMode;
  }

  void refresh() {
    stockItems.value = null;
    stocks.value = <StockItem>[];
    hp.onChange();
    api.getPullList(widget.task, hp);
  }

  void closeScanner() {
    if (mounted) {
      setState(() {
        scanMode = false;
      });
    }
  }

  void onQRViewCreated(QRViewController con) async {
    bool scanned = false;

    if (!scanMode) {
      await con.pauseCamera();
    }

    void onDone() {
      closeScanner();
    }

    void onError(Object val, StackTrace trace) {
      log(val);
      closeScanner();
      log(trace);
    }

    void onData(Barcode event) async {
      bool pick(StockItem element) {
        return element.uniqueID == event.code;
      }

      try {
        if (!scanned) {
          scanned = true;
          await con.pauseCamera();
          setState(() {
            scanMode = false;
            if (selectedItem != null) {
              fs = event.code == selectedItem?.qrText;
            }
          });
          if (event.code?.isNotEmpty ?? false) {
            if (mounted) {
              code.value = event.code;
              final matches = '-'.allMatches(event.code ?? '');
              if (matches.length > 1) {
                location.value = event.code;
              }
              bytes.value = event.rawBytes;
              hp.onChange();
            }
            log(event.code);
            log(event.rawBytes);
            if (flag) {
              log(selectedItem);
              Map<String, dynamic> body =
                  selectedItem?.map ?? <String, dynamic>{};
              if (body.isNotEmpty) {
                body['qr_code_text'] = event.code;
                log(body);
                final val = await api.getPullStockStatus(body, hp);
                bool sf = val.reply.success &&
                    await hp.revealToast(val.reply.message);
                if (val.quantityType != 'Box') {
                  sf = sf &&
                      await hp.revealDialogBox([
                        'Yes',
                        'No'
                      ], [
                        () {
                          hp.goBack(result: true);
                        },
                        () {
                          hp.goBack(result: false);
                        }
                      ],
                          type: AlertType.cupertino,
                          title: 'Setinhand',
                          action:
                              'Please confirm you have picked the exact amount required?');
                }
                log('Hi');
                if (sf) {
                  final body = {
                    'qr_code_id': val.qrID.toString(),
                    'stockcode': selectedItem?.productCode,
                    'user_id': currentUser.value.userID.toString(),
                    'mr_id': selectedItem?.moveRequestID.toString(),
                    'expectedqty': expected.toString()
                  };
                  log(body);
                  final v = await api.completeStockCheck(body, hp);
                  log(v);
                  log('values-quantities');
                  if (await hp.showSimplePopup('OK', () {
                        hp.goBack(result: true);
                      },
                          title: 'Setinhand',
                          type: AlertType.cupertino,
                          action: v.base.success
                              ? 'Stock Records updated successfully'
                              : 'Something went wrong!') &&
                      v.base.success) {
                    if (v.completed) {
                      code.value = null;
                      location.value = null;
                      remaining.value = v.remaining;
                      hp.onChange();
                      hp.goBack();
                    } else if (await api.getStockInfo({
                      'stockcode': val.productCode,
                      'qty_expectedd': (v.expected <= 0
                              ? selectedItem?.awaitedQuantity
                              : v.expected)
                          .toString(),
                      'task_id': widget.task.taskID.toString(),
                      'warehouse_id':
                          (wareHouseID ?? (selectedItem?.whID ?? -1)).toString()
                    }, hp)) {
                      log('@@@@@@@@@@@@@@');
                      if (v.remaining > 0 &&
                          v.expected == 0 &&
                          stocks.value.isNotEmpty) {
                        stocks.value = <StockItem>[];
                      } else {
                        log('my2');
                      }
                      didUpdateWidget(widget);
                      log('😑😑😑😑😑😑😑😑😑😑😑😑😑😑');
                    } else {
                      log('%%%%%%%%%%%%%%%%%%%%%%');
                      log(v.base.message);
                      log('*************************');
                    }
                  } else {
                    log('^^^^^^^^^^^^^^^^^^^^^');
                    log(v.base.message);
                    log('&&&&&&&&&&&&&&&&&&&&&&');
                  }
                } else if (mounted &&
                    await hp.showSimplePopup('OK', () {
                      hp.goBack(result: true);
                    },
                        title: 'Setinhand',
                        type: AlertType.cupertino,
                        action:
                            'Scanned item code not matched with the item')) {
                  setState(() {
                    selectedItem = null;
                    fs = false;
                  });
                } else {
                  log('&&&&&&&&&&&&&&&&&&&');
                  log(val.reply.message);
                  log('********************');
                }
              } else {
                log('Bye');
              }
            } else {
              log(stockItems.value);
              selectedItems = stockItems.value?.where(pick).toList();
              log(selectedItems);
              if (selectedItems?.isNotEmpty ?? false) {
                final body = {
                  'delivery_id': selectedItems?.first.deliveryID.toString(),
                  'unique_id': event.code
                };
                final rs = await api.getPullScanResult(body, hp);
                final rp = Reply.fromMap(rs);
                log(rs);
                if (await hp.showSimplePopup('OK', () {
                  hp.goBack(result: true);
                },
                    action: rp.message,
                    title: 'Setinhand',
                    type: AlertType.cupertino)) {
                  if (rp.success) {
                    final val = OtherData.fromMap(rs);
                    wareHouseID = val.reply.success
                        ? int.tryParse(val.data.toString())
                        : null;
                  } else {
                    log('<<<<<<<<<<<<<<<<<<<<');
                    log(event.format);
                    log('>>>>>>>>>>>>>>>>>>>>>');
                  }
                } else {
                  log('~~~~~~~~~~~~~~~~~~~~~~~~~');
                }
              } else if (await hp.showSimplePopup('OK', () {
                hp.goBack(result: true);
              },
                  title: 'Setinhand',
                  action: 'You have Scanned an Invalid code!!!!',
                  type: AlertType.cupertino)) {
                log('Hi');
              } else {
                log(stockItems.value?.length);
              }
            }
          } else {
            log('!!!!!!!!!!!!!!');
            final ff = await hp.showSimplePopup('OK', () {
              hp.goBack(result: false);
            },
                title: 'Setinhand',
                action: 'You have Scanned an Invalid code!!!!',
                type: AlertType.cupertino);
            final cf = await con.getSystemFeatures();
            final df = await con.getFlashStatus() ?? false;
            final ef = await con.getCameraInfo();
            if (df &&
                cf.hasBackCamera &&
                cf.hasFlash &&
                cf.hasFrontCamera &&
                ff) {
              log(ef);
            }
            log(event.code);
            log('######################');
          }
        }
      } catch (e) {
        sendAppLog(e);
        if (mounted) {
          final q = await hp.showSimplePopup('OK', () {
            hp.goBack(result: true);
          },
              action: e.toString(),
              title: 'Setinhand',
              type: AlertType.cupertino);
          if (q) rethrow;
        }
      }
      // await con.resumeCamera();
    }

    if (!css.contains(con.scannedDataStream)) {
      css.add(con.scannedDataStream);
    }
    final cs =
        con.scannedDataStream.listen(onData, onError: onError, onDone: onDone);
    if (!scs.contains(cs)) {
      scs.add(cs);
    }
  }

  Widget codeBuilder(BuildContext context, String? code, Widget? child) {
    final hpc = Helper.of(context);
    return Visibility(
        visible: code != null && code.isNotEmpty,
        child: Container(
            color: Colors.white,
            margin: EdgeInsets.only(top: hpc.height / 100),
            padding: EdgeInsets.symmetric(
                horizontal: hpc.width / 100, vertical: hpc.height / 200),
            child: Text('Scanned Code is: ${code ?? ''}')));
  }

  Widget scanCodeBuilder(BuildContext context, AsyncSnapshot<Barcode> bcs) {
    final hpc = Helper.of(context);
    return Visibility(
        visible: bcs.hasData && !bcs.hasError,
        child: Container(
            color: Colors.white,
            margin: EdgeInsets.only(top: hpc.height / 100),
            padding: EdgeInsets.symmetric(
                horizontal: hpc.width / 100, vertical: hpc.height / 200),
            child: Text(
                'Scanned Code is: ${bcs.data == null ? '' : (bcs.data?.code ?? '')}')));
  }

  Widget locationBuilder(BuildContext context, String? code, Widget? child) {
    final hpl = Helper.of(context);
    return Flexible(
        flex: 2,
        child: Visibility(
            visible: (code?.isNotEmpty ?? false) && stockCode.isNotEmpty,
            child: Container(
                color: Colors.white,
                margin: EdgeInsets.only(bottom: hpl.height / 100),
                padding: EdgeInsets.symmetric(
                    horizontal: hpl.width / 80, vertical: hpl.height / 160),
                child: Text('${code ?? ''} || $stockCode',
                    style: const TextStyle(fontWeight: FontWeight.w500)))));
  }

  Widget textBuilder(BuildContext context, int value, Widget? child) {
    final hpt = Helper.of(context);
    return Visibility(
        visible: value > 0,
        child: Container(
            margin: EdgeInsets.symmetric(vertical: hpt.height / 200),
            child: Text('Remaining Qty to be Pulled: $value')));
  }

  Widget pageBuilder(
      BuildContext context, List<StockItem>? items, Widget? child) {
    final hpr = Helper.of(context);

    Widget tableBuilder(BuildContext context, String? code, Widget? child) {
      final hpt = Helper.of(context);
      // log('Hi');
      // log(location.value);
      // log('Bye');
      return SingleChildScrollView(
          child: Table(
              border: TableBorder(
                  horizontalInside:
                      BorderSide(width: hpt.width / 250, color: Colors.white),
                  verticalInside:
                      BorderSide(width: hpt.height / 400, color: Colors.white)),
              children: [
            TableRow(
                decoration: BoxDecoration(color: hpt.theme.canvasColor),
                children: [
                  Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.symmetric(
                          horizontal: hpt.width / 100,
                          vertical: hpt.height / 50),
                      decoration: BoxDecoration(color: hpt.theme.canvasColor),
                      child:
                          const Text('Locations', textAlign: TextAlign.center)),
                  Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.symmetric(vertical: hpt.height / 50),
                      margin: EdgeInsets.only(
                          left: hpt.width / 100, right: hpt.width / 400),
                      decoration: BoxDecoration(color: hpt.theme.canvasColor),
                      child: const Text('Stock Items',
                          textAlign: TextAlign.center)),
                  Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.symmetric(vertical: hpt.height / 50),
                      margin: EdgeInsets.only(
                          left: hpt.width / 400, right: hpt.width / 200),
                      decoration: BoxDecoration(color: hpt.theme.canvasColor),
                      child: const Text('Type', textAlign: TextAlign.center)),
                  Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.symmetric(vertical: hpt.height / 50),
                      decoration: BoxDecoration(color: hpt.theme.canvasColor),
                      child: const Text('Qty', textAlign: TextAlign.center))
                ]),
            for (StockItem item in (items ?? <StockItem>[]))
              TableRow(
                  children: [
                    ValueListenableBuilder<String?>(
                      valueListenable: location,
                      builder: (context, loc, child) => Container(
                          alignment: Alignment.center,
                          padding: EdgeInsets.symmetric(
                              horizontal: hpt.width / 80,
                              vertical: (hpt.height * item.productCode.length) /
                                  ((items?.length ?? 0) > 1
                                      ? (hpr.dimensions.orientation == Orientation.landscape
                                          ? 320
                                          : 400)
                                      : (item.productCode.length > 11
                                          ? (hpr.size.longestSide > 1052
                                              ? (hpr.dimensions.orientation == Orientation.landscape
                                                  ? 1000
                                                  : 1600)
                                              : (hpr.size.longestSide < 1052
                                                  ? (hpr.dimensions.orientation ==
                                                          Orientation.landscape
                                                      ? 922.3372036854775808
                                                      : 1000)
                                                  : 1280))
                                          : (hpr.size.longestSide < 1052
                                              ? (hpr.dimensions.orientation == Orientation.landscape
                                                  ? 312.5
                                                  : 396.14081257132168796771975168)
                                              : (hpr.dimensions.orientation ==
                                                      Orientation.landscape
                                                  ? 312.5
                                                  : 400))))),
                          decoration: BoxDecoration(color: item.uniqueID == loc ? hpt.theme.hintColor : hpt.theme.toggleableActiveColor),
                          child: Text(item.uniqueID, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white))),
                    ),
                    GestureDetector(
                        child: Container(
                            alignment: Alignment.bottomCenter,
                            padding: EdgeInsets.symmetric(
                                vertical: (hpt.height * item.productCode.length) /
                                    ((items?.length ?? 0) > 1
                                        ? 274.877906944
                                        : (item.productCode.length > 11
                                            ? (hpr.size.longestSide > 1052
                                                ? (hpr.dimensions.orientation ==
                                                        Orientation.landscape
                                                    ? 1000
                                                    : 1600)
                                                : (hpr.size.longestSide < 1052
                                                    ? (hpr.dimensions.orientation == Orientation.landscape
                                                        ? 2000
                                                        : 1000)
                                                    : (hpr.dimensions.orientation == Orientation.landscape
                                                        ? 2048
                                                        : 1280)))
                                            : (hpr.size.longestSide < 1052
                                                ? (hpr.dimensions.orientation ==
                                                        Orientation.landscape
                                                    ? 312.5
                                                    : 256)
                                                : (hpr.dimensions.orientation ==
                                                        Orientation.landscape
                                                    ? 312.5
                                                    : 262.144))))),
                            margin: EdgeInsets.symmetric(horizontal: hpt.width / 625),
                            decoration: BoxDecoration(color: item.productCode == stockCode ? hpt.theme.hintColor : hpt.theme.toggleableActiveColor),
                            child: Text(item.productCode, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white))),
                        onTap: () async {
                          try {
                            // if (mounted && code == item.uniqueID) {
                            //   final matches = '-'.allMatches(code ?? '');
                            //   if (matches.length > 1) {
                            //     location.value = code;
                            //   }
                            //   hpt.onChange();
                            // }
                            expected = item.shownQuantity;
                            if (code == null &&
                                await hpt.revealDialogBox([
                                  'OK'
                                ], [
                                  () {
                                    hpt.goBack(result: true);
                                  }
                                ],
                                    action: 'Please Scan a Code first',
                                    title: 'Setinhand',
                                    type: AlertType.cupertino)) {
                              log('Hi');
                            } else if (wareHouseID != null &&
                                wareHouseID == item.whID &&
                                mounted) {
                              final map = {
                                'qty_expectedd':
                                    item.awaitedQuantity.toString(),
                                'stockcode': item.productCode,
                                'task_id': widget.task.taskID.toString(),
                                'warehouse_id': item.whID.toString()
                              };
                              flag = await api.getStockInfo(map, hpt);
                              setState(() {
                                stockCode = item.productCode;
                              });
                              flag ? hpt.onChange() : doNothing();
                            } else {
                              final c = await hpt.revealDialogBox([
                                'OK'
                              ], [
                                () {
                                  hpt.goBack(result: true);
                                }
                              ],
                                  action: 'Please Scan an appropriate Code',
                                  title: 'Setinhand',
                                  type: AlertType.cupertino);
                              if (c) {
                                log('Hi');
                              }
                            }
                          } catch (e) {
                            sendAppLog(e);
                            if (await hpt.revealDialogBox([
                              'OK'
                            ], [
                              () {
                                hpt.goBack(result: true);
                              }
                            ],
                                action: e.toString(),
                                title: 'Setinhand',
                                type: AlertType.cupertino)) rethrow;
                          }
                        }),
                    Container(
                        alignment: Alignment.center,
                        padding:
                            EdgeInsets.symmetric(vertical: hpt.height / 51.2),
                        margin: EdgeInsets.only(
                            left: hpt.width / 400, right: hpt.width / 200),
                        decoration: BoxDecoration(
                            color: hpt.theme.toggleableActiveColor),
                        child: Text(item.quantityType,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.white))),
                    Container(
                        alignment: Alignment.center,
                        padding:
                            EdgeInsets.symmetric(vertical: hpt.height / 51.2),
                        decoration: BoxDecoration(
                            color: hpt.theme.toggleableActiveColor),
                        child: Text(item.awaitedQuantity.toString(),
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.white)))
                  ],
                  decoration: BoxDecoration(
                      gradient:
                          stockCode.isEmpty || stockCode != item.productCode
                              ? null
                              : LinearGradient(colors: [
                                  hpt.theme.hintColor,
                                  hpt.theme.toggleableActiveColor
                                ], stops: const [
                                  0.5,
                                  0.5
                                ]),
                      color: hpt.theme.toggleableActiveColor))
          ]));
    }

    log(hpr.size.longestSide);

    return WillPopScope(
        onWillPop: hpr.backButtonOverride,
        child: SafeArea(
          child: Scaffold(
              bottomNavigationBar:
                  BottomWidget(heightFactor: 30, widthFactor: hpr.width),
              key: scaffoldKey,
              endDrawer: const Drawer(child: ChatListWidget()),
              backgroundColor: hpr.theme.cardColor,
              body: items == null
                  ? (child ?? const EmptyWidget())
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          children: [
                            MyAppBar(hpr, scaffoldKey,
                                leading: IconButton(
                                    onPressed: () {
                                      try {
                                        code.value = null;
                                        location.value = null;
                                        stockItems.value = null;
                                        stocks.value = <StockItem>[];
                                        hpr.onChange();
                                        hpr.goBack();
                                      } catch (e) {
                                        sendAppLog(e);
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
                                Flexible(
                                    flex: 3,
                                    child: Container(
                                        padding: const EdgeInsets.only(
                                            top: 30, right: 10, left: 10),
                                        color: Colors.white,
                                        width: double.infinity,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Flexible(
                                                child: CustomButton(
                                                    buttonColor: Colors.blue,
                                                    labelColor: hpr.theme
                                                        .scaffoldBackgroundColor,
                                                    type: ButtonType.raised,
                                                    onPressed: refresh,
                                                    child:
                                                        const Text('Refresh'))),
                                            Expanded(
                                                flex: 4,
                                                child: items.isEmpty
                                                    ? const Center(
                                                        child: Text(
                                                            'No Data Available'))
                                                    : GridView.count(
                                                        padding: EdgeInsets.only(
                                                            top:
                                                                hp.height / 80),
                                                        shrinkWrap: hpr
                                                                .dimensions
                                                                .orientation ==
                                                            Orientation
                                                                .portrait,
                                                        childAspectRatio: (hpr
                                                                    .height *
                                                                (hpr.dimensions.orientation == Orientation.landscape
                                                                    ? 2.56
                                                                    : 1.28)) /
                                                            hp.width,
                                                        crossAxisCount: 3,
                                                        crossAxisSpacing: hpr
                                                                    .dimensions
                                                                    .orientation ==
                                                                Orientation.landscape
                                                            ? 8
                                                            : 10,
                                                        physics: const NeverScrollableScrollPhysics(),
                                                        children: [
                                                            Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  const Flexible(
                                                                      child: Text(
                                                                          'MR ID')),
                                                                  Expanded(
                                                                      child: Container(
                                                                          alignment: Alignment
                                                                              .center,
                                                                          decoration: BoxDecoration(
                                                                              color: hp
                                                                                  .theme.canvasColor),
                                                                          child: Text(
                                                                              items.first.mrID.toString(),
                                                                              textAlign: TextAlign.center)))
                                                                ]),
                                                            Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  const Flexible(
                                                                      child: Text(
                                                                          'Customer')),
                                                                  Expanded(
                                                                      child: Container(
                                                                          alignment: Alignment
                                                                              .center,
                                                                          decoration: BoxDecoration(
                                                                              color: hp
                                                                                  .theme.canvasColor),
                                                                          child: Text(
                                                                              items.first.customerName,
                                                                              textAlign: TextAlign.center)))
                                                                ]),
                                                            Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  const Flexible(
                                                                      child: Text(
                                                                          'Reason')),
                                                                  Expanded(
                                                                      child: Container(
                                                                          alignment: Alignment
                                                                              .center,
                                                                          decoration: BoxDecoration(
                                                                              color: hp
                                                                                  .theme.canvasColor),
                                                                          child: Text(
                                                                              items.first.reason,
                                                                              textAlign: TextAlign.center)))
                                                                ]),
                                                            Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  const Flexible(
                                                                      child: Text(
                                                                          'Details')),
                                                                  Expanded(
                                                                      child: Container(
                                                                          alignment: Alignment
                                                                              .center,
                                                                          decoration: BoxDecoration(
                                                                              color: hp
                                                                                  .theme.canvasColor),
                                                                          child: Text(
                                                                              items.first.details,
                                                                              textAlign: TextAlign.center)))
                                                                ])
                                                          ])),
                                            Flexible(
                                                child:
                                                    ValueListenableBuilder<int>(
                                                        valueListenable:
                                                            remaining,
                                                        builder: textBuilder)),
                                            Expanded(
                                                flex: hpr.dimensions
                                                            .orientation ==
                                                        Orientation.landscape
                                                    ? 8
                                                    : 15,
                                                child: items.isEmpty
                                                    ? const Center(
                                                        child: Text(
                                                            'Nothing to pull'))
                                                    : ValueListenableBuilder<
                                                            String?>(
                                                        valueListenable: code,
                                                        builder: tableBuilder))
                                          ],
                                        ))),
                                Flexible(
                                  flex: 2,
                                  child: Column(
                                    children: [
                                      Visibility(
                                          visible: !scanMode,
                                          child: SizedBox(
                                              width: double
                                                  .infinity, // <-- match_parent, // <-- match-parent
                                              child: CustomButton(
                                                  padding: EdgeInsets.symmetric(
                                                      vertical:
                                                          hpr.height / 100),
                                                  buttonColor: hpr
                                                      .theme.selectedRowColor,
                                                  labelColor: hpr.theme
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
                                                  alignment: Alignment.topLeft,
                                                  height: hpr.height /
                                                      (hpr.screenLayout ==
                                                              Orientation
                                                                  .landscape
                                                          ? 2.56
                                                          : 4),
                                                  width: hpr.screenLayout ==
                                                          Orientation.landscape
                                                      ? hpr.width / 2.56
                                                      : null,
                                                  padding: EdgeInsets.all(
                                                      hpr.radius / 100),
                                                  child: Stack(
                                                    alignment:
                                                        Alignment.bottomCenter,
                                                    children: <Widget>[
                                                      QRView(
                                                          overlay:
                                                              QrScannerOverlayShape(
                                                                  cutOutHeight:
                                                                      hpr.height /
                                                                          2,
                                                                  cutOutWidth: hpr
                                                                      .width),
                                                          key: qrKey,
                                                          onQRViewCreated:
                                                              onQRViewCreated),
                                                      Positioned(
                                                          left: hpr
                                                                  .width /
                                                              (hpr
                                                                          .screenLayout ==
                                                                      Orientation
                                                                          .landscape
                                                                  ? 6.25
                                                                  : 6.4),
                                                          top: hpr
                                                                  .height /
                                                              (hpr
                                                                          .screenLayout ==
                                                                      Orientation
                                                                          .landscape
                                                                  ? 4
                                                                  : 6.4),
                                                          child: CustomLabelledButton(
                                                              labelColor: hpr
                                                                  .theme
                                                                  .scaffoldBackgroundColor,
                                                              buttonColor: hpr
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
                                                  vertical: hpr.height / 40,
                                                  horizontal: hpr.width / 25),
                                              padding: EdgeInsets.symmetric(
                                                  vertical: hpr.height / 8)),
                                      ValueListenableBuilder<String?>(
                                          valueListenable: code,
                                          builder: codeBuilder),
                                      // StreamBuilder<Barcode>(builder: scanCodeBuilder,stream: cs1),
                                      GestureDetector(
                                          child: Container(
                                              color: hpr.theme.disabledColor,
                                              padding: EdgeInsets.symmetric(
                                                  vertical: hpr.height / 32,
                                                  horizontal: hpr.width /
                                                      (hpr.dimensions
                                                                  .orientation ==
                                                              Orientation
                                                                  .landscape
                                                          ? 8.192
                                                          : 10.48576 /*99511627776*/)),
                                              margin: EdgeInsets.symmetric(
                                                  vertical: hp.height / 50),
                                              child: const Text(
                                                  'PARTIAL COMPLETE',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 16))),
                                          onTap: () async {
                                            // final body = {
                                            //   'delivery_Id': selectedItems
                                            //       ?.first.deliveryID
                                            //       .toString(),
                                            //   'created_by': selectedItems
                                            //       ?.first.customerID
                                            //       .toString()
                                            // };
                                            // final rp =
                                            //     await api.partialComplete(body);
                                            if (await hpr.revealDialogBox([
                                              'OK',
                                              'Cancel'
                                            ], [
                                              () {
                                                hpr.goBack(result: true);
                                              },
                                              () {
                                                hpr.goBack(result: false);
                                              }
                                            ],
                                                type: AlertType.cupertino,
                                                title: 'Setinhand',
                                                action:
                                                    'Are you want to mark this pull list as partially complete? This Pull will be place in the task list again?')) {
                                              final r = await hpr.showSimplePopup(
                                                  'OK', () {
                                                hpr.goBack(result: true);
                                              },
                                                  type: AlertType.cupertino,
                                                  title: 'Setinhand',
                                                  action:
                                                      'Successfully marked as Partially Completed');
                                              if (r) {
                                                log(selectedItems);
                                              }
                                            }
                                          }),
                                      ValueListenableBuilder<String?>(
                                          valueListenable: location,
                                          builder: locationBuilder),
                                      MultiValueListenableBuilder(
                                          builder: boxesBuilder,
                                          valueListenables: [stocks, code])
                                    ],
                                  ),
                                ),
                              ]),
                        ),
                      ],
                    )),
        ));
  }

  Widget boxesBuilder(
      BuildContext context, List<dynamic> values, Widget? child) {
    final list = values.first as List<StockItem>;
    final code = values.last == null ? '' : values.last as String;
    Widget getItem(BuildContext context, int index) {
      final hpi = Helper.of(context);
      final item = list[index];
      return GestureDetector(
          child: Card(
              color: code == item.qrText && selectedItem == item && fs
                  ? const Color(0xffe183a7)
                  : (selectedItem == item
                      ? hpi.theme.hintColor
                      : hpi.theme.toggleableActiveColor),
              margin: EdgeInsets.symmetric(
                  horizontal: hpi.width / 32, vertical: hpi.height / 100),
              child: SizedBox(
                  height: hpi.height /
                      (hpi.dimensions.orientation == Orientation.landscape
                          ? 10
                          : 13.1072),
                  width: hpi.width / 2,
                  child: Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: hpi.height /
                              (hpi.dimensions.orientation ==
                                      Orientation.landscape
                                  ? 200
                                  : 160),
                          horizontal: hpi.width / 50),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Expanded(
                                flex: 7,
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                          flex: 3,
                                          child: Text(item.stockItemID,
                                              style: const TextStyle(
                                                  color: Colors.white))),
                                      Expanded(
                                          child: Text(item.qrText,
                                              style: const TextStyle(
                                                  color: Colors.white)))
                                    ])),
                            Expanded(
                                child: Text(item.perBox.toString(),
                                    style:
                                        const TextStyle(color: Colors.white)))
                          ])))),
          onTap: () {
            setState(() {
              selectedItem = item;
              scanMode = true;
            });
          });
    }

    return Expanded(
        flex: 12,
        child: list.isEmpty
            ? (child ?? const EmptyWidget())
            : ListView.builder(
                itemBuilder: getItem,
                itemCount: list.length,
                padding: EdgeInsets.zero));
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    log(code.value);
    log(flag);
    return ValueListenableBuilder<List<StockItem>?>(
        valueListenable: stockItems,
        builder: pageBuilder,
        child: const LoaderWidget());
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    api.getPullList(widget.task, hp);
  }

  @override
  void didUpdateWidget(PullListScreen oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
    log(selectedItem);
    log('update widget');
    if (selectedItem != null) {
      log('rgigui');
      selectedItem = null;
      stockItems.value = null;
      hp.onChange();
      api.getPullList(widget.task, hp);
    }
    log(stockItems.value?.length);
    log('Hi');
    if (stocks.value.isEmpty) {
      flag = false;
      scanMode = false;
      stockCode = '';
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    customDispose();
    super.dispose();
  }
}
