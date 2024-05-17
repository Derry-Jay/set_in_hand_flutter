import '../back_end/api.dart';
import '../helpers/helper.dart';
import '../widgets/collection.dart';
import '../widgets/my_app_bar.dart';
import '../widgets/logo_widget.dart';
import '../widgets/empty_widget.dart';
import '../widgets/custom_button.dart';
import '../models/warehouse_item.dart';
import 'package:flutter/material.dart';
import '../models/stockitemModel.dart';
import '../widgets/bottom_widget.dart';
import '../widgets/collection_row.dart';
import '../widgets/collection_cell.dart';
import '../widgets/chat_list_widget.dart';
import '../widgets/collection_border.dart';
import '../widgets/custom_labelled_button.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class WhatIsThis extends StatefulWidget {
  const WhatIsThis({Key? key}) : super(key: key);

  @override
  WhatIsThisState createState() => WhatIsThisState();
}

class WhatIsThisState extends State<WhatIsThis> {
  bool pressed = false;
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  Helper get hp => Helper.of(scaffoldKey.currentContext ?? context);

  void setScanMode() {
    if (mounted && !pressed) {
      setState(() {
        pressed = true;
      });
    }
  }

  void onQRViewCreated(QRViewController con) {
    void onData(Barcode event) async {
      await con.pauseCamera();
      if (mounted) {
        setState(() {
          pressed = false;
        });
      }
      log(event.code);
      if (!(event.code == null || event.code!.isEmpty)) {
        code.value = event.code;
        api.getWareHouses(event.code ?? '', hp);
      }
      // await con.resumeCamera();
    }

    void onDone() async {
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
    final cs =
        con.scannedDataStream.listen(onData, onError: onError, onDone: onDone);
    if (!scs.contains(cs)) {
      scs.add(cs);
    }
  }

  void customDispose() async {
    warehouseitems.value = <WarehouseItem>[];
    hp.notifyWarehouse();
    availableStocks.value = <StockItem>[];
    hp.onChange();
    if (css.isNotEmpty && css.remove(css.last)) {
      log('dispose');
    }
    qrKey.currentState?.dispose();
    if (scs.isNotEmpty) {
      await scs.last.cancel();
    }
  }

  Widget codeBuilder(BuildContext context, String? code, Widget? child) {
    return Visibility(
        visible: code != null && code.isNotEmpty,
        child: Text('Scanned Code is: ${code ?? ''}'));
  }

  Widget tableBuilder(
      BuildContext context, List<WarehouseItem> values, Widget? child) {
    try {
      final hpt = Helper.of(context);
      List<CollectionRow> rows = code.value == null ||
              (code.value ?? '').isEmpty ||
              values.isEmpty
          ? <CollectionRow>[
              CollectionRow(cells: [
                CollectionCell(Padding(
                    padding: EdgeInsets.symmetric(vertical: hpt.height / 50),
                    child: const Text('', textAlign: TextAlign.center))),
                CollectionCell(Padding(
                    padding: EdgeInsets.symmetric(vertical: hpt.height / 50),
                    child: const Text('', textAlign: TextAlign.center))),
                CollectionCell(Padding(
                    padding: EdgeInsets.symmetric(vertical: hpt.height / 50),
                    child: const Text('', textAlign: TextAlign.center))),
                CollectionCell(Padding(
                    padding: EdgeInsets.symmetric(vertical: hpt.height / 50),
                    child: const Text('', textAlign: TextAlign.center)))
              ], rowStyle: BoxDecoration(color: hpt.theme.canvasColor))
            ]
          : (((RegExp(' - ').hasMatch(code.value ?? '') &&
                      ' - '.allMatches(code.value ?? '').length > 2) ||
                  !RegExp('-').hasMatch(code.value ?? '') ||
                  (values.length == 1 &&
                      values.first.reason.isEmpty &&
                      values.first.details.isEmpty))
              ? <CollectionRow>[
                  CollectionRow(cells: [
                    CollectionCell(Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: hpt.height / 50),
                        child: const Text('Location',
                            textAlign: TextAlign.center))),
                    CollectionCell(Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: hpt.height / 50),
                        child: const Text('Stock Code',
                            textAlign: TextAlign.center))),
                    CollectionCell(Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: hpt.height / 50),
                        child:
                            const Text('Type', textAlign: TextAlign.center))),
                    CollectionCell(Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: hpt.height / 50),
                        child: const Text('Quantity',
                            textAlign: TextAlign.center)))
                  ], rowStyle: BoxDecoration(color: hpt.theme.canvasColor))
                ]
              : <CollectionRow>[
                  CollectionRow(cells: [
                    CollectionCell(Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: hpt.height / 50),
                        child:
                            const Text('MR ID', textAlign: TextAlign.center))),
                    CollectionCell(Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: hpt.height / 50),
                        child: const Text('Customer',
                            textAlign: TextAlign.center))),
                    CollectionCell(Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: hpt.height / 50),
                        child:
                            const Text('Reason', textAlign: TextAlign.center))),
                    CollectionCell(Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: hpt.height / 50),
                        child: const Text('Details',
                            textAlign: TextAlign.center))),
                    CollectionCell(Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: hpt.height / 50),
                        child:
                            const Text('MR Date', textAlign: TextAlign.center)))
                  ], rowStyle: BoxDecoration(color: hpt.theme.canvasColor))
                ]);
      if (values.isNotEmpty) {
        for (WarehouseItem value in values) {
          rows.add(((RegExp(' - ').hasMatch(code.value ?? '') &&
                      ' - '.allMatches(code.value ?? '').length > 2) ||
                  !RegExp('-').hasMatch(code.value ?? '') ||
                  (value.reason.isEmpty && value.details.isEmpty))
              ? CollectionRow(
                  cells: [
                      CollectionCell(Padding(
                          padding:
                              EdgeInsets.symmetric(vertical: hpt.height / 50),
                          child: Text(value.uniqueID,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: hpt.theme.scaffoldBackgroundColor)))),
                      CollectionCell(Padding(
                          padding:
                              EdgeInsets.symmetric(vertical: hpt.height / 50),
                          child: Text(value.stockItemID,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: hpt.theme.scaffoldBackgroundColor)))),
                      CollectionCell(Padding(
                          padding:
                              EdgeInsets.symmetric(vertical: hpt.height / 50),
                          child: Text(value.isPartBox ? 'Part' : 'Full',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: hpt.theme.scaffoldBackgroundColor)))),
                      CollectionCell(Padding(
                          padding:
                              EdgeInsets.symmetric(vertical: hpt.height / 50),
                          child: Text(value.countPerBox.toString(),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: hpt.theme.scaffoldBackgroundColor))))
                    ],
                  rowStyle:
                      BoxDecoration(color: hpt.theme.toggleableActiveColor))
              : CollectionRow(
                  cells: [
                      CollectionCell(Padding(
                          padding:
                              EdgeInsets.symmetric(vertical: hpt.height / 50),
                          child: Text(value.mrNo.toString(),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: hpt.theme.scaffoldBackgroundColor)))),
                      CollectionCell(Padding(
                          padding:
                              EdgeInsets.symmetric(vertical: hpt.height / 50),
                          child: Text(value.customerName,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: hpt.theme.scaffoldBackgroundColor)))),
                      CollectionCell(Padding(
                          padding:
                              EdgeInsets.symmetric(vertical: hpt.height / 50),
                          child: Text(value.reason,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: hpt.theme.scaffoldBackgroundColor)))),
                      CollectionCell(Padding(
                          padding:
                              EdgeInsets.symmetric(vertical: hpt.height / 50),
                          child: Text(value.details,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: hpt.theme.scaffoldBackgroundColor)))),
                      CollectionCell(Padding(
                          padding:
                              EdgeInsets.symmetric(vertical: hpt.height / 50),
                          child: Text(value.mrDate,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: hpt.theme.scaffoldBackgroundColor))))
                    ],
                  rowStyle:
                      BoxDecoration(color: hpt.theme.toggleableActiveColor)));
        }
      }
      return SingleChildScrollView(
          padding: EdgeInsets.symmetric(
              vertical: hpt.height / 50, horizontal: hpt.width / 50),
          physics: values.isEmpty
              ? const NeverScrollableScrollPhysics()
              : const AlwaysScrollableScrollPhysics(),
          child: Collection(
              rows: rows,
              tableBorder: CollectionBorder(
                  vi: BorderSide(color: hpt.theme.scaffoldBackgroundColor),
                  hi: BorderSide(color: hpt.theme.scaffoldBackgroundColor))));
    } on Exception catch (e) {
      sendAppLog(e);

      log(values);
      return const EmptyWidget();
    }
  }

  Widget pageBuilder(BuildContext context, Orientation screenLayout) {
    final hpp = Helper.of(context);
    log(screenLayout);
    log(screenLayout == hpp.screenLayout);
    log('Hi');
    return WillPopScope(
        onWillPop: hp.backButtonOverride,
        child: SafeArea(
          child: Scaffold(
              bottomNavigationBar:
                  BottomWidget(heightFactor: 30, widthFactor: hpp.width),
              key: scaffoldKey,
              endDrawer: const Drawer(child: ChatListWidget()),
              body: Container(
                  decoration: const BoxDecoration(
                      gradient: LinearGradient(
                          colors: [Colors.white, Color(0xffe8e8e8)],
                          stops: [0.58, 0.59])),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          MyAppBar(hpp, scaffoldKey,
                              leading: IconButton(
                                  onPressed: () {
                                    code.value = null;
                                    availableStocks.value = <StockItem>[];
                                    try {
                                      hpp.onChange();
                                      hpp.goBack();
                                    } catch (e) {
                                      sendAppLog(e);
                                      final hpl = Helper.of(
                                          scaffoldKey.currentContext ??
                                              context);
                                      hpl.onChange();
                                      hpl.goBack();
                                    }
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
                                child:
                                    ValueListenableBuilder<List<WarehouseItem>>(
                                        builder: tableBuilder,
                                        valueListenable: warehouseitems,
                                        child: const EmptyWidget())),
                            Flexible(
                                flex: 2,
                                child: Column(
                                  children: [
                                    SizedBox(
                                        width: double
                                            .infinity, // <-- match_parent, // <-- match-parent
                                        child: CustomButton(
                                            padding: EdgeInsets.symmetric(
                                                vertical: hpp.height / 100),
                                            buttonColor:
                                                hpp.theme.selectedRowColor,
                                            labelColor: hpp
                                                .theme.scaffoldBackgroundColor,
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
                                        ? Container(
                                            alignment: Alignment.topLeft,
                                            width: screenLayout ==
                                                    Orientation.landscape
                                                ? hpp.width / 2.56
                                                : null,
                                            padding:
                                                EdgeInsets.all(hpp.radius / 80),
                                            child: Stack(
                                              alignment: Alignment.bottomCenter,
                                              children: <Widget>[
                                                SizedBox(
                                                    height:
                                                        hpp.height /
                                                            (screenLayout ==
                                                                    Orientation
                                                                        .landscape
                                                                ? 2.56
                                                                : 4),
                                                    child: QRView(
                                                        overlay:
                                                            QrScannerOverlayShape(
                                                                cutOutHeight: hpp
                                                                        .height /
                                                                    1.6,
                                                                cutOutWidth:
                                                                    hpp.width),
                                                        key: qrKey,
                                                        onQRViewCreated:
                                                            onQRViewCreated)),
                                                Positioned(
                                                    left: hpp.width /
                                                        7.0368744177664,
                                                    top: hpp.height /
                                                        (screenLayout ==
                                                                Orientation
                                                                    .landscape
                                                            ? 4
                                                            : 6.5536),
                                                    child: CustomLabelledButton(
                                                        labelColor: hpp.theme
                                                            .scaffoldBackgroundColor,
                                                        buttonColor: hpp
                                                            .theme.errorColor,
                                                        label: 'Cancel',
                                                        onPressed: () {
                                                          if (mounted) {
                                                            setState(() {
                                                              pressed = false;
                                                            });
                                                          }
                                                        },
                                                        type: ButtonType.text))
                                              ],
                                            ),
                                          )
                                        : Container(
                                            decoration: const BoxDecoration(
                                                color: Colors.black),
                                            margin: EdgeInsets.symmetric(
                                                vertical: hpp.height / 40,
                                                horizontal: hpp.width / 25),
                                            padding: EdgeInsets.symmetric(
                                                vertical: hpp.height / 8)),
                                    ValueListenableBuilder<String?>(
                                        valueListenable: code,
                                        builder: codeBuilder)
                                  ],
                                )),
                          ],
                        ),
                      ),
                    ],
                  ))),
        ));
  }

  @override
  void initState() {
    super.initState();
    hp.getConnectStatus();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    customDispose();
    //stocks.value = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(builder: pageBuilder);
  }
}
