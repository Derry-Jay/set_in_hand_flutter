import 'package:flutter/material.dart';

class DeliveryCustomDialogBox extends StatelessWidget {
  const DeliveryCustomDialogBox({Key? key}) : super(key: key);

  Widget dialogContent(BuildContext context) {
    return Expanded(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Flexible(
          flex: 1,
          child: Text(
              'Please enter the product code and the number of boxes that have been delivered'),
        ),
        Flexible(
          child: Row(
            children: const [
              Text('Stock Code'),
              TextField(
                obscureText: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Password',
                  hintText: 'Enter Password',
                ),
              ),
            ],
          ),
        ),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 0.0,
        child: dialogContent(context));
  }
}
