import 'package:flutter/material.dart';
import 'package:set_in_hand/models/table_data.dart';

class DynamicTable extends PaginatedDataTable {
  final SchemaData data;
  final Widget? heading;
  final List<Widget>? steps;
  final int? perPage, sortIndex;
  final void Function(bool?)? onPickAll;
  final void Function(int)? onPageModified;
  final void Function(int?)? onPerPageModified;
  final bool? show1stLast, showMarker, arrangeAscending;
  DynamicTable(
      {Key? key,
      required this.data,
      this.heading,
      this.steps,
      this.perPage,
      this.sortIndex,
      this.show1stLast,
      this.showMarker,
      this.arrangeAscending,
      this.onPerPageModified,
      this.onPageModified,
      this.onPickAll})
      : super(
            actions: steps,
            header: heading,
            sortColumnIndex: sortIndex,
            onSelectAll: onPickAll,
            onRowsPerPageChanged: onPerPageModified,
            onPageChanged: onPageModified,
            key: key,
            columns: data.columns,
            source: data,
            rowsPerPage: perPage ?? PaginatedDataTable.defaultRowsPerPage,
            sortAscending: arrangeAscending ?? true,
            showFirstLastButtons: show1stLast ?? false,
            showCheckboxColumn: showMarker ?? true);
}
