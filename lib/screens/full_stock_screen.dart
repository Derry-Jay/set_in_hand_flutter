import '../models/task.dart';
import '../back_end/api.dart';
import '../helpers/helper.dart';
import '../widgets/collection.dart';
import '../models/goods_check.dart';
import '../widgets/my_app_bar.dart';
import '../widgets/logo_widget.dart';
import '../widgets/empty_widget.dart';
import '../widgets/loader_widget.dart';
import '../widgets/bottom_widget.dart';
import '../widgets/custom_button.dart';
import '../models/route_argument.dart';
import 'package:flutter/material.dart';
import '../widgets/collection_row.dart';
import '../widgets/collection_cell.dart';
import '../widgets/chat_list_widget.dart';
import '../widgets/collection_border.dart';
import '../widgets/custom_labelled_button.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:multi_value_listenable_builder/multi_value_listenable_builder.dart';

class FullStockScreen extends StatefulWidget {
  final Task task;
  const FullStockScreen({Key? key, required this.task}) : super(key: key);

  @override
  FullStockScreenState createState() => FullStockScreenState();
}

class FullStockScreenState extends State<FullStockScreen> {
  bool scanMode = false;
  Helper get hp => Helper.of(qrKey.currentContext ?? context);
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void setScanMode() {
    setState(setScanValue);
  }

  void setScanValue() {
    scanMode = !scanMode;
  }

