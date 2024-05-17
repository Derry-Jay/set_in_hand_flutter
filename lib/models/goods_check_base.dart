import 'reply.dart';
import 'goods_check.dart';
import '../helpers/helper.dart';
import 'package:flutter/material.dart';


class GoodsCheckBase extends ChangeNotifier {
  final Reply reply;
  final List<GoodsCheck> lows, highs;
  GoodsCheckBase(this.reply, this.lows, this.highs);
  List<Map<String, dynamic>> get itemsMap {
    List<Map<String, dynamic>> items =
        List<Map<String, dynamic>>.empty(growable: true);
    for (int i = 0; i < maxOfTwo(lows.length, highs.length); i++) {
      final l = i >= lows.length ? GoodsCheck.emptyGood : lows[i];
      final h = i >= highs.length ? GoodsCheck.emptyGood : highs[i];
      final map = {
        'Low Pallet Locations': l.task.location,
        'High Pallet Locations': h.task.location
      };
      items.add(map);
    }
    return items;
  }

  void onChange() {
    notifyListeners();
  }

  factory GoodsCheckBase.fromMap(Map<String, dynamic> json) {
    final data = json['palletLocations'] as Map<String, dynamic>;
    final lml = List<Map<String, dynamic>>.from(data['lowValues'] ?? []);
    final hml = List<Map<String, dynamic>>.from(data['highValues'] ?? []);
    final ll =
        lml.isEmpty ? <GoodsCheck>[] : lml.map<GoodsCheck>(GoodsCheck.fromMap).toList();
    final hl =
        hml.isEmpty ? <GoodsCheck>[] : hml.map<GoodsCheck>(GoodsCheck.fromMap).toList();
    return GoodsCheckBase(Reply.fromMap(json), ll, hl);
  }
}
