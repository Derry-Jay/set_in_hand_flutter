import 'package:flutter/material.dart';
import 'package:set_in_hand/back_end/api.dart';
import 'package:set_in_hand/models/chat.dart';
// import 'package:set_in_hand/widgets/chat_item_widget.dart';
import 'package:set_in_hand/widgets/circular_loader.dart';
import '../helpers/helper.dart';
import 'chat_conversation_list_widget.dart';

class ChatListWidget extends StatefulWidget {
  const ChatListWidget({Key? key}) : super(key: key);

  @override
  ChatListWidgetState createState() => ChatListWidgetState();
}

class ChatListWidgetState extends State<ChatListWidget> {
  bool flag = false, test = false;
  int pos = -1;
  Helper get hp => Helper.of(context);
  final TextEditingController _controller = TextEditingController();

  Widget listBuilder(BuildContext context, List<Chat>? chats, Widget? child) {
    final hp = Helper.of(context);
    // Widget getItem(BuildContext context, int index) {
    //   return ChatItemWidget(chat: chats![index]);
    // }

    return flag
        ? /*ChatConversation(toUserId : chats![pos].chatID.toString(),name: chats[pos].fullName.toString(),
          profilepic: chats[pos].image)*/
        Scaffold(
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
                      /*IconButton(
                  onPressed: (){
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.arrow_back,color: Colors.black,),
                ),*/
                      /*SizedBox(width: 2,),*/
                      /*CircleAvatar(
                  backgroundImage: NetworkImage("<https://randomuser.me/api/portraits/men/5.jpg>"),
                  maxRadius: 20,
                ),*/
                      const SizedBox(
                        width: 12,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              chats![pos].fullName,
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white),
                            ),
                            /*SizedBox(height: 6,),
                      Text("Online",style: TextStyle(color: Colors.grey.shade600, fontSize: 13),),*/
                          ],
                        ),
                      ),
                      /*IconButton(icon: Icon(icon.),color: Colors.white, onPressed: () {  },),*/
                      IconButton(
                          onPressed: () {
                            setState(() {
                              flag = false;
                            });
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
                /*ListView.builder(
          itemCount: messages.length,
          shrinkWrap: true,
          padding: EdgeInsets.only(top: 10,bottom: 10),
          physics: NeverScrollableScrollPhysics(),
          itemBuilder: (context, index){
            return Container(
              padding: EdgeInsets.only(left: 14,right: 14,top: 10,bottom: 10),
              child: Align(
                alignment: (messages[index].messageType == "receiver"?Alignment.topLeft:Alignment.topRight),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: (messages[index].messageType  == "receiver"?Colors.grey.shade200:Colors.blue[200]),
                  ),
                  padding: EdgeInsets.all(16),
                  child: Text(messages[index].messageContent, style: TextStyle(fontSize: 15),),
                ),
              ),
            );
          },
        )*/
                Container(
                    margin: const EdgeInsets.only(bottom: 60),
                    child: ChatConversationListWidget(
                        toUserId: chats[pos].chatID.toString())),
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Container(
                    padding:
                        const EdgeInsets.only(left: 10, bottom: 10, top: 10),
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
                            child: const Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 15,
                        ),
                        Expanded(
                          child: TextField(
                            decoration: const InputDecoration(
                                hintText: 'Write message...',
                                hintStyle: TextStyle(color: Colors.black54),
                                border: InputBorder.none),
                            controller: _controller,
                          ),
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
                                    start(chats[pos].chatID.toString(),
                                        chats[pos].image, chats[pos].fullName);
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
          )
        : chats == null
            ? Center(
                child: CircularLoader(
                    duration: const Duration(seconds: 10),
                    loaderType: LoaderType.fadingCircle,
                    color: hp.theme.primaryColor))
            : (chats.isEmpty
                ? const Center(child: Text('No Chats Found'))
                : Container(
                    color: Colors.white,
                    child: ListView.builder(
                      itemBuilder: (context, index) {
                        return GestureDetector(
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(15),
                                  color: Colors.white,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Flexible(
                                        child: IconButton(
                                            iconSize: 40,
                                            icon: chats[index]
                                                        .image
                                                        .endsWith('.jpg') ||
                                                    chats[index]
                                                        .image
                                                        .endsWith('.jpeg') ||
                                                    chats[index]
                                                        .image
                                                        .endsWith('.png')
                                                ? CircleAvatar(
                                                    backgroundImage:
                                                        NetworkImage(
                                                            chats[index].image))
                                                : const Icon(
                                                    Icons.account_circle),
                                            onPressed: () {}),
                                      ),
                                      Expanded(
                                        flex: 3,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(chats[index].name.contains(' ')
                                                ? chats[index].name
                                                : chats[index].fullName),
                                            Text(chats[index].email),
                                          ],
                                        ),
                                      ),
                                      Visibility(
                                          visible: chats[index].count > 0,
                                          child: Container(
                                              padding: const EdgeInsets.all(7),
                                              decoration: const BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color:
                                                      Colors.lightBlueAccent),
                                              child: Text(
                                                  chats[index].count.toString(),
                                                  style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 12))))
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
                              setState(() {
                                pos = index;
                                flag = true;
                              });
                            });
                      },
                      itemCount: chats.length,
                    )));
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
      flag = false;
    });
  }

  void start(String touserid, String image, String username) async {
    DateTime currentPhoneDate = DateTime.now(); //DateTime
    //To TimeStamp
    final body = {
      'messageId': currentPhoneDate.toIso8601String(),
      'userId': currentUser.value.userID.toString(),
      'toUserId': touserid,
      'message': _controller.text,
      'datetime': DateTime.now().toString(),
      'status': '1',
      'profilepicture': image,
      'username': username
    };
    final v = await api.sendchat(body, hp);
    log(v.success);

    setState(() {
      test = false;
      _controller.clear();
      /*_controller.text = "";*/
    });
  }

  @override
  void didUpdateWidget(covariant ChatListWidget oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
    api.getChats(hp);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<Chat>?>(
        valueListenable: chats, builder: listBuilder);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    api.getChats(hp);
  }
}
