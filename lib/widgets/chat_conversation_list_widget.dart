import 'package:flutter/material.dart';
import 'package:set_in_hand/back_end/api.dart';
import 'package:set_in_hand/models/chat_message.dart';
import 'package:set_in_hand/widgets/circular_loader.dart';
import '../helpers/helper.dart';

class ChatConversationListWidget extends StatefulWidget {
  const ChatConversationListWidget({Key? key, required this.toUserId})
      : super(key: key);
  final String toUserId;

  @override
  ChatConversationListWidgetState createState() =>
      ChatConversationListWidgetState();
}

class ChatConversationListWidgetState
    extends State<ChatConversationListWidget> {
  bool flag = true;
  Helper get hp => Helper.of(context);
  ScrollController listScrollController = ScrollController();

  Widget listBuilder(
      BuildContext context, List<ChatMessage>? chats, Widget? child) {
    return flag
        ? Center(
            child: CircularLoader(
                duration: const Duration(seconds: 10),
                loaderType: LoaderType.fadingCircle,
                color: hp.theme.primaryColor))
        : (chats!.isEmpty
            ? const Center(child: Text('No Chats Found'))
            : ListView.builder(
                controller: listScrollController,
                reverse: true,
                itemBuilder: (context, index) {
                  return GestureDetector(
                      child: Container(
                          // color: Colors.amber,
                          padding: const EdgeInsets.only(
                              left: 14, right: 14, top: 10, bottom: 10),
                          child: Align(
                              alignment: (chats[(chats.length - 1) - index]
                                          .toUserId
                                          .toString() ==
                                      widget.toUserId
                                  ? Alignment.topRight
                                  : Alignment.topLeft),
                              child: (chats[(chats.length - 1) - index]
                                          .toUserId
                                          .toString() ==
                                      widget.toUserId
                                  ? Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          chats[(chats.length - 1) - index]
                                              .datetime
                                              .toString(),
                                        ),
                                        const SizedBox(height: 5),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                color:
                                                    (chats[(chats.length - 1) -
                                                                    index]
                                                                .toUserId
                                                                .toString() ==
                                                            widget.toUserId
                                                        ? Colors.blue[200]
                                                        : Colors.grey.shade200),
                                              ),
                                              padding: const EdgeInsets.all(16),
                                              child: Text(
                                                chats[(chats.length - 1) -
                                                            index]
                                                        .message ??
                                                    '',
                                                style: const TextStyle(
                                                    fontSize: 15),
                                              ),
                                            ),
                                            const SizedBox(width: 3),
                                            getValuesOfPic(chats[
                                                    (chats.length - 1) - index]
                                                .profilepicture
                                                .toString())
                                          ],
                                        )
                                      ],
                                    )
                                  : Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(chats[(chats.length - 1) - index]
                                            .datetime
                                            .toString()),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                color:
                                                    (chats[(chats.length - 1) -
                                                                    index]
                                                                .toUserId
                                                                .toString() ==
                                                            widget.toUserId
                                                        ? Colors.blue[200]
                                                        : Colors.grey.shade200),
                                              ),
                                              padding: const EdgeInsets.all(16),
                                              child: Text(
                                                chats[(chats.length - 1) -
                                                            index]
                                                        .message ??
                                                    '',
                                                style: const TextStyle(
                                                    fontSize: 15),
                                              ),
                                            ),
                                            const SizedBox(width: 3),
                                            getValuesOfPic(chats[
                                                    (chats.length - 1) - index]
                                                .profilepicture
                                                .toString())
                                          ],
                                        )
                                      ],
                                    )))),
                      onTap: () {
                        // chatListWidgetState.getItem;
                      });
                },
                itemCount: chats.length));
/*chats == null
        ? Center(
          child: CircularLoader(
            duration: const Duration(seconds: 10),
            loaderType: LoaderType.chasingDots,
            color: hp.theme.primaryColor))
        : (chats.isEmpty
        ? const Center(child: Text('No Chats Found'))
          : ListView.builder(
          itemBuilder: getItem, itemCount: chats.length));*/
  }

  void update() {
    setState(() {
      api.getChatsMessages(widget.toUserId, hp);
    });
  }

  IconButton getValuesOfPic(String values) {
    return IconButton(
      icon: CircleAvatar(
          backgroundImage: NetworkImage(profilePublicUrl + values)),
      onPressed: () {},
    );
  }

  @override
  void didUpdateWidget(covariant ChatConversationListWidget oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
    api.getChatsMessages(widget.toUserId, hp);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<ChatMessage>?>(
        valueListenable: chatmessages, builder: listBuilder);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    log(widget.toUserId);
    flag = true;
    /*getChatsMessages(widget.toUserId);*/
    callchatsmessage();
  }

  void callchatsmessage() async {
    final ch = await api.getChatsMessages(widget.toUserId, hp);
    if (ch.reply.success) {
      setState(() {
        flag = false;
      });
    }
  }
}
