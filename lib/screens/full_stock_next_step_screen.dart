import '../back_end/api.dart';
import '../helpers/helper.dart';
import '../models/goods_check.dart';
import '../widgets/loader.dart';
import '../widgets/my_app_bar.dart';
import '../widgets/logo_widget.dart';
import '../models/route_argument.dart';
import '../widgets/custom_button.dart';
import '../widgets/bottom_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/full_stock_item.dart';
import '../widgets/circular_loader.dart';
import '../widgets/chat_list_widget.dart';
import '../screens/full_stock_screen.dart';
import '../widgets/custom_labelled_button.dart';
import '../widgets/full_stock_list_widget.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class FullStockNextStepScreen extends StatefulWidget {
  final RouteArgument rar;
  const FullStockNextStepScreen({super.key, required this.rar});

  static FullStockScreenState? of(BuildContext context) =>
      context.findAncestorStateOfType<FullStockScreenState>();

  @override
  FullStockNextStepScreenState createState() => FullStockNextStepScreenState();
}

class FullStockNextStepScreenState extends State<FullStockNextStepScreen> {
  bool pressed = false;
  FullStockItem? selected;
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  Helper get hp => Helper.of(context);
  FullStockScreenState? get fss => FullStockNextStepScreen.of(context);

  void setScanMode() {
    setState(() {
      pressed = !pressed;
    });
  }

  void customDispose() async {
    qrKey.currentState?.dispose();
    if (scs.isNotEmpty) {
      await scs.last.cancel();
    }
  }

