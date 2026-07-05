import 'package:flutter/material.dart';

import 'package:aplikasi_catatan_note/router.dart';
import 'package:aplikasi_catatan_note/theme/app_theme.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Catatan',
      theme: AppTheme.darkTheme,
      routerConfig: router,
    );
  }
}
