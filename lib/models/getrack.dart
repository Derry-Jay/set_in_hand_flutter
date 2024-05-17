import 'dart:convert';

GetRackModel getRackModelFromMap(String str) =>
    GetRackModel.fromMap(json.decode(str));

String getRackModelToMap(GetRackModel data) => json.encode(data.toMap());

class GetRackModel {
  GetRackModel(
    this.success,
    this.rackData,
  );

  bool success;
  RackData rackData;

  factory GetRackModel.fromMap(Map<String, dynamic> json) => GetRackModel(
        json['success'],
        RackData.fromMap(json['rackData']),
      );

  Map<String, dynamic> toMap() => {
        'success': success,
        'rackData': rackData.toMap(),
      };
}

class RackData {
  RackData(
    this.rack,
  );

  List<Rack> rack;

  factory RackData.fromMap(Map<String, dynamic> json) => RackData(
        List<Rack>.from(json['rack'].map((x) => Rack.fromMap(x))),
      );

  Map<String, dynamic> toMap() => {
        'rack': List<dynamic>.from(rack.map((x) => x.toMap())),
      };
}

class Rack {
  Rack(
    this.id,
    this.zoneId,
    this.rack,
    this.status,
    this.createdAt,
    this.updatedAt,
  );

  int? id, zoneId, status;
  String? createdAt, updatedAt, rack;

  factory Rack.fromMap(Map<String, dynamic> json) => Rack(
      json['id'] ?? 0,
      json['zone_id'] ?? 0,
      json['rack'] ?? '',
      json['status'] ?? 0,
      json['created_at'] ?? '',
      json['updated_at'] ?? '');

  Map<String, dynamic> toMap() => {
        'id': id ?? 0,
        'zone_id': zoneId ?? 0,
        'rack': rack ?? '',
        'status': status ?? 0,
        'created_at': createdAt ?? '',
        'updated_at': updatedAt ?? '',
      };

  @override
  bool operator ==(Object other) {
    // TODO: implement ==
    return other is Rack && other.id == id;
  }

  @override
  // TODO: implement hashCode
  int get hashCode => id.hashCode;
}
