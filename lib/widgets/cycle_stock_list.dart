import 'package:flutter/material.dart';
import 'package:set_in_hand/back_end/api.dart';
import 'package:set_in_hand/widgets/circular_loader.dart';
import 'package:set_in_hand/widgets/cycle_stock_item.dart';
import '../helpers/helper.dart';
import 'package:set_in_hand/screens/cyclestockcheck.dart';
import '../models/getcyclestockcheckmodel.dart';

class CycleStockListWidget extends StatefulWidget {
  const CycleStockListWidget({Key? key}) : super(key: key);
  static CycleStockCheckState? of(BuildContext context) =>
      context.findAncestorStateOfType<CycleStockCheckState>();

  @override
  CycleStockListWidgetState createState() => CycleStockListWidgetState();
}

class CycleStockListWidgetState extends State<CycleStockListWidget> {
  Helper get hp => Helper.of(context);
  CycleStockCheckState? get ccs => CycleStockListWidget.of(context);

  Widget listBuilder(
      BuildContext context, List<GetStockItem>? items, Widget? child) {
    Widget getItem(BuildContext context, int index) {
      return CycleStockItemWidget(
          item: items?[index] ?? GetStockItem.emptyItem, index: index);
    }

    return items == null
        ? Center(
            child: CircularLoader(
                duration: const Duration(seconds: 10),
                loaderType: LoaderType.chasingDots,
                color: hp.theme.primaryColor))
        : (items.isEmpty
            ? const Center(child: Text('Nothing Found'))
            : ListView.builder(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemBuilder: getItem,
                itemCount: items.length,
                physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics())));
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<GetStockItem>?>(
        valueListenable: getStockItems, builder: listBuilder);
  }
}
