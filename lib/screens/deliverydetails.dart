import 'dart:io';
import '../back_end/api.dart';
import 'package:http/http.dart';
import '../widgets/loader.dart';
import '../helpers/helper.dart';
import '../widgets/my_dialog.dart';
import '../widgets/my_app_bar.dart';
import '../widgets/logo_widget.dart';
import '../widgets/customdialog.dart';
import '../widgets/empty_widget.dart';
import '../widgets/loader_widget.dart';
import '../widgets/bottom_widget.dart';
import '../widgets/custom_button.dart';
import '../models/delivery_stock.dart';
import '../models/route_argument.dart';
import 'package:flutter/material.dart';
import '../models/updateqrcodemodel.dart';
import '../widgets/chat_list_widget.dart';
import '../widgets/custom_labelled_button.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class DeliveryDetails extends StatefulWidget {
  final RouteArgument rar;

  const DeliveryDetails({Key? key, required this.rar}) : super(key: key);

  @override
  DeliveryDetailsState createState() => DeliveryDetailsState();
}

class DeliveryDetailsState extends State<DeliveryDetails> {
  int scannedCount = 0;
  bool scanMode = false, pressed = false, flag = false;
  String? code, location;
  String customerName = '', deliveryID = '', expected = '', actual = '';
  DeliveryStockModel? getData;
  DeliveryStockData? selected;
  UpdateQrcodemodel? updateqr;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Helper get hp {
    try {
      return Helper.of(qrKey.currentContext ?? context);
    } catch (e) {
      sendAppLog(e);

      return Helper.of(context);
    }
  }

  void carryOn(bool val) {
    flag = !val;
    if (selected != null) {
      selected = null;
    }
  }

  void setScanMode() async {
    if (selected != null && mounted) {
      setState(setScanValue);
    } else if (await hp.showSimplePopup('OK', () {
      hp.goBack(result: true);
    },
        title: 'Setinhand',
        type: AlertType.cupertino,
        action: 'Please scan any stock item')) {
      log(scanMode);
    }
  }

  void onQRViewCreated(QRViewController con) async {
    bool scanned = false;

    void onData(Barcode event) async {
      if (!scanned) {
        scanned = true;
        await con.pauseCamera();
        if (event.code?.isNotEmpty ?? false) {
          log(event.code);
          setState(() {
            code = event.code;
            scanMode = false;
          });
          qrCodeScanValue(event.code ?? '', con);
        } else if (await hp.showSimplePopup('OK', () {
          hp.goBack(result: true);
        },
            title: 'Setinhand',
            type: AlertType.cupertino,
            action: 'Qr code is empty. please scan proper code')) {
          await con.resumeCamera();
        }
      } else {
        log('how many times');
      }
    }

    void onError(Object val, StackTrace trace) async {
      // await con.stopCamera();
      log(val);
      log(trace);
      // return trace.toString();
    }

    if (!css.contains(con.scannedDataStream)) {
      css.add(con.scannedDataStream);
    }
    final cs = con.scannedDataStream.listen(onData, onError: onError);
    if (!scs.contains(cs)) {
      scs.add(cs);
    }
  }

  void setScanValue() {
    scanMode = !scanMode;
    if (!scanMode) {
      code = '';
    }
  }

