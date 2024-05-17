import '../helpers/helper.dart';
import 'package:flutter/material.dart';

class Task extends ChangeNotifier {
  final int mrNumber, taskID;
  final String customerName,
      status,
      userName,
      location,
      reason,
      details,
      lapsedTime;
  Task(this.taskID, this.customerName, this.status, this.userName,
      this.location, this.reason, this.details, this.mrNumber, this.lapsedTime);
  static Task emptyTask = Task(-1, '', '', '', '', '', '', -1, '');
  bool get isEmpty =>
      !(parseBool(taskID.toString()) || parseBool(mrNumber.toString())) &&
      status.isEmpty &&
      reason.isEmpty &&
      details.isEmpty &&
      userName.isEmpty &&
      location.isEmpty &&
      lapsedTime.isEmpty &&
      customerName.isEmpty;
  void onChange() {
    notifyListeners();
  }

  Map<String, dynamic> get map {
    Map<String, dynamic> kv = <String, dynamic>{};
    kv['task_id'] = taskID.toString();
    return kv;
  }

  Map<String, dynamic> get json {
    Map<String, dynamic> kvp = <String, dynamic>{};
    kvp['taskId'] = taskID.toString();
    kvp['customer_name'] = customerName;
    kvp['status'] = status;
    kvp['username'] = userName;
    kvp['locationcode'] = location;
    kvp['reason'] = reason;
    kvp['details'] = details;
    kvp['mr_number'] = mrNumber;
    kvp['timeelapsed'] = lapsedTime;
    return kvp;
  }

  factory Task.fromMap(Map<String, dynamic> json) {
    return Task(
        json['taskId'] ?? -1,
        json['customer_name'] ?? '',
        json['status'] ?? '',
        json['username'] ?? '',
        json['locationcode'] ?? (json['unique_id'] ?? ''),
        json['reason'] ?? '',
        json['details'] ?? '',
        json['mr_number'] ?? -1,
        json['timeelapsed'] ?? (json['date_started'] ?? ''));
  }

  @override
  bool operator ==(Object other) {
    // TODO: implement ==
    return other is Task && taskID == other.taskID;
  }

  @override
  // TODO: implement hashCode
  int get hashCode => taskID.hashCode;

  @override
  String toString() {
    // TODO: implement toString
    return '$userName has created a $status for $customerName. This is to go to $reason $details';
  }
}
