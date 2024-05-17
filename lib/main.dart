import 'dart:async';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'firebase_options.dart';
import 'generated/l10n.dart';
import 'route_generator.dart';
import 'helpers/helper.dart';
import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'widgets/route_error_screen.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  try {
    wb = WidgetsFlutterBinding.ensureInitialized();
    HttpOverrides.global = MyHttpOverrides();
    gc = await GlobalConfiguration().loadFromAsset('configurations');
    if (!(wb?.buildOwner?.debugBuilding ?? true)) {
      setUser();
      initFB();
      runApp(const MyApp());
    }
  } catch (e) {
    sendAppLog(e);
  }
}

void initFB() async {
  try {
    final app = await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    await runZonedGuarded<Future<void>>(
        body, FirebaseCrashlytics.instance.recordError);
    log(app);
  } catch (e) {
    sendAppLog(e);
  }
}

Future<void> body() async {
  wb = WidgetsFlutterBinding.ensureInitialized();
  log(wb);
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Widget rootBuilder(
      BuildContext context, AsyncSnapshot<List<ConnectivityResult>> result) {
    final hp = Helper.of(context);
    if (result.connectionState == ConnectionState.active ||
        result.connectionState == ConnectionState.done) {
      hp.getConnectStatus();
    }
    log(result.data);
    return result.hasData && !result.hasError
        ? SplashScreen(
            connectionStatus: result.data?.first ?? ConnectivityResult.none)
        : RouteErrorScreen(flag: result.hasData && !result.hasError);
  }

  @override
  Widget build(BuildContext context) {
    final hp = Helper.of(context);
    setStatusBarColor();
    if (isAndroid) rollbackOrientations();
    hp.checkPermissionStatus(Permission.camera);
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        onGenerateRoute: RouteGenerator.generateRoute,
        supportedLocales: S.delegate.supportedLocales,
        home: StreamBuilder<List<ConnectivityResult>>(
            builder: rootBuilder, stream: con.onConnectivityChanged),
        localizationsDelegates: const [
          S.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate
        ],
        theme: ThemeData(
            dividerColor: Colors.grey,
            primarySwatch: Colors.blueGrey,
            cardColor: const Color(0xffdbd9d9),
            hintColor: const Color(0xff6eb2e0),
            focusColor: const Color(0xffe5e5e5),
            errorColor: const Color(0xfff53d3d),
            hoverColor: const Color(0xffe2e4ef),
            splashColor: const Color(0xff7fc348),
            shadowColor: const Color(0xffcacddc),
            canvasColor: const Color(0xffcacdde),
            scaffoldBackgroundColor: Colors.white,
            disabledColor: const Color(0xff96989a),
            indicatorColor: const Color(0xffdedede),
            highlightColor: const Color(0xffe5b34f),
            dialogBackgroundColor: Colors.transparent,
            // selectedRowColor: const Color(0xff32db64),
            bottomAppBarColor: const Color(0xff7781e2),
            secondaryHeaderColor: const Color(0xff404040),
            toggleableActiveColor: const Color(0xffeeb134),
            unselectedWidgetColor: const Color(0xffe8e8e8)));
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    log('++++++++++++++++++++++');
    log(context);
    context?.allowLegacyUnsafeRenegotiation = true;
    log('%%%%%%%%%%%%%%%%%%%%%%');
    return super.createHttpClient(context)..maxConnectionsPerHost = 1;
  }
}