  void qrCodeScanValue(String qrText, QRViewController controller) async {
    try {
      log(qrText);
      log(selected);
      if (qrText.isNotEmpty && mounted) {
        updateqr = await api.updateQRCode(qrText, selected?.deliveryId ?? 0,
            selected?.deliveryqrcodeId ?? 0, hp);
        await controller.resumeCamera();
        setState(() {
          pressed = false;
          if (updateqr?.success ?? false) {
            flag = true;
          } else {
            selected = null;
          }
        });
        final p = await hp.showSimplePopup('OK', () {
          hp.goBack(result: updateqr?.success);
        },
            type: AlertType.cupertino,
            title: 'Setinhand',
            action: updateqr?.data ?? '');
        didUpdateWidget(widget);
        carryOn(p);
      }
    } on SocketException {
      log('No Internet connection 😑');
      final p = await hp.showSimplePopup('OK', () {
        hp.goBack(result: true);
      },
          title: 'Setinhand',
          type: AlertType.cupertino,
          action: 'No Internet connection 😑');
      if (p) {
        hp.goBack();
      }
    } on HttpException {
      log("Couldn't find the post 😱");
      final p = await hp.showSimplePopup('OK', () {
        hp.goBack(result: true);
      },
          title: 'Setinhand',
          type: AlertType.cupertino,
          action: 'Service not found. Please try later.....');
      if (p) {
        hp.goBack();
      }
    } on FormatException {
      log('Bad response format 👎');
      final p = await hp.showSimplePopup('OK', () {
        hp.goBack(result: true);
      },
          title: 'Setinhand',
          type: AlertType.cupertino,
          action: 'Server error. Please try later.....');
      if (p) {
        hp.goBack();
      }
    } on ClientException {
      log('Hi');
      final p = await hp.showSimplePopup('OK', () {
        hp.goBack(result: true);
      },
          title: 'Setinhand',
          type: AlertType.cupertino,
          action: 'Unknown error. Please try later.....');
      if (p) {
        hp.goBack();
      }
    }
    //  catch (e) {
    //  sendAppLog(e);
    //   final error = e.toString();
    //   final p = await hp.showSimplePopup('OK', () {
    //     hp.goBack(result: true);
    //   },
    //       title: 'Setinhand',
    //       type: AlertType.cupertino,
    //       action: error.contains('Connection timed out')
    //           ? 'Check Your Connection'
    //           : ((error.contains(
    //                       'Connection closed before full header was received')
    //                   ? 'Server'
    //                   : 'Unknown') +
    //               ' error. Please try later.....'));
    // }
  }

  void setData() async {
    try {
      getData = await api.getDeliveryStock(widget.rar.id ?? -1);
      if (mounted) {
        scannedCount = (((getData?.totalbox ?? 0) +
                (getData?.data.where(test).length ?? 0)) -
            ((getData?.data.length ?? 0)));
        setState(() {
          deliveryID =
              '${widget.rar.id}-${getData?.date ?? ''}\n${getData?.note ?? ''}';
          customerName = '${widget.rar.content ?? ''}\n${getData?.job ?? ''}';
          expected = getData?.totalbox.toString() ?? '';
          actual = scannedCount.toString();
        });
        log(scannedCount);
        if (getData?.data.isNotEmpty ?? false) {
          canCompletePartially.value =
              getData?.data.where(test).isNotEmpty ?? false;
          log(((((getData?.data.where(test).length ?? -1) ==
                          (getData?.data.length ?? 0)) &&
                      await hp.showSimplePopup('OK', () {
                        hp.goBack(result: true);
                      },
                          title: 'Setinhand',
                          type: AlertType.cupertino,
                          action: 'Delivery yet to Complete')) ||
                  (getData?.data.where(pick).isEmpty ?? false))
              ? 'Bye'
              : 'Partial Complete');
        } else if (parseBool(scannedCount.toString()) &&
            await hp.showSimplePopup('OK', () {
              hp.goBack(result: true);
            },
                title: 'Setinhand',
                type: AlertType.cupertino,
                action: 'Delivery yet to Complete') &&
            !canCompletePartially.value &&
            mounted) {
          canCompletePartially.value =
              getData?.data.where(test).isNotEmpty ?? false;
        } else {
          canCompletePartially.value = false;
        }
        hp.onChange();
      } else {
        log('Unmounted');
      }
    } on SocketException {
      log('No Internet connection 😑');
      final p = await hp.showSimplePopup('OK', () {
        hp.goBack(result: true);
      },
          title: 'Setinhand',
          type: AlertType.cupertino,
          action: 'No Internet connection 😑');
      if (p) {
        hp.goBack();
      }
    } on HttpException {
      log("Couldn't find the post 😱");
      final p = await hp.showSimplePopup('OK', () {
        hp.goBack(result: true);
      },
          title: 'Setinhand',
          type: AlertType.cupertino,
          action: 'Service not found. Please try later.....');
      if (p) {
        hp.goBack();
      }
    } on FormatException {
      log('Bad response format 👎');
      final p = await hp.showSimplePopup('OK', () {
        hp.goBack(result: true);
      },
          title: 'Setinhand',
          type: AlertType.cupertino,
          action: 'Server error. Please try later.....');
      if (p) {
        hp.goBack();
      }
    } on ClientException {
      log('Hi');
      final p = await hp.showSimplePopup('OK', () {
        hp.goBack(result: true);
      },
          title: 'Setinhand',
          type: AlertType.cupertino,
          action: 'Unknown error. Please try later.....');
      if (p) {
        hp.goBack();
      }
    }
    // catch (e) {
    //  sendAppLog(e);
    //   final error = e.toString();
    //   final p = await hp.showSimplePopup('OK', () {
    //     hp.goBack(result: true);
    //   },
    //       title: 'Setinhand',
    //       type: AlertType.cupertino,
    //       action: error.contains('Connection timed out')
    //           ? 'Check Your Connection'
    //           : ((error.contains(
    //                       'Connection closed before full header was received')
    //                   ? 'Server'
    //                   : 'Unknown') +
    //               ' error. Please try later.....'));
    // }
  }

