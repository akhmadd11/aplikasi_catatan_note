import 'package:flutter/material.dart';

import 'package:aplikasi_catatan_note/app.dart';
import 'package:aplikasi_catatan_note/database/database_helper.dart';

import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  await DatabaseHelper.instance.getDatabase();
  runApp(const App());
}
