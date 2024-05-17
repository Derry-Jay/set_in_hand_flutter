import 'package:flutter/material.dart';

class CollectionBorder extends TableBorder {
  final BorderRadius? radius;
  final BorderSide? lb, rb, tb, bb, hi, vi;
  const CollectionBorder(
      {this.radius, this.lb, this.rb, this.tb, this.bb, this.hi, this.vi})
      : super(
            top: tb ?? BorderSide.none,
            left: lb ?? BorderSide.none,
            right: rb ?? BorderSide.none,
            bottom: bb ?? BorderSide.none,
            verticalInside: vi ?? BorderSide.none,
            horizontalInside: hi ?? BorderSide.none,
            borderRadius: radius ?? BorderRadius.zero);
}