  void putData() async {
    try {
      getData = await api.getDeliveryStock(widget.rar.id ?? -1);
      scannedCount = (((getData?.totalbox ?? 0) +
              (getData?.data.where(test).length ?? 0)) -
          ((getData?.data.length ?? 0)));
      expected = getData?.totalbox.toString() ?? '';
      actual = scannedCount.toString();
      deliveryID =
          '${widget.rar.id}-${getData?.date ?? ''}\n${getData?.note ?? ''}';
      customerName = '${widget.rar.content ?? ''}\n${getData?.job ?? ''}';
      canCompletePartially.value =
          getData?.data.where(test).isNotEmpty ?? false;
      flag = false;
      log(getData);
      if (mounted) {
        setState(() {});
        hp.onChange();
      }
    } on SocketException {
      log('No Internet connection 😑');
      final p = await hp.showSimplePopup('OK', () {
        hp.goBack(result: true);
      },
          title: 'Setinhand',
          type: AlertType.cupertino,
          action: 'No Internet connection 😑');
      if (p) {
        hp.goBack();
      }
    } on HttpException {
      log("Couldn't find the post 😱");
      final p = await hp.showSimplePopup('OK', () {
        hp.goBack(result: true);
      },
          title: 'Setinhand',
          type: AlertType.cupertino,
          action: 'Service not found. Please try later.....');
      if (p) {
        hp.goBack();
      }
    } on FormatException {
      log('Bad response format 👎');
      final p = await hp.showSimplePopup('OK', () {
        hp.goBack(result: true);
      },
          title: 'Setinhand',
          type: AlertType.cupertino,
          action: 'Server error. Please try later.....');
      if (p) {
        hp.goBack();
      }
    } on ClientException {
      log('Hi');
      final p = await hp.showSimplePopup('OK', () {
        hp.goBack(result: true);
      },
          title: 'Setinhand',
          type: AlertType.cupertino,
          action: 'Unknown error. Please try later.....');
      if (p) {
        hp.goBack();
      }
    }
    // catch (e) {
    //  sendAppLog(e);
    //   final error = e.toString();
    //   if (mounted) {
    //     final p = await hp.showSimplePopup('OK', () {
    //       hp.goBack(result: true);
    //     },
    //         title: 'Setinhand',
    //         type: AlertType.cupertino,
    //         action: error.contains('Connection timed out')
    //             ? 'Check Your Connection'
    //             : ((error.contains(
    //                         'Connection closed before full header was received')
    //                     ? 'Server'
    //                     : 'Unknown') +
    //                 ' error. Please try later.....'));
    //     if (p) {
    //       hp.goBack();
    //     }
    //   }
    // }
  }

