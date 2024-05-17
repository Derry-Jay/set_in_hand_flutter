import 'reply.dart';
import 'chat_message.dart';
import 'package:flutter/material.dart';

class ChatMessageBase extends ChangeNotifier {
  final Reply reply;
  final List<ChatMessage> chats;
  ChatMessageBase(this.reply, this.chats);
  void onChange() {
    notifyListeners();
  }

  factory ChatMessageBase.fromMap(Map<String, dynamic> map) {
    final list = map['messageData'] == null
        ? <Map<String, dynamic>>[]
        : (map['messageData']['messages'] == null ||
                map['messageData']['messages'] == []
            ? <Map<String, dynamic>>[]
            : List<Map<String, dynamic>>.from(map['messageData']['messages']));
    return ChatMessageBase(
        Reply.fromMap(map),
        list.isEmpty
            ? <ChatMessage>[]
            : list.map<ChatMessage>(ChatMessage.fromMap).toList());
  }
}
