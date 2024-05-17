import '../back_end/api.dart';
import '../helpers/helper.dart';
import '../models/getrack.dart';
import '../widgets/my_app_bar.dart';
import '../widgets/logo_widget.dart';
import '../models/getzonemodel.dart';
import '../widgets/loader_widget.dart';
import '../models/palletlocation.dart';
import '../models/route_argument.dart';
import '../widgets/bottom_widget.dart';
import '../widgets/custom_button.dart';
import 'package:flutter/material.dart';
import '../../extensions/extension.dart';
import '../widgets/chat_list_widget.dart';
import '../widgets/custom_labelled_button.dart';
import '../models/GetpalletLocationsModel.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class STOCKMOVEMENTSCANPAGE extends StatefulWidget {
  const STOCKMOVEMENTSCANPAGE({Key? key}) : super(key: key);

  @override
  STOCKMOVEMENTScanfile createState() => STOCKMOVEMENTScanfile();
}

class STOCKMOVEMENTScanfile extends State<STOCKMOVEMENTSCANPAGE> {
  String? code;
  bool pressed = false;
  PalletLocationModel? getBuilding;
  GetZoneModel? getZonedata;
  GetRackModel? getRackdata;
  Getpalletlocationsmodel? getPallets;
  List<GetLocation>? getLocations;
  PalletBuilding? pallerdropdownvalue;
  Zone? zonedropdownvalue;
  Rack? rackdropdownvalue;
  ScrollController sc = ScrollController(),
      scrollController = ScrollController();
  Helper get hp => Helper.of(qrKey.currentContext ?? context);

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool firstTimeinitFlag = false;

  void onQRViewCreated(QRViewController con) async {
    bool scanned = false;

    void onData(Barcode event) async {
      if (!scanned) {
        scanned = true;
        // await con.stopCamera();
        await con.pauseCamera();
        if (event.code?.isNotEmpty ?? false) {
          setState(() {
            pressed = false;
            code = event.code;
            bytes.value = putData(getData(event.rawBytes ?? <int>[]));
          });
          final od = await api.scanStockMovement(code ?? '', hp);
          od.reply.success &&
                  (mounted || (qrKey.currentState?.mounted ?? false))
              ? hp.goTo('/stockMovementFinal',
                  args: RouteArgument(id: int.tryParse(od.data.toString())))
              : (await hp.revealToast(od.reply.message)
                  ? log(event.format)
                  : log('Bye'));
          // qrCodeScanValue(event.code ?? '', con);
        } else {
          // await con.resumeCamera();
          // showDialogEmpty(context, 'Qr code is empty. please scan proper code');
        }
      }
    }

    void onError(Object val, StackTrace trace) async {
      log(val);
      log(trace);
      // return trace.toString();
    }

    if (!css.contains(con.scannedDataStream)) {
      css.add(con.scannedDataStream);
    }
    final cs = con.scannedDataStream.listen(onData, onError: onError);
    if (!scs.contains(cs)) {
      scs.add(cs);
    }
  }

  void customDispose() async {
    qrKey.currentState?.dispose();
    if (scs.isNotEmpty) {
      await scs.last.cancel();
    }
  }

  void setPallets() async {
    getBuilding = await api.palletLocations(hp);
    final list = getBuilding?.palletLocations.building;
    firstTimeinitFlag = true;
    if (list != null && list.isNotEmpty && mounted) {
      setState(() {
        pallerdropdownvalue = list.first;
        getLocations = getBuilding?.palletLocations.getLocations;
      });
      setZone(list.first.id);
    } else {
      setZone(0);
    }
  }

  void setZone(int buildingid) async {
    getZonedata = await api.getZone(buildingid, hp);
    final list = getZonedata?.zoneData.zone;
    if (list != null && list.isNotEmpty && mounted) {
      setState(() {
        // zoneFlag = false;
        zonedropdownvalue = list[0];
      });
      setRack(getZonedata?.zoneData.zone.first.id ?? 0);
    } else {
      setState(() {
        //  zoneFlag = true;
        setRack(0);
        // zonedropdownvalue = ;
      });
    }
  }