  void partialCompleted(bool flag) async {
    try {
      if (flag) {
        Loader.show(context);
        final p = await hp.showPleaseWait();
        final rp = await api.deliveryPartialCompleted(widget.rar.id ?? -1, hp);
        Loader.hide();
        if (rp.success &&
            p &&
            await hp.showSimplePopup('OK', () {
              hp.goBack(result: true);
            },
                title: 'Setinhand',
                type: AlertType.cupertino,
                action: 'Partially Completed Successfully')) {
          canCompletePartially.value = !flag;
          didUpdateWidget(widget);
          // hp.onChange();
          // hp.goBack();
        } // ?  : hp.doNothing()
        // rp.success && r ? hp.goBack() : hp.doNothing();
      } else if (await hp.showSimplePopup('OK', () {
        hp.goBack(result: true);
      },
          title: 'Setinhand',
          type: AlertType.cupertino,
          action: 'Please scan any stock item')) {
        log(scannedCount);
      }
    } on SocketException {
      log('No Internet connection 😑');
      final p = await hp.showSimplePopup('OK', () {
        hp.goBack(result: true);
      },
          title: 'Setinhand',
          type: AlertType.cupertino,
          action: 'No Internet connection 😑');
      if (p) {
        hp.goBack();
      }
    } on HttpException {
      log("Couldn't find the post 😱");
      final p = await hp.showSimplePopup('OK', () {
        hp.goBack(result: true);
      },
          title: 'Setinhand',
          type: AlertType.cupertino,
          action: 'Service not found. Please try later.....');
      if (p) {
        hp.goBack();
      }
    } on FormatException {
      log('Bad response format 👎');
      final p = await hp.showSimplePopup('OK', () {
        hp.goBack(result: true);
      },
          title: 'Setinhand',
          type: AlertType.cupertino,
          action: 'Server error. Please try later.....');
      if (p) {
        hp.goBack();
      }
    } on ClientException {
      log('Hi');
      final p = await hp.showSimplePopup('OK', () {
        hp.goBack(result: true);
      },
          title: 'Setinhand',
          type: AlertType.cupertino,
          action: 'Unknown error. Please try later.....');
      if (p) {
        hp.goBack();
      }
    }
    // catch (e) {
    //  sendAppLog(e);
    //   final error = e.toString();
    //   final p = await hp.showSimplePopup('OK', () {
    //     hp.goBack(result: true);
    //   },
    //       title: 'Setinhand',
    //       type: AlertType.cupertino,
    //       action: error.contains('Connection timed out')
    //           ? 'Check Your Connection'
    //           : ((error.contains(
    //                       'Connection closed before full header was received')
    //                   ? 'Server'
    //                   : 'Unknown') +
    //               ' error. Please try later.....'));
    //   if (p) {
    //     hp.goBack();
    //   }
    // }
  }

