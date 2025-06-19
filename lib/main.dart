
import 'package:demo/auth/login/login_page.dart';

import 'package:demo/models/home_model.dart';
import 'package:demo/models/login_controller/login_controller.dart';
import 'package:demo/models/signup_controller/signup_controller.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoginController()),
        ChangeNotifierProvider(create: (_) => SignupController(),

        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(create: (context) =>
        HomeController(),
      child: Consumer<HomeController>(builder: (context, value, child) {
        return   MaterialApp(
            theme: ThemeData(
              primarySwatch: Colors.indigo,
            ),
            debugShowCheckedModeBanner: false,
            title: 'Flutter Demo',
            home:LoginPage()
        );
      },),
    );
  }
}