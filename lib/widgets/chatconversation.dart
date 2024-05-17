import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:set_in_hand/back_end/api.dart';
import 'package:set_in_hand/helpers/helper.dart';
import 'package:set_in_hand/widgets/chat_conversation_list_widget.dart';
import 'package:set_in_hand/widgets/chat_list_widget.dart';

class ChatConversation extends StatefulWidget {
  final String toUserId, name, profilepic;
  const ChatConversation(
      {Key? key,
      required this.toUserId,
      required this.name,
      required this.profilepic})
      : super(key: key);

  @override
  ChatConversationState createState() => ChatConversationState();
}

class ChatConversationState extends State<ChatConversation> {
  final TextEditingController _controller = TextEditingController();
  var pref = SharedPreferences.getInstance();
  bool test = false;
  ChatListWidgetState chatListWidgetState = ChatListWidgetState();
  Helper get hp => Helper.of(context);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        flexibleSpace: SafeArea(
          child: Container(
            color: Colors.blue,
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              children: <Widget>[
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        widget.name,
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white),
                      )
                    ],
                  ),
                ),
                IconButton(
                    onPressed: () {
                      chatListWidgetState.update();
                    },
                    icon: const Icon(Icons.close),
                    color: Colors.white,
                    tooltip: 'close'),
              ],
            ),
          ),
        ),
      ),
      body: Stack(
        children: <Widget>[
          ChatConversationListWidget(toUserId: widget.toUserId),
          Align(
            alignment: Alignment.bottomLeft,
            child: Container(
              padding: const EdgeInsets.only(left: 10, bottom: 10, top: 10),
              height: 60,
              width: double.infinity,
              color: Colors.white,
              child: Row(
                children: <Widget>[
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      height: 30,
                      width: 30,
                      decoration: BoxDecoration(
                        color: Colors.lightBlue,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child:
                          const Icon(Icons.add, color: Colors.white, size: 20),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: TextField(
                        decoration: const InputDecoration(
                            hintText: 'Write message...',
                            hintStyle: TextStyle(color: Colors.black54),
                            border: InputBorder.none),
                        controller: _controller),
                  ),
                  const SizedBox(
                    width: 15,
                  ),
                  test
                      ? const CircularProgressIndicator()
                      : FloatingActionButton(
                          onPressed: () {
                            setState(() {
                              test = true;
                              start();
                            });
                          },
                          backgroundColor: Colors.blue,
                          elevation: 0,
                          child: const Icon(
                            Icons.send,
                            color: Colors.white,
                            size: 18,
                          ),
                        )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void start() async {
    DateTime currentPhoneDate = DateTime.now(); //DateTime
    //To TimeStamp
    final body = {
      'messageId': currentPhoneDate.toIso8601String(),
      'userId': currentUser.value.userID.toString(),
      'toUserId': widget.toUserId,
      'message': _controller.text,
      'datetime': DateTime.now().toString(),
      'status': '1',
      'profilepicture': widget.profilepic,
      'username': widget.name
    };
    final v = await api.sendchat(body, hp);
    log(v.success);

    setState(() {
      test = false;
    });
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }
}
