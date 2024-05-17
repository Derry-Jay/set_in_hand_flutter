import 'package:flutter/material.dart';
import 'package:set_in_hand/models/goods_check.dart';

class GoodsCheckItemWidget extends StatelessWidget {
  final GoodsCheck item;
  const GoodsCheckItemWidget({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {}, child: Card(child: Text(item.task.location)));
  }
}
