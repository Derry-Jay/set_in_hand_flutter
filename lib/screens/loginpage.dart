import '/helpers/helper.dart';
import 'package:flutter/material.dart';
import '../../extensions/extension.dart';
import '/widgets/bottom_widget.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _checkbox = false;
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();
  Helper get hp => Helper.of(context);

  void proceed() async {
    final prefs = await sharedPrefs;
    _checkbox = prefs.containsKey('rememberme') &&
        (prefs.getBool('rememberme') ?? false);
    if (_checkbox) {
      _usernameController.text = prefs.getString('email') ?? '';
      _passwordController.text = prefs.getString('password') ?? '';
    }
  }

  void rememberMe(bool? value) async {
    final prefs = await sharedPrefs;
    log(value);
    final f = await ((value ?? false)
        ? prefs.setBool('rememberme', value ?? !_checkbox)
        : prefs.remove('rememberme'));
    bool g = true;
    if (_usernameController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty) {
      g = g &&
          await prefs.setString('email', _usernameController.text) &&
          await prefs.setString('password', _passwordController.text);
    } else if (!prefs.containsKey('rememberme')) {
      g = g && await prefs.remove('email') && await prefs.remove('password');
    }
    log(value);
    if (mounted && f && g) {
      setState(() {
        _checkbox = value ?? !_checkbox;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    proceed();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    if (loginFormKey.currentState != null) {
      loginFormKey.currentState!.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: BottomWidget(
          heightFactor: 30,
          widthFactor: MediaQuery.of(context).size.width,
        ),
        appBar: AppBar(
            centerTitle: true,
            // actions: const [
            //   IconButton(onPressed: crashApp, icon: Icon(Icons.exit_to_app,color: Colors.black,))
            // ],
            title: Image.asset('${assetImagePath}logo 2.jpg',
                fit: BoxFit.contain, height: 50),
            backgroundColor: Colors.white),
        body: SingleChildScrollView(
          padding:
              const EdgeInsets.only(left: 25, right: 25, top: 10, bottom: 10),
          child: Form(
              key: loginFormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                      padding: EdgeInsets.only(
                          left: 0, right: 0, top: 25, bottom: 10),
                      child: Text('Please log in!',
                          textAlign: TextAlign.left,
                          style: TextStyle(fontSize: 25, color: Colors.red))),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 0, right: 0, top: 10, bottom: 10),
                    child: TextFormField(
                        validator: hp.emailValidator,
                        controller: _usernameController,
                        autofocus: true,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'User Name',
                        )),
                  ),
                  Padding(
                      padding: const EdgeInsets.only(
                          left: 0, right: 0, top: 10, bottom: 10),
                      child: TextFormField(
                          // validator: hp.passwordValidator,
                          controller: _passwordController,
                          obscureText: true,
                          autofocus: false,
                          decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Password'))),
                  TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                        padding: const EdgeInsets.only(
                            left: 0, right: 0, top: 10, bottom: 10),
                        minimumSize: const Size(50, 30),
                        alignment: Alignment.centerLeft),
                    child: const Text('Forgot password',
                        style: TextStyle(fontSize: 14, color: Colors.red)),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Checkbox(value: _checkbox, onChanged: rememberMe),
                          const Text('Remember me'),
                        ]),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextButton(
                    onPressed: () async {
                      final st = loginFormKey.currentState;
                      final prefs = await sharedPrefs;
                      log(st);
                      if ((st?.mounted ?? false) && (st?.validate() ?? false)) {
                        final lg = await api.login(_usernameController.text,
                            _passwordController.text, hp);
                        if (lg.success && lg.user.isNotEmpty) {
                          bool flag = true;
                          if (_checkbox) {
                            flag = flag &&
                                await prefs.setString(
                                    'email', lg.user.userEmail) &&
                                await prefs.setString(
                                    'password', _passwordController.text);
                          }
                          flag ? hp.gotoForever('/dashboard') : doNothing();
                        } else if (await hp.showSimplePopup('Ok', () {
                          hp.goBack(result: true);
                        },
                            type: AlertType.cupertino,
                            title: 'Setinhand',
                            action:
                                'Either your Email or Password or both are incorrect')) {
                          log('2');
                        }
                      } else {
                        if (_usernameController.text.isEmpty) {
                          showDialogEmpty(context, hp.loc.EMPTY_USERNAME);
                        } else {
                          showDialogEmpty(context, hp.loc.INVALID_USERNAME);
                        }
                        log('1');
                        if (_passwordController.text.isEmpty) {
                          showDialogEmpty(context, hp.loc.EMPTY_PASSWORD);
                        } else {
                          showDialogEmpty(context, hp.loc.INVALID_PASSWORD);
                        }
                      }
                    },
                    style: TextButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.only(top: 10, bottom: 10),
                        minimumSize: Size(hp.width, 50),
                        alignment: Alignment.center),
                    child: const Text('Login',
                        style: TextStyle(fontSize: 24, color: Colors.white)),
                  ),
                ],
              )),
        ));
  }
}
