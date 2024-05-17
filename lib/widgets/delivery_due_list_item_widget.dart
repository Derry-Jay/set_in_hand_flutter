import 'package:flutter/material.dart';
import 'package:set_in_hand/models/route_argument.dart';
import 'due_delivery_list_widget.dart';
import 'package:set_in_hand/helpers/helper.dart';
import 'package:set_in_hand/models/delivery.dart';

class DeliveryDueListItemWidget extends StatefulWidget {
  final Delivery due;
  const DeliveryDueListItemWidget({Key? key, required this.due})
      : super(key: key);

  static DueDeliveryListWidgetState? of(BuildContext context) =>
      context.findAncestorStateOfType<DueDeliveryListWidgetState>();

  @override
  DeliveryDueListItemWidgetState createState() =>
      DeliveryDueListItemWidgetState();
}

class DeliveryDueListItemWidgetState extends State<DeliveryDueListItemWidget> {
  Helper get hp => Helper.of(context);
  DueDeliveryListWidgetState? get dds => DeliveryDueListItemWidget.of(context);
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        child: Container(
            height: hp.height /
                (hp.screenLayout == Orientation.landscape ? 10.24 : 13.1072),
            width: hp.width / 2,
            alignment: Alignment.center,
            margin: EdgeInsets.symmetric(
                vertical: hp.height / 128, horizontal: hp.width / 64),
            padding: EdgeInsets.all(hp.radius / 160),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(hp.radius / 125)),
              border: Border.all(
                width: 1,
                color: Colors.grey,
                style: BorderStyle.solid,
              ),
              color: Colors.white,
            ),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                      flex: 2,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Flexible(
                              child: Text(
                            'Delivery Due',
                            style: TextStyle(fontSize: 16, color: Colors.brown),
                          )),
                          Flexible(
                            child: Text(widget.due.lapsedTime,
                                style: const TextStyle(fontSize: 12)),
                          ),
                        ],
                      )),
                  // SizedBox(height: hp.height / 50),
                  Flexible(
                      flex: 3,
                      child: Text(widget.due.toString(),
                          style: const TextStyle(fontSize: 12)))
                ])),
        onTap: () {
          hp.goTo('/deliveryDetails',
              args: RouteArgument(
                  params: widget.due.json,
                  id: widget.due.deliveryID,
                  content: widget.due.customerName), vcb: () {
            dds?.dss?.didUpdateWidget(dds!.dss!.widget);
          });
        });
  }
}
