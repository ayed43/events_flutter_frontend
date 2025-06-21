

import 'package:demo/pages/app.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'auth/login/login_page.dart';
import 'models/cache_controller/cache_controller.dart';
import 'models/app_controller.dart';
import 'models/login_controller/login_controller.dart';
import 'models/signup_controller/signup_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await Hive.openBox('authBox');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CacheController()),
        ChangeNotifierProvider(create: (_) => LoginController()),
        ChangeNotifierProvider(create: (_) => SignupController()),
        ChangeNotifierProvider(create: (_) => AppController()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appController = Provider.of<CacheController>(context);

    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.indigo),
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      home: appController.isLoggedIn ? const App() :  LoginPage(),
    );
  }
}
