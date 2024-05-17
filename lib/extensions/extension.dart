import 'package:flutter/cupertino.dart';

String? validatePassword(String password) {
  RegExp re = RegExp(r'^(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#$&*~]).{8,}$');
  return password.isNotEmpty &&
          password.length >= 6 &&
          password.length <= 12 &&
          re.hasMatch(password)
      ? null
      : 'Please Enter a Valid Password';
  //(?=.*?[A-Z])
}

String? validateEmail(String email) {
  RegExp re = RegExp(
      r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$");
  return re.hasMatch(email) && re.allMatches(email).length == 1
      ? null
      : 'Please Enter a Valid Email';
}

void showDialogEmpty(BuildContext context, String subtitle) {
  Widget dialogBuilder(BuildContext context) {
    return CupertinoAlertDialog(
      title: const Text('Setinhand'),
      content: Text(subtitle),
      actions: [
        CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
            }),
        //  CupertinoDialogAction(
        //    child: const Text("NO"),
        //    onPressed: (){
        //      Navigator.of(context).pop();
        //    }
        //    ,
        //  )
      ],
    );
  }

  showCupertinoDialog(context: context, builder: dialogBuilder);
}

//  @override
//   bool operator ==(Object other) {
//     // TODO: implement ==
//     return other is PropertyType && other.typeID == typeID;
//   }

//   @override
//   // TODO: implement hashCode
//   int get hashCode => typeID.hashCode;


