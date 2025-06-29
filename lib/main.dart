

import 'package:bloc/bloc.dart';
import 'package:demo/pages/app.dart';
import 'package:demo/services/remote/dio_helper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'auth/login/login_page.dart';
import 'models/cache_controller/cache_controller.dart';
import 'models/app_controller.dart';
import 'models/login_controller/login_controller.dart';
import 'models/signup_controller/signup_controller.dart';

void main() async {
  DioHelper.init();
  Bloc.observer = MyBlocObserver();
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
      theme: ThemeData(primarySwatch: Colors.indigo,
        fontFamily: 'Ubuntu'


      ),
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      home: appController.isLoggedIn ? const App() :  LoginPage(),
    );
  }
}


class MyBlocObserver extends BlocObserver {
  @override
  void onCreate(BlocBase bloc) {
    super.onCreate(bloc);
    print('onCreate -- ${bloc.runtimeType}');
  }

  @override
  void onEvent(Bloc bloc, Object? event) {
    super.onEvent(bloc, event);
    print('onEvent -- ${bloc.runtimeType}, $event');
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    print('onChange -- ${bloc.runtimeType}, $change');
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    print('onTransition -- ${bloc.runtimeType}, $transition');
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    print('onError -- ${bloc.runtimeType}, $error');
    super.onError(bloc, error, stackTrace);
  }

  @override
  void onClose(BlocBase bloc) {
    super.onClose(bloc);
    print('onClose -- ${bloc.runtimeType}');
  }
}