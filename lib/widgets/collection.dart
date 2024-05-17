import 'package:flutter/material.dart';
import '../widgets/collection_row.dart';
import '../widgets/collection_border.dart';

class Collection extends Table {
  final List<CollectionRow>? rows;
  final CollectionBorder? tableBorder;
  Collection({this.rows, this.tableBorder, Key? key})
      : super(
            key: key, children: rows ?? <CollectionRow>[], border: tableBorder);
}