  void onQRViewCreated(QRViewController con) {
    void onData(Barcode event) async {
      await con.pauseCamera();
      if (mounted) {
        code.value = event.code;
        setScanMode();
        hp.onChange();
      }
      final body = {
        'qrCodeText': code.value,
        'stockCheckStatus': '1',
        'task_id': widget.rar.id.toString(),
        'createdBy': currentUser.value.userID.toString(),
        'warehouseId': widget.rar.tag
      };
      final val = await api.getCycleOrFullScanResult(body, hp);
      if (val.rp.success && mounted) {
        log('addd');
        // setState(() {
        // });
        selected = items.value?.firstWhere(
            (element) => element.qrCodeID == val.qrCodeID,
            orElse: () => FullStockItem.emptyItem);
        didUpdateWidget(widget);
        perBox = val.perBox;
        log('editttt');
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
      //             action: val.rp.message,
      //             title: 'SetinHand',
      //             type: AlertType.cupertino) &&
      //         val.rp.success
      //     ? didUpdateWidget(widget)
      //     : log(val.rp.message);
      // await con.resumeCamera();
    }

    void onError(Object val, StackTrace trace) async {
      // await con.stopCamera();
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

  bool pick(GoodsCheck item) {
    return !parseBool(item.status.toString());
  }

  Widget textBuilder(BuildContext context, String? val, Widget? child) {
    final hpt = Helper.of(context);
    return Visibility(
        visible: !(val == null || val.isEmpty),
        child: Padding(
            padding: pressed
                ? EdgeInsets.symmetric(vertical: hpt.height / 50)
                : EdgeInsets.only(bottom: hpt.height / 50),
            child: Text('Scanned Code is: ${val ?? ''}')));
  }

  Widget gridBuilder(
      BuildContext context, List<FullStockItem>? items, Widget? child) {
    final hpg = Helper.of(context);
    return Container(
        padding: const EdgeInsets.only(top: 30, right: 10, left: 10),
        color: Colors.white,
        width: double.infinity,
        child: items == null
            ? Center(
                child: CircularLoader(
                    duration: const Duration(seconds: 10),
                    loaderType: LoaderType.chasingDots,
                    color: hpg.theme.primaryColor))
            : Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                      width: double
                          .infinity, // <-- match_parent, // <-- match-parent
                      child: Row(
                        children: [
                          Expanded(
                              flex: 4,
                              child: Container(
                                  color: const Color(0xFFe2e4ef),
                                  padding: EdgeInsets.symmetric(
                                      vertical: hpg.height / 64,
                                      horizontal: hpg.width / 100),
                                  alignment: Alignment.center,
                                  child: const Text('Task',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Color(0xFF404040),
                                          fontSize: 17)))),
                          const SizedBox(width: 3),
                          Expanded(
                              flex: 4,
                              child: Container(
                                  color: const Color(0xFFe2e4ef),
                                  padding: EdgeInsets.symmetric(
                                      vertical: hpg.height / 64,
                                      horizontal: hpg.width / 100),
                                  alignment: Alignment.center,
                                  child: const Text('Customer',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Color(0xFF404040),
                                          fontSize: 17)))),
                          const SizedBox(width: 3),
                          Expanded(
                            flex: 4,
                            child: Container(
                                color: const Color(0xFFe2e4ef),
                                padding: EdgeInsets.symmetric(
                                    vertical: hpg.height / 200,
                                    horizontal: hpg.width / 100),
                                alignment: Alignment.center,
                                child: const Text('Date Started',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Color(0xFF404040),
                                        fontSize: 17))),
                          ),
                          const SizedBox(
                            width: 3,
                          ),
                          Expanded(
                              flex: 4,
                              child: Container(
                                  color: const Color(0xFFe2e4ef),
                                  padding: EdgeInsets.symmetric(
                                      vertical: hpg.height / 64,
                                      horizontal: hpg.width / 100),
                                  alignment: Alignment.center,
                                  child: const Text('Location',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Color(0xFF404040),
                                          fontSize: 17))))
                        ],
                      )),
                  const SizedBox(width: 3, height: 3),
                  SizedBox(
                      width: double
                          .infinity, // <-- match_parent, // <-- match-parent
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                              flex: 4,
                              child: Container(
                                  color: const Color(0xFFe2e4ef),
                                  padding: EdgeInsets.symmetric(
                                      vertical: hpg.height / 200,
                                      horizontal: hpg.width / 100),
                                  alignment: Alignment.center,
                                  child: const Text('Full Stock Check',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Color(0xFF404040),
                                          fontSize: 17)))),
                          const SizedBox(width: 3),
                          Expanded(
                            flex: 4,
                            child: Container(
                                alignment: Alignment.center,
                                color: const Color(0xFFe2e4ef),
                                padding: items.isEmpty
                                    ? EdgeInsets.all(hp.radius / 81.92)
                                    : EdgeInsets.symmetric(
                                        vertical: hpg.height / 70.368744177664,
                                        horizontal: hpg.width / 100),
                                child: Text(
                                    items.isEmpty
                                        ? (widget.rar.word ?? '')
                                        : items.first.customerName,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                        color: Color(0xFF404040),
                                        fontSize: 17))),
                          ),
                          const SizedBox(
                            width: 3,
                          ),
                          Expanded(
                              flex: 4,
                              child: Container(
                                  color: const Color(0xFFe2e4ef),
                                  padding: items.isEmpty
                                      ? EdgeInsets.all(hpg.radius / 131.072)
                                      : EdgeInsets.symmetric(
                                          vertical: hpg.height / 200,
                                          horizontal: hpg.width / 100),
                                  alignment: Alignment.center,
                                  child: Text(
                                      items.isEmpty
                                          ? (widget.rar.stuff ?? '')
                                          : items.first.createdAt,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                          color: Color(0xFF404040),
                                          fontSize: 17)))),
                          const SizedBox(width: 3),
                          Expanded(
                              flex: 4,
                              child: Container(
                                  color: const Color(0xFFe2e4ef),
                                  padding: EdgeInsets.symmetric(
                                      vertical: hpg.height / 200,
                                      horizontal: hpg.width / 100),
                                  child: Text(
                                      items.isEmpty
                                          ? (widget.rar.content ?? '')
                                          : items.first.uniqueID,
                                      style: const TextStyle(
                                          color: Color(0xFF404040),
                                          fontSize: 17),
                                      textAlign: TextAlign.center)))
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
                              color: const Color(0xFFe2e4ef),
                              padding: const EdgeInsets.all(6.4),
                              alignment: Alignment.center,
                              child: const Text('Stock Items in this location',
                                  style: TextStyle(
                                      color: Color(0xFF404040), fontSize: 17),
                                  textAlign: TextAlign.center)),
                        ),
                        const SizedBox(
                          width: 3,
                        ),
                        Expanded(
                          flex: 4,
                          child: Container(
                              height: 50.0,
                              color: const Color(0xFFe2e4ef),
                              padding: const EdgeInsets.all(15),
                              alignment: Alignment.center,
                              child: const Text('Quantity Expected',
                                  style: TextStyle(
                                      color: Color(0xFF404040), fontSize: 17))),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 3, height: 2),
                  Expanded(
                    flex: 4,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Expanded(flex: 4, child: FullStockListWidget()),
                        const SizedBox(width: 3),
                        Expanded(
                            flex: 4,
                            child: items.isEmpty
                                ? Container(
                                    height: hpg.height / 10,
                                    width: double.infinity,
                                    alignment: Alignment.center,
                                    color: const Color(0xFFe2e4ef),
                                    padding: EdgeInsets.all(hpg.radius / 81.92),
                                    child: Text(
                                        perBox > -1 ? perBox.toString() : '',
                                        style: const TextStyle(
                                            color: Color(0xFF404040),
                                            fontSize: 40)))
                                : Column(
                                    children: [
                                      Container(
                                          height: hpg.height / 10,
                                          width: double.infinity,
                                          alignment: Alignment.center,
                                          color: const Color(0xFFe2e4ef),
                                          padding: EdgeInsets.all(
                                              hpg.radius / 81.92),
                                          child: Text(
                                              perBox > -1
                                                  ? perBox.toString()
                                                  : '',
                                              style: const TextStyle(
                                                  color: Color(0xFF404040),
                                                  fontSize: 40))),
                                      const SizedBox(height: 20),
                                      Container(
                                          height: 50.0,
                                          color: const Color(0xFFe2e4ef),
                                          padding: const EdgeInsets.all(15),
                                          width: double.infinity,
                                          alignment: Alignment.center,
                                          child: const Text('Update Quantity',
                                              style: TextStyle(
                                                  color: Color(0xFF404040),
                                                  fontSize: 17))),
                                      const SizedBox(height: 3),
                                      Container(
                                          height: 100.0,
                                          color: const Color(0xFFe2e4ef),
                                          padding: const EdgeInsets.all(15),
                                          width: double.infinity,
                                          alignment: Alignment.center,
                                          child: EditableText(
                                              textAlign: TextAlign.center,
                                              cursorHeight: hp.height / 25,
                                              cursorWidth: hp.width / 320,
                                              onEditingComplete: () {
                                                try {
                                                  FocusManager
                                                      .instance.primaryFocus
                                                      ?.unfocus();
                                                } catch (e) {
                                                  sendAppLog(e);
                                                }
                                              },
                                              onSelectionHandleTapped: () {
                                                f1.requestFocus();
                                              },
                                              inputFormatters: [
                                                FilteringTextInputFormatter(
                                                    RegExp(
                                                        '[A-Za-z|\\.|\\,|\\;|\\:|\\"|\\\'|\\?|\\/|\\{|\\}|\\[|\\]]|\\~|\\`|\\!|\\@|\\#|\\\$|\\%|\\^|\\&|\\*|\\(|\\)|\\_|\\-|\\+|\\=|\\<|\\>|\\||\\ |\\£|\\¥|\\§]'),
                                                    allow: false)
                                              ],
                                              keyboardType:
                                                  TextInputType.number,
                                              controller: tec,
                                              focusNode: f1,
                                              style: const TextStyle(
                                                  color: Color(0xFF404040),
                                                  fontSize: 40),
                                              cursorColor:
                                                  const Color(0xff2e61e9),
                                              backgroundCursorColor:
                                                  hp.theme.canvasColor))
                                    ],
                                  )),
                      ],
                    ),
                  ),
                ],
              ));
  }

  Widget buttonBuilder(
      BuildContext context, List<FullStockItem>? items, Widget? child) {
    List<bool> flags = <bool>[];
    bool flag = false;
    final hpb = Helper.of(context);
    log(((lows.value ?? <GoodsCheck>[]) + (highs.value ?? <GoodsCheck>[])));

    void setFlag(FullStockItem item) {
      flags.add(item.stockCheckStatus == 2);
    }

    void afterUpdate() {
      try {
        perBox = -1;
        if (hpb.mounted) {
          didUpdateWidget(widget);
          // hpb.onChange();
        }
        if (tec.text.isNotEmpty) {
          tec.text = '';
        }
      } catch (e) {
        sendAppLog(e);
      }
    }

    void afterFinish() {
      code.value = null;
      perBox = -1;
      hpb.onChange();
      ((lows.value ?? <GoodsCheck>[]) + (highs.value ?? <GoodsCheck>[]))
              .where(pick)
              .isEmpty
          ? hpb.goBackForeverTo('/dashboard')
          : hpb.goBack();
    }

    if (items?.isNotEmpty ?? false) {
      items?.forEach(setFlag);
      flag = !flags.contains(false);
    }

    return GestureDetector(
        child: Container(
            color: hpb.theme.selectedRowColor,
            padding: EdgeInsets.symmetric(
                vertical: hpb.height / 32, horizontal: hpb.width / 10),
            child: Text(
                (items?.isEmpty ?? true)
                    ? 'CONFIRM ZERO STOCK'
                    : 'TAP TO ${flag ? 'FINALIZE' : 'COMPLETE'}',
                style: const TextStyle(color: Colors.white, fontSize: 16))),
        onTap: () async {
          try {
            if ((items?.isEmpty ?? true) &&
                await hp.revealDialogBox([
                  'Yes',
                  'No'
                ], [
                  () {
                    hpb.goBack(result: true);
                  },
                  () {
                    hpb.goBack(result: false);
                  }
                ],
                    title: 'Setinhand',
                    action:
                        'You are confirming that the location ${widget.rar.content ?? ''} does not contain stock at this time. Is this correct?',
                    type: AlertType.cupertino)) {
              final body = {
                'task_id': widget.rar.id.toString(),
                'type': 'full',
                'warehouse_id': widget.rar.tag,
                'status': '1'
              };
              Loader.show(context);
              // final q = await hpb.showPleaseWait();
              final val = await api.completeCycleOrFullStock(body, hpb);
              Loader.hide();
              await hpb.showSimplePopup('OK', () {
                        hpb.goBack(result: true);
                      },
                          action: val.message,
                          title: 'SetinHand',
                          type: AlertType.cupertino) &&
                      val.success
                  ? afterFinish()
                  : log('Bye');
            } else if (flag) {
              final map = {
                'task_id': widget.rar.id.toString(),
                'type': 'full',
                'warehouse_id': widget.rar.tag,
                'status': '1'
              };
              Loader.show(context);
              final rp = await api.completeCycleOrFullStock(map, hpb);
              Loader.hide();
              await hpb.showSimplePopup('OK', () {
                        hp.goBack(result: true);
                      },
                          action: rp.message,
                          title: 'SetinHand',
                          type: AlertType.cupertino) &&
                      rp.success
                  ? afterFinish()
                  : log(code);
            } else if ((code.value?.isNotEmpty ?? false)) {
              Map<String, dynamic> map = {
                'qrCodeText': code.value,
                'stockCheckStatus': '2',
                'task_id': widget.rar.id.toString(),
                'createdBy': currentUser.value.userID.toString(),
                'warehouseId': widget.rar.tag
              };
              bool flag = true;
              if (tec.text.isNotEmpty) {
                flag = flag &&
                    await hpb.revealDialogBox([
                      'Yes',
                      'No'
                    ], [
                      () {
                        hpb.goBack(result: true);
                      },
                      () {
                        hpb.goBack(result: false);
                      }
                    ],
                        title: 'Setinhand',
                        action:
                            ' You have update the quantity of stock item (${selected?.stockItemID}) to ${tec.text}. Is this correct?',
                        type: AlertType.cupertino);
                map['updateQuantity'] = tec.text;
              }
              log(map);
              if (flag) {
                hpb.showLoader();
                final val = await api.getCycleOrFullScanResult(map, hpb);
                Loader.hide();
                await hpb.showSimplePopup('OK', () {
                          hpb.goBack(result: true);
                        },
                            action: val.rp.message,
                            title: 'Setinhand',
                            type: AlertType.cupertino) &&
                        val.rp.success
                    ? afterUpdate()
                    : log('inga dhaan');
              } else {
                log('anga dhaan');
              }
            } else if (await hpb.showSimplePopup('OK', () {
              hpb.goBack(result: true);
            },
                title: 'Setinhand',
                type: AlertType.cupertino,
                action: 'Please scan a code')) {}
          } catch (e) {
            if (Loader.isShown) {
              Loader.hide();
            }
            sendAppLog(e);
          }
        });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    api.getFullStockItems(
        int.tryParse(widget.rar.tag ?? '-1') ?? -1, widget.rar.id ?? -1, hp);
  }

  @override
  void didUpdateWidget(covariant FullStockNextStepScreen oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
    api.getFullStockItems(
        int.tryParse(widget.rar.tag ?? '-1') ?? -1, widget.rar.id ?? -1, hp);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    customDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    log(widget.rar.tag);
    log(widget.rar.id);
    return WillPopScope(
        onWillPop: hp.backButtonOverride,
        child: SafeArea(
          child: Scaffold(
            bottomNavigationBar:
                BottomWidget(heightFactor: 30, widthFactor: hp.width),
            key: scaffoldKey,
            endDrawer: const Drawer(child: ChatListWidget()),
            backgroundColor: hp.theme.cardColor,
            body: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    MyAppBar(hp, scaffoldKey,
                        leading: IconButton(
                            onPressed: () {
                              code.value = null;
                              perBox = -1;
                              hp.onChange();
                              hp.goBack();
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
                          child: ValueListenableBuilder<List<FullStockItem>?>(
                              valueListenable: items, builder: gridBuilder)),
                      Flexible(
                        flex: 2,
                        child: Column(
                          children: [
                            SizedBox(
                                width: double
                                    .infinity, // <-- match_parent, // <-- match-parent
                                child: CustomButton(
                                    padding: EdgeInsets.symmetric(
                                        vertical: hp.height / 100),
                                    buttonColor: hp.theme.selectedRowColor,
                                    labelColor:
                                        hp.theme.scaffoldBackgroundColor,
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
                                                  color: Colors.white))
                                        ]))),
                            pressed
                                ? Visibility(
                                    visible: pressed,
                                    child: Container(
                                        alignment: Alignment.topLeft,
                                        height: hp.height / 4,
                                        padding: const EdgeInsets.all(10),
                                        child: Stack(
                                          alignment: Alignment.bottomCenter,
                                          children: <Widget>[
                                            QRView(
                                                overlay: QrScannerOverlayShape(
                                                    cutOutHeight: hp.height / 2,
                                                    cutOutWidth: hp.width),
                                                key: qrKey,
                                                onQRViewCreated:
                                                    onQRViewCreated),
                                            Positioned(
                                                left: hp.width / 6.4,
                                                top: hp.height / 6.4,
                                                child: CustomLabelledButton(
                                                    labelColor: hp.theme
                                                        .scaffoldBackgroundColor,
                                                    buttonColor:
                                                        hp.theme.errorColor,
                                                    label: 'Cancel',
                                                    onPressed: setScanMode,
                                                    type: ButtonType.text)),
                                          ],
                                        )))
                                : Container(
                                    decoration: const BoxDecoration(
                                        color: Colors.black),
                                    margin: EdgeInsets.symmetric(
                                        vertical: hp.height / 40,
                                        horizontal: hp.width / 25),
                                    padding: EdgeInsets.symmetric(
                                        vertical: hp.height / 8)),
                            ValueListenableBuilder<String?>(
                                valueListenable: code, builder: textBuilder),
                            ValueListenableBuilder<List<FullStockItem>?>(
                                valueListenable: items, builder: buttonBuilder)
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
}
