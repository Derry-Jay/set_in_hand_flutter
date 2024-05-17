import 'package:quiver/core.dart';
import 'package:flutter/material.dart';

class StockItem {
  final int qrID,
      mrID,
      whID,
      awaitedQuantity,
      quantityPerBox,
      moveRequestID,
      deliveryID,
      customerID,
      perBox,
      format,
      shownQuantity,
      manualPull,
      removeID,
      remainingCards;
  final String customerName,
      reason,
      details,
      productCode,
      stockItemID,
      qrText,
      uniqueID,
      quantityType,
      deliveryDate;
  StockItem(
      this.qrID,
      this.customerName,
      this.mrID,
      this.reason,
      this.details,
      this.productCode,
      this.stockItemID,
      this.qrText,
      this.whID,
      this.uniqueID,
      this.awaitedQuantity,
      this.quantityPerBox,
      this.moveRequestID,
      this.deliveryID,
      this.customerID,
      this.perBox,
      this.format,
      this.quantityType,
      this.manualPull,
      this.shownQuantity,
      this.removeID,
      this.remainingCards,
      this.deliveryDate);

  Map<String, dynamic> get map {
    Map<String, dynamic> mp = <String, dynamic>{};
    mp['delivery_id'] = deliveryID.toString();
    mp['mr_id'] = moveRequestID.toString();
    mp['qr_code_id'] = qrID.toString();
    mp['stockcode'] = productCode;
    mp['warehouse_id'] = whID.toString();
    return mp;
  }

  Map<String, dynamic> get json {
    Map<String, dynamic> kv = <String, dynamic>{};
    kv['qr_code_id'] = qrID.toString();
    kv['mr_id'] = mrID.toString();
    kv['warehouse_id'] = whID.toString();
    kv['delivery_id'] = deliveryID.toString();
    kv['stockcode'] = productCode;
    kv['qrcodetext'] = qrText;
    kv['expectedqty'] = awaitedQuantity.toString();
    return kv;
  }

  List<String> get values {
    return <String>[
      uniqueID,
      productCode,
      quantityType,
      awaitedQuantity.toString()
    ];
  }

  factory StockItem.fromMap(Map<String, dynamic> body) {
    return StockItem(
        body['qrCodeId'] ?? 0,
        body['customer_name'] ?? '',
        body['mr_number'] ?? 0,
        body['reason'] ?? '',
        body['details'] ?? '',
        body['product_code'] ?? (body['stockitem'] ?? ''),
        body['stock_item_id'] ?? (body['stockitem'] ?? ''),
        body['qrcodetext'] ?? '',
        body['warehouse_id'] ?? (body['warehouseId'] ?? -1),
        body['unique_id'] ?? '',
        body['expectedqty'] ??
            (body['qty_expected'] ?? (body['expectedQuantity'] ?? 0)),
        body['quantity_per_box'] is int
            ? body['quantity_per_box']
            : (int.tryParse(body['quantity_per_box'] == null
                    ? '0'
                    : (body['quantity_per_box'] is String
                        ? body['quantity_per_box']
                        : body['quantity_per_box'].toString())) ??
                (body['box_qty'] ?? 0)),
        body['moveReqId'] ?? 0,
        body['deliveryId'] ?? 0,
        body['customersId'] ?? 0,
        body['perbox'] ?? (body['qr_perbox'] ?? (body['box_qty'] ?? 0)),
        body['format'] ?? -1,
        body['quantity_type'] ?? '',
        body['manualPull'] ?? -1,
        body['show_qty'] ?? 0,
        body['remove_id'] ?? -1,
        body['remaining_cards'] ?? -1,
        body['delivery_date'] ?? '');
  }

  bool isIn(List<StockItem> items) {
    bool flag = false;
    if (items.isEmpty) {
      return items.isNotEmpty;
    } else {
      for (StockItem item in items) {
        if (item == this) {
          flag = true;
          break;
        }
      }
      return flag;
    }
  }

  @override
  String toString() {
    // TODO: implement toString
    return json.toString();
  }

  @override
  bool operator ==(Object other) => other is StockItem && other.qrID == qrID;

  @override
  // TODO: implement hashCode
  int get hashCode => hash4(qrID.hashCode, moveRequestID.hashCode,
      deliveryID.hashCode, whID.hashCode);
}

class StockItemBase extends ChangeNotifier {
  final bool success;
  final List<StockItem> items;
  final int remainingQuantity;
  StockItemBase(this.success, this.remainingQuantity, this.items);
  void onChange() {
    notifyListeners();
  }

  factory StockItemBase.fromMap(Map<String, dynamic> json) {
    final list = List<Map<String, dynamic>>.from(json['getStockPullItems'] ??
        (json['get_stock_info'] ??
            ((json['data'] == null
                    ? null
                    : (json['data']['warehousedetails'] ??
                        json['data']['boxdetails'])) ??
                [])));
    return StockItemBase(json['success'], json['remaining_qty'] ?? -1,
        list.isEmpty ? <StockItem>[] : list.map(StockItem.fromMap).toList());
  }
}
