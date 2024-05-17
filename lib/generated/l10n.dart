// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Please enter the username`
  String get EMPTY_USERNAME {
    return Intl.message(
      'Please enter the username',
      name: 'EMPTY_USERNAME',
      desc: '',
      args: [],
    );
  }

  /// `Please enter the password`
  String get EMPTY_PASSWORD {
    return Intl.message(
      'Please enter the password',
      name: 'EMPTY_PASSWORD',
      desc: '',
      args: [],
    );
  }

  /// `Please enter the proper email id`
  String get INVALID_USERNAME {
    return Intl.message(
      'Please enter the proper email id',
      name: 'INVALID_USERNAME',
      desc: '',
      args: [],
    );
  }

  /// `Please enter the proper password`
  String get INVALID_PASSWORD {
    return Intl.message(
      'Please enter the proper password',
      name: 'INVALID_PASSWORD',
      desc: '',
      args: [],
    );
  }

  /// `Please Wait`
  String get pleaseWait {
    return Intl.message(
      'Please Wait',
      name: 'pleaseWait',
      desc: '',
      args: [],
    );
  }

  /// `Please enter the stock code`
  String get STOCKCODE_EMPTY {
    return Intl.message(
      'Please enter the stock code',
      name: 'STOCKCODE_EMPTY',
      desc: '',
      args: [],
    );
  }

  /// `Please enter the number of boxes`
  String get BOX_EMPTY {
    return Intl.message(
      'Please enter the number of boxes',
      name: 'BOX_EMPTY',
      desc: '',
      args: [],
    );
  }

  /// `Please enter the quantity of boxes`
  String get QTY_BOX_EMPTY {
    return Intl.message(
      'Please enter the quantity of boxes',
      name: 'QTY_BOX_EMPTY',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
