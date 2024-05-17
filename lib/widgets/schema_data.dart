import '../back_end/api.dart';
import 'package:flutter/material.dart';

class MySchemaData extends DataTableSource {
  DataColumn mapKeyToColumn(String e) => DataColumn(label: Text(e), tooltip: e);

  List<DataColumn> get columns {
    List<String> mapKeys = <String>[];
    for (Map<String, dynamic> item in fci) {
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
    return mapKeys.map<DataColumn>(mapKeyToColumn).toList();
  }

  List<DataRow> get rows {
    List<DataRow> drs = <DataRow>[];
    for (int i = 0; i < rowCount; i++) {
      final row = getRow(i);
      drs.add(row);
    }
    return drs;
  }

  @override
  bool get isRowCountApproximate => false;
  @override
  int get rowCount => fci.length;
  @override
  int get selectedRowCount => 0;
  @override
  DataRow getRow(int index) {
    DataCell mapCell(DataColumn e) =>
        DataCell(Text(fci[index][e.tooltip] ?? ''));

    return DataRow(cells: columns.map<DataCell>(mapCell).toList());
  }
}
