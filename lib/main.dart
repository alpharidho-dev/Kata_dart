import 'package:flutter/material.dart';

import 'core/api_client.dart';
import 'core/theme.dart';
import 'routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Memuat sesi yang tersimpan (token di secure storage, data akun di prefs)
  // sebelum UI pertama dibangun, supaya status login sudah benar sejak awal.
  await ApiClient.init();
  runApp(const KataApp());
}

/// Akar aplikasi: hanya menyiapkan tema dan daftar rute.
class KataApp extends StatelessWidget {
  const KataApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KATA',
      theme: AppTheme.dark,
      initialRoute: AppRoutes.home,
      onGenerateRoute: AppRoutes.generateRoute,
      debugShowCheckedModeBanner: false,
    );
  }
}