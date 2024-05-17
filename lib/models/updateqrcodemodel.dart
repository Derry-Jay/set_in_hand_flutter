import 'dart:convert';

UpdateQrcodemodel updateQrcodemodelFromMap(String str) =>
    UpdateQrcodemodel.fromMap(json.decode(str));

String updateQrcodemodelToMap(UpdateQrcodemodel data) =>
    json.encode(data.toMap());

class UpdateQrcodemodel {
  UpdateQrcodemodel(
    this.success,
    this.data,
    this.message,
  );

  bool success;
  String? data;
  String? message;

  factory UpdateQrcodemodel.fromMap(Map<String, dynamic> json) =>
      UpdateQrcodemodel(
        json['success'],
        json['Data'] ?? '',
        json['message'] ?? '',
      );

  Map<String, dynamic> toMap() => {
        'success': success,
        'Data': data ?? '',
        'message': message ?? '',
      };
}
