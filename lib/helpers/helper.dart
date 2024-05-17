import 'dart:math';
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import '../models/user.dart';
import '../back_end/api.dart';
import '/generated/l10n.dart';
import '../widgets/loader.dart';
import '../widgets/schema_row.dart';
import '../widgets/empty_widget.dart';
import '../widgets/schema_column.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import '../widgets/custom_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import '../widgets/circular_loader.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:global_configuration/global_configuration.dart';

enum TableType { notification, document }

enum AlertType { normal, cupertino }

enum PickImageType { camera, gallery, multiple }

enum PopupType { menu, modal, ios }

enum PossessorType { me, other }

enum DateType { birth, death }

enum APIMode { live, staging, testing, dev }

enum ButtonType { raised, text, border }

enum LoaderType {
  normal,
  rotatingPlain,
  doubleBounce,
  wave,
  wanderingCubes,
  fadingFour,
  fadingCube,
  pulse,
  chasingDots,
  threeBounce,
  circle,
  cubeGrid,
  fadingCircle,
  rotatingCircle,
  foldingCube,
  pumpingHeart,
  hourGlass,
  pouringHourGlass,
  pouringHourGlassRefined,
  fadingGrid,
  ring,
  ripple,
  spinningCircle,
  spinningLines,
  squareCircle,
  dualRing,
  pianoWave,
  dancingSquare,
  threeInOut
}

DateTime? currentBackPressTime;

RegExp mailExp = RegExp(
        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+"),
    passExp =
        RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$');

Connectivity con = Connectivity();

DeviceInfoPlugin dip = DeviceInfoPlugin();

List<String> splashScreenItems = <String>['logo.jpg', 'puzzle_128.gif'];

API api = API(APIMode.dev);

FocusNode f1 = FocusNode();

GlobalConfiguration? gc;

GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

GlobalKey<RefreshIndicatorState> refreshKey =
    GlobalKey<RefreshIndicatorState>();

WidgetsBinding? wb;

String get userKey => '$title User';

List<Stream<Barcode>> css = <Stream<Barcode>>[];

List<StreamSubscription<Barcode>> scs = <StreamSubscription<Barcode>>[];

GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

final isIOS = defaultTargetPlatform == TargetPlatform.iOS;

final isMac = defaultTargetPlatform == TargetPlatform.macOS;

final isLinux = defaultTargetPlatform == TargetPlatform.linux;

final isFuchsia = defaultTargetPlatform == TargetPlatform.fuchsia;

final isAndroid = defaultTargetPlatform == TargetPlatform.android;

final isWindows = defaultTargetPlatform == TargetPlatform.windows;

final isWeb =
    !(isAndroid || isIOS || isMac || isWindows || isLinux || isFuchsia);

final dF = isAndroid || isFuchsia || isLinux || isWindows;

final isPortable = isAndroid || isIOS;

const title = 'Set In Hand';

final sharedPrefs = SharedPreferences.getInstance();

final assetImagePath = gc?.getValue<String>('asset_image_path') ?? '';

final profilePublicUrl =
    '${gc?.getValue<String>('bucket_path') ?? ''}profilepic/';

void log(Object? object) {
  if (kDebugMode) print(object);
}

void crashApp() {
  FirebaseCrashlytics.instance.crash();
}

void sendAppLog(Object? object) async {
  ((kProfileMode || kReleaseMode) && object != null)
      ? await FirebaseCrashlytics.instance.log(object.toString())
      : log(object);
}

void doNothing() {}

void onImageError(Object object, StackTrace? trace) {
  log(object);
  log(trace);
}

void delayedFunc(Duration duration, VoidCallback vcb) async {
  await Future.delayed(duration, vcb);
}

void addYearsToDateString(TextEditingController tec, int k) {
  log(tec.text);
  final list = tec.text.split('/');
  List<int> li = <int>[];
  for (String num in list) {
    li.add(int.tryParse(num) ?? 0);
  }
  li.last = li.last + k;
  tec.text = li.join('/');
}

void deductYearsToDateString(TextEditingController tec, int k) {
  log(tec.text);
  final list = tec.text.split('/');
  List<int> li = <int>[];
  for (String num in list) {
    li.add(int.tryParse(num) ?? 0);
  }
  li.last = li.last - k;
  tec.text = li.join('/');
}

void rollbackOrientations() async {
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeRight,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
}

void lockScreenRotation() async {
  await SystemChrome.setPreferredOrientations([
    // DeviceOrientation.landscapeRight,
    // DeviceOrientation.landscapeLeft,
    DeviceOrientation.portraitUp
  ]);
}

void setStatusBarColor() {
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
      systemNavigationBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.white,
      statusBarIconBrightness: Brightness.light,
      statusBarColor: Colors.white));
}

