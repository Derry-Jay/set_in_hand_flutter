import 'package:flutter/material.dart';
import 'package:set_in_hand/helpers/helper.dart';
import 'package:set_in_hand/models/chatmessage.dart';

class ChatConversationItemWidget extends StatefulWidget {
  final ChatMessage messages;

  const ChatConversationItemWidget({Key? key, required this.messages})
      : super(key: key);

  @override
  ChatConversationItemWidgetState createState() =>
      ChatConversationItemWidgetState();
}

class ChatConversationItemWidgetState
    extends State<ChatConversationItemWidget> {
  Helper get hp => Helper.of(context);
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        child: Container(
          padding:
              const EdgeInsets.only(left: 14, right: 14, top: 10, bottom: 10),
          child: Align(
            alignment: (widget.messages.messageType == 'receiver'
                ? Alignment.topLeft
                : Alignment.topRight),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: (widget.messages.messageType == 'receiver'
                    ? Colors.grey.shade200
                    : Colors.blue[200]),
              ),
              padding: const EdgeInsets.all(16),
              child: Text(
                widget.messages.messageContent,
                style: const TextStyle(fontSize: 15),
              ),
            ),
          ),
        ),
        onTap: () {
          // chatListWidgetState.getItem;
        });
  }
}
