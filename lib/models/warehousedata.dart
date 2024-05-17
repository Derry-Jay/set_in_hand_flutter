import 'dart:convert';

WarehouseData warehouseDataFromMap(String str) =>
    WarehouseData.fromMap(json.decode(str));

String warehouseDataToMap(WarehouseData data) => json.encode(data.toMap());

class WarehouseData {
  WarehouseData(
    this.success,
    this.getStockItems,
  );

  bool success;
  List<GetStockItemWareHouse> getStockItems;

  factory WarehouseData.fromMap(Map<String, dynamic> json) => WarehouseData(
        json['success'],
        List<GetStockItemWareHouse>.from(
            json['getStockItems'].map((x) => GetStockItemWareHouse.fromMap(x))),
      );

  Map<String, dynamic> toMap() => {
        'success': success,
        'getStockItems':
            List<dynamic>.from(getStockItems.map((x) => x.toMap())),
      };
}

class GetStockItemWareHouse {
  GetStockItemWareHouse(
    this.warehouseId,
    this.qrcodeId,
    this.customerName,
    this.customerId,
    this.stockCheckStatus,
    this.qtyExpected,
    this.stockItemId,
    this.uniqueId,
    this.qrcodetext,
  );

  int? warehouseId;
  int? qrcodeId;
  String? customerName;
  int? customerId;
  String? stockCheckStatus;
  int? qtyExpected;
  String? stockItemId;
  String? uniqueId;
  String? qrcodetext;

  factory GetStockItemWareHouse.fromMap(Map<String, dynamic> json) =>
      GetStockItemWareHouse(
        json['warehouse_id'],
        json['qrcodeId'],
        json['customer_name'],
        json['customerId'],
        json['stock_check_status'],
        json['qty_expected'],
        json['stock_item_id'],
        json['unique_id'],
        json['qrcodetext'],
      );

  Map<String, dynamic> toMap() => {
        'warehouse_id': warehouseId,
        'qrcodeId': qrcodeId,
        'customer_name': customerName,
        'customerId': customerId,
        'stock_check_status': stockCheckStatus,
        'qty_expected': qtyExpected,
        'stock_item_id': stockItemId,
        'unique_id': uniqueId,
        'qrcodetext': qrcodetext,
      };
}

WarehouseIdGet warehouseIdGetFromMap(String str) =>
    WarehouseIdGet.fromMap(json.decode(str));

String warehouseIdGetToMap(WarehouseIdGet data) => json.encode(data.toMap());

class WarehouseIdGet {
  WarehouseIdGet(this.success, {this.warehouseId, this.message});

  bool success;
  int? warehouseId;
  String? message;

  factory WarehouseIdGet.fromMap(Map<String, dynamic> json) =>
      WarehouseIdGet(json['success'],
          warehouseId: json['warehouseId'], message: json['message']);

  Map<String, dynamic> toMap() =>
      {'success': success, 'warehouseId': warehouseId, 'message': message};
}

MovetoAllStocks movestockIdGetFromMap(String str) =>
    MovetoAllStocks.fromMap(json.decode(str));

String movestockIdGetToMap(MovetoAllStocks data) => json.encode(data.toMap());

class MovetoAllStocks {
  MovetoAllStocks(
    this.success,
    this.message,
  );

  bool success;
  String message;

  factory MovetoAllStocks.fromMap(Map<String, dynamic> json) => MovetoAllStocks(
        json['success'],
        json['message'],
      );

  Map<String, dynamic> toMap() => {
        'success': success,
        'message': message,
      };
}