  void deliveryCompletedProcess() async {
    try {
      final compList = getData?.data.where(pick) ??
          const Iterable<DeliveryStockData>.empty();
      // log(getData?.data.length);
      // log(scannedCount);
      // log(expected);
      if (compList.isEmpty &&
          ((getData?.data.length ?? 0) + scannedCount ==
              (int.tryParse(expected) ?? 0)) &&
          (await hp.appearDialogBox<bool>(
                  child: const AlertDialog(content: MyDialog())) ??
              false)) {
        log(widget.rar.id);
        Loader.show(context);
        final rp = await api.deliveryCompleted(widget.rar.id ?? -1);
        Loader.hide();
        if (await hp.showSimplePopup('OK', () {
              hp.goBack(result: true);
            },
                title: 'Setinhand',
                type: AlertType.cupertino,
                action: rp.message) &&
            rp.success) {
          canCompletePartially.value = false;
          hp.onChange();
          hp.goBack();
        }
      } else if ((scannedCount != (int.tryParse(expected) ?? 0)) &&
          await hp.showSimplePopup('OK', () {
            hp.goBack(result: true);
          },
              title: 'Setinhand',
              type: AlertType.cupertino,
              action:
                  'Some of the items are not yet scanned, please scan the stock item')) {
        log(scannedCount);
        log(compList.length);
      } else {
        log('object');
      }
    } on SocketException {
      log('No Internet connection 😑');
      final p = !hp.isDialogOpen &&
          await hp.showSimplePopup('OK', () {
            hp.goBack(result: true);
          },
              title: 'Setinhand',
              type: AlertType.cupertino,
              action: 'No Internet connection 😑');
      if (p) {
        hp.goBack();
      }
    } on HttpException {
      log("Couldn't find the post 😱");
      // final p = await hp.showSimplePopup('OK', () {
      //   hp.goBack(result: true);
      // },
      //     title: 'Setinhand',
      //     type: AlertType.cupertino,
      //     action: 'Service not found. Please try later.....');
      // if (p) {
      //   hp.goBack();
      // }
    } on FormatException {
      log('Bad response format 👎');
      // final p = await hp.showSimplePopup('OK', () {
      //   hp.goBack(result: true);
      // },
      //     title: 'Setinhand',
      //     type: AlertType.cupertino,
      //     action: 'Server error. Please try later.....');
      // if (p) {
      //   hp.goBack();
      // }
    } on ClientException {
      log('Hi');
      // final p = await hp.showSimplePopup('OK', () {
      //   hp.goBack(result: true);
      // },
      //     title: 'Setinhand',
      //     type: AlertType.cupertino,
      //     action: 'Unknown error. Please try later.....');
      // if (p) {
      //   hp.goBack();
      // }
    }
  }

  bool pick(DeliveryStockData element) {
    log(element.status);
    return !parseBool(element.status.toString());
  }

  bool test(DeliveryStockData element) {
    log(element.status);
    return parseBool(element.status.toString());
  }

  Widget pageBuilder(BuildContext context, Orientation screenLayout) {
    final hps = Helper.of(context);

    Widget buttonBuilder(BuildContext context, bool flag, Widget? child) {
      final hpb = Helper.of(context);
      void onTap() {
        partialCompleted(flag);
      }

      return GestureDetector(
          onTap: onTap,
          child: Container(
              height: hpb.height /
                  (screenLayout == Orientation.landscape ? 8 : 10.73741824),
              color: flag ? Colors.green : const Color(0xff919293),
              padding: EdgeInsets.all(hpb.radius / 50),
              child: const Text('Partial Delivery',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 19))));
    }

