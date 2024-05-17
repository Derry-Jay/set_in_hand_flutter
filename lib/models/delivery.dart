import '../helpers/helper.dart';
import 'package:flutter/material.dart';

class Delivery extends ChangeNotifier {
  final int deliveryID;
  final bool allowRedirect;
  final String customerName, lapsedTime, createdAt;
  Delivery(this.allowRedirect, this.deliveryID, this.customerName,
      this.createdAt, this.lapsedTime);
  void onChange() {
    notifyListeners();
  }

  static Delivery emptyDelivery = Delivery(false, -1, '', '', '');

  Map<String, dynamic> get json {
    Map<String, dynamic> map = <String, dynamic>{};
    map['deliveryId'] = deliveryID;
    map['customer_name'] = customerName;
    return map;
  }

  factory Delivery.fromMap(Map<String, dynamic> json) {
    return Delivery(
        parseBool(json['allow_redirect']?.toString() ?? '0'),
        json['deliveryId'] ?? json['subsetDeliveryId'],
        json['customer_name'] ?? '',
        json['created_at'] ?? '',
        json['timeelapsed'] ?? '');
  }

  @override
  String toString() {
    // TODO: implement toString
    return '$customerName ($deliveryID) has activated a stock';
  }
}
