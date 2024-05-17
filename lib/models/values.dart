import 'reply.dart';
import '../helpers/helper.dart';
import 'package:flutter/material.dart';

class Values extends ChangeNotifier {
  final Reply rp;
  final int awaitedQty, perBox, qrCodeID;
  Values(this.rp, this.awaitedQty, this.qrCodeID, this.perBox);
  static Values emptyValue = Values(Reply.emptyReply, 0, -1, 0);
  void onChange() {
    notifyListeners();
  }

  factory Values.fromMap(Map<String, dynamic> json) {
    log(json);
    return Values(Reply.fromMap(json), json['expectedQuantity'] ?? -1,
        json['qrCodeId'] ?? -1, json['box_qty'] ?? -1);
  }
}