  void setRack(int zoneid) async {
    getRackdata = await api.getRack(zoneid, hp);
    final list = getRackdata?.rackData.rack;
    if (list != null && list.isNotEmpty && mounted) {
      setState(() {
        // rackFlag = false;
        rackdropdownvalue = list[0];
      });
    } else {
      setState(() {
        //  rackFlag = true;
        // zonedropdownvalue = ;
      });
    }
  }

  void setpalletDetails(int zoneId, int buildingId, int rackId) async {
    if (zoneId != 0 && buildingId != 0 && rackId != 0) {
      getPallets = await api.getPalletLocations(zoneId, buildingId, rackId, hp);
      log(getPallets?.palletLocations);
      log(mounted);
      if (mounted) {
        setState(() {
          getLocations = getPallets?.palletLocations.getLocations ?? [];
          log(getLocations);
          contentsOfStocksSpaces();
        });
      }
    } else {
      showDialogEmpty(
          context, 'Please check the pallets, zone and rack are selected');
    }
  }

  void setScanMode() {
    if (mounted) setState(setScanValue);
  }

  void setScanValue() {
    pressed = !pressed;
  }

  Widget scrollDownButton() {
    return Container(
      height: 60,
      width: double.infinity,
      padding: const EdgeInsets.only(bottom: 15, left: 0, right: 0),
      child: TextButton(
        style: ButtonStyle(
          foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
          backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
        ),
        onPressed: () {
          // setState(() {
          //   // _messages.insert(0, new Text("message ${_messages.length}"));
          //   getLocations?.insert(0, new Text("message ${getLocations.length}"));
          // });
          scrollController.animateTo(
            scrollController.position.maxScrollExtent,
            curve: Curves.bounceInOut,
            duration: const Duration(milliseconds: 1500),
          );
        },
        child: const Text(
          'Scroll Down',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.normal),
        ),
      ),
    );
  }

  Widget pageBuilder(BuildContext context, Orientation screenLayout) {
    final hpp = Helper.of(context);
    log(screenLayout);
    log(hpp.screenLayout);
    log('Hi');
    return WillPopScope(
        onWillPop: hp.backButtonOverride,
        child: SafeArea(
          child: Scaffold(
              bottomNavigationBar:
                  BottomWidget(heightFactor: 30, widthFactor: hpp.width),
              backgroundColor: const Color(0xffdbd9d9),
              key: _scaffoldKey,
              endDrawer: const Drawer(child: ChatListWidget()),
              body: getBuilding == null ||
                      getZonedata == null ||
                      getRackdata == null
                  ? const LoaderWidget()
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          children: [
                            MyAppBar(hpp, _scaffoldKey,
                                leading: IconButton(
                                    onPressed: hpp.goBack,
                                    icon:
                                        const Icon(Icons.arrow_back_ios_new))),
                            const LogoWidget()
                          ],
                        ),
                        Flexible(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Flexible(
                                flex: 3,
                                child: Container(
                                    padding: const EdgeInsets.all(10),
                                    color: Colors.white,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            palletDropDown(),
                                            zoneDropDown(),
                                            rackDropDown(),
                                            SizedBox(
                                              width: 80,
                                              child: ElevatedButton(
                                                  style: ButtonStyle(
                                                      backgroundColor:
                                                          MaterialStateProperty
                                                              .all(Colors.blue),
                                                      padding:
                                                          MaterialStateProperty
                                                              .all(
                                                                  const EdgeInsets
                                                                      .all(12)),
                                                      textStyle:
                                                          MaterialStateProperty
                                                              .all(
                                                                  const TextStyle(
                                                                      fontSize:
                                                                          12))),
                                                  onPressed: () {
                                                    log(pallerdropdownvalue
                                                        ?.id);
                                                    log(zonedropdownvalue?.id);
                                                    log(rackdropdownvalue?.id);
                                                    setpalletDetails(
                                                        pallerdropdownvalue
                                                                ?.id ??
                                                            0,
                                                        zonedropdownvalue?.id ??
                                                            0,
                                                        rackdropdownvalue?.id ??
                                                            0);
                                                  },
                                                  child: const Text('Search')),
                                            ),
                                          ],
                                        ),
                                        Container(
                                          margin:
                                              const EdgeInsets.only(top: 50),
                                          padding: const EdgeInsets.all(15),
                                          alignment: Alignment.topLeft,
                                          color: Colors.grey,
                                          height: 50,
                                          child: const Text(
                                            'Pallet Locations',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontSize: 17,
                                                color: Colors.black54),
                                          ),
                                        ),
                                        contentsOfStocksSpaces(),
                                        const SizedBox(
                                          height: 50,
                                        ),
                                        scrollDownButton()
                                      ],
                                    )),
                              ),
                              Flexible(
                                  flex: 2,
                                  child: Column(children: [
                                    SizedBox(
                                        width: double
                                            .infinity, // <-- match_parent, // <-- match-parent
                                        child: CustomButton(
                                            padding: EdgeInsets.symmetric(
                                                vertical: hpp.height / 100),
                                            buttonColor:
                                                hpp.theme.selectedRowColor,
                                            labelColor: hpp
                                                .theme.scaffoldBackgroundColor,
                                            type: ButtonType.raised,
                                            onPressed: setScanMode,
                                            child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: const [
                                                  Icon(Icons.qr_code_scanner,
                                                      color: Colors.white),
                                                  Text('Scan Code',
                                                      style: TextStyle(
                                                          color: Colors.white))
                                                ]))),
                                    pressed
                                        ? Container(
                                            alignment: Alignment.topLeft,
                                            height: hpp.height /
                                                (screenLayout ==
                                                        Orientation.landscape
                                                    ? 2.56
                                                    : 4),
                                            width: screenLayout ==
                                                    Orientation.landscape
                                                ? hpp.width / 2.56
                                                : null,
                                            padding:
                                                EdgeInsets.all(hpp.radius / 80),
                                            child: Stack(
                                              alignment: Alignment.bottomCenter,
                                              children: <Widget>[
                                                QRView(
                                                    overlay:
                                                        QrScannerOverlayShape(
                                                            cutOutHeight:
                                                                hpp.height / 2,
                                                            cutOutWidth:
                                                                hpp.width),
                                                    key: qrKey,
                                                    onQRViewCreated:
                                                        onQRViewCreated),
                                                Positioned(
                                                    left: hpp.width /
                                                        7.0368744177664,
                                                    top: hpp.height /
                                                        (screenLayout ==
                                                                Orientation
                                                                    .landscape
                                                            ? 4
                                                            : 6.4),
                                                    child: CustomLabelledButton(
                                                        labelColor: hpp.theme
                                                            .scaffoldBackgroundColor,
                                                        buttonColor: hpp
                                                            .theme.errorColor,
                                                        label: 'Cancel',
                                                        onPressed: setScanMode,
                                                        type: ButtonType.text)),
                                              ],
                                            ),
                                          )
                                        : Container(
                                            decoration: const BoxDecoration(
                                                color: Colors.black),
                                            margin: EdgeInsets.symmetric(
                                                vertical: hpp.height / 40,
                                                horizontal: hpp.width / 25),
                                            padding: EdgeInsets.symmetric(
                                                vertical: hpp.height / 8)),
                                    Visibility(
                                        visible:
                                            code != null && code!.isNotEmpty,
                                        child: Flexible(
                                            child: Text('Scanned Result: ${code ?? ''}')))
                                    //     ,
                                    // imageCode == null
                                    //     ? const EmptyWidget()
                                    //     : Image.memory(imageCode!,
                                    //         errorBuilder: hpp.errorBuilder)
                                  ])),
                            ],
                          ),
                        ),
                      ],
                    )),
        ));
  }

  DropdownButton palletDropDown() {
    return DropdownButton<PalletBuilding>(
      icon: const Icon(Icons.keyboard_arrow_down),
      dropdownColor: Colors.white,
      value: pallerdropdownvalue,
      onChanged: (PalletBuilding? newValue) => setState(() {
        // log(newValue);
        pallerdropdownvalue = newValue!;
        setZone(newValue.id);
      }),
      selectedItemBuilder: (BuildContext context) {
        return (getBuilding?.palletLocations.building ?? [])
            .map((PalletBuilding? item) {
          return Padding(
              padding: const EdgeInsets.all(15),
              child: Text(item?.building ?? '', textAlign: TextAlign.center));
        }).toList();
      },
      items: (getBuilding?.palletLocations.building ?? [])
          .map((PalletBuilding item) {
        return DropdownMenuItem<PalletBuilding>(
            value: item,
            child: pallerdropdownvalue?.id == item.id
                ? Container(
                    color: Colors.white,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // firstFlag = false;
                        Text(item.building),
                        Image.asset(
                          '${assetImagePath}checked.png',
                          color: Colors.blue,
                        )
                      ],
                    ),
                  )
                : Text(item.building));
      }).toList(),
    );
  }

