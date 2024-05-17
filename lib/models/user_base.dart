import 'user.dart';

class UserBase {
  final bool success;
  final User user;
  UserBase(this.success, this.user);
  factory UserBase.fromMap(Map<String, dynamic> json) {
    final list = List<Map<String, dynamic>>.from(json['userData'] ?? []);
    return UserBase(json['success'] ?? false,
        list.isEmpty ? User.emptyUser : User.fromMap(list.first));
  }
}
