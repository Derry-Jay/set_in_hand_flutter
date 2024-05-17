import 'chat.dart';
import 'reply.dart';
import 'package:flutter/material.dart';

class ChatBase extends ChangeNotifier {
  final Reply reply;
  final List<Chat> chats;
  ChatBase(this.reply, this.chats);
  void onChange() {
    notifyListeners();
  }

  factory ChatBase.fromMap(Map<String, dynamic> map) {
    final list = map['userData'] == null
        ? <Map<String, dynamic>>[]
        : (map['userData']['users'] == null || map['userData']['users'] == []
            ? <Map<String, dynamic>>[]
            : List<Map<String, dynamic>>.from(map['userData']['users']));
    return ChatBase(Reply.fromMap(map),
        list.isEmpty ? <Chat>[] : list.map(Chat.fromMap).toList());
  }
}