void hideLoader(Duration time, {LoaderType? type}) {
  try {
    overlayLoader(time, type: type).remove();
  } catch (e) {
    sendAppLog(e);
  }
}

OverlayEntry overlayLoader(Duration time, {LoaderType? type}) {
  Widget loaderbuilder(BuildContext context) {
    final hp = Helper.of(context);
    return Positioned(
        top: 0,
        left: 0,
        width: hp.width,
        height: hp.height,
        child: Material(
            color: hp.theme.primaryColor.withOpacity(0.85),
            child: CircularLoader(
                duration: time,
                loaderType: type,
                // widthFactor: 16,
                // heightFactor: 16,
                color: hp.theme.primaryColor)));
  }

  return OverlayEntry(builder: loaderbuilder);
}

Widget imageFromBytesBuilder(
    BuildContext context, List<int>? pic, Widget? child) {
  final hpi = Helper.of(context);
  try {
    final intList = pic ?? <int>[];
    log(intList);
    final bytes1 = putData(getData(intList));
    final bytes2 = Uint8List.fromList(intList);
    return SizedBox(
        width: hpi.width,
        height: hpi.height,
        child:
            Column(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          Image.memory(bytes1, errorBuilder: errorBuilder),
          Image.memory(bytes2, errorBuilder: errorBuilder)
        ]));
  } catch (e) {
    sendAppLog(e);
    return (child ?? const EmptyWidget());
  }
}

String getData(List<int> values) {
  return base64.encode(values);
}

Uint8List putData(String value) {
  return base64.decode(value);
}

bool isFeasibleTable(List<SchemaRow> rows, List<SchemaColumn> columns) {
  bool flag = true;
  for (SchemaRow row in rows) {
    if (row.items.length != columns.length) {
      flag = false;
      break;
    }
  }
  return flag;
}

bool parseBool(String? source) {
  return (source?.isNotEmpty ?? false) &&
      (source?.toLowerCase() == 'true' ||
          source?.toUpperCase() == 'TRUE' ||
          source?.toLowerCase() == 'yes' ||
          source?.toUpperCase() == 'YES' ||
          source?.toLowerCase() == 'ok' ||
          source?.toUpperCase() == 'OK' ||
          ((int.tryParse(source ?? '0') ?? 0) > 0));
}

num maxOfTwo(num a, num b) {
  return a > b ? a : (b > a ? b : 0);
}

num sumOfList(List<num> numbers) {
  if (numbers.isEmpty) {
    return 0;
  } else if (numbers.length == 1) {
    return numbers.first;
  } else {
    num sum = 0;
    for (num number in numbers) {
      sum += number;
    }
    return sum;
  }
}

num listAdd(List<dynamic> list) {
  if (list.isEmpty) {
    return 0;
  } else if (list.length == 1) {
    return num.tryParse(list.first.toString()) ?? 0;
  } else {
    num sum = 0;
    for (var item in list) {
      sum += num.tryParse(item.toString()) ?? 0;
    }
    return sum;
  }
}

String capitalize(String s) => s[0].toUpperCase() + s.substring(1);

num max(num a, num b) {
  return a > b ? a : (b > a ? b : 0);
}

num maxInArr(List<num> nos) {
  num max = nos.first;
  for (num element in nos) {
    if (element > max) {
      max = element;
    }
  }
  return max;
}

bool predicate(Route route) {
  log(route);
  return false;
}

Future<List<String>> getLocalStorageKeys() async {
  final prefs = await sharedPrefs;
  return prefs.getKeys().toList();
}

String limitString(String text, int limit, {String hiddenText = '...'}) {
  return text.substring(0, min<int>(limit, text.length)) +
      (text.length > limit ? hiddenText : '');
}

Widget errorBuilder(BuildContext context, Object object, StackTrace? trace) {
  final dims = MediaQuery.maybeOf(context) ?? MediaQuery.of(context);
  final size = dims.size;
  final theme = Theme.of(context);
  final radius = pow(pow(size.height, 2) + pow(size.width, 2), 0.5);
  log(trace);
  log('tracobj');
  log(object);
  return Icon(Icons.error_sharp,
      color: theme.secondaryHeaderColor, size: radius / 40);
}

void setUser() async {
  try {
    final prefs = await sharedPrefs;
    if (prefs.containsKey(userKey)) {
      final uss = prefs.getString(userKey) ?? '';
      log(gc?.getValue<String>('staging'));
      log(uss);
      log(gc?.getValue<String>('testing'));
      final user = User.fromMap(json.decode(uss));
      currentUser.value = user;
      user.onChange();
    } else {
      log(gc?.getValue('live'));
    }
  } catch (e) {
    sendAppLog(e);
  }
}

