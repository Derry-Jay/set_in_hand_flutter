import '../models/reply.dart';
import '../models/warehouse_item.dart';
import 'package:flutter/material.dart';

class WarehouseItemBase extends ChangeNotifier {
  final Reply reply;
  final List<WarehouseItem> warehouseitems;
  WarehouseItemBase(this.reply, this.warehouseitems);
  void onChange() {
    notifyListeners();
  }

  factory WarehouseItemBase.fromMap(Map<String, dynamic> map) {
    final json = map['data'];
    final list = json == null
        ? <Map<String, dynamic>>[]
        : (((json['stockcodedetails'] == null ||
                    json['stockcodedetails'] == []) &&
                (json['warehousedetails'] == null ||
                    json['warehousedetails'] == []) &&
                (json['boxdetails'] == null || json['boxdetails'] == []))
            ? <Map<String, dynamic>>[]
            : List<Map<String, dynamic>>.from(json['stockcodedetails'] ??
                (json['warehousedetails'] ?? json['boxdetails'])));
    return WarehouseItemBase(
        Reply.fromMap(map),
        list.isEmpty
            ? <WarehouseItem>[]
            : list.map<WarehouseItem>(WarehouseItem.fromMap).toList());
  }
}
