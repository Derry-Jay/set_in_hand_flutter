import 'package:flutter/material.dart';
import 'package:set_in_hand/helpers/helper.dart';
import 'package:set_in_hand/models/chat.dart';
import 'package:set_in_hand/widgets/chat_list_widget.dart';

class ChatItemWidget extends StatefulWidget {
  final Chat chat;
  const ChatItemWidget({Key? key, required this.chat}) : super(key: key);
  @override
  ChatItemWidgetState createState() => ChatItemWidgetState();
}

class ChatItemWidgetState extends State<ChatItemWidget> {
  final GlobalKey<ChatListWidgetState> _key = GlobalKey<ChatListWidgetState>();

  Helper get hp => Helper.of(context);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: IconButton(
                        iconSize: 40,
                        icon: widget.chat.image.endsWith('.jpg') ||
                                widget.chat.image.endsWith('.jpeg') ||
                                widget.chat.image.endsWith('.png')
                            ? CircleAvatar(
                                backgroundImage:
                                    NetworkImage(widget.chat.image))
                            : const Icon(Icons.account_circle),
                        onPressed: () {}),
                  ),
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.chat.name.contains(' ')
                            ? widget.chat.name
                            : widget.chat.fullName),
                        Text(widget.chat.email),
                      ],
                    ),
                  ),
                  Visibility(
                      visible: widget.chat.count > 0,
                      child: Container(
                          padding: const EdgeInsets.all(7),
                          decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.lightBlueAccent),
                          child: Text(widget.chat.count.toString(),
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 12))))
                ],
              ),
            ),
            Container(
              height: 0.5,
              color: Colors.black,
            )
          ],
        ),
        onTap: () {
          /*
          DashboardScreenState chatListWidgetState = new DashboardScreenState();
          chatListWidgetState.getItem;*/
          _key.currentState!.update();
        });
  }
}
