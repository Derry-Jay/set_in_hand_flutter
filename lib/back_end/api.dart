import 'dart:io';
import 'dart:convert';
import '../models/task.dart';
import '../models/user.dart';
import '../models/base.dart';
import '../models/chat.dart';
import 'package:dio/dio.dart';
import '../models/reply.dart';
import '../models/values.dart';
import '../models/getrack.dart';
import '../helpers/helper.dart';
import 'package:http/http.dart';
import '../models/delivery.dart';
import '../models/user_base.dart';
import '../models/chat_base.dart';
import '../models/misc_data.dart';
import '../models/quantities.dart';
import '../models/goods_check.dart';
import '../models/chat_message.dart';
import '../models/getzonemodel.dart';
import '../models/warehousedata.dart';
import '../models/palletlocation.dart';
import '../models/stockitemModel.dart';
import '../models/warehouse_item.dart';
import '../models/delivery_stock.dart';
import 'package:flutter/material.dart';
import '../models/full_stock_item.dart';
import '../models/shownotification.dart';
import '../models/goods_check_base.dart';
import '../models/pull_scan_output.dart';
import '../models/readnotification.dart';
import '../models/chat_message_base.dart';
import '../models/warehouseitembase.dart';
import '../models/updateqrcodemodel.dart';
import '../models/getqrcodeiddetails.dart';
import '../models/full_stock_item_base.dart';
import '../models/getcyclestockcheckmodel.dart';
import '../models/GetpalletLocationsModel.dart';
import '../models/GetCompletedDelieveriesModel.dart';
import '../models/GetCompletedDeliveriesDetails.dart';

final dio = Dio();
// final client = Client();
// final clientHttp = HttpClient();
GetStockItem? item;
List<Map<String, dynamic>> fci =
    List<Map<String, dynamic>>.empty(growable: true);
TextEditingController tec = TextEditingController();
int perBox = -1;
ValueNotifier<List<Task>?> tasks = ValueNotifier(null);
ValueNotifier<User> currentUser = ValueNotifier(User.emptyUser);
ValueNotifier<List<Delivery>?> dueDeliveries = ValueNotifier(null);
ValueNotifier<int> remaining = ValueNotifier(0),
    box = ValueNotifier(-1),
    update = ValueNotifier(0),
    count = ValueNotifier(0);
ValueNotifier<List<StockItem>?> stockItems = ValueNotifier(null);
ValueNotifier<List<GoodsCheck>?> highs = ValueNotifier(null),
    lows = ValueNotifier(null);
ValueNotifier<List<FullStockItem>?> items = ValueNotifier(null);
ValueNotifier<List<Chat>?> chats = ValueNotifier(null);
ValueNotifier<List<ChatMessage>?> chatmessages = ValueNotifier(null);
ValueNotifier<List<GetStockItem>?> getStockItems = ValueNotifier(null);
ValueNotifier<List<StockItem>> stocks = ValueNotifier(<StockItem>[]),
    availableStocks = ValueNotifier(<StockItem>[]);
ValueNotifier<List<WarehouseItem>> warehouseitems =
    ValueNotifier(<WarehouseItem>[]);
ValueNotifier<List<GetCompletedDeliveriesDetailDeliveryDatum>?> data =
    ValueNotifier(null);
ValueNotifier<bool> canCompletePartially = ValueNotifier(false);
ValueNotifier<String?> code = ValueNotifier(null),
    location = ValueNotifier(null);
ValueNotifier<List<int>?> bytes = ValueNotifier(null);

class API {
  final APIMode mode;
  late String baseURL;
  API(this.mode) {
    baseURL = gc?.getValue<String>(mode.name) ?? '';
  }

