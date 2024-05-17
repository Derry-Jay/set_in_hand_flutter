import 'role.dart';
import 'dart:convert';
import '../helpers/helper.dart';
import 'package:flutter/material.dart';

class User extends ChangeNotifier {
  final Role role;
  final int userID, status, createdBy, loginStatus, updatedBy;
  final String userName, userEmail, token, phoneNo, uuID, image;
  User(
      this.userID,
      this.userName,
      this.userEmail,
      this.phoneNo,
      this.uuID,
      this.status,
      this.token,
      this.createdBy,
      this.loginStatus,
      this.role,
      this.image,
      this.updatedBy);
  bool get isEmpty => userID == -1 || userID == 0;
  bool get isNotEmpty => !isEmpty;
  bool get isAdmin => isNotEmpty && role.roleID == 1;
  static User emptyUser =
      User(-1, '', '', '', '', -1, '', -1, -1, Role(-1, ''), '', -1);
  void onChange() {
    notifyListeners();
  }

  Map<String, dynamic> get json {
    Map<String, dynamic> map = role.json;
    map['id'] = userID;
    map['username'] = userName;
    map['email'] = userEmail;
    map['mobilenumber'] = phoneNo;
    map['uuid'] = uuID;
    map['status'] = status;
    map['remember_token'] = token;
    map['created_by'] = createdBy;
    map['is_logged_in'] = loginStatus;
    map['updated_by'] = updatedBy;
    map['profilepicture'] = image.split('/').last;
    return map;
  }

  Map<String, dynamic> get map {
    Map<String, dynamic> json = <String, dynamic>{};
    json['user_id'] = userID.toString();
    return json;
  }

  factory User.fromMap(Map<String, dynamic> json) {
    return User(
        json['id'] ?? -1,
        json['username'] ?? '',
        json['email'] ?? '',
        json['mobilenumber'] ?? '',
        json['uuid'] ?? '',
        json['status'] ?? '',
        json['remember_token'] ?? '',
        json['created_by'] ?? -1,
        json['is_logged_in'] == null
            ? -1
            : (json['is_logged_in'] is int
                ? json['is_logged_in']
                : (int.tryParse(json['is_logged_in'] is String
                        ? json['is_logged_in']
                        : json['is_logged_in'].toString()) ??
                    -1)),
        Role.fromMap(json),
        '${gc?.getValue<String>('bucket_path') ?? ''}profilepic/${json['profilepicture'] ?? ''}',
        json['updated_by'] ?? -1);
  }

  @override
  bool operator ==(Object other) {
    // TODO: implement ==
    return other is User && userID == other.userID;
  }

  @override
  String toString() {
    // TODO: implement toString
    return jsonEncode(json);
  }

  @override
  // TODO: implement hashCode
  int get hashCode => userID.hashCode;
}
