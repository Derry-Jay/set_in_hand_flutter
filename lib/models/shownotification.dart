import 'dart:convert';

ShowNotification showNotificationFromMap(String str) => ShowNotification.fromMap(json.decode(str));

String showNotificationToMap(ShowNotification data) => json.encode(data.toMap());

class ShowNotification {
    ShowNotification(
        this.success,
        this.getNotification,
    );

    bool success;
    List<GetNotification> getNotification;

    factory ShowNotification.fromMap(Map<String, dynamic> json) => ShowNotification(
         json['success'],
         List<GetNotification>.from(json['getNotification'].map((x) => GetNotification.fromMap(x))),
    );

    Map<String, dynamic> toMap() => {
        'success': success,
        'getNotification': List<dynamic>.from(getNotification.map((x) => x.toMap())),
    };
}

class GetNotification {
    GetNotification(
        this.id,
        this.title,
        this.content,
        this.createdAt,
    );

    int id;
    String title;
    String content;
    String createdAt;

    factory GetNotification.fromMap(Map<String, dynamic> json) => GetNotification(
         json['id'],
         json['title'],
         json['content'],
         json['created_at'],
    );

    Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'content': content,
        'created_at': createdAt,
    };
}
