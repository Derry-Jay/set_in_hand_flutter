import 'dart:convert';
import '../helpers/helper.dart';
import '../widgets/schema_row.dart';
import '../widgets/schema_cell.dart';
import '../widgets/schema_column.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class SchemaData extends DataTableSource {
  final Color? rowColor;
  final EdgeInsets? padding;
  final BoxDecoration? decoration;
  final List<Map<String, dynamic>> data;
  final void Function(int, bool)? onSort;
  final void Function(PointerExitEvent)? onExit;
  final void Function(TapDownDetails)? onTapDown;
  final void Function(PointerHoverEvent)? onHover;
  final void Function(PointerEnterEvent)? onEnter;
  final VoidCallback? onTap, onDoubleTap, onLongPress, onTapCancel;
  SchemaData(
      {required this.data,
      this.rowColor,
      this.onTapDown,
      this.onTap,
      this.onDoubleTap,
      this.onLongPress,
      this.onTapCancel,
      this.onEnter,
      this.onExit,
      this.onHover,
      this.padding,
      this.onSort,
      this.decoration})
      : super();
  List<Map<String, dynamic>> selectedItems = <Map<String, dynamic>>[];

  factory SchemaData.fromString(String e) =>
      SchemaData.fromIterable(jsonDecode(e));

  factory SchemaData.fromIterable(Iterable<dynamic> elements) =>
      SchemaData(data: List<Map<String, dynamic>>.from(elements));

  SchemaColumn mapKeyToColumn(String e) => SchemaColumn(
      columnName: e,
      decoration: decoration,
      padding: padding,
      whileSort: onSort);

  void onChange() {
    notifyListeners();
  }

  List<SchemaColumn> get columns {
    if (data.isEmpty) {
      return <SchemaColumn>[];
    } else {
      List<String> mapKeys = <String>[];
      for (Map<String, dynamic> item in data) {
        if (item.isEmpty) {
          continue;
        } else {
          for (String key in item.keys) {
            if (!mapKeys.contains(key)) {
              mapKeys.add(key);
            } else {
              continue;
            }
          }
        }
      }
      return mapKeys.map<SchemaColumn>(mapKeyToColumn).toList();
    }
  }

  List<SchemaRow> get rows {
    List<SchemaRow> drs = <SchemaRow>[];
    for (int i = 0; i < rowCount; i++) {
      drs.add(getRow(i));
    }
    return drs;
  }

  @override
  SchemaRow getRow(int index) {
    // TODO: implement getRow
    try {
      if (data.isEmpty) {
        return SchemaRow(items: const <SchemaCell>[]);
      } else {
        final val = data[index];
        // final flag = ((index + 1) % 2) == 0;
        SchemaCell mapCell(String e) => SchemaCell(
            MouseRegion(
                cursor: val[e].toString().contains('http')
                    ? SystemMouseCursors.click
                    : SystemMouseCursors.text,
                onEnter: onEnter,
                onHover: onHover,
                onExit: onExit,
                child: SelectableText(
                    val[e] is String ? val[e] : val[e].toString(),
                    style: TextStyle(
                        decoration: val[e].toString().contains('http')
                            ? TextDecoration.underline
                            : null))),
            onPress: onTap,
            onDoublePress: onDoubleTap,
            onLongTap: onLongPress,
            onPressCancel: onTapCancel,
            onPressDown: onTapDown);

        void onPickedChanged(bool? value) {
          void selectOrUnselectRow() {
            selectedItems.add(val);
            onChange();
          }

          try {
            selectOrUnselectRow();
          } catch (e) {
            sendAppLog(e);
          }
        }

        return SchemaRow(
            rowColor: rowColor,
            onPickChanged: onPickedChanged,
            isSelected: selectedItems.contains(val),
            items: val.keys.map<SchemaCell>(mapCell).toList());
      }
    } catch (e) {
      sendAppLog(e);

      rethrow;
    }
  }

  @override
  // TODO: implement isRowCountApproximate
  bool get isRowCountApproximate => false;

  @override
  // TODO: implement rowCount
  int get rowCount => data.length;

  @override
  // TODO: implement selectedRowCount
  int get selectedRowCount => selectedItems.length;
}
