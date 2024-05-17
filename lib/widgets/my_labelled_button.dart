import 'package:flutter/material.dart';
import 'package:set_in_hand/helpers/helper.dart';
import 'custom_labelled_button.dart';

class MyLabelledButton extends StatelessWidget {
  final String label;
  final ButtonType type;
  final VoidCallback? onPressed;
  final FontWeight? labelWeight;
  final double? labelSize, widthFactor, heightFactor, elevation, radiusFactor;
  const MyLabelledButton(
      {Key? key,
      required this.label,
      this.labelWeight,
      this.elevation,
      this.labelSize,
      this.heightFactor,
      this.widthFactor,
      this.radiusFactor,
      required this.type,
      this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomLabelledButton(
        label: label,
        labelWeight: labelWeight,
        elevation: elevation,
        labelSize: labelSize,
        onPressed: onPressed,
        buttonColor: Colors.black,
        labelColor: Colors.white,
        type: type);
  }
}