bool Function(Route<dynamic>) getRoutePredicate(String routeName) {
  return ModalRoute.withName(routeName);
}

class Helper extends ChangeNotifier {
  late BuildContext buildContext;
  Helper.of(BuildContext context) {
    try {
      buildContext = context;
    } catch (e) {
      sendAppLog(e);
    }
  }
  S get loc => S.maybeOf(buildContext) ?? S.of(buildContext);
  ThemeData get theme => Theme.of(buildContext);
  OverlayState? get ol => Overlay.of(buildContext);
  FocusNode get node => FocusScope.of(buildContext);
  ModalRoute<Object?>? get route => ModalRoute.of(buildContext);
  ScaffoldState get sct =>
      Scaffold.maybeOf(buildContext) ?? Scaffold.of(buildContext);
  NavigatorState get nav =>
      Navigator.maybeOf(buildContext) ?? Navigator.of(buildContext);
  MediaQueryData get dimensions =>
      MediaQuery.maybeOf(buildContext) ?? MediaQuery.of(buildContext);
  ScaffoldMessengerState get smcT =>
      ScaffoldMessenger.maybeOf(buildContext) ??
      ScaffoldMessenger.of(buildContext);
  bool get mounted => st?.mounted ?? false;
  bool get isDialogOpen {
    try {
      return !(route?.isCurrent ?? true);
    } catch (e) {
      sendAppLog(e);
      return false;
    }
  }

  Size get size => dimensions.size;
  double get pixelRatio => dimensions.devicePixelRatio;
  double get textScaleFactor => ((dimensions.textScaleFactor +
          MediaQuery.textScaleFactorOf(buildContext)) /
      2);
  Orientation get screenLayout => dimensions.orientation;
  double get height => size.height;
  double get width => size.width;
  double get aspectRatio => size.aspectRatio;
  double get radius => sqrt(pow(height, 2) + pow(width, 2));
  Type get widgetType => buildContext.widget.runtimeType;
  State? get st => buildContext.findAncestorStateOfType();
  TextTheme get textTheme => theme.textTheme;
  double get factor => pow(
          (pow(aspectRatio, 3) + pow(textScaleFactor, 3) + pow(pixelRatio, 3)),
          1 / 3)
      .toDouble();

  bool get isMobile => isPortable && size.shortestSide < 600;

  bool get isTablet => isPortable && size.shortestSide >= 600;

  void onChange() {
    notifyListeners();
  }

  void reload(VoidCallback vcb) async {
    try {
      if (st?.mounted ?? false) {
        st?.setState(vcb);
      }
      onChange();
    } catch (e) {
      sendAppLog(e);
    }
  }

  void addLoader(Duration time, {LoaderType? type}) {
    try {
      if (ol?.mounted ?? false) {
        ol?.insert(overlayLoader(time, type: type));
      } else {
        log(time);
      }
    } catch (e) {
      sendAppLog(e);
    }
  }

  void showLoader() {
    if (Loader.isShown) {
      log('object');
    } else {
      Loader.show(buildContext);
    }
  }

  void gotoRoute(Route screen) async {
    try {
      if (route != screen) {
        final p = await nav.push(screen);
        log(p);
      }
    } catch (e) {
      sendAppLog(e);

      if (ModalRoute.of(navigatorKey.currentContext ?? buildContext) !=
          screen) {
        final p = await navigatorKey.currentState?.push(screen);
        log(p);
      }
    }
  }

  void goTo(String routeName, {dynamic args, VoidCallback? vcb}) async {
    try {
      if (route?.settings.name != routeName) {
        final p = await nav.pushNamed(routeName, arguments: args);
        log(p);
        if (vcb != null) {
          reload(vcb);
        }
      } else {
        log(routeName);
      }
    } catch (e) {
      sendAppLog(e);

      if (ModalRoute.of(navigatorKey.currentContext ?? buildContext)
              ?.settings
              .name !=
          routeName) {
        final p = await navigatorKey.currentState
            ?.pushNamed(routeName, arguments: args);
        log(p);
        if (vcb != null) {
          reload(vcb);
        }
      } else {
        log(routeName);
      }
    }
  }

  void gotoOnce(String routeName,
      {dynamic args, dynamic result, VoidCallback? vcb}) async {
    try {
      if (route?.settings.name != routeName) {
        final p = await nav.pushReplacementNamed(routeName,
            arguments: args, result: result);
        if (vcb != null) {
          reload(vcb);
        }
        log(p);
      } else {
        log(routeName);
      }
    } catch (e) {
      sendAppLog(e);

      if (ModalRoute.of(navigatorKey.currentContext ?? buildContext)
              ?.settings
              .name !=
          routeName) {
        final p = await navigatorKey.currentState
            ?.pushReplacementNamed(routeName, arguments: args, result: result);
        if (vcb != null) {
          reload(vcb);
        }
        log(p);
      } else {
        log(routeName);
      }
    }
  }

