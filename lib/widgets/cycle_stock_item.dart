import '../back_end/api.dart';
import '../helpers/helper.dart';
import 'package:flutter/material.dart';
import '../widgets/cycle_stock_list.dart';
import '../models/getcyclestockcheckmodel.dart';

class CycleStockItemWidget extends StatefulWidget {
  final int index;
  final GetStockItem item;
  const CycleStockItemWidget(
      {Key? key, required this.item, required this.index})
      : super(key: key);

  static CycleStockListWidgetState? of(BuildContext context) =>
      context.findAncestorStateOfType<CycleStockListWidgetState>();

  @override
  CycleStockItemWidgetState createState() => CycleStockItemWidgetState();
}

class CycleStockItemWidgetState extends State<CycleStockItemWidget> {
  Helper get hp => Helper.of(context);
  CycleStockListWidgetState? get cls => CycleStockItemWidget.of(context);
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () async {
          item = widget.item;
          box.value = -1;
          if (await hp.revealDialogBox([
            'Yes',
            'No'
          ], [
            () {
              hp.goBack(result: true);
            },
            () {
              hp.goBack(result: false);
            }
          ],
              title: 'Setinhand',
              action: 'Do you want to update the quantity as 0?',
              type: AlertType.cupertino)) {
            Map<String, dynamic> body = item?.map ?? <String, dynamic>{};
            body['createdBy'] = currentUser.value.userID.toString();
            body['updateQuantity'] = '0';
            body['stockCheckStatus'] = '2';
            body['qrcodeid'] = item?.qrcodeId.toString();
            body['task_id'] = cls?.ccs?.widget.task.taskID.toString();
            final rp = await api.updateCycleStockZero(body,hp);
            await hp.showSimplePopup('OK', () {
                      hp.goBack(result: true);
                    },
                        title: 'Setinhand',
                        type: AlertType.cupertino,
                        action: rp.message) &&
                    rp.success
                ? cls?.ccs?.didUpdateWidget(cls!.ccs!.widget)
                : doNothing();
          } else {
            cls?.setState(() {});
            // cls?.ccs?.setState(() {
            //   cls?.ccs?.pressed = true;
            // });
          }
          hp.onChange();
        },
        child: Container(
            margin: EdgeInsets.only(top: hp.height / 400),
            padding: EdgeInsets.all(hp.radius / 125),
            alignment: Alignment.topLeft,
            color: widget.item.stockCheckStatus == 2
                ? hp.theme.splashColor
                : (item == null
                    ? hp.theme.toggleableActiveColor
                    : (item == widget.item
                        ? hp.theme.hintColor
                        : hp.theme.toggleableActiveColor)),
            child: Text(widget.item.stockItemId,
                style: const TextStyle(color: Colors.white, fontSize: 17))));
  }
}
