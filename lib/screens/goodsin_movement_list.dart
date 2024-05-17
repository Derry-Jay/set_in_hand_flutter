import '../back_end/api.dart';
import 'package:intl/intl.dart';
import '../helpers/helper.dart';
import '../widgets/my_app_bar.dart';
import '../widgets/logo_widget.dart';
import '../widgets/bottom_widget.dart';
import '../models/route_argument.dart';
import 'package:flutter/material.dart';
import '../widgets/chat_list_widget.dart';
import '../models/GetCompletedDelieveriesModel.dart';

class GoodsInMovementList extends StatefulWidget {
  const GoodsInMovementList({Key? key}) : super(key: key);

  @override
  State<GoodsInMovementList> createState() => _GoodsInMovementListState();
}

class _GoodsInMovementListState extends State<GoodsInMovementList> {
  List<GetCompletedDeliveriesDeliveryDatum>? futureData;

  Helper get hp => Helper.of(context);

  void setData() async {
    futureData = await api.fetchGetCompletedDeliveries(hp);
    if (mounted) {
      setState(() {
        DateFormat format = DateFormat('dd/MM/yyyy');
        var dataNullCheck = futureData ?? [];
        if (dataNullCheck.isNotEmpty) {
          dataNullCheck.sort((a, b) {
            var value = format.parse(a.deliveryDate);
            var value2 = format.parse(b.deliveryDate);
            log(value);
            return value2.compareTo(value);
          });
        }
      });
    }
  }

  void goodsInMovementscanPage(String deliveryID, String customerName) async {
    hp.goTo('/goodsInMovementScan',
        args: RouteArgument(tag: customerName, content: deliveryID));
    // Navigator.push(
    //     context,
    //     MaterialPageRoute(
    //         builder: (context) => GoodsInMovementScanPage(
    //             rar: )));
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    setData();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: hp.backButtonOverride,
        child: SafeArea(
          child: Scaffold(
            bottomNavigationBar:
                BottomWidget(heightFactor: 30, widthFactor: hp.width),
            key: _scaffoldKey,
            endDrawer: const Drawer(child: ChatListWidget()),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      MyAppBar(hp, _scaffoldKey,
                          leading: IconButton(
                              onPressed: hp.goBack,
                              icon: const Icon(Icons.arrow_back_ios_new))),
                      const LogoWidget()
                    ],
                  ),
                  Flexible(
                    child: SingleChildScrollView(
                        child: Center(
                      child: Column(
                        children: <Widget>[
                          const SizedBox(
                            height: 50,
                          ),
                          SizedBox(
                            width: 225.0 + 225.0 + 225.0 + 3.0,
                            height: 60.0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Container(
                                  width: 225.0,
                                  height: 60.0,
                                  color: hp.theme.dividerColor,
                                  padding: const EdgeInsets.only(
                                      top: 20, bottom: 15, left: 25, right: 20),
                                  child: Text('Delivery Date',
                                      style: TextStyle(
                                          color: hp.theme.secondaryHeaderColor,
                                          fontSize: 20)),
                                ),
                                Container(
                                  width: 225.0,
                                  height: 60.0,
                                  color: hp.theme.dividerColor,
                                  padding: const EdgeInsets.only(
                                      top: 20, bottom: 15, left: 25, right: 20),
                                  child: Text('Delivery ID',
                                      style: TextStyle(
                                          color: hp.theme.secondaryHeaderColor,
                                          fontSize: 20)),
                                ),
                                Container(
                                  width: 225.0,
                                  height: 60.0,
                                  color: hp.theme.dividerColor,
                                  padding: const EdgeInsets.only(
                                      top: 20, bottom: 15, left: 25, right: 20),
                                  child: Text('Customer',
                                      style: TextStyle(
                                          color: hp.theme.secondaryHeaderColor,
                                          fontSize: 20)),
                                ),
                              ],
                            ),
                          ),
                          futureData == null
                              ? Center(
                                  heightFactor: 6.4,
                                  child: Image.asset(
                                      '${assetImagePath}puzzle_128.gif'))
                              : Container(
                                  margin: const EdgeInsets.only(
                                      top: 1, bottom: 20, left: 20, right: 20),
                                  child: Table(
                                    defaultColumnWidth:
                                        const FixedColumnWidth(226.0),
                                    border: TableBorder.all(
                                        color: Colors.white,
                                        style: BorderStyle.solid,
                                        width: 1),
                                    children: futureData?.map((datas) {
                                          return TableRow(children: [
                                            TableCell(
                                                child: GestureDetector(
                                              child: Container(
                                                padding: const EdgeInsets.only(
                                                    bottom: 15,
                                                    top: 15,
                                                    left: 15,
                                                    right: 5),
                                                color: hp.theme.disabledColor,
                                                child: Text(datas.deliveryDate,
                                                    style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 20)),
                                              ),
                                              onTap: () => hp.goTo(
                                                  '/goodsInMovementScan',
                                                  args: RouteArgument(
                                                      tag: datas.customerName,
                                                      content: datas.deliveryId
                                                          .toString())),
                                            )),
                                            TableCell(
                                                child: GestureDetector(
                                              child: Container(
                                                padding: const EdgeInsets.only(
                                                    bottom: 15,
                                                    top: 15,
                                                    left: 15,
                                                    right: 5),
                                                color: hp.theme.disabledColor,
                                                child: Text(
                                                    datas.deliverydateId,
                                                    style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 20)),
                                              ),
                                              onTap: () => hp.goTo(
                                                  '/goodsInMovementScan',
                                                  args: RouteArgument(
                                                      tag: datas.customerName,
                                                      content: datas.deliveryId
                                                          .toString())),
                                            )
                                                // Container(
                                                //     padding: const EdgeInsets.only(bottom: 15, top: 15, left: 15,right: 5),
                                                //     child:Text(datas.deliverydateId, style: const TextStyle(color: Colors.white,fontSize: 20)),
                                                //     color: hp.theme.disabledColor,
                                                //   )
                                                ),
                                            TableCell(
                                              child: GestureDetector(
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            bottom: 15,
                                                            top: 15,
                                                            left: 15,
                                                            right: 5),
                                                    color:
                                                        hp.theme.disabledColor,
                                                    child: Text(
                                                        datas.customerName,
                                                        style: const TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 20)),
                                                  ),
                                                  onTap: () => hp.goTo(
                                                          '/goodsInMovementScan',
                                                          vcb: () {
                                                        data.value = null;
                                                        hp.onChange();
                                                      },
                                                          args: RouteArgument(
                                                              tag: datas
                                                                  .customerName,
                                                              content: datas
                                                                  .deliveryId
                                                                  .toString()))),
                                              // Container(
                                              //     padding: const EdgeInsets.only(bottom: 15, top: 15, left: 15,right: 5),
                                              //     child:Text(datas.customerName, style: const TextStyle(color: Colors.white,fontSize: 20)),
                                              //     color: hp.theme.disabledColor,
                                              //   )
                                            ),
                                          ]);
                                        }).toList() ??
                                        [],
                                  ),
                                ),
                        ],
                      ),
                    )),
                  )
                ],
              ),
            ),
          ),
        ));
  }
}