  void gotoForever(String routeName, {dynamic args}) async {
    try {
      if (route?.settings.name != routeName) {
        final p = await nav.pushNamedAndRemoveUntil(routeName, predicate,
            arguments: args);
        log(p);
      } else {
        log(routeName);
      }
    } catch (e) {
      sendAppLog(e);

      if (ModalRoute.of(navigatorKey.currentContext ?? buildContext)
              ?.settings
              .name !=
          routeName) {
        final p = await navigatorKey.currentState
            ?.pushNamedAndRemoveUntil(routeName, predicate, arguments: args);
        log(p);
      } else {
        log(routeName);
      }
    }
  }

  void goBackForeverTo(String routeName) {
    try {
      nav.popUntil(getRoutePredicate(routeName));
    } catch (e) {
      sendAppLog(e);

      navigatorKey.currentState?.popUntil(getRoutePredicate(routeName));
    }
  }

  void goBack({dynamic result}) {
    try {
      log(result);
      nav.pop(result);
    } catch (e) {
      sendAppLog(e);

      navigatorKey.currentState?.pop(result);
    }
  }

  void goBackEmpty() {
    goBack();
  }

  Future<bool> showPleaseWait() {
    return revealToast('Please wait....', length: Toast.LENGTH_LONG);
  }

  Future<bool?> showDialogBox(
      {Widget? title,
      AlertType? type,
      Widget? content,
      bool? dismissive,
      String? barrierLabel,
      List<Widget>? actions,
      TextStyle? titleStyle,
      Curve? insetAnimation,
      TextStyle? actionStyle,
      Duration? insetDuration,
      EdgeInsets? titlePadding,
      EdgeInsets? actionPadding,
      EdgeInsets? buttonPadding,
      EdgeInsets? contentPadding,
      RouteSettings? routeSettings,
      ScrollController? scrollController,
      MainAxisAlignment? actionsAlignment,
      ScrollController? actionScrollController}) {
    Widget dialogBuilder(BuildContext context) {
      switch (type) {
        case AlertType.cupertino:
          return CupertinoAlertDialog(
              title: title,
              content: content,
              actions: actions ?? <Widget>[],
              scrollController: scrollController,
              actionScrollController: actionScrollController,
              insetAnimationCurve: insetAnimation ?? Curves.decelerate,
              insetAnimationDuration:
                  insetDuration ?? const Duration(milliseconds: 100));
        case AlertType.normal:
        default:
          return AlertDialog(
              title: title,
              content: content,
              actions: actions,
              titlePadding: titlePadding,
              titleTextStyle: titleStyle,
              buttonPadding: buttonPadding,
              contentTextStyle: actionStyle,
              actionsAlignment: actionsAlignment,
              actionsPadding: actionPadding ?? EdgeInsets.zero,
              contentPadding: contentPadding ??
                  EdgeInsets.symmetric(
                      horizontal: width / 25, vertical: height / 100));
      }
    }

    return type == AlertType.cupertino
        ? showCupertinoDialog<bool>(
            context: buildContext,
            builder: dialogBuilder,
            barrierLabel: barrierLabel,
            routeSettings: routeSettings,
            barrierDismissible: dismissive ?? false)
        : showDialog<bool>(
            context: buildContext,
            builder: dialogBuilder,
            barrierLabel: barrierLabel,
            routeSettings: routeSettings,
            barrierDismissible: dismissive ?? false);
  }

  Future<bool> revealDialogBox(List<String> options, List<VoidCallback> actions,
      {String? title,
      String? action,
      AlertType? type,
      bool? dismissive,
      Curve? insetAnimation,
      TextStyle? titleStyle,
      TextStyle? actionStyle,
      TextStyle? optionStyle,
      Duration? insetDuration,
      EdgeInsets? titlePadding,
      EdgeInsets? actionPadding,
      EdgeInsets? buttonPadding,
      ScrollController? scrollController,
      ScrollController? actionScrollController}) async {
    Widget optionsMap(String e) {
      final child = Text(e, style: optionStyle);
      final onTap = actions[options.indexOf(e)];
      log(type);
      switch (type) {
        case AlertType.cupertino:
          return CupertinoDialogAction(
              onPressed: onTap, textStyle: actionStyle, child: child);
        case AlertType.normal:
        default:
          return TextButton(onPressed: onTap, child: child);
      }
    }

    return options.length == actions.length &&
            options.isNotEmpty &&
            actions.isNotEmpty
        ? (await showDialogBox(
                type: type,
                dismissive: dismissive,
                titleStyle: titleStyle,
                actionStyle: actionStyle,
                titlePadding: titlePadding,
                buttonPadding: buttonPadding,
                actionPadding: actionPadding,
                insetDuration: insetDuration,
                insetAnimation: insetAnimation,
                scrollController: scrollController,
                actionScrollController: actionScrollController,
                actions: options.map<Widget>(optionsMap).toList(),
                title: title == null ? null : Text(title),
                content: action == null ? null : Text(action)) ??
            false)
        : options.length == actions.length &&
            options.isNotEmpty &&
            actions.isNotEmpty;
  }

