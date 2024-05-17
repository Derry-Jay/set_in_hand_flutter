import 'dart:convert';

GetZoneModel getZoneModelFromMap(String str) => GetZoneModel.fromMap(json.decode(str));

String getZoneModelToMap(GetZoneModel data) => json.encode(data.toMap());

class GetZoneModel {
    GetZoneModel(
        this.success,
        this.zoneData,
    );

    bool success;
    ZoneData zoneData;

    factory GetZoneModel.fromMap(Map<String, dynamic> json) => GetZoneModel(
         json['success'],
         ZoneData.fromMap(json['zoneData']),
    );

    Map<String, dynamic> toMap() => {
        'success': success,
        'zoneData': zoneData.toMap(),
    };
}

class ZoneData {
    ZoneData(
        this.zone,
    );

    List<Zone> zone;

    factory ZoneData.fromMap(Map<String, dynamic> json) => ZoneData(
         List<Zone>.from(json['zone'].map((x) => Zone.fromMap(x))),
    );

    Map<String, dynamic> toMap() => {
        'zone': List<dynamic>.from(zone.map((x) => x.toMap())),
    };
}

class Zone {
    Zone(
        this.id,
        this.buildingId,
        this.zone,
        this.status,
        this.createdAt,
        this.updatedAt,
    );

    int? id;
    int? buildingId;
    String? zone;
    int? status;
    String? createdAt;
    String? updatedAt;

    factory Zone.fromMap(Map<String, dynamic> json) => Zone(
        json['id'] ?? 0,
         json['building_id'] ?? 0,
         json['zone'] ?? '',
        json['status'] ?? 0,
        json['created_at'] ?? '',
         json['updated_at'] ?? ''
    );

    Map<String, dynamic> toMap() => {
        'id': id ?? 0,
        'building_id': buildingId ?? 0,
        'zone': zone ?? '',
        'status': status ?? 0,
        'created_at': createdAt ?? '',
        'updated_at': updatedAt ?? '',
    };

    @override
    bool operator ==(Object other) {
      // TODO: implement ==
      return other is Zone && other.id == id;
    }

    @override
    // TODO: implement hashCode
    int get hashCode => id.hashCode;
}
