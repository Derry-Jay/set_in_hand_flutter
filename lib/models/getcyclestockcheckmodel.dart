import 'dart:convert';
import '../helpers/helper.dart';
import 'package:flutter/material.dart';

Getcyclestockcheckmodel getcyclestockcheckmodelFromJson(String str) =>
    Getcyclestockcheckmodel.fromJson(json.decode(str));

String getcyclestockcheckmodelToJson(Getcyclestockcheckmodel data) =>
    json.encode(data.toJson());

class Getcyclestockcheckmodel extends ChangeNotifier {
  Getcyclestockcheckmodel({
    required this.success,
    required this.getStockItems,
  });

  bool success;
  List<GetStockItem> getStockItems;

  void onChange() {
    notifyListeners();
  }

  factory Getcyclestockcheckmodel.fromJson(Map<String, dynamic> json) {
    int sorter(GetStockItem val1, GetStockItem val2) {
      try {
        return (DateTime.tryParse(val1.createdAt)
                    ?.difference(DateTime.tryParse(val2.createdAt)!))
                ?.inDays ??
            0;
      } catch (e) {
        sendAppLog(e);
        return 0;
      }
    }

    final ls = List<Map<String, dynamic>>.from(json['getStockItems'] ?? [])
        .map<GetStockItem>(GetStockItem.fromJson)
        .toList();
    ls.sort(sorter);
    return Getcyclestockcheckmodel(
        success: json['success'] ?? false,
        getStockItems: json['getStockItems'] == null ? <GetStockItem>[] : ls);
  }

  Map<String, dynamic> toJson() => {
        'success': success,
        'getStockItems': List<dynamic>.from(getStockItems.map((x) => x.json)),
      };
}

class GetStockItem {
  GetStockItem(
      {required this.qrcodeId,
      required this.id,
      required this.customerName,
      required this.customerId,
      required this.status,
      required this.stockCheckStatus,
      required this.qtyExpected,
      required this.stockItemId,
      required this.uniqueId,
      required this.warehouseId,
      required this.createdAt});

  static GetStockItem emptyItem = GetStockItem(
      qrcodeId: -1,
      id: -1,
      customerName: '',
      customerId: -1,
      status: '',
      stockCheckStatus: -1,
      qtyExpected: 0,
      stockItemId: '',
      uniqueId: '',
      warehouseId: -1,
      createdAt: '');

  final String customerName, status, stockItemId, uniqueId, createdAt;
  final int qrcodeId,
      id,
      customerId,
      stockCheckStatus,
      qtyExpected,
      warehouseId;

  Map<String, dynamic> get map {
    Map<String, dynamic> kv = <String, dynamic>{};
    // kv['createdBy'] = customerId.toString();
    kv['warehouseId'] = warehouseId.toString();
    return kv;
  }

  Map<String, dynamic> get json {
    Map<String, dynamic> kvp = <String, dynamic>{};
    kvp = map;
    kvp['status'] = status;
    kvp['unique_id'] = uniqueId;
    kvp['customer_name'] = customerName;
    kvp['qty_expected'] = qtyExpected.toString();
    kvp['stock_item_id'] = stockItemId;
    kvp['stock_check_status'] = stockCheckStatus.toString();
    kvp['qrCodeID'] = qrcodeId.toString();
    kvp['id'] = id.toString();
    return kvp;
  }

  factory GetStockItem.fromJson(Map<String, dynamic> json) => GetStockItem(
      qrcodeId: json['qrcodeId'],
      id: json['id'],
      customerName: json['customer_name'],
      customerId: json['customerId'],
      status: json['status'],
      stockCheckStatus: int.tryParse(json['stock_check_status'] ?? '-1') ?? -1,
      qtyExpected: json['qty_expected'],
      stockItemId: json['stock_item_id'],
      uniqueId: json['unique_id'],
      warehouseId: json['warehouse_id'],
      createdAt: json['created_at']);

  @override
  bool operator ==(Object other) =>
      other is GetStockItem && other.qrcodeId == qrcodeId;

  @override
  // TODO: implement hashCode
  int get hashCode => id.hashCode;

  @override
  String toString() {
    // TODO: implement toString
    return json.toString();
  }
}
