import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:set_in_hand/extensions/extension.dart';
import 'package:set_in_hand/generated/l10n.dart';
import 'package:set_in_hand/models/delivery_stock.dart';
import 'package:set_in_hand/models/updateqrcodemodel.dart';
import '../helpers/helper.dart';

class CustomDialog extends StatefulWidget {
  final bool addEdit;
  final String? deliveryID;
  final DeliveryStockData? getData;

  const CustomDialog(
      {Key? key, this.deliveryID, this.getData, this.addEdit = false})
      : super(key: key);

  @override
  CustomDialogState createState() => CustomDialogState();
}

class CustomDialogState extends State<CustomDialog> {
  final stockCodeController = TextEditingController(),
      boxesController = TextEditingController(),
      qtyBoxesController = TextEditingController();

  UpdateQrcodemodel? adddiscrepencies;

  Helper get hp => Helper.of(context);

  @override
  void initState() {
    super.initState();
    if (widget.addEdit) {
      log(widget.getData?.customerName);
      stockCodeController.text = widget.getData?.productCode ?? '';
      boxesController.text = widget.getData?.noOfBoxes.toString() ?? '';
      qtyBoxesController.text = widget.getData?.qtyExpected.toString() ?? '';
    }
  }

  Widget dialogContent(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10.0,
            offset: Offset(0.0, 10.0),
          ),
        ],
      ),
      child: Column(
        // To make the card compact
        children: [
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
                      'ADD/EDIT A DISCREPANCY',
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
              child: Column(
                // To make the card compact
                children: [
                  const Text(
                      'Please enter the product code and the number of boxes that have been delivered'),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      const SizedBox(
                        width: 100,
                        child:
                            Text('Stock Code', style: TextStyle(fontSize: 16)),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Flexible(
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 0, right: 0, top: 10, bottom: 10),
                          child: TextFormField(
                            readOnly: widget.addEdit,
                            keyboardType: TextInputType.text,
                            autofocus: false,
                            controller: stockCodeController,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Stock Code',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      const SizedBox(
                        width: 100,
                        child: Text('Boxes', style: TextStyle(fontSize: 16)),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Flexible(
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 0, right: 0, top: 10, bottom: 10),
                          child: TextFormField(
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            autofocus: false,
                            controller: boxesController,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Boxes',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      const SizedBox(
                        width: 100,
                        child:
                            Text('Qty Per Box', style: TextStyle(fontSize: 16)),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Flexible(
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 0, right: 0, top: 10, bottom: 10),
                          child: TextFormField(
                            readOnly: widget.addEdit,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            controller: qtyBoxesController,
                            autofocus: false,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Qty Per Box',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                    height: 0.8,
                    color: Colors.black,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'CANCEL',
                          style: TextStyle(color: Colors.orange),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Container(
                        height: 50,
                        width: 1,
                        color: Colors.black,
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      GestureDetector(
                        onTap: () {
                          validate(context);
                        },
                        child: const Text('CONTINUE',
                            style: TextStyle(color: Colors.greenAccent)),
                      ),
                    ],
                  )
                ],
              ))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      content: dialogContent(context),
    );
  }

  validate(BuildContext context) {
    if (stockCodeController.text == '') {
      showDialogEmpty(context, S().STOCKCODE_EMPTY);
    } else {
      if (boxesController.text == '') {
        showDialogEmpty(context, S().BOX_EMPTY);
      } else {
        if (qtyBoxesController.text == '') {
          showDialogEmpty(context, S().QTY_BOX_EMPTY);
        } else {
          log(stockCodeController.text);
          log(boxesController.text);
          log(qtyBoxesController.text);
          if (widget.addEdit == false) {
            addDiscrepenc(stockCodeController.text, boxesController.text,
                qtyBoxesController.text);
          } else {
            editDiscrepenc(stockCodeController.text, boxesController.text,
                qtyBoxesController.text);
          }
        }
      }
    }
  }

  void addDiscrepenc(String stockCode, String boxes, String qtyBoxes) async {
    hp.showPleaseWait();
    adddiscrepencies = await api.addDiscrepencies(
        widget.deliveryID ?? '', stockCode, boxes, qtyBoxes, 'add', hp);
    log(adddiscrepencies?.data.toString());
    var status = adddiscrepencies?.success;
    if (status ?? false) {
      if (adddiscrepencies?.message?.isEmpty ?? false) {
        showDialogAPISucces(context, adddiscrepencies?.data.toString() ?? '');
      } else {
        showDialogAPISucces(
            context, adddiscrepencies?.message.toString() ?? '');
      }
    } else {
      showDialogAPISucces(context, adddiscrepencies?.message.toString() ?? '');
    }
  }

  void editDiscrepenc(String stockCode, String boxes, String qtyBoxes) async {
    if ((int.tryParse(boxes) ?? 0) < (widget.getData?.noOfBoxes ?? 0)) {
      hp.showPleaseWait();
      adddiscrepencies = await api.addDiscrepencies(
          widget.deliveryID ?? '', stockCode, boxes, qtyBoxes, 'edit', hp);
      var status = adddiscrepencies?.success;
      if (status ?? false) {
        if (adddiscrepencies?.message?.isEmpty ?? false) {
          showDialogAPISucces(context, adddiscrepencies?.data.toString() ?? '');
        } else {
          showDialogAPISucces(
              context, adddiscrepencies?.message.toString() ?? '');
        }
      } else {
        showDialogAPISucces(
            context, adddiscrepencies?.message.toString() ?? '');
      }
    } else {
      showDialogAPISucces(
          context, 'Number of boxes is greater than Boxes in Stock');
    }
  }

  void showDialogAPISucces(BuildContext context, String subtitle) {
    showCupertinoDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: const Text('Setinhand'),
          content: Text(subtitle),
          actions: [
            CupertinoDialogAction(
                child: const Text('OK'),
                onPressed: () {
                  // Navigator.of(context).pop();
                  Navigator.of(context)
                      .popUntil(ModalRoute.withName('/deliveryDetails'));
                }),
          ],
        );
      },
    );
  }
}
