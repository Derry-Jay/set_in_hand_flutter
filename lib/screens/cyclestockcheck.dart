import '../models/task.dart';
import '../back_end/api.dart';
import '../helpers/helper.dart';
import '../widgets/loader.dart';
import '../widgets/my_app_bar.dart';
import '../widgets/logo_widget.dart';
import '../widgets/empty_widget.dart';
import '../widgets/loader_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/custom_button.dart';
import '../widgets/bottom_widget.dart';
import '../widgets/chat_list_widget.dart';
import '../widgets/cycle_stock_list.dart';
import '../widgets/custom_labelled_button.dart';
import '../models/getcyclestockcheckmodel.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class CycleStockCheck extends StatefulWidget {
  final Task task;
  const CycleStockCheck({Key? key, required this.task}) : super(key: key);

  @override
  CycleStockCheckState createState() => CycleStockCheckState();
}

class CycleStockCheckState extends State<CycleStockCheck> {
  int? whID;
  bool isLoading = true, pressed = false;
  Helper get hp => Helper.of(qrKey.currentContext ?? context);
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void setScanMode() async {
    if (mounted) {
      setState(() {
        pressed = true;
      });
    }
  }

  void onQRViewCreated(QRViewController con) {
    void onData(Barcode event) async {
      if (mounted && (event.code?.isNotEmpty ?? false)) {
        code.value = event.code;
        hp.onChange();
        setState(() {
          pressed = false;
        });
      }
      await con.pauseCamera();
      if ((getStockItems.value?.isNotEmpty ?? false) &&
          (code.value?.isNotEmpty ?? false)) {
        Map<String, dynamic> body = item?.warehouseId == whID
            ? (item?.map ?? {'warehouseId': whID?.toString()})
            : {'warehouseId': whID?.toString()};
        body['createdBy'] = currentUser.value.userID.toString();
        body['qrCodeText'] = code.value;
        body['stockCheckStatus'] = '1';
        body['task_id'] = widget.task.taskID.toString();
        log(body);
        final val = await api.getCycleOrFullScanResult(body, hp);
        if (val.rp.success && mounted) {
          log('Hiv');
          // setState(() {
          item = getStockItems.value?.firstWhere((element) {
            log('----------------------');
            // log(widget.task.taskID);
            log(element.qrcodeId);
            log(val.qrCodeID);
            log('______________________');
            return element.qrcodeId == val.qrCodeID;
          }, orElse: () => GetStockItem.emptyItem);
          // });
          didUpdateWidget(widget);
          // tec.text = val.awaitedQty > -1 ? val.awaitedQty.toString() : '';
          perBox = val.perBox;
          // hp.onChange();
        } else if (await hp.showSimplePopup('OK', () {
          hp.goBack(result: true);
        },
            title: 'Setinhand',
            type: AlertType.cupertino,
            action: val.rp.message)) {
          log(getData(event.rawBytes ?? <int>[]));
        }
        // await hp.showSimplePopup('OK', () {
        //           hp.goBack(result: true);
        //         },
        //             title: 'Setinhand',
        //             type: AlertType.cupertino,
        //             action: rp.message) &&
        //         rp.success
        //     ? didUpdateWidget(widget)
        //     : log(hp.getData(event.rawBytes ?? <int>[]));
      }
      await con.resumeCamera();
    }

    void onDone() async {
      await con.stopCamera();
    }

    void onError(Object val, StackTrace trace) async {
      await con.stopCamera();
      log(val);
      log(trace);
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

  bool pick(GetStockItem element) {
    return element.stockCheckStatus == 1;
  }

  GetStockItem returnIfNone() {
    return GetStockItem.emptyItem;
  }

  Widget codeBuilder(BuildContext context, String? code, Widget? child) {
    final hpc = Helper.of(context);
    return Visibility(
        visible: !(code?.isEmpty ?? true),
        child: Padding(
            padding: pressed
                ? EdgeInsets.symmetric(vertical: hpc.height / 50)
                : EdgeInsets.only(bottom: hpc.height / 50),
            child: Text('Scanned Code is: ${code ?? ''}')));
  }

  // Widget textBuilder(BuildContext context, int val, Widget? child) {
  //   final hpt = Helper.of(context);
  //   return Container(
  //       height: hpt.height / 10,
  //       width: double.infinity,
  //       alignment: Alignment.center,
  //       color: const Color(0xFFe2e4ef),
  //       padding: EdgeInsets.all(hpt.radius / 81.92),
  //       child: Text(val > -1 ? val.toString() : '',
  //           style: const TextStyle(color: Color(0xFF404040), fontSize: 40)));
  // }

  Widget pageBuilder(
      BuildContext context, List<GetStockItem>? items, Widget? child) {
    List<bool> flags = <bool>[];
    bool flag = false;
    final hpr = Helper.of(context);

    void setFlag(GetStockItem item) {
      flags.add(item.stockCheckStatus == 2);
    }

    void afterComplete() {
      tec.text = '';
      box.value = -1;
      perBox = -1;
      code.value = null;
      getStockItems.value = null;
      if (hpr.mounted) {
        hpr.onChange();
        hpr.st?.setState(() {});
      }
      hpr.goBack();
    }

    void updateStock() {
      // box.value = -1;
      try {
        Loader.show(context);
        perBox = -1;
        if (hpr.mounted) {
          didUpdateWidget(widget);
          // hpr.onChange();
        }
        if (tec.text.isNotEmpty) {
          tec.text = '';
        }
        Loader.hide();
      } catch (e) {
        if (Loader.isShown) {
          Loader.hide();
        }
        sendAppLog(e);
      }
    }

    if (items?.isNotEmpty ?? false) {
      whID = items?.first.warehouseId;
      items?.forEach(setFlag);
      flag = !flags.contains(false);
    }
    log(whID);
    return WillPopScope(
        onWillPop: hp.backButtonOverride,
        child: SafeArea(
          child: Scaffold(
            bottomNavigationBar:
                BottomWidget(heightFactor: 30, widthFactor: hpr.width),
            key: _scaffoldKey,
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
                          MyAppBar(hpr, _scaffoldKey,
                              leading: IconButton(
                                  onPressed: () {
                                    tec.text = '';
                                    box.value = -1;
                                    perBox = -1;
                                    code.value = null;
                                    getStockItems.value = null;
                                    if (hpr.mounted) {
                                      setState(() {});
                                      hpr.onChange();
                                    }
                                    hpr.goBack();
                                  },
                                  icon: const Icon(Icons.arrow_back_ios_new))),
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
                                    child: items.isEmpty
                                        ? const Center(child: Text('No Data'))
                                        : Column(
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
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    vertical:
                                                                        hpr.height /
                                                                            80),
                                                            alignment:
                                                                Alignment
                                                                    .center,
                                                            child: const Text(
                                                                'Task',
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style: TextStyle(
                                                                    color: Color(
                                                                        0xFF404040),
                                                                    fontSize:
                                                                        17))),
                                                      ),
                                                      const SizedBox(
                                                        width: 3,
                                                      ),
                                                      Expanded(
                                                        flex: 4,
                                                        child: Container(
                                                            height: 50.0,
                                                            color: const Color(
                                                                0xFFe2e4ef),
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    vertical:
                                                                        hpr.height /
                                                                            80),
                                                            alignment: Alignment
                                                                .center,
                                                            child: const Text(
                                                                'Customer',
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style: TextStyle(
                                                                    color: Color(
                                                                        0xFF404040),
                                                                    fontSize:
                                                                        17))),
                                                      ),
                                                      const SizedBox(
                                                        width: 3,
                                                      ),
                                                      Expanded(
                                                        flex: 4,
                                                        child: Container(
                                                          height: 50.0,
                                                          color: const Color(
                                                              0xFFe2e4ef),
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  vertical:
                                                                      hpr.height /
                                                                          80),
                                                          alignment:
                                                              Alignment.center,
                                                          child: const Text(
                                                              'Date Started',
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: TextStyle(
                                                                  color: Color(
                                                                      0xFF404040),
                                                                  fontSize:
                                                                      17)),
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        width: 3,
                                                      ),
                                                      Expanded(
                                                        flex: 4,
                                                        child: Container(
                                                          height: 50.0,
                                                          color: const Color(
                                                              0xFFe2e4ef),
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  vertical:
                                                                      hpr.height /
                                                                          80),
                                                          alignment:
                                                              Alignment.center,
                                                          child: const Text(
                                                              'Location',
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: TextStyle(
                                                                  color: Color(
                                                                      0xFF404040),
                                                                  fontSize:
                                                                      17)),
                                                        ),
                                                      ),
                                                    ],
                                                  )),
                                              const SizedBox(
                                                  width: 3, height: 3),
                                              SizedBox(
                                                  width: double
                                                      .infinity, // <-- match_parent, // <-- match-parent
                                                  child: Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Expanded(
                                                          flex: 4,
                                                          child: Container(
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                              color: const Color(
                                                                  0xFFe2e4ef),
                                                              padding: EdgeInsets.symmetric(
                                                                  vertical:
                                                                      hpr.height /
                                                                          80),
                                                              child: Text(
                                                                  items.first
                                                                      .status,
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                  style: const TextStyle(
                                                                      color: Color(
                                                                          0xFF404040),
                                                                      fontSize:
                                                                          17)))),
                                                      const SizedBox(
                                                        width: 3,
                                                      ),
                                                      Expanded(
                                                          flex: 4,
                                                          child: Container(
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                              color: const Color(
                                                                  0xFFe2e4ef),
                                                              padding: EdgeInsets.symmetric(
                                                                  vertical:
                                                                      hpr.height /
                                                                          50),
                                                              child: Text(
                                                                  items.first
                                                                      .customerName,
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                  style: const TextStyle(
                                                                      color: Color(
                                                                          0xFF404040),
                                                                      fontSize:
                                                                          17)))),
                                                      const SizedBox(
                                                        width: 3,
                                                      ),
                                                      Expanded(
                                                        flex: 4,
                                                        child: Container(
                                                            color: const Color(
                                                                0xFFe2e4ef),
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    vertical: hpr
                                                                            .height /
                                                                        50),
                                                            child: Text(
                                                                items.first
                                                                    .createdAt,
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style: const TextStyle(
                                                                    color: Color(
                                                                        0xFF404040),
                                                                    fontSize:
                                                                        17))),
                                                      ),
                                                      const SizedBox(
                                                        width: 3,
                                                      ),
                                                      Expanded(
                                                          flex: 4,
                                                          child: Container(
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                              color: const Color(
                                                                  0xFFe2e4ef),
                                                              padding: EdgeInsets.symmetric(
                                                                  vertical:
                                                                      hpr.height /
                                                                          80),
                                                              child: Text(
                                                                  items.first
                                                                      .uniqueId,
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                  style: const TextStyle(
                                                                      color: Color(
                                                                          0xFF404040),
                                                                      fontSize:
                                                                          17)))),
                                                    ],
                                                  )),
                                              const SizedBox(
                                                width: 3,
                                                height: 10,
                                              ),
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
                                                                .all(6.4),
                                                        alignment:
                                                            Alignment.center,
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
                                                        height: 50.0,
                                                        color: const Color(
                                                            0xFFe2e4ef),
                                                        padding:
                                                            const EdgeInsets
                                                                .all(15),
                                                        alignment:
                                                            Alignment.center,
                                                        child: const Text(
                                                            'Box QTY',
                                                            style: TextStyle(
                                                                color: Color(
                                                                    0xFF404040),
                                                                fontSize: 17)),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(
                                                  width: 3, height: 2),
                                              Expanded(
                                                flex: 4,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    const Expanded(
                                                        flex: 4,
                                                        child:
                                                            CycleStockListWidget()),
                                                    const SizedBox(width: 3),
                                                    Expanded(
                                                        flex: 4,
                                                        child: Column(
                                                          children: [
                                                            Container(
                                                                height:
                                                                    hpr.height /
                                                                        10,
                                                                width: double
                                                                    .infinity,
                                                                alignment:
                                                                    Alignment
                                                                        .center,
                                                                color: const Color(
                                                                    0xFFe2e4ef),
                                                                padding: EdgeInsets.all(
                                                                    hpr.radius /
                                                                        81.92),
                                                                child: Text(
                                                                    perBox > -1
                                                                        ? perBox
                                                                            .toString()
                                                                        : '',
                                                                    style: const TextStyle(
                                                                        color: Color(
                                                                            0xFF404040),
                                                                        fontSize:
                                                                            40))),
                                                            const SizedBox(
                                                                height: 20),
                                                            Container(
                                                                height: 50.0,
                                                                color: const Color(
                                                                    0xFFe2e4ef),
                                                                padding:
                                                                    const EdgeInsets
                                                                            .all(
                                                                        15),
                                                                width: double
                                                                    .infinity,
                                                                alignment:
                                                                    Alignment
                                                                        .center,
                                                                child: const Text(
                                                                    'Update Quantity',
                                                                    style: TextStyle(
                                                                        color: Color(
                                                                            0xFF404040),
                                                                        fontSize:
                                                                            17))),
                                                            const SizedBox(
                                                                height: 3),
                                                            Container(
                                                                height: 100.0,
                                                                color: const Color(
                                                                    0xFFe2e4ef),
                                                                padding:
                                                                    const EdgeInsets.all(
                                                                        15),
                                                                width: double
                                                                    .infinity,
                                                                alignment:
                                                                    Alignment
                                                                        .center,
                                                                child:
                                                                    EditableText(
                                                                        textAlign: TextAlign
                                                                            .center,
                                                                        cursorHeight:
                                                                            hpr.height /
                                                                                25,
                                                                        cursorWidth: hpr.width /
                                                                            320,
                                                                        onEditingComplete:
                                                                            () {
                                                                          f1.unfocus();
                                                                          // if (hpr.f1.nextFocus()) {
                                                                          // }
                                                                        },
                                                                        onSelectionHandleTapped:
                                                                            () {
                                                                          f1.requestFocus();
                                                                        },
                                                                        inputFormatters: [
                                                                          FilteringTextInputFormatter(
                                                                              RegExp('[A-Za-z|\\.|\\,|\\;|\\:|\\"|\\\'|\\?|\\/|\\{|\\}|\\[|\\]]|\\~|\\`|\\!|\\@|\\#|\\\$|\\%|\\^|\\&|\\*|\\(|\\)|\\_|\\-|\\+|\\=|\\<|\\>|\\||\\ |\\£|\\¥|\\§]'),
                                                                              allow: false)
                                                                        ],
                                                                        keyboardType: TextInputType
                                                                            .phone,
                                                                        controller:
                                                                            tec,
                                                                        focusNode:
                                                                            f1,
                                                                        style: const TextStyle(
                                                                            color: Color(
                                                                                0xFF404040),
                                                                            fontSize:
                                                                                40),
                                                                        cursorColor:
                                                                            const Color(
                                                                                0xff2e61e9),
                                                                        backgroundCursorColor: hpr
                                                                            .theme
                                                                            .canvasColor))
                                                          ],
                                                        )),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ))),
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
                                                  vertical: hpr.height / 100),
                                              buttonColor:
                                                  hpr.theme.selectedRowColor,
                                              labelColor: hpr.theme
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
                                              height: hpr.height /
                                                  (hpr.screenLayout ==
                                                          Orientation.landscape
                                                      ? 2.56
                                                      : 4),
                                              width: hpr.screenLayout ==
                                                      Orientation.landscape
                                                  ? hpr.width / 2.56
                                                  : null,
                                              padding: const EdgeInsets.all(10),
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
                                                              cutOutWidth:
                                                                  hpr.width),
                                                      key: qrKey,
                                                      onQRViewCreated:
                                                          onQRViewCreated),
                                                  Positioned(
                                                      left: hpr.width /
                                                          (hpr.screenLayout ==
                                                                  Orientation
                                                                      .landscape
                                                              ? 6.25
                                                              : 6.4),
                                                      top: hpr.height /
                                                          (hpr.screenLayout ==
                                                                  Orientation
                                                                      .landscape
                                                              ? 4
                                                              : 6.4),
                                                      child:
                                                          CustomLabelledButton(
                                                              labelColor: hpr
                                                                  .theme
                                                                  .scaffoldBackgroundColor,
                                                              buttonColor: hpr
                                                                  .theme
                                                                  .errorColor,
                                                              label: 'Cancel',
                                                              onPressed: () {
                                                                if (mounted) {
                                                                  setState(() {
                                                                    pressed =
                                                                        false;
                                                                  });
                                                                }
                                                              },
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
                                  GestureDetector(
                                      child: Container(
                                          color: hpr.theme.selectedRowColor,
                                          padding: EdgeInsets.symmetric(
                                              vertical: hpr.height / 32,
                                              horizontal: hpr.width /
                                                  (hpr.screenLayout ==
                                                          Orientation.landscape
                                                      ? 7.7371252455336267181195264
                                                      : 9.671406556917033397649408)),
                                          child: Text(
                                              'TAP TO ${flag ? 'FINALIZE' : 'COMPLETE'}',
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16))),
                                      onTap: () async {
                                        try {
                                          if (item ==
                                                  null /* &&
                                              await hp.showSimplePopup('OK',
                                                  () {
                                                hp.goBack(result: true);
                                              },
                                                  title: 'Setinhand',
                                                  type: AlertType.cupertino,
                                                  action:
                                                      'Please scan a stock item')*/
                                              ) {
                                            log('object');
                                          } else if (flag) {
                                            Map<String, dynamic> body = {
                                              'status': '1',
                                              'type': 'cycle'
                                            };
                                            body['task_id'] =
                                                widget.task.taskID.toString();
                                            body['warehouse_id'] =
                                                (item?.warehouseId ?? whID)
                                                    .toString();
                                            Loader.show(context);
                                            final p = await hp.showPleaseWait();
                                            final val = await api
                                                .completeCycleOrFullStock(
                                                    body, hpr);
                                            Loader.hide();
                                            await hpr.showSimplePopup('OK', () {
                                                      hpr.goBack(result: true);
                                                    },
                                                        action: val.message,
                                                        title: 'Setinhand',
                                                        type: AlertType
                                                            .cupertino) &&
                                                    val.success &&
                                                    p
                                                ? afterComplete()
                                                : log('Bye');
                                          } else {
                                            Map<String, dynamic> map =
                                                item?.warehouseId == whID
                                                    ? (item?.map ??
                                                        {
                                                          'warehouseId':
                                                              whID?.toString()
                                                        })
                                                    : {
                                                        'warehouseId':
                                                            whID?.toString()
                                                      };
                                            map['createdBy'] = currentUser
                                                .value.userID
                                                .toString();
                                            map['qrCodeText'] = code.value;
                                            map['stockCheckStatus'] = '2';
                                            map['task_id'] =
                                                widget.task.taskID.toString();
                                            bool flag = true;
                                            if (tec.text.isNotEmpty) {
                                              flag = flag &&
                                                  await hpr.revealDialogBox([
                                                    'Yes',
                                                    'No'
                                                  ], [
                                                    () {
                                                      hpr.goBack(result: true);
                                                    },
                                                    () {
                                                      hpr.goBack(result: false);
                                                    }
                                                  ],
                                                      title: 'Setinhand',
                                                      action:
                                                          ' You have update the quantity of stock item (${item?.uniqueId}) to ${tec.text}. Is this correct?',
                                                      type:
                                                          AlertType.cupertino);
                                              map['updateQuantity'] = tec.text;
                                            }
                                            log(map);
                                            if (flag) {
                                              // Loader.show(context);
                                              hpr.showLoader();
                                              final val = await api
                                                  .getCycleOrFullScanResult(
                                                      map, hpr);
                                              Loader.hide();
                                              await hpr.showSimplePopup('OK',
                                                          () {
                                                        hp.goBack(result: true);
                                                      },
                                                          action:
                                                              val.rp.message,
                                                          title: 'Setinhand',
                                                          type: AlertType
                                                              .cupertino) &&
                                                      val.rp.success
                                                  ? updateStock()
                                                  : log('Bye');
                                            }
                                          }
                                        } catch (e) {
                                          if (Loader.isShown) {
                                            Loader.hide();
                                          }
                                          sendAppLog(e);
                                        }
                                      })
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
        ));
  }

  @override
  void didUpdateWidget(covariant CycleStockCheck oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
    api.fetchGetCycleStockItems(widget.task, hp);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    hp.getConnectStatus();
    api.fetchGetCycleStockItems(widget.task, hp);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<GetStockItem>?>(
        valueListenable: getStockItems,
        builder: pageBuilder,
        child: const LoaderWidget());
  }
}
