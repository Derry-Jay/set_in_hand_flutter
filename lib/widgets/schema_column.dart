import 'package:flutter/material.dart';

class SchemaColumn extends DataColumn {
  final bool? isDigit;
  final String columnName;
  final EdgeInsets? padding;
  final BoxDecoration? decoration;
  final void Function(int, bool)? whileSort;
  SchemaColumn(
      {required this.columnName,
      this.padding,
      this.isDigit,
      this.decoration,
      this.whileSort})
      : super(
            numeric: isDigit ?? false,
            onSort: whileSort,
            tooltip: columnName,
            label: Container(
                padding: padding,
                decoration: decoration,
                child: SelectableText(columnName.contains(RegExp(r'[iI][dD]'))
                    ? columnName.toUpperCase()
                    : columnName)));
}
