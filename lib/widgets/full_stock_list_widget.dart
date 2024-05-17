import 'package:flutter/material.dart';
import 'package:set_in_hand/screens/full_stock_next_step_screen.dart';

import '../back_end/api.dart';
import '../helpers/helper.dart';
import '../models/full_stock_item.dart';
import 'circular_loader.dart';
import 'full_stock_item_widget.dart';

class FullStockListWidget extends StatefulWidget {
  const FullStockListWidget({Key? key}) : super(key: key);

  static FullStockNextStepScreenState? of(BuildContext context) =>
      context.findAncestorStateOfType<FullStockNextStepScreenState>();

  @override
  FullStockListWidgetState createState() => FullStockListWidgetState();
}

class FullStockListWidgetState extends State<FullStockListWidget> {
  Helper get hp => Helper.of(context);
  FullStockNextStepScreenState? get fss => FullStockListWidget.of(context);
  Widget listBuilder(
      BuildContext context, List<FullStockItem>? items, Widget? child) {
    Widget getItem(BuildContext context, int index) {
      return FullStockItemWidget(item: items![index], index: index);
    }

    return items == null
        ? Center(
            child: CircularLoader(
                duration: const Duration(seconds: 10),
                loaderType: LoaderType.chasingDots,
                color: hp.theme.primaryColor))
        : (items.isEmpty
            ? Container(
                decoration: BoxDecoration(color: hp.theme.errorColor),
                padding: EdgeInsets.symmetric(
                    vertical: hp.height / 64, horizontal: hp.width / 32),
                child: Text('No Stock Item in this Location',
                    style: TextStyle(color: hp.theme.scaffoldBackgroundColor)))
            : ListView.builder(
                shrinkWrap: true,
                itemBuilder: getItem,
                itemCount: items.length,
                scrollDirection: Axis.vertical,
                physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics())));
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<FullStockItem>?>(
        valueListenable: items, builder: listBuilder);
  }
}
