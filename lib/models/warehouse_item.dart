import '../helpers/helper.dart';

class WarehouseItem {
  final int qrCodeID,
      warehouseID,
      awaitedQuantity,
      deliveryID,
      customerID,
      countPerBox,
      format,
      remainingQuantity,
      mrNo;
  final bool isPartBox;
  final String customerName,
      productCode,
      stockItemID,
      qrText,
      uniqueID,
      reason,
      details,
      mrTime,
      mrDate;

  WarehouseItem(
      this.qrCodeID,
      this.customerName,
      this.mrNo,
      this.reason,
      this.details,
      this.productCode,
      this.stockItemID,
      this.qrText,
      this.warehouseID,
      this.uniqueID,
      this.awaitedQuantity,
      this.deliveryID,
      this.customerID,
      this.format,
      this.remainingQuantity,
      this.countPerBox,
      this.mrDate,
      this.mrTime,
      this.isPartBox);

  factory WarehouseItem.fromMap(Map<String, dynamic> json) {
    return WarehouseItem(
        json['qrCodeId'] ?? -1,
        json['customer_name'] ?? '',
        json['mr_number'] ?? 0,
        json['reason'] ?? '',
        json['details'] ?? '',
        json['product_code'] ?? '',
        json['stock_item_id'] ?? '',
        json['qrcodetext'] ?? '',
        json['warehouse_id'] ?? (json['warehouseId'] ?? -1),
        json['unique_id'] ?? '',
        parseBool(json['qty_expected'] == null
                ? ''
                : (json['qty_expected'] is String
                    ? json['qty_expected']
                    : json['qty_expected'].toString()))
            ? json['qty_expected']
            : ((json['quantity_per_box'] ?? 0) is int
                ? (json['quantity_per_box'] ?? 0)
                : (int.tryParse(json['quantity_per_box'] ?? '0') ?? 0)),
        json['deliveryId'] ?? -1,
        json['customersId'] ?? -1,
        json['format'] ?? 0,
        json['remaining_cards'] ?? 0,
        json['qr_perbox'] ?? (json['perbox'] ?? 0),
        json['mr_date'] ?? (json['mr_datee'] ?? ''),
        json['mr_time'] ?? '',
        parseBool(json['is_partbox'] == null
            ? ''
            : (json['is_partbox'] is String
                ? json['is_partbox']
                : json['is_partbox'].toString())));
  }
}
