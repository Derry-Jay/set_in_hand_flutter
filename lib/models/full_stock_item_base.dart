import 'reply.dart';
import 'full_stock_item.dart';
import 'package:flutter/material.dart';

class FullStockItemBase extends ChangeNotifier {
  final Reply reply;
  final List<FullStockItem> items;
  FullStockItemBase(this.reply, this.items);
  void onChange() {
    notifyListeners();
  }

  factory FullStockItemBase.fromMap(Map<String, dynamic> json) {
    final list = List<Map<String, dynamic>>.from(json['getStockItems'] ?? []);
    return FullStockItemBase(
        Reply.fromMap(json),
        list.isEmpty
            ? <FullStockItem>[]
            : list.map(FullStockItem.fromMap).toList());
  }
}