  Future<bool> showSimpleYesNo(
      {bool? flag,
      bool? reverse,
      String? title,
      String? action,
      AlertType? type,
      bool? dismissive,
      Curve? insetAnimation,
      TextStyle? titleStyle,
      TextStyle? actionStyle,
      TextStyle? optionStyle,
      Duration? insetDuration,
      EdgeInsets? titlePadding,
      EdgeInsets? actionPadding,
      EdgeInsets? buttonPadding,
      ScrollController? scrollController,
      ScrollController? actionScrollController}) {
    VoidCallback mapAction(String action) {
      return () {
        goBack(result: parseBool(action));
      };
    }

    final options = [
      (flag ?? true) ? 'YES' : 'OK',
      (flag ?? true) ? 'NO' : 'Cancel'
    ];
    final actions = ((reverse ?? false) ? options.reversed : options)
        .map<VoidCallback>(mapAction)
        .toList();
    return revealDialogBox(options, actions,
        type: type,
        title: title,
        action: action,
        dismissive: dismissive,
        titleStyle: titleStyle,
        actionStyle: actionStyle,
        optionStyle: optionStyle,
        titlePadding: titlePadding,
        insetDuration: insetDuration,
        buttonPadding: buttonPadding,
        actionPadding: actionPadding,
        insetAnimation: insetAnimation,
        scrollController: scrollController,
        actionScrollController: actionScrollController);
  }

  Future<bool> showSimplePopup(String option, VoidCallback onActionDone,
      {String? action,
      String? title,
      AlertType? type,
      bool? dismissive,
      Curve? insetAnimation,
      TextStyle? titleStyle,
      TextStyle? actionStyle,
      TextStyle? optionStyle,
      Duration? insetDuration,
      EdgeInsets? titlePadding,
      EdgeInsets? actionPadding,
      EdgeInsets? buttonPadding,
      ScrollController? scrollController,
      ScrollController? actionScrollController}) {
    return revealDialogBox([option], [onActionDone],
        type: type,
        title: title,
        action: action,
        dismissive: dismissive,
        titleStyle: titleStyle,
        actionStyle: actionStyle,
        optionStyle: optionStyle,
        titlePadding: titlePadding,
        buttonPadding: buttonPadding,
        actionPadding: actionPadding,
        insetDuration: insetDuration,
        insetAnimation: insetAnimation,
        scrollController: scrollController,
        actionScrollController: actionScrollController);
  }

  Future<T?> appearDialogBox<T>(
      {Widget? child,
      Widget? title,
      AlertType? type,
      Widget? content,
      bool? dismissive,
      String? barrierLabel,
      List<Widget>? actions,
      TextStyle? titleStyle,
      Curve? insetAnimation,
      TextStyle? actionStyle,
      Duration? insetDuration,
      EdgeInsets? titlePadding,
      EdgeInsets? actionPadding,
      EdgeInsets? buttonPadding,
      EdgeInsets? contentPadding,
      RouteSettings? routeSettings,
      ScrollController? scrollController,
      MainAxisAlignment? actionsAlignment,
      ScrollController? actionScrollController}) {
    Widget dialogBuilder(BuildContext context) {
      switch (type) {
        case AlertType.cupertino:
          return CupertinoAlertDialog(
              title: title,
              content: content,
              actions: actions ?? <Widget>[],
              scrollController: scrollController,
              actionScrollController: actionScrollController,
              insetAnimationCurve: insetAnimation ?? Curves.decelerate,
              insetAnimationDuration:
                  insetDuration ?? const Duration(milliseconds: 100));
        case AlertType.normal:
          return AlertDialog(
              title: title,
              content: content,
              actions: actions,
              titlePadding: titlePadding,
              titleTextStyle: titleStyle,
              buttonPadding: buttonPadding,
              contentTextStyle: actionStyle,
              actionsAlignment: actionsAlignment,
              actionsPadding: actionPadding ?? EdgeInsets.zero,
              contentPadding: contentPadding ??
                  EdgeInsets.symmetric(
                      horizontal: width / 25, vertical: height / 100));
        default:
          return child ?? const EmptyWidget();
      }
    }

    return type == AlertType.cupertino
        ? showCupertinoDialog<T>(
            context: buildContext,
            builder: dialogBuilder,
            barrierLabel: barrierLabel,
            routeSettings: routeSettings,
            barrierDismissible: dismissive ?? false)
        : showDialog<T>(
            context: buildContext,
            builder: dialogBuilder,
            barrierLabel: barrierLabel,
            routeSettings: routeSettings,
            barrierDismissible: dismissive ?? false);
  }