  void onQRViewCreated(QRViewController con) async {
    void onData(Barcode event) async {
      await con.pauseCamera();
      log(event.code);
      code.value = event.code;
      if (mounted) {
        hp.onChange();
        setState(() {
          scanMode = false;
        });
      }
      final rp = await api.getFullStockScanResult(
          code.value ?? '', widget.task.taskID);
      if (rp.reply.success &&
          (mounted || (qrKey.currentState?.mounted ?? false))) {
        code.value = null;
        hp.onChange();
        didUpdateWidget(widget);
        qrKey.currentState?.dispose();
        final ts =
            ((lows.value ?? <GoodsCheck>[]) + (highs.value ?? <GoodsCheck>[]))
                .firstWhere((element) => element.task.location == event.code,
                    orElse: () => GoodsCheck.emptyGood)
                .task;
        hp.goTo('/fullStockItems',
            args: RouteArgument(
                content: ts.location,
                stuff: ts.lapsedTime,
                word: ts.customerName,
                id: widget.task.taskID,
                tag: rp.data.toString()), vcb: () {
          didUpdateWidget(widget);
        });
      } else if (await hp.showSimplePopup('OK', () {
        hp.goBack(result: true);
      },
          action: rp.reply.message,
          title: 'SetinHand',
          type: AlertType.cupertino)) {
        log(event.format);
      }
      // await con.resumeCamera();
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

  void customDispose() async {
    qrKey.currentState?.dispose();
    if (scs.isNotEmpty && css.isNotEmpty && css.remove(css.last)) {
      await scs.last.cancel();
      log(scs.remove(scs.last) ? 'dkc' : 'sbp');
    }
  }

  Widget codeBuilder(BuildContext context, String? code, Widget? child) {
    final hpc = Helper.of(context);
    return Visibility(
        visible: code?.isNotEmpty ?? false,
        child: Container(
            color: Colors.white,
            margin: EdgeInsets.only(top: hpc.height / 100),
            padding: EdgeInsets.symmetric(
                horizontal: hpc.width / 100, vertical: hpc.height / 200),
            child: Text('Scanned Code is: ${code ?? ''}')));
  }

  Widget pageBuilder(
      BuildContext context, List<dynamic> values, Widget? child) {
    final hpr = Helper.of(context);
    final lowList = values.first == null
        ? <GoodsCheck>[]
        : List<GoodsCheck>.from(values.first);
    final highList = values.last == null
        ? <GoodsCheck>[]
        : List<GoodsCheck>.from(values.last);
    final list = lowList.isEmpty
        ? (highList.isEmpty ? <GoodsCheck>[] : highList)
        : lowList;
    final ct = max(lowList.length, highList.length).toInt();
    List<CollectionRow> dataRows = <CollectionRow>[];
    log(list);
    if (list.isNotEmpty) {
      for (int i = 0; i < ct; i++) {
        final l = i >= lowList.length ? GoodsCheck.emptyGood : lowList[i];
        final h = i >= highList.length ? GoodsCheck.emptyGood : highList[i];
        dataRows.add(CollectionRow(
            cells: [
              CollectionCell(Padding(
                  padding: EdgeInsets.symmetric(vertical: hpr.height / 50),
                  child: l.isEmpty
                      ? const EmptyWidget()
                      : Text(l.task.location,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: hpr.theme.scaffoldBackgroundColor)))),
              CollectionCell(Padding(
                  padding: EdgeInsets.symmetric(vertical: hpr.height / 50),
                  child: h.isEmpty
                      ? const EmptyWidget()
                      : Text(h.task.location,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: hpr.theme.scaffoldBackgroundColor))))
            ],
            rowStyle: BoxDecoration(
                gradient: l.status == h.status
                    ? null
                    : LinearGradient(colors: <Color>[
                        l.status == 2
                            ? hpr.theme.hintColor
                            : (l.status == 1
                                ? hpr.theme.splashColor
                                : (l.status == 0
                                    ? hpr.theme.toggleableActiveColor
                                    : hpr.theme.scaffoldBackgroundColor))
                        ,
                        h.status == 2
                            ? hpr.theme.hintColor
                            : (h.status == 1
                                ? hpr.theme.splashColor
                                : (h.status == 0
                                    ? hpr.theme.toggleableActiveColor
                                    : hpr.theme.scaffoldBackgroundColor))
                      ], stops: const [
                        0.5,
                        0.5
                      ]),
                color: l.status == h.status
                    ? (l.status == 2 && h.status == 2
                        ? hpr.theme.hintColor
                        : (l.status == 0 && h.status == 0
                            ? hpr.theme.toggleableActiveColor
                            : (l.status == 1 && h.status == 1
                                ? hp.theme.splashColor
                                : null)))
                    : null)));
      }
    }
    return WillPopScope(
        onWillPop: hp.backButtonOverride,
        child: SafeArea(
          child: Scaffold(
            bottomNavigationBar:
                BottomWidget(heightFactor: 30, widthFactor: hpr.width),
            key: _scaffoldKey,
            endDrawer: const Drawer(child: ChatListWidget()),
            backgroundColor: hpr.theme.cardColor,
            body: values.contains(null) || values.isEmpty
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
                                    code.value = null;
                                    lows.value = null;
                                    highs.value = null;
                                    hpr.onChange();
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
                                child: Column(
                                  children: [
                                    Container(
                                        padding: const EdgeInsets.only(
                                            top: 30, right: 10, left: 10),
                                        color: Colors.white,
                                        width: double.infinity,
                                        height: hpr.height / 5.12,
                                        child: list.isEmpty
                                            ? const Center(
                                                child: Text('No Data'))
                                            : Collection(
                                                rows: [
                                                    CollectionRow(
                                                        cells: [
                                                          CollectionCell(Padding(
                                                              padding: EdgeInsets
                                                                  .symmetric(
                                                                      vertical:
                                                                          hpr.height /
                                                                              50),
                                                              child: const Text(
                                                                  'Task',
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center))),
                                                          CollectionCell(Padding(
                                                              padding: EdgeInsets
                                                                  .symmetric(
                                                                      vertical:
                                                                          hpr.height /
                                                                              50),
                                                              child: const Text(
                                                                  'Customer',
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center))),
                                                          CollectionCell(Padding(
                                                              padding: EdgeInsets
                                                                  .symmetric(
                                                                      vertical:
                                                                          hpr.height /
                                                                              50),
                                                              child: const Text(
                                                                  'Date Started',
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center)))
                                                        ],
                                                        rowStyle: BoxDecoration(
                                                            color: hpr.theme
                                                                .canvasColor)),
                                                    CollectionRow(
                                                        rowStyle: BoxDecoration(
                                                            color: hpr.theme
                                                                .hoverColor),
                                                        cells: [
                                                          CollectionCell(Padding(
                                                              padding: EdgeInsets
                                                                  .symmetric(
                                                                      vertical:
                                                                          hpr.height /
                                                                              50),
                                                              child: const Text(
                                                                  'Full Stock Check',
                                                                  softWrap:
                                                                      true,
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center))),
                                                          CollectionCell(Padding(
                                                              padding: EdgeInsets
                                                                  .symmetric(
                                                                      vertical:
                                                                          hpr.height /
                                                                              50),
                                                              child: Text(
                                                                  list
                                                                      .first
                                                                      .task
                                                                      .customerName,
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center))),
                                                          CollectionCell(Padding(
                                                              padding: EdgeInsets
                                                                  .symmetric(
                                                                      vertical:
                                                                          hpr.height /
                                                                              50),
                                                              child: Text(
                                                                  list
                                                                      .first
                                                                      .task
                                                                      .lapsedTime,
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center)))
                                                        ])
                                                  ],
                                                tableBorder: CollectionBorder(
                                                    hi: BorderSide(
                                                        width: hpr.width / 250,
                                                        color: Colors.white),
                                                    vi: BorderSide(
                                                        width: hpr.height / 400,
                                                        color: Colors.white)))),
                                    Expanded(
                                        flex: 10,
                                        child: Container(
                                            color: Colors.white,
                                            padding: EdgeInsets.symmetric(
                                                horizontal: hpr.width / 100),
                                            child: Collection(
                                                tableBorder: CollectionBorder(
                                                    vi: BorderSide(
                                                        color: hpr.theme
                                                            .scaffoldBackgroundColor)),
                                                rows: [
                                                  CollectionRow(
                                                      cells: [
                                                        CollectionCell(Padding(
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    vertical:
                                                                        hpr.height /
                                                                            50),
                                                            child: const Text(
                                                                'Low Pallet Locations',
                                                                textAlign:
                                                                    TextAlign
                                                                        .center))),
                                                        CollectionCell(Padding(
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    vertical:
                                                                        hpr.height /
                                                                            50),
                                                            child: const Text(
                                                                'High Pallet Locations',
                                                                textAlign:
                                                                    TextAlign
                                                                        .center)))
                                                      ],
                                                      rowStyle: BoxDecoration(
                                                          color: hpr.theme
                                                              .canvasColor))
                                                ]))),
                                    Container(
                                        color: Colors.white,
                                        width: double.infinity,
                                        height: hpr.height /
                                            (hpr.dimensions.orientation ==
                                                    Orientation.landscape
                                                ? 1.6384
                                                : 1.6),
                                        child: SingleChildScrollView(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: hpr.width / 100),
                                            child: Collection(
                                                rows: dataRows,
                                                tableBorder: CollectionBorder(
                                                    tb: BorderSide(
                                                        color: hpr.theme
                                                            .scaffoldBackgroundColor),
                                                    vi: BorderSide(
                                                        color: hpr.theme
                                                            .scaffoldBackgroundColor),
                                                    hi: BorderSide(
                                                        color: hpr.theme.scaffoldBackgroundColor)))))
                                  ],
                                )),
                            Flexible(
                              flex: 2,
                              child: Column(
                                  // ,
                                  children: [
                                    Visibility(
                                        visible: !scanMode,
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
                                                        MainAxisAlignment
                                                            .center,
                                                    children: const [
                                                      Icon(
                                                          Icons.qr_code_scanner,
                                                          color: Colors.white),
                                                      Text('Scan Code',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white))
                                                    ])))),
                                    scanMode
                                        ? Visibility(
                                            visible: scanMode,
                                            child: Container(
                                                alignment: Alignment.topLeft,
                                                height: hpr.height /
                                                    (hpr.screenLayout == Orientation.landscape
                                                        ? 2.56
                                                        : 4),
                                                width: hpr.screenLayout ==
                                                        Orientation.landscape
                                                    ? hpr.width / 2.56
                                                    : null,
                                                padding: EdgeInsets.all(
                                                    hpr.radius /
                                                        (hpr.screenLayout ==
                                                                Orientation
                                                                    .landscape
                                                            ? 200
                                                            : 100)),
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
                                        builder: codeBuilder,
                                        valueListenable: code)
                                  ]),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
          ),
        ));
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    hp.getConnectStatus();
    api.getFullStockCheck(widget.task, hp);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    customDispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant FullStockScreen oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
    hp.getConnectStatus();
    api.getFullStockCheck(widget.task, hp);
  }

  @override
  Widget build(BuildContext context) {
    return MultiValueListenableBuilder(
        valueListenables: [lows, highs],
        builder: pageBuilder,
        child: const LoaderWidget());
  }
}