// zoneFlag == true ? Zone(0, 0, '', 0, '', '') :
  DropdownButton zoneDropDown() {
    return DropdownButton<Zone>(
      dropdownColor: Colors.white,
      value: zonedropdownvalue,
      icon: const Icon(Icons.keyboard_arrow_down),
      selectedItemBuilder: (BuildContext context) {
        return (getZonedata?.zoneData.zone ?? []).map((Zone? item) {
          return Padding(
            padding: const EdgeInsets.all(15),
            child: Text(
              item?.zone ?? '',
              textAlign: TextAlign.center,
              style: const TextStyle(),
            ),
          );
        }).toList();
      },
      items: (getZonedata?.zoneData.zone ?? []).map((Zone item) {
        return DropdownMenuItem<Zone>(
          value: item,
          // child: Text(item.zone ?? ''),
          child: zonedropdownvalue?.id == item.id
              ? Container(
                  color: Colors.white,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(item.zone ?? ''),
                      Image.asset(
                        '${assetImagePath}checked.png',
                        color: Colors.blue,
                      )
                    ],
                  ),
                )
              : Text(item.zone ?? ''),
        );
      }).toList(),
      onChanged: (Zone? newValue) {
        setState(() {
          // log(newValue);
          zonedropdownvalue = newValue;
          setRack(newValue?.id ?? 0);
        });
      },
    );
  }

