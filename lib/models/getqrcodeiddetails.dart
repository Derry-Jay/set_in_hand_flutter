import 'dart:convert';

GetQrCodeIdDetails getQrCodeIdDetailsFromMap(String str) =>
    GetQrCodeIdDetails.fromMap(json.decode(str));

String getQrCodeIdDetailsToMap(GetQrCodeIdDetails data) =>
    json.encode(data.toMap());

class GetQrCodeIdDetails {
  GetQrCodeIdDetails(
    this.success,
    this.type,
    this.id,
  );

  bool success;
  String type;
  int id;

  factory GetQrCodeIdDetails.fromMap(Map<String, dynamic> json) =>
      GetQrCodeIdDetails(
        json['success'] ?? false,
        json['type'] ?? '',
        json['id'] ?? 0,
      );

  Map<String, dynamic> toMap() => {
        'success': success,
        'type': type,
        'id': id,
      };
}
