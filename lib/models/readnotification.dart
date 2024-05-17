import 'dart:convert';

ReadNotification readNotificationFromMap(String str) => ReadNotification.fromMap(json.decode(str));

String readNotificationToMap(ReadNotification data) => json.encode(data.toMap());

class ReadNotification {
    ReadNotification(
        this.success,
        this.mesaage,
        
    );

    bool success;
    String mesaage;

    factory ReadNotification.fromMap(Map<String, dynamic> json) => ReadNotification(
         json['success'],
        json['mesaage'] ?? '',
    );

    Map<String, dynamic> toMap() => {
        'success': success,
        'mesaage': mesaage,
    };
}
