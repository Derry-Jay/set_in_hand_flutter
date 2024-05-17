import 'package:flutter/material.dart';
import 'package:set_in_hand/models/readnotification.dart';
import 'package:set_in_hand/models/shownotification.dart';
import 'package:set_in_hand/widgets/circular_loader.dart';
import '../../extensions/time_ago.dart';
import '../helpers/helper.dart';

class ShowNotifications extends StatefulWidget {
  const ShowNotifications({Key? key}) : super(key: key);

  @override
  ShowNotificationsState createState() => ShowNotificationsState();
}

class ShowNotificationsState extends State<ShowNotifications> {
  ReadNotification? readNotification;
  Helper get hp => Helper.of(context);

  Widget dialogBuilder(
      BuildContext context, AsyncSnapshot<List<GetNotification>> list) {
    final hpd = Helper.of(context);
    Widget getItem(BuildContext context, int index) {
      final item = list.data?[index];
      final hpi = Helper.of(context);
      return GestureDetector(
          child: Card(
              child: //Padding(
                  // padding: const EdgeInsets.all(8.0),
                  Container(
            //  padding: const EdgeInsets.all(1.0),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  width: 30,
                ),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(
                        width: 30,
                      ),
                      Text(
                        TimeAgo.timeAgoSinceDate(item?.createdAt ?? ''),
                        overflow: TextOverflow.clip,
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    ]),
                const SizedBox(
                  height: 5,
                ),
                Row(
                  children: [
                    Expanded(
                        flex: 9,
                        child: Text(
                          item?.title ?? '',
                          style: TextStyle(
                              color: hpi.theme.errorColor, fontSize: 20),
                        )),
                    Expanded(
                        flex: 1,
                        child: IconButton(
                            alignment: Alignment.centerRight,
                            onPressed: () {
                              readNotificationAPICalled(
                                  item?.id.toString() ?? '');
                            },
                            icon:
                                Image.asset('${assetImagePath}green_tick.png'),
                            tooltip: 'notification'))
                  ],
                ),
                const SizedBox(
                  height: 5,
                ),
                Text(
                  item?.content ?? '',
                  overflow: TextOverflow.clip,
                  style:
                      const TextStyle(color: Color(0xff838acd), fontSize: 17),
                  textAlign: TextAlign.start,
                ),
                const SizedBox(
                  height: 10,
                )
              ],
            ),
          )),
          onTap: () async {
            readNotificationAPICalled(item?.id.toString() ?? '');
          });
    }

    log(list.data?.length);
    log('inga vandhiya');

    return list.hasData && !list.hasError
        ? ListView.builder(
            itemBuilder: getItem,
            itemCount: list.data?.length,
            scrollDirection: Axis.vertical,
            physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics()))
        : Center(
            child: CircularLoader(
                color: hpd.theme.primaryColor,
                loaderType: LoaderType.fadingCircle,
                duration: const Duration(seconds: 10)));
  }

  void readNotificationAPICalled(String notificationID) async {
    try {
      log(notificationID);
      readNotification = await api.readNotificationAPI(notificationID, hp);
      if (await hp.revealToast(readNotification?.mesaage ?? 'Api Failure') &&
          (readNotification?.success ?? false)) {
        setState(() {});
      }
    } catch (e) {
      sendAppLog(e);
    }
  }

  @override
  void initState() {
    super.initState();
    hp.getConnectStatus();
  }

  @override
  Widget build(BuildContext context) {
    // return AlertDialog(

    //   scrollable: true,
    //   shape: RoundedRectangleBorder(
    //     borderRadius: BorderRadius.circular(10),
    //   ),
    //   elevation: 0.0,
    //   backgroundColor: Colors.transparent,
    //   content: dialogContent(context),
    // );
    return Align(
        alignment: Alignment.topRight,
        child: Padding(
          padding: const EdgeInsets.only(top: 75, right: 35),
          child: Container(
              height: 400,
              width: 325,
              padding:
                  const EdgeInsets.only(top: 10, bottom: 10, left: 5, right: 5),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10.0,
                    offset: Offset(0.0, 10.0),
                  ),
                ],
              ),
              child: FutureBuilder<List<GetNotification>>(
                  future: api.showNotificationAPI(hp), builder: dialogBuilder)),
        ));
  }
}
