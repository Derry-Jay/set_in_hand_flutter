import 'dart:convert';

Getpalletlocationsmodel getpalletlocationsmodelFromMap(String str) => Getpalletlocationsmodel.fromMap(json.decode(str));

String getpalletlocationsmodelToMap(Getpalletlocationsmodel data) => json.encode(data.toMap());

class Getpalletlocationsmodel {
    Getpalletlocationsmodel(
        this.success,
        this.palletLocations,
    );

    bool success;
    PalletLocations2 palletLocations;

    factory Getpalletlocationsmodel.fromMap(Map<String, dynamic> json) => Getpalletlocationsmodel(
        json['success'],
        PalletLocations2.fromMap(json['palletLocations']),
    );

    Map<String, dynamic> toMap() => {
        'success': success,
        'palletLocations': palletLocations.toMap(),
    };
}

class PalletLocations2 {
    PalletLocations2(
        this.getLocations,
    );

    List<GetLocation> getLocations;

    factory PalletLocations2.fromMap(Map<String, dynamic> json) => PalletLocations2(
        List<GetLocation>.from(json['getLocations'].map((x) => GetLocation.fromMap(x))),
    );

    Map<String, dynamic> toMap() => {
        'getLocations': List<dynamic>.from(getLocations.map((x) => x.toMap())),
    };
}

class GetLocation {
    GetLocation(
        this.customerName,
        this.warehouseId,
        this.uniqueId,
        this.stockCheckId,
        this.status,
    );

    String? customerName;
    int? warehouseId;
    String? uniqueId;
    int? stockCheckId;
    String? status;

    factory GetLocation.fromMap(Map<String, dynamic> json) => GetLocation(
        json['customer_name'] ?? '',
        json['warehouseId'] ?? 0,
         json['unique_id'] ?? '',
         json['stockCheckId'] ?? 0,
        json['status'] ?? '',
    );

    Map<String, dynamic> toMap() => {
        'customer_name': customerName ?? '',
        'warehouseId': warehouseId ?? 0,
        'unique_id': uniqueId ?? '',
        'stockCheckId': stockCheckId ?? 0,
        'status': status ?? '',
    };
}