  Future<T?> manifestDialogBox<T>(
      List<String> options, List<VoidCallback> actions,
      {String? title,
      String? action,
      AlertType? type,
      bool? dismissive,
      TextStyle? titleStyle,
      TextStyle? actionStyle,
      TextStyle? optionStyle,
      Duration? insetDuration,
      EdgeInsets? titlePadding,
      EdgeInsets? actionPadding,
      EdgeInsets? buttonPadding,
      ScrollController? scrollController,
      ScrollController? actionScrollController,
      Curve? insetAnimation}) async {
    Widget optionsMap(String e) {
      final child = Text(e, style: optionStyle);
      final onTap = actions[options.indexOf(e)];
      log(type);
      switch (type) {
        case AlertType.cupertino:
          return CupertinoDialogAction(
              onPressed: onTap, textStyle: actionStyle, child: child);
        case AlertType.normal:
        default:
          return CustomButton(
              type: ButtonType.text, onPressed: onTap, child: child);
      }
    }

    return options.length == actions.length &&
            options.isNotEmpty &&
            actions.isNotEmpty
        ? await appearDialogBox<T>(
            type: type,
            dismissive: dismissive,
            titleStyle: titleStyle,
            actionStyle: actionStyle,
            titlePadding: titlePadding,
            buttonPadding: buttonPadding,
            actionPadding: actionPadding,
            insetDuration: insetDuration,
            insetAnimation: insetAnimation,
            scrollController: scrollController,
            title: title == null ? null : Text(title),
            content: action == null ? null : Text(action),
            actionScrollController: actionScrollController,
            actions: options.map<Widget>(optionsMap).toList())
        : null;
  }

  String? nameValidator(String? name) =>
      name != null && name.length > 2 ? null : loc.INVALID_USERNAME;

  String? descriptionValidator(String? description) =>
      description != null && description.isNotEmpty && description.length > 5
          ? null
          : 'Please Enter Description!!!!';

  String? passwordValidator(String? password) =>
      password != null && passExp.hasMatch(password) && password.length > 9
          ? null
          : loc.INVALID_PASSWORD;

  String? emailValidator(String? email) => email != null &&
          email.isNotEmpty &&
          mailExp.hasMatch(email) &&
          mailExp.allMatches(email).length == 1
      ? null
      : loc.INVALID_USERNAME;

  String? dateValidator(String? date) {
    List<String> temp;
    if (date == null) {
      temp = <String>[];
    } else if (date.contains('/')) {
      temp = date.split('/');
    } else if (date.contains('-')) {
      temp = date.split('-');
    } else {
      temp = <String>[];
    }
    if (temp.isNotEmpty &&
        temp[(temp.indexOf(temp.first) + temp.indexOf(temp.last)) ~/ 2]
                .length ==
            1) {
      temp[(temp.indexOf(temp.first) + temp.indexOf(temp.last)) ~/ 2] =
          '0${temp[(temp.indexOf(temp.first) + temp.indexOf(temp.last)) ~/ 2]}';
    }
    String ip = temp.isNotEmpty ? temp.reversed.join('-') : '';
    log(ip);
    return DateTime.tryParse(ip) != null
        ? null
        : 'Please Enter a Valid Date!!!';
  }

  String putDateToString(DateTime dt) => '${dt.day}/${dt.month}/${dt.year}';

  String getAppropriateDateString(String irregularDate) {
    return irregularDate.split('/').reversed.join('-');
  }

  Future<DateTime> getDatePicker(
      {AlertType? alertType, DateTime? dateTime, DateType? dateType}) async {
    final today = DateTime.now();
    final DateTime picked, startDate, endDate;
    switch (dateType) {
      case DateType.birth:
        startDate = DateTime(
            (dateTime == null ? today.year : dateTime.year) - 50, 1, 1);
        endDate = dateTime ?? today;
        break;
      case DateType.death:
        startDate = dateTime ?? today;
        endDate = DateTime((dateTime == null ? today.year : dateTime.year) + 50,
            12, 31, 23, 59, 59);
        break;
      default:
        startDate = DateTime(
            (dateTime == null ? today.year : dateTime.year) - 50, 1, 1);
        endDate = DateTime((dateTime == null ? today.year : dateTime.year) + 50,
            12, 31, 23, 59, 59);
        break;
    }
    log(startDate);
    log(dateTime);
    switch (alertType) {
      case AlertType.cupertino:
        picked = await showIOSStyleDatePicker(
            initial: dateTime ?? today,
            firstDate: startDate,
            lastDate: endDate);
        break;
      case AlertType.normal:
      default:
        picked = await showDatePicker(
                context: buildContext,
                initialDate: dateTime ?? today,
                firstDate: startDate,
                lastDate: endDate) ??
            today;
        break;
    }
    return picked;
  }

