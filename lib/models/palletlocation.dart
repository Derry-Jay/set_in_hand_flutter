import 'dart:convert';
import 'GetpalletLocationsModel.dart';

PalletLocationModel palletLocationModelFromMap(String str) => PalletLocationModel.fromMap(json.decode(str));

String palletLocationModelToMap(PalletLocationModel data) => json.encode(data.toMap());

class PalletLocationModel {
    PalletLocationModel(
        this.success,
        this.palletLocations,
    );

    bool success;
    PalletLocations palletLocations;

    factory PalletLocationModel.fromMap(Map<String, dynamic> json) => PalletLocationModel(
         json['success'],
         PalletLocations.fromMap(json['palletLocations']),
    );

    Map<String, dynamic> toMap() => {
        'success': success,
        'palletLocations': palletLocations.toMap(),
    };
}

class PalletLocations {
    PalletLocations(
        this.building,
        this.getLocations,
    );

    List<PalletBuilding> building;
    List<GetLocation> getLocations;

    factory PalletLocations.fromMap(Map<String, dynamic> json) => PalletLocations(
         List<PalletBuilding>.from(json['building'].map((x) => PalletBuilding.fromMap(x))),
         List<GetLocation>.from(json['getLocations'].map((x) => GetLocation.fromMap(x))),
    );

    Map<String, dynamic> toMap() => {
        'building': List<dynamic>.from(building.map((x) => x.toMap())),
        'getLocations': List<dynamic>.from(getLocations.map((x) => x.toMap())),
    };
}

class PalletBuilding {
    PalletBuilding(
        this.building,
        this.id,
    );

    String building;
    int id;

    factory PalletBuilding.fromMap(Map<String, dynamic> json) => PalletBuilding(
        json['building'],
         json['id'],
    );

    Map<String, dynamic> toMap() => {
        'building': building,
        'id': id,
    };

    @override
    bool operator ==(Object other) {
      // TODO: implement ==
      return other is PalletBuilding && other.id == id;
    }

    @override
    // TODO: implement hashCode
    int get hashCode => id.hashCode;
}

// class GetPalletLocation {
//     GetPalletLocation(
//         this.customerName,
//         this.warehouseId,
//         this.uniqueId,
//         this.stockCheckId,
//         this.status,
//     );

//     String customerName;
//     int warehouseId;
//     String uniqueId;
//     int? stockCheckId;
//     String? status;

//     factory GetPalletLocation.fromMap(Map<String, dynamic> json) => GetPalletLocation(
//          json["customer_name"],
//          json["warehouseId"],
//         json["unique_id"],
//         json["stockCheckId"] ?? 0,
//         json["status"] ?? '',
//     );

//     Map<String, dynamic> toMap() => {
//         "customer_name": customerName,
//         "warehouseId": warehouseId,
//         "unique_id": uniqueId,
//         "stockCheckId": stockCheckId ?? 0,
//         "status": status ?? '',
//     };
// }