    return WillPopScope(
        onWillPop: hp.backButtonOverride,
        child: SafeArea(
          child: Scaffold(
            bottomNavigationBar:
                BottomWidget(heightFactor: 30, widthFactor: hps.width),
            key: _scaffoldKey,
            endDrawer: const Drawer(child: ChatListWidget()),
            backgroundColor: const Color(0xffdbd9d9),
            body: getData == null
                ? const LoaderWidget()
                : Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          MyAppBar(hps, _scaffoldKey,
                              leading: IconButton(
                                  onPressed: () {
                                    if (canCompletePartially.value) {
                                      canCompletePartially.value = false;
                                      hps.onChange();
                                    }
                                    hps.goBack();
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
                              flex: 4,
                              child: Container(
                                padding: const EdgeInsets.only(
                                    top: 30, right: 10, left: 10),
                                color: Colors.white,
                                width: double.infinity,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                        width: double
                                            .infinity, // <-- match_parent, // <-- match-parent
                                        child: Row(
                                          children: [
                                            Expanded(
                                                flex: 4,
                                                child: Container(
                                                    color: hps.theme.focusColor,
                                                    alignment: Alignment.center,
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            vertical:
                                                                hps.height / 64,
                                                            horizontal:
                                                                hps.width / 50),
                                                    child: const Text(
                                                        'Delivery ID',
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                            color: Color(
                                                                0xFF404040),
                                                            fontSize:
                                                                16.384)))),
                                            const SizedBox(width: 3),
                                            Expanded(
                                                flex: 4,
                                                child: Container(
                                                    color: hps.theme.focusColor,
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            vertical:
                                                                hps.height / 64,
                                                            horizontal:
                                                                hps.width / 50),
                                                    alignment: Alignment.center,
                                                    child: const Text(
                                                        'Customer',
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                            color: Color(
                                                                0xFF404040),
                                                            fontSize:
                                                                16.384)))),
                                            const SizedBox(width: 3),
                                            Expanded(
                                                flex: 4,
                                                child: Container(
                                                    color: hps.theme.focusColor,
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            vertical:
                                                                hps.height / 64,
                                                            horizontal:
                                                                hps.width / 50),
                                                    alignment: Alignment.center,
                                                    child: const Text(
                                                        'Expected',
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                            color: Color(
                                                                0xFF404040),
                                                            fontSize:
                                                                16.384)))),
                                            const SizedBox(width: 3),
                                            Expanded(
                                                flex: 4,
                                                child: Container(
                                                    color: hps.theme.focusColor,
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            vertical:
                                                                hps.height / 64,
                                                            horizontal:
                                                                hps.width / 50),
                                                    alignment: Alignment.center,
                                                    child: const Text('Actual',
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                            color: Color(
                                                                0xFF404040),
                                                            fontSize:
                                                                16.384)))),
                                          ],
                                        )),
                                    const SizedBox(width: 3, height: 3),
                                    SizedBox(
                                        width: double
                                            .infinity, // <-- match_parent, // <-- match-parent
                                        child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                  flex: 4,
                                                  child: Container(
                                                      color: const Color(
                                                          0xFFe2e4ef),
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              vertical: hps
                                                                      .height /
                                                                  160,
                                                              horizontal:
                                                                  hps.width /
                                                                      400),
                                                      alignment:
                                                          Alignment.center,
                                                      child: Text(deliveryID,
                                                          style: const TextStyle(
                                                              color: Color(
                                                                  0xFF404040),
                                                              fontSize: 16.384),
                                                          textAlign: TextAlign
                                                              .center))),
                                              const SizedBox(width: 3),
                                              Expanded(
                                                  flex: 4,
                                                  child: Container(
                                                      color: const Color(
                                                          0xFFe2e4ef),
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              vertical: hps
                                                                      .height /
                                                                  64,
                                                              horizontal:
                                                                  hps.width /
                                                                      50),
                                                      alignment:
                                                          Alignment.center,
                                                      child: Text(customerName,
                                                          style: const TextStyle(
                                                              color: Color(
                                                                  0xFF404040),
                                                              fontSize: 16.384),
                                                          textAlign: TextAlign
                                                              .center))),
                                              const SizedBox(width: 3),
                                              Expanded(
                                                  flex: 4,
                                                  child: Container(
                                                      color: const Color(
                                                          0xFFe2e4ef),
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              vertical: hps
                                                                      .height /
                                                                  64,
                                                              horizontal:
                                                                  hps.width /
                                                                      50),
                                                      alignment:
                                                          Alignment.center,
                                                      child: Text(expected,
                                                          style: const TextStyle(
                                                              color: Color(
                                                                  0xFF404040),
                                                              fontSize: 16.384),
                                                          textAlign: TextAlign
                                                              .center))),
                                              const SizedBox(width: 3),
                                              Expanded(
                                                  flex: 4,
                                                  child: Container(
                                                      color: const Color(
                                                          0xFFe2e4ef),
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              vertical: hps
                                                                      .height /
                                                                  64,
                                                              horizontal:
                                                                  hps.width /
                                                                      50),
                                                      alignment:
                                                          Alignment.center,
                                                      child: Text(actual,
                                                          style: const TextStyle(
                                                              color: Color(
                                                                  0xFF404040),
                                                              fontSize: 16.384),
                                                          textAlign: TextAlign
                                                              .center))),
                                            ])),
                                    const SizedBox(width: 3, height: 50),
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
                                              padding: const EdgeInsets.all(15),
                                              child: const Text(
                                                  'Stock Items Due',
                                                  style: TextStyle(
                                                      color: Color(0xFF404040),
                                                      fontSize: 16.384)),
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 3,
                                          ),
                                          Expanded(
                                            flex: 4,
                                            child: GestureDetector(
                                              onTap: () async {
                                                await showDialog(
                                                    context: context,
                                                    builder:
                                                        (BuildContext context) {
                                                      if (selected == null) {
                                                        return CustomDialog(
                                                            deliveryID: getData
                                                                ?.data
                                                                .first
                                                                .deliveryId
                                                                .toString());
                                                      } else {
                                                        return CustomDialog(
                                                            deliveryID: selected
                                                                ?.deliveryId
                                                                .toString(),
                                                            getData: selected,
                                                            addEdit: true);
                                                      }
                                                    });
                                                didUpdateWidget(widget);
                                              },
                                              child: Container(
                                                height: 50.0,
                                                color: const Color(0xFFe2e4ef),
                                                padding:
                                                    const EdgeInsets.all(15),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    const Text('Discrepancies',
                                                        style: TextStyle(
                                                            color: Color(
                                                                0xFF404040),
                                                            fontSize: 16.384)),
                                                    IconButton(
                                                        onPressed: () {},
                                                        padding:
                                                            const EdgeInsets
                                                                    .only(
                                                                bottom: 15),
                                                        icon: const Icon(
                                                            Icons.add_outlined),
                                                        tooltip:
                                                            'notification'),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 3, height: 2),
                                    Flexible(
                                      flex: 4,
                                      child: Row(
                                        children: [
                                          Expanded(
                                            flex: 4,
                                            child: getData == null
                                                ? Image.asset(
                                                    '${assetImagePath}puzzle_128.gif')
                                                : (getData!.data.isEmpty
                                                    ? const EmptyWidget()
                                                    : ListView.builder(
                                                        scrollDirection:
                                                            Axis.vertical,
                                                        shrinkWrap: true,
                                                        physics:
                                                            const BouncingScrollPhysics(
                                                                parent:
                                                                    AlwaysScrollableScrollPhysics()),
                                                        itemBuilder: listItem,
                                                        itemCount: getData
                                                                ?.data.length ??
                                                            0)),
                                          ),
                                          const SizedBox(
                                            width: 3,
                                          ),
                                          const Expanded(
                                            flex: 4,
                                            child: SizedBox(),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
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
                                                    vertical: hps.height / 100),
                                                buttonColor:
                                                    hps.theme.selectedRowColor,
                                                labelColor: hps.theme
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
                                                height: hps.height /
                                                    (screenLayout ==
                                                            Orientation
                                                                .landscape
                                                        ? 2.56
                                                        : 4),
                                                width: screenLayout ==
                                                        Orientation.landscape
                                                    ? hps.width / 2.56
                                                    : null,
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: hps.width / 80),
                                                child: Stack(
                                                  alignment:
                                                      Alignment.bottomCenter,
                                                  children: <Widget>[
                                                    QRView(
                                                        overlay:
                                                            QrScannerOverlayShape(
                                                                cutOutHeight:
                                                                    hps.height /
                                                                        1.6,
                                                                cutOutWidth:
                                                                    hps.width),
                                                        key: qrKey,
                                                        onQRViewCreated:
                                                            onQRViewCreated),
                                                    Positioned(
                                                        left: hps.width / 8,
                                                        top: hps.height /
                                                            (screenLayout ==
                                                                    Orientation
                                                                        .landscape
                                                                ? 3.2768
                                                                : 5.24288),
                                                        child: CustomLabelledButton(
                                                            labelColor: hps
                                                                .theme
                                                                .scaffoldBackgroundColor,
                                                            buttonColor: hps
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
                                                vertical: hps.height / 40,
                                                horizontal: hps.width / 25),
                                            padding: EdgeInsets.symmetric(
                                                vertical: hps.height / 8)),
                                    SizedBox(
                                        height: hps.height / 20,
                                        width: hps.width,
                                        child: Visibility(
                                            visible: code != null &&
                                                code!.isNotEmpty,
                                            child: Text(
                                              'Scanned Code is: ${code ?? ''}',
                                              textAlign: TextAlign.center,
                                            ))),
                                    SizedBox(
                                        width: double
                                            .infinity, // <-- match_parent, // <-- match-parent
                                        child: Row(
                                          children: [
                                            Expanded(
                                                flex: 4,
                                                child: ValueListenableBuilder<
                                                        bool>(
                                                    builder: buttonBuilder,
                                                    valueListenable:
                                                        canCompletePartially)),
                                            const SizedBox(
                                              width: 3,
                                            ),
                                            Expanded(
                                                flex: 4,
                                                child: GestureDetector(
                                                    onTap:
                                                        deliveryCompletedProcess,
                                                    child: Container(
                                                      alignment:
                                                          Alignment.center,
                                                      height: hps.height /
                                                          (screenLayout ==
                                                                  Orientation
                                                                      .landscape
                                                              ? 8
                                                              : 10.73741824),
                                                      color: getData?.data
                                                                  .where(pick)
                                                                  .isEmpty ??
                                                              false
                                                          ? Colors.green
                                                          : const Color(
                                                              0xff919293),
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 15,
                                                              bottom: 15,
                                                              left: 15,
                                                              right: 5),
                                                      child: const Text(
                                                        'Completed',
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 19),
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                    ))),
                                          ],
                                        )),
                                  ],
                                ))
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
        ));
  }

  Widget listItem(BuildContext context, int index) {
    final item = getData == null || getData!.data.isEmpty
        ? DeliveryStockData.emptyData
        : getData!.data[index];
    return GestureDetector(
        onTap: () {
          setState(() {
            selected = item;
            scanMode = true;
          });
        },
        child: Container(
          margin: const EdgeInsets.only(top: 1),
          padding: const EdgeInsets.all(10),
          alignment: Alignment.topLeft,
          color: parseBool(item.status.toString()) || (selected == item && flag)
              ? const Color(0xffe183a7)
              : (selected == item && !parseBool(item.status.toString())
                  ? const Color(0xff79c0e6)
                  : Colors.orangeAccent),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                      child: Text(item.stockItemId,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 16.384))),
                  IconButton(
                      onPressed: () {},
                      icon: parseBool(item.status.toString()) ||
                              (selected == item && flag)
                          ? Image.asset('${assetImagePath}purple_tick.png')
                          : Image.asset('${assetImagePath}pending.png'),
                      tooltip: 'sfsdf'),
                ],
              ),
              Text('Qty :${item.qtyExpected}',
                  style:
                      const TextStyle(color: Colors.white, fontSize: 16.384)),
            ],
          ),
        ));
  }

  @override
  void initState() {
    super.initState();
    hp.getConnectStatus();
    setData();
  }

  @override
  void didUpdateWidget(covariant DeliveryDetails oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
    putData();
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(builder: pageBuilder);
  }
}
