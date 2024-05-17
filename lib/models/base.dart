import 'task.dart';
import 'reply.dart';
import 'delivery.dart';
import 'package:flutter/material.dart';

class Base extends ChangeNotifier {
  final Reply reply;
  final List<Task> tasks;
  final List<Delivery> dues;
  Base(this.reply, this.tasks, this.dues);
  void onChange() {
    notifyListeners();
  }

  factory Base.fromMap(Map<String, dynamic> json) {
    final data = json['tasks'] as Map<String, dynamic>;
    final td = data['tasks'];
    final dd = data['deliveryDue'];
    final ltd = List<Map<String, dynamic>>.from(td ?? []);
    final dtd = List<Map<String, dynamic>>.from(dd ?? []);
    return Base(
        Reply.fromMap(json),
        ltd.isEmpty ? <Task>[] : ltd.map<Task>(Task.fromMap).toList(),
        dtd.map<Delivery>(Delivery.fromMap).toList());
  }
}
