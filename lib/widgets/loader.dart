import '../helpers/helper.dart';
import 'package:flutter/material.dart';

const defaultValue = 56.0;

class Loader extends StatelessWidget {
  static OverlayEntry? _currentLoader;

  const Loader._(this._progressIndicator, this.themeData);

  final Widget? _progressIndicator;
  final ThemeData? themeData;
  static WidgetsBinding widgetBind = WidgetsBinding.instance;

  static OverlayState? _overlayState;

  /// If you need to check your loader is being shown or
  /// not just call the property ```Loader.isShown'''
  static bool get isShown => _currentLoader != null;

  /// If you need to show an normal overlayloader,
  /// just call ```Loader.show(context)``` with a build context.
  /// BuildContext is a required param.

  static void show(
    BuildContext context, {

    /// Define your custom progress indicator if you want [optional]
    Widget? progressIndicator,

    /// Define Theme [optional]
    ThemeData? themeData,

    /// Define Overlay color [optional]
    Color? overlayColor,

    /// overlayTop mean overlay start from Top margin.
    ///
    /// If you have custom appbar and you want to show loader without custom
    /// appbar then will be custom appbar height here and also you have to make
    /// sure [isAppbarOverlay = false].
    double? overlayFromTop,

    /// overlayFromBottom mean overlay end to Bottom margin.
    ///
    /// If you have custom BottomAppBar and you want to show loader without
    /// custom BottomAppBar then will be custom BottomAppBar height here and
    /// also you have to make sure [isBottomBarOverlay = false].
    double? overlayFromBottom,

    /// isAppbarOverlay default true.
    ///
    /// If you need to appbar outside from overlay loader then make it false.
    bool isAppbarOverlay = true,

    /// isBottomBarOverlay default true.
    ///
    /// If you need to BottomBar outside from overlay loader then make it false.
    bool isBottomBarOverlay = true,

    /// isSafeAreaOverlay default true.
    ///
    /// If you don't want to overlay  your safe area like statusBar and
    /// bottomNavBar then make it false.
    bool isSafeAreaOverlay = true,
  }) {
    var safeBottomPadding = MediaQuery.of(context).padding.bottom;
    var defaultPaddingTop = 0.0;
    var defaultPaddingBottom = 0.0;
    if (!isAppbarOverlay) {
      isSafeAreaOverlay = false;
    }
    if (!isSafeAreaOverlay) {
      defaultPaddingTop = defaultValue;
      defaultPaddingBottom = defaultValue + safeBottomPadding;
    } else {
      defaultPaddingTop = defaultValue;
      defaultPaddingBottom = defaultValue;
    }

    _overlayState = Overlay.of(context);
    if (_currentLoader == null) {
      ///Create current Loader Entry
      _currentLoader = OverlayEntry(builder: (context) {
        return Stack(
          children: <Widget>[
            _overlayWidget(
                isSafeAreaOverlay,
                overlayColor ?? const Color(0x99ffffff),
                isAppbarOverlay ? 0.0 : overlayFromTop ?? defaultPaddingTop,
                isBottomBarOverlay
                    ? 0.0
                    : overlayFromBottom ?? defaultPaddingBottom),
            Center(child: Loader._(progressIndicator, themeData))
          ],
        );
      });

      try {
        widgetBind.addPostFrameCallback((_) {
          if (_currentLoader != null) {
            _overlayState?.insert(_currentLoader!);
          } else {
            log(_);
          }
        });
      } catch (e) {
        sendAppLog(e);
      }
    }
  }

  static Widget _overlayWidget(bool isSafeArea, Color overlayColor,
      double overlayFromTop, double overlayFromBottom) {
    return isSafeArea
        ? Container(
            color: overlayColor,
            margin:
                EdgeInsets.only(top: overlayFromTop, bottom: overlayFromBottom))
        : SafeArea(
            child: Container(
                color: overlayColor,
                margin: EdgeInsets.only(
                    top: overlayFromTop, bottom: overlayFromBottom)));
  }

  /// You have to call ```Loader.hide()``` method inside the [dispose()] to clear loader.
  ///
  ///  The overlay or hide your loader when your view is disposed otherwise
  ///  [throws] an exception.
  /// And also you have to call ```Loader.hide()``` method when you need to hide
  /// your overlay loader.
  ///
  /// For example,
  /// After finishing your api call you need to hide your loader.
  /// then just call ```Loader.hide()```
  static void hide() {
    try {
      _currentLoader?.mounted ?? false
          ? _currentLoader?.remove()
          : log('object');
    } catch (e) {
      sendAppLog(e);
    } finally {
      log('hibye');
      _currentLoader = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final hp = Helper.of(context);
    return SafeArea(
        child: Scaffold(
            backgroundColor: Colors.grey.withOpacity(0.5),
            body: Center(
                child: AnimatedContainer(
                    height: hp.height / 10,
                    width: hp.width / 4,
                    // padding: EdgeInsets.all(32),
                    duration: const Duration(seconds: 10),
                    decoration: BoxDecoration(
                        color: Colors.black, border: Border.all()),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _progressIndicator ??
                              Image.asset('${assetImagePath}puzzle_128.gif',
                                  height: hp.height / (hp.factor * 10)),
                          const Text('Please Wait...',
                              textAlign: TextAlign.center,
                              style:
                                  TextStyle(color: Colors.white, fontSize: 20))
                        ])))));
  }
}
