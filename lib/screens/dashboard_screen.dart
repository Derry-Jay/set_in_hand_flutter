import '../back_end/api.dart';
import '../helpers/helper.dart';
import '../widgets/my_app_bar.dart';
import '../widgets/logo_widget.dart';
import '../widgets/empty_widget.dart';
import '../widgets/loader_widget.dart';
import 'package:flutter/material.dart';
import '../widgets/bottom_widget.dart';
import '../widgets/task_list_widget.dart';
import '../widgets/chat_list_widget.dart';
import '../widgets/due_delivery_list_widget.dart';
import 'package:horizontal_data_table/refresh/pull_to_refresh/pull_to_refresh.dart';
import 'package:multi_value_listenable_builder/multi_value_listenable_builder.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  DashboardScreenState createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  double cx = 0.0, cy = 0.0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  RefreshController refreshController =
      RefreshController(initialRefresh: false);
  Helper get hp => Helper.of(context);

  Widget contentBuilder(
      BuildContext context, List<dynamic> values, Widget? child) {
    final tl = values.first;
    final dl = values.last;

    final hpc = Helper.of(context);

    return tl == null && dl == null
        ? (child ?? const EmptyWidget())
        : Column(
            children: [
              Stack(
                children: [
                  SizedBox(
                      width: hpc.width,
                      height: hpc.height *
                          (hpc.screenLayout == Orientation.landscape
                              ? 0.93
                              : 0.95),
                      child: SmartRefresher(
                          enablePullDown: true,
                          onRefresh: refreshList,
                          controller: refreshController,
                          child: Container(
                              padding: const EdgeInsets.only(top: 60),
                              height: hpc.height * 1.048576,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(stops: [
                                  hpc.screenLayout == Orientation.landscape
                                      ? 0.82
                                      : 0.76,
                                  hpc.screenLayout == Orientation.landscape
                                      ? 0.84
                                      : 0.78
                                ], colors: const [
                                  Color(0xffe8e8e8),
                                  Colors.white
                                ]),
                              ),
                              child: Row(
                                // mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Flexible(
                                            child: Container(
                                          margin: const EdgeInsets.all(20),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              const Text(
                                                'TASKS',
                                                style: TextStyle(
                                                  fontSize: 18,
                                                ),
                                              ),
                                              Image.asset(
                                                  '${assetImagePath}side_stock_icon.png',
                                                  fit: BoxFit.fill,
                                                  height: 30),
                                            ],
                                          ),
                                        )),
                                        const Expanded(
                                            flex: 7, child: TaskListWidget())
                                      ],
                                    ),
                                  ),
                                  Container(color: Colors.white, width: 10),
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Flexible(
                                            child: Container(
                                          margin: const EdgeInsets.all(20),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              const Text(
                                                'DELIVERIES',
                                                style: TextStyle(
                                                  fontSize: 18,
                                                ),
                                              ),
                                              Image.asset(
                                                '${assetImagePath}deliveries.png',
                                                fit: BoxFit.scaleDown,
                                                height: 25,
                                              ),
                                            ],
                                          ),
                                        )),
                                        const Expanded(
                                            flex: 7,
                                            child: DueDeliveryListWidget())
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: 180,
                                    padding: const EdgeInsets.only(top: 25),
                                    height: hpc.height * (1.6),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Expanded(
                                            child: GestureDetector(
                                          onTap: () {
                                            hpc.goTo('/stockMovementOptions');
                                          },
                                          child: Column(
                                            children: <Widget>[
                                              Image.asset(
                                                  '${assetImagePath}move_icon.png',
                                                  width: hpc.width / 4,
                                                  height: hpc.height / 5.12),
                                              SizedBox(height: hp.height / 125),
                                              const Text('STOCK MOVEMENT',
                                                  style: TextStyle(
                                                      color: Colors.grey,
                                                      fontSize: 20),
                                                  textAlign: TextAlign.center)
                                            ],
                                          ),
                                        )),
                                        Expanded(
                                            child: GestureDetector(
                                          onTap: () {
                                            // code.value = null;
                                            // location.value = null;
                                            // hpc.onChange();
                                            // hpc.goTo('/qr');
                                          },
                                          child: Column(
                                            children: <Widget>[
                                              Image.asset(
                                                  '${assetImagePath}add_delivery.png',
                                                  width: 150,
                                                  height: 90),
                                              const SizedBox(
                                                height: 15,
                                              ),
                                              const Text('ADD DELIVERY',
                                                  style: TextStyle(
                                                      color: Colors.grey,
                                                      fontSize: 20),
                                                  textAlign: TextAlign.center)
                                            ],
                                          ),
                                        )),
                                        Expanded(
                                            child: GestureDetector(
                                          onTap: () {
                                            hpc.goTo('/whatIsThis');
                                          },
                                          child: Column(
                                            children: <Widget>[
                                              Image.asset(
                                                  '${assetImagePath}question.png',
                                                  width: 83,
                                                  height: 140),
                                              const SizedBox(
                                                height: 15,
                                              ),
                                              const Text(
                                                "WHAT'S THIS",
                                                style: TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 20),
                                                textAlign: TextAlign.center,
                                              )
                                            ],
                                          ),
                                        ))
                                      ],
                                    ),
                                  )
                                ],
                              )))),
                  MyAppBar(hpc, _scaffoldKey,
                      leading: Icon(Icons.dehaze, size: hp.height / 25)),
                  const LogoWidget()
                ],
              )
            ],
          );
  }

  void dragDown(DragDownDetails details) {
    cx = details.globalPosition.dx;
    cy = details.globalPosition.dy;
    log(details.globalPosition.dx);
    log(details.globalPosition.dy);
  }

  void tapUp(TapUpDetails details) {
    final x = details.globalPosition.dx;
    final y = details.globalPosition.dy;
    log(x);
    log(y);
    cx = x;
    cy = y;
  }

  void tapDown(TapDownDetails details) {
    final x = details.globalPosition.dx;
    final y = details.globalPosition.dy;
    log(x);
    log(y);
    cx = x;
    cy = y;
  }

  void refreshList() async {
    await Future.delayed(const Duration(seconds: 2));
    tasks.value = null;
    dueDeliveries.value = null;
    hp.notifyTasks();
    hp.notifyDues();
    getData();
  }

  void getData() async {
    await Future.delayed(Duration.zero, assignData);
  }

  void assignData() {
    try {
      refreshController.refreshToIdle();
      api.getTasks(hp);
      refreshController.refreshCompleted();
    } catch (e) {
      sendAppLog(e);

      refreshController.refreshFailed();
    }
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  void didUpdateWidget(DashboardScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    api.getTasks(hp);
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
                body: MultiValueListenableBuilder(
                    valueListenables: [tasks, dueDeliveries],
                    builder: contentBuilder,
                    child: const LoaderWidget()))));
  }
}
