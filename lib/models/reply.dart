import 'package:flutter/material.dart';

class Reply extends ChangeNotifier {
  final bool success;
  final String message;
  Reply(this.success, this.message);
  void onChange() {
    notifyListeners();
  }

  factory Reply.fromMap(Map<String, dynamic> json) {
    return Reply(
        json['success'] ?? false,
        (json['message'] ??
                (json['Data'] ??
                    (json['isfrom'] ??
                        (json['error'] ??
                            (json['type'] ??
                                ((json['userData'] is String
                                        ? json['userData']
                                        : '') ??
                                    ((json['success'] ?? false)
                                        ? 'Success'
                                        : 'Error')))))))
            .toString()
            .trim());
  }

  static Reply emptyReply = Reply(false, 'Error');
}
