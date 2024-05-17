class FullStockItem {
  final String customerName, status, stockItemID, uniqueID, createdAt;
  final int qrCodeID,
      customerID,
      stockCheckStatus,
      qtyExpected,
      warehouseID,
      stockCheckID,
      taskID;
  FullStockItem(
      this.stockCheckID,
      this.warehouseID,
      this.status,
      this.qrCodeID,
      this.customerName,
      this.customerID,
      this.createdAt,
      this.qtyExpected,
      this.stockCheckStatus,
      this.stockItemID,
      this.uniqueID,
      this.taskID);

  static FullStockItem emptyItem =
      FullStockItem(-1, -1, '', -1, '', -1, '', -1, -1, '', '', -1);

  Map<String, dynamic> get map {
    Map<String, dynamic> kv = <String, dynamic>{};
    // kv['createdBy'] = customerID.toString();
    kv['warehouseId'] = warehouseID.toString();
    kv['task_id'] = taskID.toString();
    return kv;
  }

  factory FullStockItem.fromMap(Map<String, dynamic> json) {
    return FullStockItem(
        json['stockCheckId'],
        json['warehouse_id'],
        json['status'],
        json['qrcodeId'],
        json['customer_name'],
        json['customerId'],
        json['created_at'],
        json['qty_expected'],
        int.tryParse(json['stock_check_status'] ?? '-1') ?? -1,
        json['stock_item_id'],
        json['unique_id'],
        json['taskId']);
  }
}
