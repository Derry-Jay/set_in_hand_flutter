import 'package:global_configuration/global_configuration.dart';

class Chat {
  final DateTime lastLogged;
  final String name, email, image, fullName, token, uuID;
  final int chatID, isLoggedIn, count, status, phone, job, typeID;
  Chat(
      this.chatID,
      this.uuID,
      this.name,
      this.typeID,
      this.fullName,
      this.email,
      this.phone,
      this.job,
      this.image,
      this.status,
      this.token,
      this.isLoggedIn,
      this.lastLogged,
      this.count);

  factory Chat.fromMap(Map<String, dynamic> map) {
    return Chat(
        map['id'],
        map['uuid'],
        map['username'] ?? '',
        map['type_id'],
        (map['firstname'] ?? '') + ' ' + (map['lastname'] ?? ''),
        map['email'] ?? '',
        int.tryParse(map['mobilenumber'] ?? '-1') ?? -1,
        int.tryParse(map['jobtitle'] ?? '-1') ?? -1,
        '${GlobalConfiguration().getValue<String>('bucket_path')}profilepic/${map['profilepicture'] ?? ''}',
        map['status'],
        map['remember_token'] ?? '',
        int.tryParse(map['is_logged_in'] ?? '-1') ?? -1,
        DateTime.tryParse(map['last_logged_date']) ?? DateTime.now(),
        map['messagesCount'] ?? 0);
  }
}
