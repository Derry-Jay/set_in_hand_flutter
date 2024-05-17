import 'dart:convert';
import 'package:flutter/material.dart';

Getcompleteddeliveriesdetailsmodel getcompleteddeliveriesdetailsmodelFromJson(
        String str) =>
    Getcompleteddeliveriesdetailsmodel.fromJson(json.decode(str));

String getcompleteddeliveriesdetailsmodelToJson(
        Getcompleteddeliveriesdetailsmodel data) =>
    json.encode(data.toJson());

class Getcompleteddeliveriesdetailsmodel extends ChangeNotifier {
  Getcompleteddeliveriesdetailsmodel(
    this.success,
    this.deliveryData,
  );

  bool success;
  List<GetCompletedDeliveriesDetailDeliveryDatum> deliveryData;

  void onChange() {
    notifyListeners();
  }

  factory Getcompleteddeliveriesdetailsmodel.fromJson(
          Map<String, dynamic> json) =>
      Getcompleteddeliveriesdetailsmodel(
        json['success'],
        List<Map<String, dynamic>>.from(json['DeliveryData'])
            .map((x) => GetCompletedDeliveriesDetailDeliveryDatum.fromJson(x))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'success': success,
        'DeliveryData': List<dynamic>.from(deliveryData.map((x) => x.toJson())),
      };
}

class GetCompletedDeliveriesDetailDeliveryDatum {
  GetCompletedDeliveriesDetailDeliveryDatum(
      this.deliveryqrcodeId,
      this.stockItemId,
      this.qrcodetext,
      this.productCode,
      this.customerName,
      this.customerId,
      this.inputby,
      this.deliverydateId,
      this.deliveryDate,
      this.warehouseId,
      this.status,
      this.deliveryId,
      this.valueScanned);

  int? deliveryqrcodeId;
  String? stockItemId;
  String? qrcodetext;
  String? productCode;
  String? customerName;
  int? customerId;
  String? inputby;
  dynamic deliverydateId;
  String? deliveryDate;
  int? warehouseId;
  int? status;
  int? deliveryId;
  bool? valueScanned;

  factory GetCompletedDeliveriesDetailDeliveryDatum.fromJson(
          Map<String, dynamic> json) =>
      GetCompletedDeliveriesDetailDeliveryDatum(
        json['deliveryqrcodeId'] ?? 0,
        json['stock_item_id'] ?? '',
        json['qrcodetext'] ?? '',
        json['product_code'] ?? '',
        json['customer_name'] ?? '',
        json['customer_id'] ?? '',
        json['inputby'] ?? '',
        json['deliverydateId'] ?? '',
        json['delivery_date'],
        json['warehouse_id'] ?? 0,
        json['status'] ?? 0,
        json['deliveryId'] ?? 0,
        json['valueScanned'] ?? false,
      );

  Map<String, dynamic> toJson() => {
        'deliveryqrcodeId': deliveryqrcodeId ?? 0,
        'stock_item_id': stockItemId ?? '',
        'qrcodetext': qrcodetext ?? '',
        'product_code': productCode ?? '',
        'customer_name': customerName ?? '',
        'customer_id': customerId ?? '',
        'inputby': inputby ?? '',
        'deliverydateId': deliverydateId ?? '',
        'delivery_date': deliveryDate,
        'warehouse_id': warehouseId ?? 0,
        'status': status ?? 0,
        'deliveryId': deliveryId ?? 0,
        'valueScanned': valueScanned ?? false
      };
  
  @override
  String toString() {
    // TODO: implement toString
    return jsonEncode(toJson());
  }
}
