import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class AppL10n {
  static const supportedLocales = [
    Locale('ar'),
    Locale('en'),
    Locale('fr'),
    Locale('es'),
    Locale('tr'),
    Locale('ur'),
    Locale('id'),
    Locale('ms'),
    Locale('fa'),
    Locale('bn'),
  ];

  static const delegates = [
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];
}