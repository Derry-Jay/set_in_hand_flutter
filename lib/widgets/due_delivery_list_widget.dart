import 'empty_widget.dart';
import '../back_end/api.dart';
import '../helpers/helper.dart';
import '../models/delivery.dart';
import 'package:flutter/material.dart';
import '../screens/dashboard_screen.dart';
import 'delivery_due_list_item_widget.dart';

class DueDeliveryListWidget extends StatefulWidget {
  const DueDeliveryListWidget({Key? key}) : super(key: key);

  static DashboardScreenState? of(BuildContext context) =>
      context.findAncestorStateOfType<DashboardScreenState>();

  @override
  DueDeliveryListWidgetState createState() => DueDeliveryListWidgetState();
}

class DueDeliveryListWidgetState extends State<DueDeliveryListWidget> {
  DashboardScreenState? get dss => DueDeliveryListWidget.of(context);

  void deliveryListener() {
    log('delivery');
  }

  Widget listBuilder(
      BuildContext context, List<Delivery>? dues, Widget? child) {
    Widget getItem(BuildContext context, int index) {
      return DeliveryDueListItemWidget(
          due: dues?[index] ?? Delivery.emptyDelivery);
    }

    return dues == null
        ? (child ?? const EmptyWidget())
        : (dues.isEmpty
            ? const Text('No Due Deliveries Found')
            : ListView.builder(
                physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics()),
                itemBuilder: getItem,
                itemCount: dues.length));
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    dueDeliveries.addListener(deliveryListener);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<Delivery>?>(
        valueListenable: dueDeliveries, builder: listBuilder);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    dueDeliveries.removeListener(deliveryListener);
    super.dispose();
  }
}
