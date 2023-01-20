import 'package:bingnuos_admin_panel/ui/theme/app_theme.dart';
import 'package:bingnuos_admin_panel/utils/app_locale.dart';
import 'package:flutter/material.dart';

class SnackBarService {
  final BuildContext context;

  SnackBarService(this.context);

  void show(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        elevation: 16,
        behavior: SnackBarBehavior.floating,
        content: Text(message, style: Theme.of(context).textTheme.headline4),
        margin: const EdgeInsets.only(bottom: 15, left: 15, right: 15),
        backgroundColor: AppTheme.primaryColor,
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
          label: AppLocale(context).ok,
        ),
      ),
    );
  }
}