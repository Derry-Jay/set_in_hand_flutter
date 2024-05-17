import '../helpers/helper.dart';
import 'package:flutter/material.dart';

class MyDialog extends StatefulWidget {
  const MyDialog({Key? key}) : super(key: key);

  @override
  MyDialogState createState() => MyDialogState();
}

class MyDialogState extends State<MyDialog> {
  Helper get hp => Helper.of(context);
  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.zero,
        margin: EdgeInsets.zero,
        height: hp.height / 3.2,
        width: hp.width / 1.6,
        decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(10),
            boxShadow: const [
              BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10.0,
                  offset: Offset(0.0, 10.0))
            ]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
              decoration: const BoxDecoration(
                color: Colors.lightBlueAccent,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10.0,
                    offset: Offset(0.0, 10.0),
                  ),
                ],
              ),
              height: 50,
              width: double.infinity,
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(),
                  const Flexible(
                    flex: 4,
                    child: Text(
                      'COMPLETED DELIVERY',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  Container(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                        color: Colors.white,
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.close),
                        tooltip: 'sfsdf'),
                  )
                ],
              )),
          Container(
              padding: const EdgeInsets.all(15),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('You are marking this delivery as completed'),
                const SizedBox(height: 10),
                const Text('Is this correct?', style: TextStyle(fontSize: 16)),
                Padding(
                    padding: EdgeInsets.symmetric(vertical: hp.height / 40),
                    child: const Divider()),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  GestureDetector(
                      onTap: () {
                        hp.goBack(result: false);
                      },
                      child: Padding(
                          padding: EdgeInsets.only(right: hp.width / 32),
                          child: Text('NO',
                              style: TextStyle(color: hp.theme.errorColor)))),
                  Container(height: 50, width: 1, color: Colors.black),
                  GestureDetector(
                      onTap: () {
                        hp.goBack(result: true);
                      },
                      child: Padding(
                          padding: EdgeInsets.only(left: hp.width / 32),
                          child: const Text('YES',
                              style: TextStyle(color: Colors.greenAccent))))
                ])
              ]))
        ]));
  }
}