// rackFlag == true ? Rack(0, 0, '', 0, '', '') :
  DropdownButton rackDropDown() {
    return DropdownButton<Rack>(
      dropdownColor: Colors.white,
      value: rackdropdownvalue,
      icon: const Icon(Icons.keyboard_arrow_down),
      selectedItemBuilder: (BuildContext context) {
        return (getRackdata?.rackData.rack ?? []).map((Rack? item) {
          return Padding(
            padding: const EdgeInsets.all(15),
            child: Text(item?.rack ?? '', textAlign: TextAlign.center),
          );
        }).toList();
      },
      items: (getRackdata?.rackData.rack ?? []).map((Rack item) {
        return DropdownMenuItem<Rack>(
          value: item,
          // child: Text(item.zone ?? ''),
          child: rackdropdownvalue?.id == item.id
              ? Container(
                  color: Colors.white,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(item.rack ?? ''),
                      Image.asset(
                        '${assetImagePath}checked.png',
                        color: Colors.blue,
                      )
                    ],
                  ),
                )
              : Text(item.rack ?? ''),
        );
      }).toList(),
      onChanged: (Rack? newValue) {
        // rackdropdownvalue = newValue;
        setState(() {
          rackdropdownvalue = newValue;
          rackDropDown();
        });
      },
    );
  }

  Expanded contentsOfStocksSpaces() {
    return Expanded(
      flex: 4,
      child: Container(
          margin: EdgeInsets.only(bottom: hp.height / 100),
          width: double.infinity,
          child: (getLocations!.isEmpty)
              ? Image.asset('${assetImagePath}puzzle_128.gif')
              : buildingpallets()),
    );
  }

  ListView buildingpallets() {
    return ListView.builder(
      controller: scrollController,
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      physics: BouncingScrollPhysics(
          parent: (getLocations?.length ?? 0) <= 10
              ? const NeverScrollableScrollPhysics()
              : const AlwaysScrollableScrollPhysics()),
      itemBuilder: (context, index) {
        final item = getLocations![index];
        // firstTimeinitFlag = false;
        // log('Hi');
        // log(item.status);
        //
        return Container(
          margin: const EdgeInsets.only(top: 1),
          padding: const EdgeInsets.all(15),
          alignment: Alignment.topLeft,
          height: 50,
          color: parseBool(item.status)
              ? hp.theme.splashColor
              : hp.theme.toggleableActiveColor,
          child: Text(
            item.uniqueId ?? '',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 17, color: Colors.white),
          ),
        );
      },
      itemCount: getLocations?.length,
    );
  }

  @override
  void dispose() {
    customDispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    hp.getConnectStatus();
    setPallets();
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(builder: pageBuilder);
  }
}

