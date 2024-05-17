import 'package:flutter/material.dart';

class SchemaCell extends DataCell {
  final Widget cellData;
  final void Function(TapDownDetails)? onPressDown;
  final VoidCallback? onPress, onDoublePress, onLongTap, onPressCancel;
  const SchemaCell(
    this.cellData, {
    this.onPress,
    this.onDoublePress,
    this.onLongTap,
    this.onPressDown,
    this.onPressCancel,
  }) : super(cellData,
            onTap: onPress,
            onLongPress: onLongTap,
            onTapDown: onPressDown,
            onDoubleTap: onDoublePress,
            onTapCancel: onPressCancel);
}