  Future<DateTime> showIOSStyleDatePicker(
      {DateTime? initial, DateTime? firstDate, DateTime? lastDate}) async {
    Widget iOSDatePickerBuilder(BuildContext context) {
      DateTime dat = DateTime.now();
      void onDateTimeChanged(DateTime dt) {
        dat = dt;
      }

      return Card(
          color: Colors.white,
          margin: EdgeInsets.only(top: height / 1.6),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Flexible(
                    child: OutlinedButton(
                        style: ButtonStyle(
                            shape: MaterialStateProperty.all<OutlinedBorder>(
                                RoundedRectangleBorder(
                                    side: const BorderSide(color: Colors.blue),
                                    borderRadius:
                                        BorderRadius.circular(radius / 160))),
                            foregroundColor:
                                MaterialStateProperty.all<Color>(Colors.blue),
                            padding: MaterialStateProperty.all<EdgeInsets>(
                                EdgeInsets.symmetric(
                                    vertical: height / 40,
                                    horizontal: width / 10))),
                        onPressed: () {
                          goBack(result: dat);
                        },
                        child: const Text('Done'))),
                Expanded(
                    child: CupertinoDatePicker(
                        minimumDate: firstDate,
                        maximumDate: lastDate,
                        initialDateTime: initial,
                        mode: CupertinoDatePickerMode.date,
                        onDateTimeChanged: onDateTimeChanged))
              ]));
    }

    final today = DateTime.now();
    final picked = await showCupertinoModalPopup<DateTime>(
            context: buildContext, builder: iOSDatePickerBuilder) ??
        today;
    return picked;
  }

  Future<bool> revealToast(String content,
      {double? fontSize, ToastGravity? gravity, Toast? length}) async {
    try {
      final p = await Fluttertoast.showToast(
              msg: content,
              fontSize: fontSize,
              gravity: gravity,
              toastLength: length) ??
          false;
      return p;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> onWillPop() async {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime ?? now) >
            const Duration(seconds: 2)) {
      currentBackPressTime = now;
      final p = await revealToast('Tap Again to Leave');
      return !p;
    } else {
      await SystemChannels.platform.invokeMethod('SystemNavigator.pop');
      return true;
    }
  }

  void checkPermissionStatus(Permission permission) async {
    if (isIOS) {
      final ini = await dip.iosInfo;
      if (ini.isPhysicalDevice) {
        final p = await permission.status;
        rqs:
        if (p.isDenied) {
          final r = await permission.request();
          if (r.isDenied) {
            checkPermissionStatus(permission);
          } else {
            break rqs;
          }
        } else {
          break rqs;
        }
      } else {
        log(ini.identifierForVendor);
        log(ini.localizedModel);
        log(ini.model);
        log(ini.name);
        log(ini.systemName);
        log(ini.systemVersion);
        log(ini.utsname.machine);
        log(ini.utsname.nodename);
        log(ini.utsname.release);
        log(ini.utsname.sysname);
        log(ini.utsname.version);
      }
    } else if (isAndroid) {
      final dro = await dip.androidInfo;
      if (dro.isPhysicalDevice ?? false) {
        final p = await permission.status;
        rqs:
        if (p.isDenied || p.isPermanentlyDenied) {
          final r = await permission.request();
          if (r.isDenied || r.isPermanentlyDenied) {
            checkPermissionStatus(permission);
          } else {
            break rqs;
          }
        } else {
          break rqs;
        }
      } else {
        log(dro.board);
        log(dro.bootloader);
        log(dro.brand);
        log(dro.device);
        log(dro.display);
        log(dro.fingerprint);
        log(dro.hardware);
        log(dro.host);
        log(dro.id);
        log(dro.manufacturer);
        log(dro.version);
        log(dro.type);
        log(dro.tags);
        log(dro.systemFeatures);
        log(dro.supported64BitAbis);
        log(dro.supported32BitAbis);
        log(dro.model);
        log(dro.product);
      }
    }
  }

  Future<bool> backButtonOverride({dynamic result}) {
    return Navigator.maybePop(buildContext, result);
  }

  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> getSnackBar(
      String content,
      {Duration? duration,
      Color? backgroundColor,
      double? elevation,
      EdgeInsetsGeometry? margin,
      EdgeInsetsGeometry? padding,
      double? width,
      ShapeBorder? shape,
      SnackBarBehavior? behavior,
      SnackBarAction? action,
      Animation<double>? animation,
      void Function()? onVisible,
      DismissDirection? dismissDirection}) {
    return renderSnackBar(Text(content),
        duration: duration,
        backgroundColor: backgroundColor,
        behavior: behavior,
        elevation: elevation,
        margin: margin,
        padding: padding,
        width: width,
        dismissDirection: dismissDirection ?? DismissDirection.down,
        animation: animation,
        action: action,
        onVisible: onVisible,
        shape: shape);
  }

  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> renderSnackBar(
      Widget content,
      {Duration? duration,
      Color? backgroundColor,
      double? elevation,
      EdgeInsetsGeometry? margin,
      EdgeInsetsGeometry? padding,
      double? width,
      ShapeBorder? shape,
      SnackBarBehavior? behavior,
      SnackBarAction? action,
      Animation<double>? animation,
      void Function()? onVisible,
      DismissDirection? dismissDirection}) {
    return smcT.showSnackBar(SnackBar(
        content: content,
        backgroundColor: backgroundColor,
        behavior: behavior,
        elevation: elevation,
        margin: margin,
        padding: padding,
        width: width,
        duration: duration ?? const Duration(seconds: 4),
        dismissDirection: dismissDirection ?? DismissDirection.down,
        animation: animation,
        action: action,
        onVisible: onVisible,
        shape: shape));
  }

  Future<SnackBarClosedReason> displayBar(String text,
      {Duration? duration}) async {
    final p = getSnackBar(text, duration: duration);
    await SystemChannels.platform.invokeMethod(p.close.toString());
    return p.closed;
  }

  Future<SnackBarClosedReason> revealSnackBar(Widget child,
      {Duration? duration}) async {
    final p = renderSnackBar(child, duration: duration);
    await SystemChannels.platform.invokeMethod(p.close.toString());
    return p.closed;
  }

  void reloadOnly() {
    reload(doNothing);
  }

  void getConnectStatus({VoidCallback? vcb, dynamic args}) async {
    final connectivityResult = await con.checkConnectivity();
    chc:
    if (connectivityResult == ConnectivityResult.none) {
      final f1 = isDialogOpen ||
          await showSimplePopup('Try Again', () {
            goBack(result: connectivityResult == ConnectivityResult.none);
            getConnectStatus(vcb: vcb, args: args);
          },
              title: 'Setinhand',
              type: AlertType.cupertino,
              action: 'Check Your Connection');
      if (!f1) break chc;
    } else if (vcb != null) {
      await SystemChannels.platform.invokeMethod(vcb.toString(), args);
    }
  }

  void signout() async {
    try {
      final rp = await api.logout(this);
      bool val = await revealToast(rp.message) && rp.success;
      final prefs = await sharedPrefs;
      prefs.containsKey('rememberme') && (prefs.getBool('rememberme') ?? false)
          ? log('fhhgewi')
          : val = val &&
              await prefs.remove('email') &&
              await prefs.remove('password');
      for (String key in prefs.getKeys()) {
        val = val &&
            (key == 'spDeviceToken' ||
                    key == 'rememberme' ||
                    key == 'email' ||
                    key == 'password'
                ? true
                : await prefs.remove(key));
      }
      tasks.value = null;
      stockItems.value = null;
      dueDeliveries.value = null;
      currentUser.value = User.emptyUser;
      notifyAll();
      goBack(result: val);
    } catch (e) {
      sendAppLog(e);
    }
  }

  void logout() async {
    final p = await revealDialogBox([
      'No',
      'Yes'
    ], [
      () {
        goBack(result: false);
        log('Error');
      },
      signout
    ],
        title: 'Setinhand',
        type: AlertType.cupertino,
        action: 'Are you sure to log out?');
    p ? gotoForever('/login') : doNothing();
  }

  void notifyUser() {
    currentUser.notifyListeners();
  }

  void notifyTasks() {
    tasks.notifyListeners();
  }

  void notifyDues() {
    dueDeliveries.notifyListeners();
  }

  void notifyGoods() {
    data.notifyListeners();
  }

  void notifyStocks() {
    stockItems.notifyListeners();
  }

  void notifyWarehouse() {
    warehouseitems.notifyListeners();
  }

  void notifyBoxes() {
    stocks.notifyListeners();
  }

  void notifyMoveCount() {
    count.notifyListeners();
  }

  void notifyAll() {
    notifyUser();
    notifyTasks();
    notifyDues();
    notifyGoods();
    notifyStocks();
    notifyBoxes();
    notifyWarehouse();
  }
}
