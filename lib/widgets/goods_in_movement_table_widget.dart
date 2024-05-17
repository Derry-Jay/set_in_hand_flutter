import '../back_end/api.dart';
import 'collection_border.dart';
import '../helpers/helper.dart';
import '../widgets/collection.dart';
import '../widgets/empty_widget.dart';
import 'package:flutter/material.dart';
import '../widgets/collection_row.dart';
import '../widgets/collection_cell.dart';
import '../screens/goodsin_movement_scanpage.dart';
import '../models/GetCompletedDeliveriesDetails.dart';

class GoodsInMovementTableWidget extends StatefulWidget {
  const GoodsInMovementTableWidget({Key? key}) : super(key: key);

  static GoodsInMovementScanPageState? of(BuildContext context) =>
      context.findAncestorStateOfType<GoodsInMovementScanPageState>();

  @override
  State<GoodsInMovementTableWidget> createState() =>
      _GoodsInMovementTableWidgetState();
}

class _GoodsInMovementTableWidgetState
    extends State<GoodsInMovementTableWidget> {
  GoodsInMovementScanPageState? get gps =>
      GoodsInMovementTableWidget.of(context);
  Widget tableBuilder(BuildContext context,
      List<GetCompletedDeliveriesDetailDeliveryDatum>? list, Widget? child) {
    final hpr = Helper.of(context);
    if (list == null || list.isEmpty) {
      return child ?? const EmptyWidget();
    } else {
      List<CollectionRow> dataRows = <CollectionRow>[
        CollectionRow(cells: [
          CollectionCell(Padding(
              padding: EdgeInsets.symmetric(vertical: hpr.height / 50),
              child: const Text('Stock Items', textAlign: TextAlign.center))),
          CollectionCell(Padding(
              padding: EdgeInsets.symmetric(vertical: hpr.height / 50),
              child: const Text('QR Code', textAlign: TextAlign.center)))
        ], rowStyle: BoxDecoration(color: hpr.theme.canvasColor))
      ];
      for (GetCompletedDeliveriesDetailDeliveryDatum item in list) {
        dataRows.add(CollectionRow(
            cells: [
              CollectionCell(Padding(
                  padding: EdgeInsets.symmetric(vertical: hpr.height / 50),
                  child: item.stockItemId == null
                      ? const EmptyWidget()
                      : Text(item.stockItemId ?? '',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: hpr.theme.scaffoldBackgroundColor)))),
              CollectionCell(Padding(
                  padding: EdgeInsets.symmetric(vertical: hpr.height / 50),
                  child: item.qrcodetext == null
                      ? const EmptyWidget()
                      : Text(item.qrcodetext ?? '',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: hpr.theme.scaffoldBackgroundColor))))
            ],
            rowStyle: BoxDecoration(
                color: gps == null
                    ? hpr.theme.toggleableActiveColor
                    : (gps!.scanSelected.contains(item.qrcodetext)
                        ? hpr.theme.hintColor
                        : hpr.theme.toggleableActiveColor))));
      }
      return SingleChildScrollView(
          child: Collection(
              rows: dataRows,
              tableBorder: CollectionBorder(
                  hi: BorderSide(width: hpr.width / 250, color: Colors.white),
                  vi: BorderSide(
                      width: hpr.height / 400, color: Colors.white))));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<
            List<GetCompletedDeliveriesDetailDeliveryDatum>?>(
        valueListenable: data,
        builder: tableBuilder,
        child: Image.asset('${assetImagePath}puzzle_128.gif'));
  }
}
