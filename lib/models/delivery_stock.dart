import 'dart:convert';
import '../helpers/helper.dart';
import 'package:quiver/core.dart';

DeliveryStockModel deliveryStockModelFromMap(String str) =>
    DeliveryStockModel.fromMap(json.decode(str));

String deliveryStockModelToMap(DeliveryStockModel data) =>
    json.encode(data.toMap());

class DeliveryStockModel {
  bool success;
  String job, note, date;
  int scanedCount, totalbox;
  List<DeliveryStockData> data;

  DeliveryStockModel(this.success, this.data, this.scanedCount, this.totalbox,
      this.job, this.note, this.date);

  factory DeliveryStockModel.fromMap(Map<String, dynamic> json) {
    bool retention(DeliveryStockData element) {
      log(element.status);
      log(element.mrID);
      return !(parseBool(element.status.toString()) &&
          parseBool(element.mrID.toString()));
    }

    final ct = int.tryParse(json['totalbox'].toString()) ??
        listAdd((json['stock_total_box_count'] ?? <String, int>{})
                .values
                .toList())
            .toInt();
    final cs = json['scanedCount'] ?? 0;
    final arr = List<Map<String, dynamic>>.from(json['Data'] ?? []);
    final list = cs == ct ? <Map<String, dynamic>>[] : arr;
    final set = list.map<DeliveryStockData>(DeliveryStockData.fromMap).toSet();
    set.isEmpty ? log(json) : set.retainWhere(retention);
    return DeliveryStockModel(
        json['success'] ?? false,
        set.isEmpty ? <DeliveryStockData>[] : set.toList(),
        cs,
        ct,
        arr.first['jobno'] ?? '',
        arr.first['deliverynote_no'] ?? '',
        arr.first['delivery_date'] ?? '');
  }

  Map<String, dynamic> toMap() => {
        'success': success,
        'Data': List<dynamic>.from(data.map((x) => x.toMap())),
        'scanedCount': scanedCount,
        'totalbox': totalbox
      };
}

class DeliveryStockData {
  DeliveryStockData(
      this.deliveryqrcodeId,
      this.qrcodestatus,
      this.stockItemId,
      this.status,
      this.customerName,
      this.deliveryId,
      this.deliveryDate,
      this.partBox,
      this.noOfBoxes,
      this.totalbox,
      this.qtyExpected,
      this.jobno,
      this.deliverynoteNo,
      this.deliveryIdd,
      this.productCode,
      this.mrID);

  final int deliveryqrcodeId,
      qrcodestatus,
      status,
      deliveryId,
      partBox,
      noOfBoxes,
      qtyExpected,
      deliveryIdd,
      mrID;
  final String stockItemId,
      customerName,
      deliveryDate,
      totalbox,
      jobno,
      deliverynoteNo,
      productCode;

  static DeliveryStockData emptyData = DeliveryStockData(
      -1, -1, '', -1, '', -1, '', 0, 0, '', 0, '', '', -1, '', 0);

  factory DeliveryStockData.fromMap(Map<String, dynamic> json) =>
      DeliveryStockData(
          json['deliveryqrcodeId'] ?? 0,
          json['qrcodestatus'] ?? 0,
          json['stock_item_id'] ?? '',
          json['status'] ?? 0,
          json['customer_name'] ?? '',
          json['delivery_id'] ?? 0,
          json['delivery_date'] ?? '',
          json['part_box'] ?? 0,
          json['no_of_boxes'] ?? 0,
          json['totalbox'] ?? '',
          json['qty_expected'] ?? 0,
          json['jobno'] ?? '',
          json['deliverynote_no'] ?? '',
          json['delivery_idd'] ?? 0,
          json['product_code'] ?? '',
          json['mr_id'] ?? 0);

  Map<String, dynamic> toMap() => {
        'deliveryqrcodeId': deliveryqrcodeId,
        'qrcodestatus': qrcodestatus,
        'stock_item_id': stockItemId,
        'status': status,
        'customer_name': customerName,
        'delivery_id': deliveryId,
        'delivery_date': deliveryDate,
        'part_box': partBox,
        'no_of_boxes': noOfBoxes,
        'totalbox': totalbox,
        'qty_expected': qtyExpected,
        'jobno': jobno,
        'deliverynote_no': deliverynoteNo,
        'delivery_idd': deliveryIdd,
        'product_code': productCode
      };

  @override
  String toString() {
    // TODO: implement toString
    return jsonEncode(toMap());
  }

  @override
  bool operator ==(Object other) =>
      other is DeliveryStockData &&
      other.deliveryqrcodeId == deliveryqrcodeId &&
      other.stockItemId == stockItemId;

  @override
  // TODO: implement hashCode
  int get hashCode => hash2(deliveryqrcodeId, stockItemId);
}

class StockTotalBoxCount {
  StockTotalBoxCount({required this.ap45});

  String ap45;

  factory StockTotalBoxCount.fromMap(Map<String, dynamic> json) =>
      StockTotalBoxCount(ap45: json['ap45']);

  Map<String, dynamic> toMap() => {'ap45': ap45};
}
