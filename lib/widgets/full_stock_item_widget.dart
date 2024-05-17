import 'package:flutter/material.dart';
import 'package:set_in_hand/helpers/helper.dart';
import 'package:set_in_hand/models/full_stock_item.dart';
import 'package:set_in_hand/widgets/full_stock_list_widget.dart';

class FullStockItemWidget extends StatefulWidget {
  final FullStockItem item;
  final int index;
  const FullStockItemWidget({Key? key, required this.item, required this.index})
      : super(key: key);

  static FullStockListWidgetState? of(BuildContext context) =>
      context.findAncestorStateOfType<FullStockListWidgetState>();

  @override
  FullStockItemWidgetState createState() => FullStockItemWidgetState();
}

class FullStockItemWidgetState extends State<FullStockItemWidget> {
  Helper get hp => Helper.of(context);
  FullStockListWidgetState? get fls => FullStockItemWidget.of(context);
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () async {},
        child: Container(
            margin: EdgeInsets.only(top: hp.height / 400),
            padding: EdgeInsets.all(hp.radius / 125),
            alignment: Alignment.topLeft,
            color: widget.item.stockCheckStatus == 2
                ? hp.theme.splashColor
                : (widget.item.stockCheckStatus == 1 ||
                        fls?.fss?.selected == widget.item
                    ? hp.theme.hintColor
                    : hp.theme.toggleableActiveColor),
            child: Text(widget.item.stockItemID,
                style: const TextStyle(color: Colors.white, fontSize: 17))));
  }
}
