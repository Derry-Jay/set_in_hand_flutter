import '../helpers/helper.dart';
import '../widgets/schema_row.dart';
import '../widgets/schema_column.dart';
import 'package:flutter/material.dart';

class Schema extends DataTable {
  final List<SchemaRow> records;
  final List<SchemaColumn> fields;
  Schema({Key? key, required this.records, required this.fields})
      : assert(isFeasibleTable(records, fields)),
        super(key: key, rows: records, columns: fields);
}
