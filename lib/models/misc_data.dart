import 'reply.dart';
import '../helpers/helper.dart';
import 'package:flutter/material.dart';

class OtherData extends ChangeNotifier {
  final Reply reply;
  final dynamic data;
  OtherData(this.reply, this.data);
  void onChange() {
    notifyListeners();
  }

  static OtherData emptyData = OtherData(Reply.emptyReply, null);

  factory OtherData.fromMap(Map<String, dynamic> json) {
    return OtherData(
        Reply.fromMap(json),
        json['tasks'] ??
            (json['id'] ??
                (json['warehouse_id'] ??
                    (json['warehouseId'] ??
                        (json['count'] ??
                            ((gc?.getValue<String>('bucket_path') ?? '') +
                                json['filename'].toString()))))));
  }
}