  void getTasks(Helper hp) async {
    final clientHttp = HttpClient();
    clientHttp.findProxy = null;
    // try {
    //   final url = Uri.tryParse(baseURL + 'getTasks') ?? Uri();
    //   final response = await client.get(url);
    //   final data = json.decode(response.body) as Map<String, dynamic>;
    //   final base = Base.fromMap(data);
    //   tasks.value = response.statusCode == 200 ? base.tasks : <Task>[];
    //   dueDeliveries.value =
    //       response.statusCode == 200 ? base.dues : <Delivery>[];
    //   base.onChange();
    // }catch (e) {
    //   final error = e.toString();
    //   clientHttp.close(force: true);
    //   final p = !hp.isDialogOpen && await hp.showSimplePopup('OK', () {
    //     hp.goBack(result: true);
    //   },
    //       title: 'Setinhand',
    //       type: AlertType.cupertino,
    //       action: error.contains('Connection timed out')
    //           ? 'Check Your Connection'
    //           : ((error.contains(
    //                           'Connection closed before full header was received') ||
    //                       error.contains('FormatException')
    //                   ? 'Server'
    //                   : 'Unknown') +
    //               ' error. Please try later.....'));
    // }
    try {
      final url = Uri.tryParse('${baseURL}getTasks') ?? Uri();
      final request = await clientHttp.getUrl(url);
      clientHttp.close();
      final response = await request.close();
      final resStr = await response.transform(utf8.decoder).join();
      // log(resStr);
      final data = json.decode(resStr) as Map<String, dynamic>;
      final base = Base.fromMap(data);
      tasks.value = response.statusCode == 200 ? base.tasks : <Task>[];
      dueDeliveries.value =
          response.statusCode == 200 ? base.dues : <Delivery>[];
      base.onChange();
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
      final p = !hp.isDialogOpen &&
          !hp.isDialogOpen &&
          await hp.showSimplePopup('OK', () {
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
      final p = !hp.isDialogOpen &&
          !hp.isDialogOpen &&
          await hp.showSimplePopup('OK', () {
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
      final p = !hp.isDialogOpen &&
          !hp.isDialogOpen &&
          await hp.showSimplePopup('OK', () {
            hp.goBack(result: true);
          },
              title: 'Setinhand',
              type: AlertType.cupertino,
              action: 'Unknown error. Please try later.....');
      if (p) {
        hp.goBack();
      }
    } finally {
      clientHttp.close(force: true);
    }
  }

  void getPullList(Task task, Helper hp) async {
    final clientHttp = HttpClient();
    clientHttp.findProxy = null;
    final url = Uri.tryParse('${baseURL}getstocking') ?? Uri();
    final request = await clientHttp.postUrl(url);
    final body = {'task_id': task.taskID, 'user_id': currentUser.value.userID};
    log(body);
    final reqStr = json.encode(body);
    request.headers.set('content-type', 'application/json');
    request.headers.contentType =
        ContentType('application', 'json', charset: 'utf-8');
    request.write(reqStr);
    try {
      final response = await request.close();
      final resStr = await response.transform(utf8.decoder).join();
      log(resStr);
      final data = json.decode(resStr) as Map<String, dynamic>;
      final rp = Reply.fromMap(data);
      final sib = StockItemBase.fromMap(data);
      if (rp.success) {
        stockItems.value =
            response.statusCode == 200 ? sib.items : <StockItem>[];
        remaining.value =
            response.statusCode == 200 ? sib.remainingQuantity : 0;
        sib.onChange();
      } else if (!hp.isDialogOpen &&
          await hp.showSimplePopup('OK', () {
            hp.goBack(result: true);
          },
              title: 'Setinhand',
              type: AlertType.cupertino,
              action: rp.message)) {
        hp.goBack();
      } else {
        log(baseURL);
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
      final p = !hp.isDialogOpen &&
          await hp.showSimplePopup('OK', () {
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
      final p = !hp.isDialogOpen &&
          await hp.showSimplePopup('OK', () {
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
      final p = !hp.isDialogOpen &&
          await hp.showSimplePopup('OK', () {
            hp.goBack(result: true);
          },
              title: 'Setinhand',
              type: AlertType.cupertino,
              action: 'Unknown error. Please try later.....');
      if (p) {
        hp.goBack();
      }
    } finally {
      clientHttp.close(force: true);
    }
    // catch (e) {
    //  sendAppLog(e);
    //   final error = e.toString();
    //   if (!hp.isDialogOpen && await hp.showSimplePopup('OK', () {
    //     hp.goBack(result: true);
    //   },
    //       title: 'Setinhand',
    //       type: AlertType.cupertino,
    //       action: error.contains('Connection timed out')
    //           ? 'Check Your Connection'
    //           : ((error.contains(
    //                           'Connection closed before full header was received') ||
    //                       error.contains('FormatException')
    //                   ? 'Server'
    //                   : 'Unknown') +
    //               ' error. Please try later.....'))) {
    //     hp.goBack();
    //   }
    // }
  }

  void getFullStockCheck(Task task, Helper hp) async {
    final clientHttp = HttpClient();
    clientHttp.findProxy = null;
    try {
      final url =
          Uri.tryParse('${baseURL}getFullStockItems/${task.taskID}') ?? Uri();
      log(url);
      final request = await clientHttp.getUrl(url);
      clientHttp.close();
      final response = await request.close();
      final resStr = await response.transform(utf8.decoder).join();
      log(resStr);
      final data = json.decode(resStr) as Map<String, dynamic>;
      final gcb = GoodsCheckBase.fromMap(data);
      highs.value = response.statusCode == 200 ? gcb.highs : <GoodsCheck>[];
      lows.value = response.statusCode == 200 ? gcb.lows : <GoodsCheck>[];
      fci = gcb.itemsMap;
      gcb.onChange();
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
      final p = !hp.isDialogOpen &&
          await hp.showSimplePopup('OK', () {
            hp.goBack(result: true);
          },
              title: 'Setinhand',
              type: AlertType.cupertino,
              action: 'Service not found 😱. Please try later.....');
      if (p) {
        hp.goBack();
      }
    } on FormatException {
      log('Bad response format 👎');
      final p = !hp.isDialogOpen &&
          await hp.showSimplePopup('OK', () {
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
      final p = !hp.isDialogOpen &&
          await hp.showSimplePopup('OK', () {
            hp.goBack(result: true);
          },
              title: 'Setinhand',
              type: AlertType.cupertino,
              action: 'Unknown error. Please try later.....');
      if (p) {
        hp.goBack();
      }
    } finally {
      clientHttp.close(force: true);
    }
    // try {
    //   final url = Uri.tryParse(
    //           baseURL + 'getFullStockItems/' + task.taskID.toString()) ??
    //       Uri();
    //   final response = await client.get(url);
    //   final data = json.decode(response.body) as Map<String, dynamic>;
    //   final gcb = GoodsCheckBase.fromMap(data);
    //   highs.value = response.statusCode == 200 ? gcb.highs : <GoodsCheck>[];
    //   lows.value = response.statusCode == 200 ? gcb.lows : <GoodsCheck>[];
    //   fci = gcb.itemsMap;
    //   gcb.onChange();
    // }
    // catch (e) {
    //   final error = e.toString();
    //   final p = !hp.isDialogOpen && await hp.showSimplePopup('OK', () {
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

  void fetchGetCycleStockItems(Task task, Helper hp) async {
    final client = Client();
    try {
      final url = Uri.parse('${baseURL}getCycleStockItems/${task.taskID}');
      log(url);
      final response = await client.get(url);
      client.close();
      final data = json.decode(response.body);
      final gcc = Getcyclestockcheckmodel.fromJson(data);
      getStockItems.value =
          response.statusCode == 200 ? gcc.getStockItems : <GetStockItem>[];
      gcc.onChange();
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
      final p = !hp.isDialogOpen &&
          await hp.showSimplePopup('OK', () {
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
      final p = !hp.isDialogOpen &&
          await hp.showSimplePopup('OK', () {
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
      final p = !hp.isDialogOpen &&
          await hp.showSimplePopup('OK', () {
            hp.goBack(result: true);
          },
              title: 'Setinhand',
              type: AlertType.cupertino,
              action: 'Unknown error. Please try later.....');
      if (p) {
        hp.goBack();
      }
    } finally {
      client.close();
    }
    // catch (e) {
    //  sendAppLog(e);
    //   client.close();
    //   final error = e.toString();
    //   final p = !hp.isDialogOpen && await hp.showSimplePopup('OK', () {
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

  void getChats(Helper hp) async {
    final client = Client();
    try {
      final url =
          Uri.tryParse('${baseURL}chatlistuser/${currentUser.value.userID}') ??
              Uri();
      final response = await client.get(url);
      client.close();
      log(response.body);
      final data = json.decode(response.body) as Map<String, dynamic>;
      final cb = ChatBase.fromMap(data);
      chats.value = response.statusCode == 200 ? cb.chats : <Chat>[];
      cb.onChange();
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
      final p = !hp.isDialogOpen &&
          await hp.showSimplePopup('OK', () {
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
      final p = !hp.isDialogOpen &&
          await hp.showSimplePopup('OK', () {
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
      final p = !hp.isDialogOpen &&
          await hp.showSimplePopup('OK', () {
            hp.goBack(result: true);
          },
              title: 'Setinhand',
              type: AlertType.cupertino,
              action: 'Unknown error. Please try later.....');
      if (p) {
        hp.goBack();
      }
    } finally {
      client.close();
    }
    // catch (e) {
    //  sendAppLog(e);
    //   final error = e.toString();
    //   final p = !hp.isDialogOpen && await hp.showSimplePopup('OK', () {
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

  void getWareHouses(String location, Helper hp) async {
    final client = Client();
    try {
      final url = Uri.tryParse('${baseURL}getdetailsbyqrcode') ?? Uri();
      final response = await client.post(url, body: {'qrcodetext': location});
      client.close();
      log(response.body);
      final data = json.decode(response.body) as Map<String, dynamic>;
      final sb = WarehouseItemBase.fromMap(data);
      if (sb.reply.success &&
          sb.warehouseitems.isNotEmpty &&
          await hp.revealToast(sb.reply.message)) {
        warehouseitems.value = sb.warehouseitems;
        sb.onChange();
      } else if (!sb.reply.success &&
          hp.mounted &&
          !hp.isDialogOpen &&
          await hp.showSimplePopup('OK', () {
            hp.goBack(result: true);
          },
              type: AlertType.cupertino,
              title: 'Setinhand',
              action: sb.reply.message)) {
        log(data);
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
      final p = !hp.isDialogOpen &&
          await hp.showSimplePopup('OK', () {
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
      final p = !hp.isDialogOpen &&
          await hp.showSimplePopup('OK', () {
            hp.goBack(result: true);
          },
              title: 'Setinhand',
              type: AlertType.cupertino,
              action: 'Server error. Please try later.....');
      if (p) {
        code.value = null;
        hp.onChange();
        hp.goBack();
      }
    } on ClientException {
      log('Hi');
      final p = !hp.isDialogOpen &&
          await hp.showSimplePopup('OK', () {
            hp.goBack(result: true);
          },
              title: 'Setinhand',
              type: AlertType.cupertino,
              action: 'Unknown error. Please try later.....');
      if (p) {
        code.value = null;
        hp.onChange();
        hp.goBack();
      }
    } on Exception catch (e) {
      sendAppLog(e);

      log('Bye');
    } finally {
      client.close();
    }
    // catch (e) {
    //  sendAppLog(e);
    //   client.close();
    //   final error = e.toString();
    //   final p = !hp.isDialogOpen && await hp.showSimplePopup('OK', () {
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

  void getFullStockItems(int warehouseID, int taskID, Helper hp) async {
    final client = Client();
    try {
      final url =
          Uri.tryParse('${baseURL}getStockItems/$warehouseID/$taskID') ?? Uri();
      final response = await client.get(url);
      client.close();
      final data = json.decode(response.body);
      final fsi = FullStockItemBase.fromMap(data);
      items.value = fsi.items;
      fsi.onChange();
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
      final p = !hp.isDialogOpen &&
          await hp.showSimplePopup('OK', () {
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
      final p = !hp.isDialogOpen &&
          await hp.showSimplePopup('OK', () {
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
      final p = !hp.isDialogOpen &&
          await hp.showSimplePopup('OK', () {
            hp.goBack(result: true);
          },
              title: 'Setinhand',
              type: AlertType.cupertino,
              action: 'Unknown error. Please try later.....');
      if (p) {
        hp.goBack();
      }
    } finally {
      client.close();
    }
    // catch (e) {
    //  sendAppLog(e);
    //   client.close();
    //   final error = e.toString();
    //   final p = !hp.isDialogOpen && await hp.showSimplePopup('OK', () {
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

  void fetchGetCompletedDeliveriesDetails(String deliveryID, Helper hp) async {
    final client = Client();
    try {
      final url = Uri.parse('${baseURL}getDeliveryDetails/$deliveryID');
      final response = await client.get(url);
      client.close();
      final info = json.decode(response.body) as Map<String, dynamic>;
      final gcd = Getcompleteddeliveriesdetailsmodel.fromJson(info);
      data.value = response.statusCode == 200
          ? gcd.deliveryData
          : <GetCompletedDeliveriesDetailDeliveryDatum>[];
      gcd.onChange();
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
      final p = !hp.isDialogOpen &&
          await hp.showSimplePopup('OK', () {
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
      final p = !hp.isDialogOpen &&
          await hp.showSimplePopup('OK', () {
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
      final p = !hp.isDialogOpen &&
          await hp.showSimplePopup('OK', () {
            hp.goBack(result: true);
          },
              title: 'Setinhand',
              type: AlertType.cupertino,
              action: 'Unknown error. Please try later.....');
      if (p) {
        hp.goBack();
      }
    } finally {
      client.close();
    }
    // catch (e) {
    //  sendAppLog(e);
    //   client.close();
    //   final error = e.toString();
    //   final p = !hp.isDialogOpen && await hp.showSimplePopup('OK', () {
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

  Future<DeliveryStockModel> getDeliveryStock(int deliveryId) async {
    final client = Client();
    try {
      final url = Uri.tryParse('${baseURL}deliverystock/$deliveryId') ?? Uri();
      log(url);
      final response = await client.post(url);
      log(response.body);
      return DeliveryStockModel.fromMap(
          json.decode(response.body) as Map<String, dynamic>);
    } catch (e) {
      sendAppLog(e);

      rethrow;
    }
  }

  Future<UserBase> login(String email, String password, Helper hp) async {
    final prefs = await sharedPrefs;
    final clientHttp = HttpClient();
    clientHttp.findProxy = null;
    try {
      final url = Uri.tryParse(
              '$baseURL${gc?.getValue<String>('Login') ?? ''}?email=$email&password=$password') ??
          Uri();
      final request = await clientHttp.postUrl(url);
      clientHttp.close();
      final response = await request.close();
      final resStr = await response.transform(utf8.decoder).join();
      log(resStr);
      final data = json.decode(resStr) as Map<String, dynamic>;
      final ub = UserBase.fromMap(data);
      final ps = await prefs.setString(userKey, ub.user.toString());
      currentUser.value =
          response.statusCode == 200 && ps ? ub.user : User.emptyUser;
      return ub;
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
      rethrow;
    } on HttpException {
      log("Couldn't find the post 😱");
      final p = !hp.isDialogOpen &&
          await hp.showSimplePopup('OK', () {
            hp.goBack(result: true);
          },
              title: 'Setinhand',
              type: AlertType.cupertino,
              action: 'Service not found. Please try later.....');
      if (p) {
        hp.goBack();
      }
      rethrow;
    } on FormatException {
      log('Bad response format 👎');
      final p = !hp.isDialogOpen &&
          await hp.showSimplePopup('OK', () {
            hp.goBack(result: true);
          },
              title: 'Setinhand',
              type: AlertType.cupertino,
              action: 'Server error. Please try later.....');
      if (p) {
        hp.goBack();
      }
      rethrow;
    } on ClientException {
      log('Hi');
      final p = !hp.isDialogOpen &&
          await hp.showSimplePopup('OK', () {
            hp.goBack(result: true);
          },
              title: 'Setinhand',
              type: AlertType.cupertino,
              action: 'Unknown error. Please try later.....');
      if (p) {
        hp.goBack();
      }
      rethrow;
    } finally {
      clientHttp.close(force: true);
    }
    // try {
    //   final prefs = await sharedPrefs;
    //   final urlFinal = baseURL +
    //       (gc?.getValue<String>('Login') ?? '') +
    //       '?email=' +
    //       email +
    //       '&password=' +
    //       password;
    //   log(urlFinal);
    //   final url = Uri.tryParse(urlFinal) ?? Uri();
    //   final response = await client.post(url);
    //   log(response.body);
    //   log(response.statusCode);
    //   final data = json.decode(response.body);
    //   final ub = UserBase.fromMap(data);
    //   final ps = await prefs.setString(userKey, ub.user.toString());
    //   currentUser.value =
    //       response.statusCode == 200 && ps ? ub.user : User.emptyUser;
    //   return ub;
    // }
    // catch (e) {
    //  sendAppLog(e);
    //   clientHttp.close(force: true);
    //   rethrow;
    // }
  }

  Future<ChatMessageBase> getChatsMessages(String toUserid, Helper hp) async {
    final client = Client();
    try {
      final url = Uri.tryParse('${baseURL}usersmessges') ?? Uri();
      final data1 = {
        'userId': currentUser.value.userID.toString(),
        'toUserId': toUserid,
      };
      log(data1);
      var body = json.encode(data1);
      final response = await client.post(url,
          headers: {'Content-Type': 'application/json'}, body: body);
      client.close();
      log(response.body);
      final data = json.decode(response.body) as Map<String, dynamic>;
      log(response.statusCode);
      log(data);
      final cb = ChatMessageBase.fromMap(data);
      log(cb);
      chatmessages.value =
          response.statusCode == 200 ? cb.chats : <ChatMessage>[];
      cb.onChange();
      return cb;
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
      rethrow;
    } on HttpException {
      log("Couldn't find the post 😱");
      final p = !hp.isDialogOpen &&
          await hp.showSimplePopup('OK', () {
            hp.goBack(result: true);
          },
              title: 'Setinhand',
              type: AlertType.cupertino,
              action: 'Service not found. Please try later.....');
      if (p) {
        hp.goBack();
      }
      rethrow;
    } on FormatException {
      log('Bad response format 👎');
      final p = !hp.isDialogOpen &&
          await hp.showSimplePopup('OK', () {
            hp.goBack(result: true);
          },
              title: 'Setinhand',
              type: AlertType.cupertino,
              action: 'Server error. Please try later.....');
      if (p) {
        hp.goBack();
      }
      rethrow;
    } on ClientException {
      log('Hi');
      final p = !hp.isDialogOpen &&
          await hp.showSimplePopup('OK', () {
            hp.goBack(result: true);
          },
              title: 'Setinhand',
              type: AlertType.cupertino,
              action: 'Unknown error. Please try later.....');
      if (p) {
        hp.goBack();
      }
      rethrow;
    } finally {
      client.close();
    }
    //  catch (e) {
    //  sendAppLog(e);
    //   client.close();
    //   final error = e.toString();
    //   final p = !hp.isDialogOpen && await hp.showSimplePopup('OK', () {
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
    //   rethrow;
    // }
  }

  Future<Reply> logout(Helper hp) async {
    final prefs = await sharedPrefs;
    final client = Client();
    try {
      final url = Uri.tryParse('${baseURL}logout') ?? Uri();
      final response = await client
          .post(url, body: {'user_id': currentUser.value.userID.toString()});
      client.close();
      log(response.body);
      final data = json.decode(response.body) as Map<String, dynamic>;
      final sib = Reply.fromMap(data);
      if (response.statusCode == 200 &&
          sib.success &&
          await prefs.remove('user_id') &&
          await prefs.remove('login')) {
        log(sib.message);
      }
      return sib;
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
      rethrow;
    } on HttpException {
      log("Couldn't find the post 😱");
      final p = !hp.isDialogOpen &&
          await hp.showSimplePopup('OK', () {
            hp.goBack(result: true);
          },
              title: 'Setinhand',
              type: AlertType.cupertino,
              action: 'Service not found. Please try later.....');
      if (p) {
        hp.goBack();
      }
      rethrow;
    } on FormatException {
      log('Bad response format 👎');
      final p = !hp.isDialogOpen &&
          await hp.showSimplePopup('OK', () {
            hp.goBack(result: true);
          },
              title: 'Setinhand',
              type: AlertType.cupertino,
              action: 'Server error. Please try later.....');
      if (p) {
        hp.goBack();
      }
      rethrow;
    } on ClientException {
      log('Hi');
      final p = !hp.isDialogOpen &&
          await hp.showSimplePopup('OK', () {
            hp.goBack(result: true);
          },
              title: 'Setinhand',
              type: AlertType.cupertino,
              action: 'Unknown error. Please try later.....');
      if (p) {
        hp.goBack();
      }
      rethrow;
    } finally {
      client.close();
    }
    // catch (e) {
    //  sendAppLog(e);
    //   client.close();
    //   rethrow;
    // }
  }

  Future<List<GetCompletedDeliveriesDeliveryDatum>> fetchGetCompletedDeliveries(
      Helper hp) async {
    final client = Client();
    try {
      final url = Uri.parse(
          baseURL + (gc?.getValue<String>('Get_Completed_Deliveries') ?? ''));
      final response = await client.get(url);
      client.close();
      final data = json.decode(response.body);
      return response.statusCode == 200
          ? GetCompletedDeliveriesModel.fromJson(data).deliveryData
          : <GetCompletedDeliveriesDeliveryDatum>[];
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
      rethrow;
    } on HttpException {
      log("Couldn't find the post 😱");
      final p = !hp.isDialogOpen &&
          await hp.showSimplePopup('OK', () {
            hp.goBack(result: true);
          },
              title: 'Setinhand',
              type: AlertType.cupertino,
              action: 'Service not found. Please try later.....');
      if (p) {
        hp.goBack();
      }
      rethrow;
    } on FormatException {
      log('Bad response format 👎');
      final p = !hp.isDialogOpen &&
          await hp.showSimplePopup('OK', () {
            hp.goBack(result: true);
          },
              title: 'Setinhand',
              type: AlertType.cupertino,
              action: 'Server error. Please try later.....');
      if (p) {
        hp.goBack();
      }
      rethrow;
    } on ClientException {
      log('Hi');
      final p = !hp.isDialogOpen &&
          await hp.showSimplePopup('OK', () {
            hp.goBack(result: true);
          },
              title: 'Setinhand',
              type: AlertType.cupertino,
              action: 'Unknown error. Please try later.....');
      if (p) {
        hp.goBack();
      }
      rethrow;
    } finally {
      client.close();
    }
    // catch (e) {
    //  sendAppLog(e);
    //   client.close();
    //   final error = e.toString();
    //   final p = !hp.isDialogOpen && await hp.showSimplePopup('OK', () {
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
    //   rethrow;
    // }
  }

  Future<UpdateQrcodemodel> updateQRCode(
      String qrcodeText, int deliveryID, int deliveryCodeID, Helper hp) async {
    final client = Client();
    try {
      final url = Uri.tryParse('${baseURL}updateqrcode') ?? Uri();
      log(url);
      final body = {
        'qrcodetext': qrcodeText,
        'delivery_id': deliveryID.toString(),
        'user_id': currentUser.value.userID.toString(),
        'deliveryqrcodeId': deliveryCodeID.toString()
      };
      log(body);
      final response = await client.post(url, body: body);
      client.close();
      log(response.statusCode);
      log(response.body);
      canCompletePartially.value = true;
      hp.onChange();
      return UpdateQrcodemodel.fromMap(json.decode(response.body));
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
      rethrow;
    } on HttpException {
      log("Couldn't find the post 😱");
      final p = !hp.isDialogOpen &&
          await hp.showSimplePopup('OK', () {
            hp.goBack(result: true);
          },
              title: 'Setinhand',
              type: AlertType.cupertino,
              action: 'Service not found. Please try later.....');
      if (p) {
        hp.goBack();
      }
      rethrow;
    } on FormatException {
      log('Bad response format 👎');
      final p = !hp.isDialogOpen &&
          await hp.showSimplePopup('OK', () {
            hp.goBack(result: true);
          },
              title: 'Setinhand',
              type: AlertType.cupertino,
              action: 'Server error. Please try later.....');
      if (p) {
        hp.goBack();
      }
      rethrow;
    } on ClientException {
      log('Hi');
      final p = !hp.isDialogOpen &&
          await hp.showSimplePopup('OK', () {
            hp.goBack(result: true);
          },
              title: 'Setinhand',
              type: AlertType.cupertino,
              action: 'Unknown error. Please try later.....');
      if (p) {
        hp.goBack();
      }
      rethrow;
    } finally {
      client.close();
    }
    // catch (e) {
    //  sendAppLog(e);
    //   client.close();
    //   rethrow;
    // }
  }

  Future<Reply> deliveryPartialCompleted(int deliveryId, Helper hp) async {
    final client = Client();
    try {
      final body = {
        'delivery_Id': deliveryId.toString(),
        'created_by': currentUser.value.userID.toString()
      };
      final url = Uri.tryParse('${baseURL}deliveryPartialcomplete') ?? Uri();
      log(body);
      final response = await client.post(url, body: body);
      client.close();
      log(response.statusCode);
      log(response.body);
      final data = json.decode(response.body) as Map<String, dynamic>;
      canCompletePartially.value = false;
      hp.onChange();
      return Reply.fromMap(data);
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
      rethrow;
    } on HttpException {
      log("Couldn't find the post 😱");
      final p = !hp.isDialogOpen &&
          await hp.showSimplePopup('OK', () {
            hp.goBack(result: true);
          },
              title: 'Setinhand',
              type: AlertType.cupertino,
              action: 'Service not found. Please try later.....');
      if (p) {
        hp.goBack();
      }
      rethrow;
    } on FormatException {
      log('Bad response format 👎');
      final p = !hp.isDialogOpen &&
          await hp.showSimplePopup('OK', () {
            hp.goBack(result: true);
          },
              title: 'Setinhand',
              type: AlertType.cupertino,
              action: 'Server error. Please try later.....');
      if (p) {
        hp.goBack();
      }
      rethrow;
    } on ClientException {
      log('Hi');
      final p = !hp.isDialogOpen &&
          await hp.showSimplePopup('OK', () {
            hp.goBack(result: true);
          },
              title: 'Setinhand',
              type: AlertType.cupertino,
              action: 'Unknown error. Please try later.....');
      if (p) {
        hp.goBack();
      }
      rethrow;
    } finally {
      client.close();
    }
    // catch (e) {
    //  sendAppLog(e);
    //   client.close();
    //   rethrow;
    // }
  }

  Future<Reply> deliveryCompleted(int deliveryId) async {
    final client = Client();
    try {
      final url = Uri.tryParse('${baseURL}deliverycomplete') ?? Uri();
      final response = await client.post(url, body: {
        'delivery_id': deliveryId.toString(),
        'created_by': currentUser.value.userID.toString()
      });
      client.close();
      log(response.statusCode);
      final data = json.decode(response.body) as Map<String, dynamic>;
      log(data);
      final deliverystock = Reply.fromMap(data);
      return deliverystock;
    } catch (e) {
      sendAppLog(e);

      rethrow;
    }
  }

  Future<PalletLocationModel> palletLocations(Helper hp) async {
    final client = Client();
    try {
      final url = Uri.tryParse('${baseURL}getpalletlocation') ?? Uri();
      final response = await client.get(url);
      client.close();
      Map<String, dynamic> userMap = json.decode(response.body);
      log(userMap);
      var palletLocation = PalletLocationModel.fromMap(userMap);
      return palletLocation;
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
      rethrow;
    } on HttpException {
      log("Couldn't find the post 😱");
      final p = !hp.isDialogOpen &&
          await hp.showSimplePopup('OK', () {
            hp.goBack(result: true);
          },
              title: 'Setinhand',
              type: AlertType.cupertino,
              action: 'Service not found. Please try later.....');
      if (p) {
        hp.goBack();
      }
      rethrow;
    } on FormatException {
      log('Bad response format 👎');
      final p = !hp.isDialogOpen &&
          await hp.showSimplePopup('OK', () {
            hp.goBack(result: true);
          },
              title: 'Setinhand',
              type: AlertType.cupertino,
              action: 'Server error. Please try later.....');
      if (p) {
        hp.goBack();
      }
      rethrow;
    } on ClientException {
      log('Hi');
      final p = !hp.isDialogOpen &&
          await hp.showSimplePopup('OK', () {
            hp.goBack(result: true);
          },
              title: 'Setinhand',
              type: AlertType.cupertino,
              action: 'Unknown error. Please try later.....');
      if (p) {
        hp.goBack();
      }
      rethrow;
    } finally {
      client.close();
    }
    // catch (e) {
    //  sendAppLog(e);
    //   client.close();
    //   rethrow;
    // }
  }

  Future<GetZoneModel> getZone(int buildingId, Helper hp) async {
    final client = Client();
    try {
      final url = Uri.tryParse('${baseURL}getzone') ?? Uri();
      final response =
          await client.post(url, body: {'building_id': buildingId.toString()});
      client.close();
      Map<String, dynamic> userMap = json.decode(response.body);
      var getZoneLocation = GetZoneModel.fromMap(userMap);
      return getZoneLocation;
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
      rethrow;
    } on HttpException {
      log("Couldn't find the post 😱");
      final p = !hp.isDialogOpen &&
          await hp.showSimplePopup('OK', () {
            hp.goBack(result: true);
          },
              title: 'Setinhand',
              type: AlertType.cupertino,
              action: 'Service not found. Please try later.....');
      if (p) {
        hp.goBack();
      }
      rethrow;
    } on FormatException {
      log('Bad response format 👎');
      final p = !hp.isDialogOpen &&
          await hp.showSimplePopup('OK', () {
            hp.goBack(result: true);
          },
              title: 'Setinhand',
              type: AlertType.cupertino,
              action: 'Server error. Please try later.....');
      if (p) {
        hp.goBack();
      }
      rethrow;
    } on ClientException {
      log('Hi');
      final p = !hp.isDialogOpen &&
          await hp.showSimplePopup('OK', () {
            hp.goBack(result: true);
          },
              title: 'Setinhand',
              type: AlertType.cupertino,
              action: 'Unknown error. Please try later.....');
      if (p) {
        hp.goBack();
      }
      rethrow;
    } finally {
      client.close();
    }
    // catch (e) {
    //  sendAppLog(e);
    //   client.close();
    //   rethrow;
    // }
  }

  Future<GetRackModel> getRack(int zoneId, Helper hp) async {
    final client = Client();
    try {
      final url = Uri.tryParse('${baseURL}getrack') ?? Uri();
      final response =
          await client.post(url, body: {'zone_id': zoneId.toString()});
      client.close();
      Map<String, dynamic> userMap = json.decode(response.body);
      var getZoneLocation = GetRackModel.fromMap(userMap);
      return getZoneLocation;
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
      rethrow;
    } on HttpException {
      log("Couldn't find the post 😱");
      final p = !hp.isDialogOpen &&
          await hp.showSimplePopup('OK', () {
            hp.goBack(result: true);
          },
              title: 'Setinhand',
              type: AlertType.cupertino,
              action: 'Service not found. Please try later.....');
      if (p) {
        hp.goBack();
      }
      rethrow;
    } on FormatException {
      log('Bad response format 👎');
      final p = !hp.isDialogOpen &&
          await hp.showSimplePopup('OK', () {
            hp.goBack(result: true);
          },
              title: 'Setinhand',
              type: AlertType.cupertino,
              action: 'Server error. Please try later.....');
      if (p) {
        hp.goBack();
      }
      rethrow;
    } on ClientException {
      log('Hi');
      final p = !hp.isDialogOpen &&
          await hp.showSimplePopup('OK', () {
            hp.goBack(result: true);
          },
              title: 'Setinhand',
              type: AlertType.cupertino,
              action: 'Unknown error. Please try later.....');
      if (p) {
        hp.goBack();
      }
      rethrow;
    } finally {
      client.close();
    }
    // catch (e) {
    //  sendAppLog(e);
    //   client.close();
    //   rethrow;
    // }
  }

  Future<Getpalletlocationsmodel> getPalletLocations(
      int buildingId, int zoneId, int rackId, Helper hp) async {
    final client = Client();
    try {
      final url = Uri.tryParse('${baseURL}getpalletlocations') ?? Uri();
      log(url);
      final body = {
        'zone_id': zoneId.toString(),
        'building_id': buildingId.toString(),
        'rack_id': rackId.toString()
      };
      log(body);
      final response = await client.post(url, body: body);
      client.close();
      Map<String, dynamic> userMap = json.decode(response.body);
      log(userMap);
      var getZoneLocation = Getpalletlocationsmodel.fromMap(userMap);
      return getZoneLocation;
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
      rethrow;
    } on HttpException {
      log("Couldn't find the post 😱");
      final p = !hp.isDialogOpen &&
          await hp.showSimplePopup('OK', () {
            hp.goBack(result: true);
          },
              title: 'Setinhand',
              type: AlertType.cupertino,
              action: 'Service not found. Please try later.....');
      if (p) {
        hp.goBack();
      }
      rethrow;
    } on FormatException {
      log('Bad response format 👎');
      final p = !hp.isDialogOpen &&
          await hp.showSimplePopup('OK', () {
            hp.goBack(result: true);
          },
              title: 'Setinhand',
              type: AlertType.cupertino,
              action: 'Server error. Please try later.....');
      if (p) {
        hp.goBack();
      }
      rethrow;
    } on ClientException {
      log('Hi');
      final p = !hp.isDialogOpen &&
          await hp.showSimplePopup('OK', () {
            hp.goBack(result: true);
          },
              title: 'Setinhand',
              type: AlertType.cupertino,
              action: 'Unknown error. Please try later.....');
      if (p) {
        hp.goBack();
      }
      rethrow;
    } finally {
      client.close();
    }
    // catch (e) {
    //  sendAppLog(e);
    //   client.close();
    //   rethrow;
    // }
  }

  Future<Reply> getFullScanResult(Map<String, dynamic> body, Helper hp) async {
    final client = Client();
    try {
      final url = Uri.tryParse('${baseURL}scanLocations') ?? Uri();
      final response = await client.post(url, body: body);
      client.close();
      final data = json.decode(response.body);
      final rp = Reply.fromMap(data);
      return response.statusCode == 200 ? rp : Reply.emptyReply;
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
      rethrow;
    } on HttpException {
      log("Couldn't find the post 😱");
      final p = !hp.isDialogOpen &&
          await hp.showSimplePopup('OK', () {
            hp.goBack(result: true);
          },
              title: 'Setinhand',
              type: AlertType.cupertino,
              action: 'Service not found. Please try later.....');
      if (p) {
        hp.goBack();
      }
      rethrow;
    } on FormatException {
      log('Bad response format 👎');
      final p = !hp.isDialogOpen &&
          await hp.showSimplePopup('OK', () {
            hp.goBack(result: true);
          },
              title: 'Setinhand',
              type: AlertType.cupertino,
              action: 'Server error. Please try later.....');
      if (p) {
        hp.goBack();
      }
      rethrow;
    } on ClientException {
      log('Hi');
      final p = !hp.isDialogOpen &&
          await hp.showSimplePopup('OK', () {
            hp.goBack(result: true);
          },
              title: 'Setinhand',
              type: AlertType.cupertino,
              action: 'Unknown error. Please try later.....');
      if (p) {
        hp.goBack();
      }
      rethrow;
    } finally {
      client.close();
    }
    // catch (e) {
    //  sendAppLog(e);
    //   client.close();
    //   rethrow;
    // }
  }

  Future<Values> getCycleOrFullScanResult(
      Map<String, dynamic> body, Helper hp) async {
    final client = Client();
    try {
      log(body);
      final url = Uri.tryParse('${baseURL}stockBlockAndComplete') ?? Uri();
      final response = await client.post(url, body: body);
      client.close();
      log(response.body);
      final data = json.decode(response.body);
      final val = Values.fromMap(data);
      // box.value = val.perBox;
      // tec.text = val.awaitedQty > -1 ? val.awaitedQty.toString() : '';
      // box.notifyListeners();
      // update.notifyListeners();
      return response.statusCode == 200 ? val : Values.emptyValue;
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
      rethrow;
    } on HttpException {
      log("Couldn't find the post 😱");
      final p = !hp.isDialogOpen &&
          !hp.isDialogOpen &&
          await hp.showSimplePopup('OK', () {
            hp.goBack(result: true);
          },
              title: 'Setinhand',
              type: AlertType.cupertino,
              action: 'Service not found. Please try later.....');
      if (p) {
        hp.goBack();
      }
      rethrow;
    } on FormatException {
      log('Bad response format 👎');
      final p = !hp.isDialogOpen &&
          await hp.showSimplePopup('OK', () {
            hp.goBack(result: true);
          },
              title: 'Setinhand',
              type: AlertType.cupertino,
              action: 'Server error. Please try later.....');
      if (p) {
        hp.goBack();
      }
      rethrow;
    } on ClientException {
      log('Hi');
      final p = !hp.isDialogOpen &&
          await hp.showSimplePopup('OK', () {
            hp.goBack(result: true);
          },
              title: 'Setinhand',
              type: AlertType.cupertino,
              action: 'Unknown error. Please try later.....');
      if (p) {
        hp.goBack();
      }
      rethrow;
    } finally {
      client.close();
    }
    // catch (e) {
    //  sendAppLog(e);
    //   client.close();
    //   rethrow;
    // }
  }

  Future<UpdateQrcodemodel> addDiscrepencies(
      String deliveryId,
      String stockCode,
      String box,
      String qtybox,
      String action,
      Helper hp) async {
    final client = Client();
    try {
      final url = Uri.tryParse('${baseURL}updatebox') ?? Uri();
      log(url);
      final body = {
        'delivery_Id': deliveryId,
        'created_by': currentUser.value.userID.toString(),
        'stockcode': stockCode,
        'box': box,
        'qty_per_box': qtybox,
        'action': action,
      };
      log(body);
      final response = await client.post(url, body: body);
      client.close();
      log(response.body);
      Map<String, dynamic> userMap = json.decode(response.body);
      var deliverystock = UpdateQrcodemodel.fromMap(userMap);
      return deliverystock;
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
      rethrow;
    } on HttpException {
      log("Couldn't find the post 😱");
      final p = !hp.isDialogOpen &&
          await hp.showSimplePopup('OK', () {
            hp.goBack(result: true);
          },
              title: 'Setinhand',
              type: AlertType.cupertino,
              action: 'Service not found. Please try later.....');
      if (p) {
        hp.goBack();
      }
      rethrow;
    } on FormatException {
      log('Bad response format 👎');
      final p = !hp.isDialogOpen &&
          await hp.showSimplePopup('OK', () {
            hp.goBack(result: true);
          },
              title: 'Setinhand',
              type: AlertType.cupertino,
              action: 'Server error. Please try later.....');
      if (p) {
        hp.goBack();
      }
      rethrow;
    } on ClientException {
      log('Hi');
      final p = !hp.isDialogOpen &&
          await hp.showSimplePopup('OK', () {
            hp.goBack(result: true);
          },
              title: 'Setinhand',
              type: AlertType.cupertino,
              action: 'Unknown error. Please try later.....');
      if (p) {
        hp.goBack();
      }
      rethrow;
    } finally {
      client.close();
    }
    // catch (e) {
    //  sendAppLog(e);
    //   client.close();
    //   rethrow;
    // }
  }

  Future<Map<String, dynamic>> getPullScanResult(
      Map<String, dynamic> body, Helper hp) async {
    final client = Client();
    try {
      final url = Uri.tryParse('${baseURL}locationCheck') ?? Uri();
      final response = await client.post(url, body: body);
      client.close();
      final data = json.decode(response.body);
      return data;
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
      rethrow;
    } on HttpException {
      log("Couldn't find the post 😱");
      final p = !hp.isDialogOpen &&
          await hp.showSimplePopup('OK', () {
            hp.goBack(result: true);
          },
              title: 'Setinhand',
              type: AlertType.cupertino,
              action: 'Service not found. Please try later.....');
      if (p) {
        hp.goBack();
      }
      rethrow;
    } on FormatException {
      log('Bad response format 👎');
      final p = !hp.isDialogOpen &&
          await hp.showSimplePopup('OK', () {
            hp.goBack(result: true);
          },
              title: 'Setinhand',
              type: AlertType.cupertino,
              action: 'Server error. Please try later.....');
      if (p) {
        hp.goBack();
      }
      rethrow;
    } on ClientException {
      log('Hi');
      final p = !hp.isDialogOpen &&
          await hp.showSimplePopup('OK', () {
            hp.goBack(result: true);
          },
              title: 'Setinhand',
              type: AlertType.cupertino,
              action: 'Unknown error. Please try later.....');
      if (p) {
        hp.goBack();
      }
      rethrow;
    } finally {
      client.close();
    }
    // catch (e) {
    //  sendAppLog(e);
    //   client.close();
    //   rethrow;
    // }
  }

  Future<bool> getStockInfo(Map<String, dynamic> body, Helper hp) async {
    final client = Client();
    try {
      log(body);
      final url = Uri.tryParse('${baseURL}getStockInfo') ?? Uri();
      final response = await client.post(url, body: body);
      client.close();
      log(response.body);
      log(response.statusCode);
      final data = json.decode(response.body);
      final stb = StockItemBase.fromMap(data);
      log(stb.items.length);
      log('flag');
      stocks.value = stb.items;
      stb.onChange();
      return response.statusCode == 200 && stb.success;
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
      rethrow;
    } on HttpException {
      log("Couldn't find the post 😱");
      final p = !hp.isDialogOpen &&
          await hp.showSimplePopup('OK', () {
            hp.goBack(result: true);
          },
              title: 'Setinhand',
              type: AlertType.cupertino,
              action: 'Service not found. Please try later.....');
      if (p) {
        hp.goBack();
      }
      rethrow;
    } on FormatException {
      log('Bad response format 👎');
      final p = !hp.isDialogOpen &&
          await hp.showSimplePopup('OK', () {
            hp.goBack(result: true);
          },
              title: 'Setinhand',
              type: AlertType.cupertino,
              action: 'Server error. Please try later.....');
      if (p) {
        hp.goBack();
      }
      rethrow;
    } on ClientException {
      log('Hi');
      final p = !hp.isDialogOpen &&
          await hp.showSimplePopup('OK', () {
            hp.goBack(result: true);
          },
              title: 'Setinhand',
              type: AlertType.cupertino,
              action: 'Unknown error. Please try later.....');
      if (p) {
        hp.goBack();
      }
      rethrow;
    } finally {
      client.close();
    }
    // catch (e) {
    //  sendAppLog(e);
    //   client.close();
    //   return false;
    // }
  }

  Future<PullScanOutput> getPullStockStatus(
      Map<String, dynamic> body, Helper hp) async {
    final client = Client();
    try {
      final url = Uri.tryParse('${baseURL}stockCheck') ?? Uri();
      final response = await client.post(url, body: body);
      client.close();
      // log(body);
      // log(response.body);
      final data = json.decode(response.body) as Map<String, dynamic>;
      return PullScanOutput.fromMap(data);
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
      rethrow;
    } on HttpException {
      log("Couldn't find the post 😱");
      final p = !hp.isDialogOpen &&
          await hp.showSimplePopup('OK', () {
            hp.goBack(result: true);
          },
              title: 'Setinhand',
              type: AlertType.cupertino,
              action: 'Service not found. Please try later.....');
      if (p) {
        hp.goBack();
      }
      rethrow;
    } on FormatException {
      log('Bad response format 👎');
      final p = !hp.isDialogOpen &&
          await hp.showSimplePopup('OK', () {
            hp.goBack(result: true);
          },
              title: 'Setinhand',
              type: AlertType.cupertino,
              action: 'Server error. Please try later.....');
      if (p) {
        hp.goBack();
      }
      rethrow;
    } on ClientException {
      log('Hi');
      final p = !hp.isDialogOpen &&
          await hp.showSimplePopup('OK', () {
            hp.goBack(result: true);
          },
              title: 'Setinhand',
              type: AlertType.cupertino,
              action: 'Unknown error. Please try later.....');
      if (p) {
        hp.goBack();
      }
      rethrow;
    } finally {
      client.close();
    }
    // catch (e) {
    //  sendAppLog(e);
    //   client.close();
    //   rethrow;
    // }
  }

  Future<Reply> partialComplete(Map<String, dynamic> body, Helper hp) async {
    final client = Client();
    try {
      final url = Uri.tryParse('${baseURL}deliveryPartialcomplete') ?? Uri();
      final response = await client.post(url, body: body);
      client.close();
      final data = json.decode(response.body);
      final rp = Reply.fromMap(data);
      return response.statusCode == 200 ? rp : Reply.emptyReply;
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
      rethrow;
    } on HttpException {
      log("Couldn't find the post 😱");
      final p = !hp.isDialogOpen &&
          await hp.showSimplePopup('OK', () {
            hp.goBack(result: true);
          },
              title: 'Setinhand',
              type: AlertType.cupertino,
              action: 'Service not found. Please try later.....');
      if (p) {
        hp.goBack();
      }
      rethrow;
    } on FormatException {
      log('Bad response format 👎');
      final p = !hp.isDialogOpen &&
          await hp.showSimplePopup('OK', () {
            hp.goBack(result: true);
          },
              title: 'Setinhand',
              type: AlertType.cupertino,
              action: 'Server error. Please try later.....');
      if (p) {
        hp.goBack();
      }
      rethrow;
    } on ClientException {
      log('Hi');
      final p = !hp.isDialogOpen &&
          await hp.showSimplePopup('OK', () {
            hp.goBack(result: true);
          },
              title: 'Setinhand',
              type: AlertType.cupertino,
              action: 'Unknown error. Please try later.....');
      if (p) {
        hp.goBack();
      }
      rethrow;
    } finally {
      client.close();
    }
    // catch (e) {
    //  sendAppLog(e);
    //   client.close();
    //   rethrow;
    // }
  }

  Future<Quantities> completeStockCheck(
      Map<String, dynamic> body, Helper hp) async {
    final client = Client();
    try {
      log(body);
      final url = Uri.tryParse('${baseURL}stockCheckComplete') ?? Uri();
      final response = await client.post(url, body: body);
      client.close();
      log(response.statusCode);
      log(response.body);
      final data = json.decode(response.body) as Map<String, dynamic>;
      final qt = response.statusCode == 200
          ? Quantities.fromMap(data)
          : Quantities.emptyQuantity;
      return qt;
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
      rethrow;
    } on HttpException {
      log("Couldn't find the post 😱");
      final p = !hp.isDialogOpen &&
          await hp.showSimplePopup('OK', () {
            hp.goBack(result: true);
          },
              title: 'Setinhand',
              type: AlertType.cupertino,
              action: 'Service not found. Please try later.....');
      if (p) {
        hp.goBack();
      }
      rethrow;
    } on FormatException {
      log('Bad response format 👎');
      final p = !hp.isDialogOpen &&
          await hp.showSimplePopup('OK', () {
            hp.goBack(result: true);
          },
              title: 'Setinhand',
              type: AlertType.cupertino,
              action: 'Server error. Please try later.....');
      if (p) {
        hp.goBack();
      }
      rethrow;
    } on ClientException {
      log('Hi');
      final p = !hp.isDialogOpen &&
          await hp.showSimplePopup('OK', () {
            hp.goBack(result: true);
          },
              title: 'Setinhand',
              type: AlertType.cupertino,
              action: 'Unknown error. Please try later.....');
      if (p) {
        hp.goBack();
      }
      rethrow;
    } finally {
      client.close();
    }
    // catch (e) {
    //  sendAppLog(e);
    //   client.close();
    //   rethrow;
    // }
  }

  Future<List<GetNotification>> showNotificationAPI(Helper hp) async {
    final client = Client();
    try {
      final url = Uri.tryParse('${baseURL}showNotification') ?? Uri();
      final response = await client
          .post(url, body: {'user_id': currentUser.value.userID.toString()});
      client.close();
      log(response.statusCode);
      log(response.body);
      Map<String, dynamic> userMap = json.decode(response.body);
      // var deliverystock = ShowNotification.fromMap(userMap);
      // return deliverystock;
      return response.statusCode == 200
          ? ShowNotification.fromMap(userMap).getNotification
          : <GetNotification>[];
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
      rethrow;
    } on HttpException {
      log("Couldn't find the post 😱");
      final p = !hp.isDialogOpen &&
          await hp.showSimplePopup('OK', () {
            hp.goBack(result: true);
          },
              title: 'Setinhand',
              type: AlertType.cupertino,
              action: 'Service not found. Please try later.....');
      if (p) {
        hp.goBack();
      }
      rethrow;
    } on FormatException {
      log('Bad response format 👎');
      final p = !hp.isDialogOpen &&
          await hp.showSimplePopup('OK', () {
            hp.goBack(result: true);
          },
              title: 'Setinhand',
              type: AlertType.cupertino,
              action: 'Server error. Please try later.....');
      if (p) {
        hp.goBack();
      }
      rethrow;
    } on ClientException {
      log('Hi');
      final p = !hp.isDialogOpen &&
          await hp.showSimplePopup('OK', () {
            hp.goBack(result: true);
          },
              title: 'Setinhand',
              type: AlertType.cupertino,
              action: 'Unknown error. Please try later.....');
      if (p) {
        hp.goBack();
      }
      rethrow;
    } finally {
      client.close();
    }
    // catch (e) {
    //  sendAppLog(e);
    //   client.close();
    //   rethrow;
    // }
  }

  Future<Reply> updateCycleStockZero(
      Map<String, dynamic> body, Helper hp) async {
    final client = Client();
    try {
      final url = Uri.tryParse('${baseURL}updatezerostockquantity') ?? Uri();
      final response = await client.post(url, body: body);
      client.close();
      final data = json.decode(response.body);
      final rp = Reply.fromMap(data);
      return response.statusCode == 200 ? rp : Reply.emptyReply;
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
      rethrow;
    } on HttpException {
      log("Couldn't find the post 😱");
      final p = !hp.isDialogOpen &&
          await hp.showSimplePopup('OK', () {
            hp.goBack(result: true);
          },
              title: 'Setinhand',
              type: AlertType.cupertino,
              action: 'Service not found. Please try later.....');
      if (p) {
        hp.goBack();
      }
      rethrow;
    } on FormatException {
      log('Bad response format 👎');
      final p = !hp.isDialogOpen &&
          await hp.showSimplePopup('OK', () {
            hp.goBack(result: true);
          },
              title: 'Setinhand',
              type: AlertType.cupertino,
              action: 'Server error. Please try later.....');
      if (p) {
        hp.goBack();
      }
      rethrow;
    } on ClientException {
      log('Hi');
      final p = !hp.isDialogOpen &&
          await hp.showSimplePopup('OK', () {
            hp.goBack(result: true);
          },
              title: 'Setinhand',
              type: AlertType.cupertino,
              action: 'Unknown error. Please try later.....');
      if (p) {
        hp.goBack();
      }
      rethrow;
    } finally {
      client.close();
    }
    // catch (e) {
    //  sendAppLog(e);
    //   client.close();
    //   rethrow;
    // }
  }

  Future<OtherData> scanStockMovement(String location, Helper hp) async {
    final client = Client();
    try {
      final url = Uri.tryParse('${baseURL}scanstockmovementLocations') ?? Uri();
      final response = await client.post(url, body: {'unique_id': location});
      client.close();
      final data = json.decode(response.body);
      final od = OtherData.fromMap(data);
      return response.statusCode == 200 ? od : OtherData.emptyData;
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
      rethrow;
    } on HttpException {
      log("Couldn't find the post 😱");
      final p = !hp.isDialogOpen &&
          await hp.showSimplePopup('OK', () {
            hp.goBack(result: true);
          },
              title: 'Setinhand',
              type: AlertType.cupertino,
              action: 'Service not found. Please try later.....');
      if (p) {
        hp.goBack();
      }
      rethrow;
    } on FormatException {
      log('Bad response format 👎');
      final p = !hp.isDialogOpen &&
          await hp.showSimplePopup('OK', () {
            hp.goBack(result: true);
          },
              title: 'Setinhand',
              type: AlertType.cupertino,
              action: 'Server error. Please try later.....');
      if (p) {
        hp.goBack();
      }
      rethrow;
    } on ClientException {
      log('Hi');
      final p = !hp.isDialogOpen &&
          await hp.showSimplePopup('OK', () {
            hp.goBack(result: true);
          },
              title: 'Setinhand',
              type: AlertType.cupertino,
              action: 'Unknown error. Please try later.....');
      if (p) {
        hp.goBack();
      }
      rethrow;
    } finally {
      client.close();
    }
    // catch (e) {
    //  sendAppLog(e);
    //   client.close();
    //   rethrow;
    // }
  }

  Future<ReadNotification> readNotificationAPI(
      String notificationId, Helper hp) async {
    final client = Client();
    try {
      final url = Uri.parse('${baseURL}markread/$notificationId');
      final response = await client.get(url);
      client.close();
      final data = json.decode(response.body);
      return response.statusCode == 200
          ? ReadNotification.fromMap(data)
          : ReadNotification(false, 'Api failure');
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
      rethrow;
    } on HttpException {
      log("Couldn't find the post 😱");
      final p = !hp.isDialogOpen &&
          await hp.showSimplePopup('OK', () {
            hp.goBack(result: true);
          },
              title: 'Setinhand',
              type: AlertType.cupertino,
              action: 'Service not found. Please try later.....');
      if (p) {
        hp.goBack();
      }
      rethrow;
    } on FormatException {
      log('Bad response format 👎');
      final p = !hp.isDialogOpen &&
          await hp.showSimplePopup('OK', () {
            hp.goBack(result: true);
          },
              title: 'Setinhand',
              type: AlertType.cupertino,
              action: 'Server error. Please try later.....');
      if (p) {
        hp.goBack();
      }
      rethrow;
    } on ClientException {
      log('Hi');
      final p = !hp.isDialogOpen &&
          await hp.showSimplePopup('OK', () {
            hp.goBack(result: true);
          },
              title: 'Setinhand',
              type: AlertType.cupertino,
              action: 'Unknown error. Please try later.....');
      if (p) {
        hp.goBack();
      }
      rethrow;
    } finally {
      client.close();
    }
    // catch (e) {
    //  sendAppLog(e);
    //   client.close();
    //   rethrow;
    // }
  }

  Future<Reply> sendchat(Map<String, dynamic> body, Helper hp) async {
    final client = Client();
    try {
      final url = Uri.tryParse('${baseURL}sendchat') ?? Uri();
      final response = await client.post(url, body: body);
      client.close();
      log(response.body);
      final data = json.decode(response.body);
      final rp = Reply.fromMap(data);
      return response.statusCode == 200 ? rp : Reply.emptyReply;
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
      rethrow;
    } on HttpException {
      log("Couldn't find the post 😱");
      final p = !hp.isDialogOpen &&
          await hp.showSimplePopup('OK', () {
            hp.goBack(result: true);
          },
              title: 'Setinhand',
              type: AlertType.cupertino,
              action: 'Service not found. Please try later.....');
      if (p) {
        hp.goBack();
      }
      rethrow;
    } on FormatException {
      log('Bad response format 👎');
      final p = !hp.isDialogOpen &&
          await hp.showSimplePopup('OK', () {
            hp.goBack(result: true);
          },
              title: 'Setinhand',
              type: AlertType.cupertino,
              action: 'Server error. Please try later.....');
      if (p) {
        hp.goBack();
      }
      rethrow;
    } on ClientException {
      log('Hi');
      final p = !hp.isDialogOpen &&
          await hp.showSimplePopup('OK', () {
            hp.goBack(result: true);
          },
              title: 'Setinhand',
              type: AlertType.cupertino,
              action: 'Unknown error. Please try later.....');
      if (p) {
        hp.goBack();
      }
      rethrow;
    } finally {
      client.close();
    }
    // catch (e) {
    //  sendAppLog(e);
    //   client.close();
    //   rethrow;
    // }
  }

  Future<Reply> completeCycleOrFullStock(
      Map<String, dynamic> body, Helper hp) async {
    final client = Client();
    try {
      final url = Uri.tryParse('${baseURL}finalizeTask') ?? Uri();
      final response = await client.post(url, body: body);
      client.close();
      final data = json.decode(response.body) as Map<String, dynamic>;
      return Reply.fromMap(data);
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
      rethrow;
    } on HttpException {
      log("Couldn't find the post 😱");
      final p = !hp.isDialogOpen &&
          await hp.showSimplePopup('OK', () {
            hp.goBack(result: true);
          },
              title: 'Setinhand',
              type: AlertType.cupertino,
              action: 'Service not found. Please try later.....');
      if (p) {
        hp.goBack();
      }
      rethrow;
    } on FormatException {
      log('Bad response format 👎');
      final p = !hp.isDialogOpen &&
          await hp.showSimplePopup('OK', () {
            hp.goBack(result: true);
          },
              title: 'Setinhand',
              type: AlertType.cupertino,
              action: 'Server error. Please try later.....');
      if (p) {
        hp.goBack();
      }
      rethrow;
    } on ClientException {
      log('Hi');
      final p = !hp.isDialogOpen &&
          await hp.showSimplePopup('OK', () {
            hp.goBack(result: true);
          },
              title: 'Setinhand',
              type: AlertType.cupertino,
              action: 'Unknown error. Please try later.....');
      if (p) {
        hp.goBack();
      }
      rethrow;
    } finally {
      client.close();
    }
    // catch (e) {
    //  sendAppLog(e);
    //   client.close();
    //   rethrow;
    // }
  }

  Future<List<GetStockItemWareHouse>> warehouseDataAPI(
      String warehouseid, Helper hp) async {
    final client = Client();
    try {
      final url = Uri.parse('${baseURL}getmoveStockItems/$warehouseid');
      final response = await client.get(url);
      client.close();
      final data = json.decode(response.body);
      // Map<String, dynamic> userMap = json.decode(response.body);
      return response.statusCode == 200
          ? WarehouseData.fromMap(data).getStockItems
          : <GetStockItemWareHouse>[];
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
      rethrow;
    } on HttpException {
      log("Couldn't find the post 😱");
      final p = !hp.isDialogOpen &&
          await hp.showSimplePopup('OK', () {
            hp.goBack(result: true);
          },
              title: 'Setinhand',
              type: AlertType.cupertino,
              action: 'Service not found. Please try later.....');
      if (p) {
        hp.goBack();
      }
      rethrow;
    } on FormatException {
      log('Bad response format 👎');
      final p = !hp.isDialogOpen &&
          await hp.showSimplePopup('OK', () {
            hp.goBack(result: true);
          },
              title: 'Setinhand',
              type: AlertType.cupertino,
              action: 'Server error. Please try later.....');
      if (p) {
        hp.goBack();
      }
      rethrow;
    } on ClientException {
      log('Hi');
      final p = !hp.isDialogOpen &&
          await hp.showSimplePopup('OK', () {
            hp.goBack(result: true);
          },
              title: 'Setinhand',
              type: AlertType.cupertino,
              action: 'Unknown error. Please try later.....');
      if (p) {
        hp.goBack();
      }
      rethrow;
    } finally {
      client.close();
    }
    // catch (e) {
    //  sendAppLog(e);
    //   client.close();
    //   rethrow;
    // }
  }

  Future<GetQrCodeIdDetails> moveStocksQrcodeAPI(
      String scanedcode, Helper hp) async {
    final client = Client();
    try {
      final url = Uri.tryParse('${baseURL}getqrcodeid') ?? Uri();
      final response = await client.post(url, body: {
        'scanedcode': scanedcode,
      });
      client.close();
      log(response.statusCode);
      log(response.body);
      Map<String, dynamic> userMap = json.decode(response.body);
      return response.statusCode == 200
          ? GetQrCodeIdDetails.fromMap(userMap)
          : GetQrCodeIdDetails(false, '', 0);
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
      rethrow;
    } on HttpException {
      log("Couldn't find the post 😱");
      final p = !hp.isDialogOpen &&
          await hp.showSimplePopup('OK', () {
            hp.goBack(result: true);
          },
              title: 'Setinhand',
              type: AlertType.cupertino,
              action: 'Service not found. Please try later.....');
      if (p) {
        hp.goBack();
      }
      rethrow;
    } on FormatException {
      log('Bad response format 👎');
      final p = !hp.isDialogOpen &&
          await hp.showSimplePopup('OK', () {
            hp.goBack(result: true);
          },
              title: 'Setinhand',
              type: AlertType.cupertino,
              action: 'Server error. Please try later.....');
      if (p) {
        hp.goBack();
      }
      rethrow;
    } on ClientException {
      log('Hi');
      final p = !hp.isDialogOpen &&
          await hp.showSimplePopup('OK', () {
            hp.goBack(result: true);
          },
              title: 'Setinhand',
              type: AlertType.cupertino,
              action: 'Unknown error. Please try later.....');
      if (p) {
        hp.goBack();
      }
      rethrow;
    } finally {
      client.close();
    }
    // catch (e) {
    //  sendAppLog(e);
    //   client.close();
    //   rethrow;
    // }
  }

  Future<WarehouseIdGet> scanstockmovementLocations(
      String scanedcode, Helper hp) async {
    final client = Client();
    try {
      final url = Uri.tryParse('${baseURL}scanstockmovementLocations') ?? Uri();
      final response = await client.post(url, body: {
        'unique_id': scanedcode,
      });
      client.close();
      Map<String, dynamic> userMap = json.decode(response.body);
      return response.statusCode == 200
          ? WarehouseIdGet.fromMap(userMap)
          : WarehouseIdGet(false);
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
      rethrow;
    } on HttpException {
      log("Couldn't find the post 😱");
      final p = !hp.isDialogOpen &&
          await hp.showSimplePopup('OK', () {
            hp.goBack(result: true);
          },
              title: 'Setinhand',
              type: AlertType.cupertino,
              action: 'Service not found. Please try later.....');
      if (p) {
        hp.goBack();
      }
      rethrow;
    } on FormatException {
      log('Bad response format 👎');
      final p = !hp.isDialogOpen &&
          await hp.showSimplePopup('OK', () {
            hp.goBack(result: true);
          },
              title: 'Setinhand',
              type: AlertType.cupertino,
              action: 'Server error. Please try later.....');
      if (p) {
        hp.goBack();
      }
      rethrow;
    } on ClientException {
      log('Hi');
      final p = !hp.isDialogOpen &&
          await hp.showSimplePopup('OK', () {
            hp.goBack(result: true);
          },
              title: 'Setinhand',
              type: AlertType.cupertino,
              action: 'Unknown error. Please try later.....');
      if (p) {
        hp.goBack();
      }
      rethrow;
    } finally {
      client.close();
    }
    // catch (e) {
    //  sendAppLog(e);
    //   client.close();
    //   rethrow;
    // }
  }

  Future<OtherData> getFullStockScanResult(String code, int taskID) async {
    final client = Client();
    try {
      log(code);
      log(taskID);
      final url = Uri.tryParse('${baseURL}scanLocations') ?? Uri();
      final response = await client.post(url, body: {
        'unique_id': code,
        'task_id': taskID.toString(),
        'created_by': currentUser.value.userID.toString()
      });
      client.close();
      log(response.statusCode);
      log(response.body);
      final data = json.decode(response.body);
      final od = OtherData.fromMap(data);
      return response.statusCode == 200 ? od : OtherData.emptyData;
    } catch (e) {
      sendAppLog(e);

      client.close();
      rethrow;
    }
  }

  Future<Reply> assignPalletsLocations(
      String scanedcode, List<String> deliveryId, String customerid) async {
    final body = {
      'deliveryqrcodeIds': deliveryId,
      'unique_id': scanedcode,
      'customer_id': customerid
    };
    final url = Uri.parse('${baseURL}assignPalletLocation');
    final clientHttp = HttpClient();
    clientHttp.findProxy = null;
    final request = await clientHttp.postUrl(url);
    final reqStr = json.encode(body);
    log(body);
    request.headers.set('content-type', 'application/json');
    request.headers.contentType =
        ContentType('application', 'json', charset: 'utf-8');
    request.write(reqStr);
    try {
      final response = await request.close();
      clientHttp.close();
      final data = await response.transform(utf8.decoder).join();
      log(data);
      final rpl = Reply.fromMap(json.decode(data));
      count.value = 0;
      count.notifyListeners();
      return response.statusCode == 200 ? rpl : Reply(false, '');
    } catch (e) {
      count.value = 0;
      count.notifyListeners();
      sendAppLog(e);
      clientHttp.close(force: true);
      rethrow;
    }
  }

  Future<Reply> moveStocksAPI(
      String warehouseid, List<int> qrcodeids, Helper hp) async {
    final body = {
      'created_by': currentUser.value.userID.toString(),
      'warehouseid': warehouseid,
      'qrcodeids': qrcodeids
    };
    final url = Uri.tryParse('${baseURL}movetootherlocation') ?? Uri();
    final clientHttp = HttpClient();
    clientHttp.findProxy = null;
    final request = await clientHttp.postUrl(url);
    final reqStr = json.encode(body);
    log(body);
    request.headers.set('content-type', 'application/json');
    request.headers.contentType =
        ContentType('application', 'json', charset: 'utf-8');
    request.write(reqStr);
    try {
      final response = await request.close();
      clientHttp.close();
      final data = await response.transform<String>(utf8.decoder).join();
      log(data);
      final rpl = Reply.fromMap(json.decode(data));
      return response.statusCode == 200 ? rpl : Reply(false, '');
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
      rethrow;
    } on HttpException {
      log("Couldn't find the post 😱");
      final p = !hp.isDialogOpen &&
          await hp.showSimplePopup('OK', () {
            hp.goBack(result: true);
          },
              title: 'Setinhand',
              type: AlertType.cupertino,
              action: 'Service not found. Please try later.....');
      if (p) {
        hp.goBack();
      }
      rethrow;
    } on FormatException {
      log('Bad response format 👎');
      final p = !hp.isDialogOpen &&
          await hp.showSimplePopup('OK', () {
            hp.goBack(result: true);
          },
              title: 'Setinhand',
              type: AlertType.cupertino,
              action: 'Server error. Please try later.....');
      if (p) {
        hp.goBack();
      }
      rethrow;
    } on ClientException {
      log('Hi');
      final p = !hp.isDialogOpen &&
          await hp.showSimplePopup('OK', () {
            hp.goBack(result: true);
          },
              title: 'Setinhand',
              type: AlertType.cupertino,
              action: 'Unknown error. Please try later.....');
      if (p) {
        hp.goBack();
      }
      rethrow;
    } finally {
      clientHttp.close(force: true);
    }
    // catch (e) {
    //  sendAppLog(e);
    //   clientHttp.close(force: true);
    //   rethrow;
    // }
  }

  Future<Reply> storePullList(Map<String, dynamic> body, Helper hp) async {
    final client = Client();
    try {
      final url = Uri.tryParse('${baseURL}pulllistresponse') ?? Uri();
      final response = await client.post(url, body: body);
      client.close();
      log(response.body);
      final data = json.decode(response.body) as Map<String, dynamic>;
      return Reply.fromMap(data);
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
      rethrow;
    } on HttpException {
      log("Couldn't find the post 😱");
      final p = !hp.isDialogOpen &&
          await hp.showSimplePopup('OK', () {
            hp.goBack(result: true);
          },
              title: 'Setinhand',
              type: AlertType.cupertino,
              action: 'Service not found. Please try later.....');
      if (p) {
        hp.goBack();
      }
      rethrow;
    } on FormatException {
      log('Bad response format 👎');
      final p = !hp.isDialogOpen &&
          await hp.showSimplePopup('OK', () {
            hp.goBack(result: true);
          },
              title: 'Setinhand',
              type: AlertType.cupertino,
              action: 'Server error. Please try later.....');
      if (p) {
        hp.goBack();
      }
      rethrow;
    } on ClientException {
      log('Hi');
      final p = !hp.isDialogOpen &&
          await hp.showSimplePopup('OK', () {
            hp.goBack(result: true);
          },
              title: 'Setinhand',
              type: AlertType.cupertino,
              action: 'Unknown error. Please try later.....');
      if (p) {
        hp.goBack();
      }
      rethrow;
    } finally {
      client.close();
    }
    // catch (e) {
    //  sendAppLog(e);
    //   client.close();
    //   rethrow;
    // }
  }
}