class BuildingDropdown extends StatefulWidget {
  final List<PalletBuilding> buildingList;
  // final String customer_name;

  const BuildingDropdown({Key? key, required this.buildingList})
      : super(key: key);

  @override
  BuildingDropdownState createState() => BuildingDropdownState();
}

class BuildingDropdownState extends State<BuildingDropdown> {
  // Initial Selected Value
  PalletBuilding? dropdownvalue;

  // List of items in our dropdown menu
  var items = [
    'Item 1',
    'Item 1',
    'Item 3',
    'Item 4',
    'Item 5',
  ];

  @override
  Widget build(BuildContext context) {
    return DropdownButton<PalletBuilding>(
      // Initial Value
      value: dropdownvalue,
      // hint: Container(
      //     child: Text(widget.buildingList.first.building),
      //   ),

      // Down Arrow Icon
      icon: const Icon(Icons.keyboard_arrow_down),

      // Array list of items
      items: widget.buildingList.map((PalletBuilding item) {
        return DropdownMenuItem<PalletBuilding>(
          value: item,
          child: Text(item.building),
        );
      }).toList(),
      // After selecting the desired option,it will
      // change button value to selected value
      onChanged: (PalletBuilding? newValue) {
        setState(() {
          // log(newValue);
          dropdownvalue = newValue!;
        });
      },
    );
  }
}

class ZoneDropdown extends StatefulWidget {
  final List<Zone> zoneList;
  // final String customer_name;

  const ZoneDropdown({Key? key, required this.zoneList}) : super(key: key);

  @override
  ZoneDropdownState createState() => ZoneDropdownState();
}

class ZoneDropdownState extends State<ZoneDropdown> {
  // Initial Selected Value
  Zone? dropdownvalue;

  @override
  Widget build(BuildContext context) {
    return DropdownButton<Zone>(
      // Initial Value
      value: dropdownvalue,

      // hint: Container(
      //     child: Text(widget.zoneList.first.zone ?? ''),
      //   ),

      // Down Arrow Icon
      icon: const Icon(Icons.keyboard_arrow_down),

      // Array list of items
      items: widget.zoneList.map((Zone item) {
        return DropdownMenuItem<Zone>(
          value: item,
          child: Text(item.zone ?? ''),
        );
      }).toList(),
      // After selecting the desired option,it will
      // change button value to selected value
      onChanged: (Zone? newValue) {
        setState(() {
          // log(newValue);
          dropdownvalue = newValue!;
        });
      },
    );
  }
}

class RackDropdown extends StatefulWidget {
  final List<Rack> rackList;
  // final String customer_name;

  const RackDropdown({Key? key, required this.rackList}) : super(key: key);

  @override
  RackDropdownState createState() => RackDropdownState();
}

class RackDropdownState extends State<RackDropdown> {
  Rack? dropdownvalue;

  @override
  Widget build(BuildContext context) {
    return DropdownButton<Rack>(
      // Initial Value
      value: dropdownvalue,

      // hint: Container(
      //     child: Text(widget.rackList.first.rack ?? ''),
      //   ),

      // Down Arrow Icon
      icon: const Icon(Icons.keyboard_arrow_down),

      // Array list of items
      items: widget.rackList.map((Rack item) {
        return DropdownMenuItem<Rack>(
          value: item,
          child: Text(item.rack ?? ''),
        );
      }).toList(),
      // After selecting the desired option,it will
      // change button value to selected value
      onChanged: (Rack? newValue) {
        setState(() {
          // log(newValue);
          dropdownvalue = newValue!;
        });
      },
    );
  }
}
