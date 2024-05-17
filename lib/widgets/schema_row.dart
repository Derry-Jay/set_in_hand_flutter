import 'schema_cell.dart';
import 'package:flutter/material.dart';

class SchemaRow extends DataRow {
  final Color? rowColor;
  final bool? isSelected;
  final List<SchemaCell> items;
  final VoidCallback? onLongTap;
  final void Function(bool?)? onPickChanged;
  SchemaRow(
      {required this.items,
      this.rowColor,
      this.isSelected,
      this.onPickChanged,
      this.onLongTap})
      : super(
            cells: items,
            onLongPress: onLongTap,
            selected: isSelected ?? false,
            onSelectChanged: onPickChanged,
            color: MaterialStateProperty.all<Color?>(rowColor));
}
