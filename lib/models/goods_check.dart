import 'task.dart';
import 'dart:convert';
import '../helpers/helper.dart';

class GoodsCheck {
  final Task task;
  final int stockCheckID, status;
  GoodsCheck(this.stockCheckID, this.status, this.task);
  static GoodsCheck emptyGood = GoodsCheck(-1, -1, Task.emptyTask);
  bool get isEmpty =>
      parseBool(stockCheckID.toString()) &&
      parseBool(status.toString()) &&
      task.isEmpty;
  Map<String, dynamic> get json {
    Map<String, dynamic> kvp = task.json;
    kvp['stockCheckId'] = stockCheckID;
    kvp['status'] = status;
    return kvp;
  }

  factory GoodsCheck.fromMap(Map<String, dynamic> json) {
    return GoodsCheck(json['stockCheckId'] ?? -1,
        int.tryParse(json['status'] ?? '-1') ?? -1, Task.fromMap(json));
  }

  @override
  String toString() {
    // TODO: implement toString
    return jsonEncode(json);
  }
}
