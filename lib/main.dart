import 'package:demo/auth/login/login_page.dart';
import 'package:demo/models/app_controller/app_controller.dart';
import 'package:demo/models/home_model.dart';
import 'package:demo/models/login_controller/login_controller.dart';
import 'package:demo/models/signup_controller/signup_controller.dart';
import 'package:demo/pages/app.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await Hive.openBox('authBox');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppController()),
        ChangeNotifierProvider(create: (_) => LoginController()),
        ChangeNotifierProvider(create: (_) => SignupController()),
        ChangeNotifierProvider(create: (_) => HomeController()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appController = Provider.of<AppController>(context);

    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.indigo),
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      home: appController.isLoggedIn ? const App() :  LoginPage(),
    );
  }
}
