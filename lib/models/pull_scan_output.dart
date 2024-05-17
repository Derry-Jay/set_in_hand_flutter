import 'reply.dart';

class PullScanOutput {
  final Reply reply;
  final int qrID;
  final String productCode, quantityType;
  PullScanOutput(this.reply, this.qrID, this.productCode, this.quantityType);
  factory PullScanOutput.fromMap(Map<String, dynamic> map) {
    return PullScanOutput(Reply.fromMap(map), map['qr_code_id'] ?? -1,
        map['product_code'] ?? '', map['quantity_type'] ?? '');
  }
}
