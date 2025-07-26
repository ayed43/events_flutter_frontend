import 'package:bloc/bloc.dart';
import 'package:demo/pages/app.dart';
import 'package:demo/services/remote/dio_helper.dart';
import 'package:flutter/material.dart';
import 'package:onboarding_screen/onboarding_screen.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'auth/login/login_page.dart';
import 'models/cache_controller/cache_controller.dart';
import 'models/app_controller.dart';
import 'models/login_controller/login_controller.dart';
import 'models/signup_controller/signup_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  DioHelper.init();
  Bloc.observer = MyBlocObserver();

  await Hive.initFlutter();
  final authBox = await Hive.openBox('authBox');
  final settingsBox = await Hive.openBox('settingsBox'); // new box for onboardingShown


  // Check if onboarding was shown before
  final onboardingShown = settingsBox.get('onboardingShown', defaultValue: false);


  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CacheController()),
        ChangeNotifierProvider(create: (_) => LoginController()),
        ChangeNotifierProvider(create: (_) => SignupController()),
        ChangeNotifierProvider(create: (_) => AppController()),
      ],
      child: MyApp(showOnboarding: !onboardingShown),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool showOnboarding;

  const MyApp({super.key, required this.showOnboarding});

  @override
  Widget build(BuildContext context) {
    final appController = Provider.of<CacheController>(context);

    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        fontFamily: 'Ubuntu',
      ),
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      home:
      showOnboarding
          ? const OnboardingWrapper()
          : appController.isLoggedIn
          ? const App()
          : LoginPage(),
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

class OnboardingWrapper extends StatefulWidget {
  const OnboardingWrapper({super.key});

  @override
  State<OnboardingWrapper> createState() => _OnboardingWrapperState();
}

class _OnboardingWrapperState extends State<OnboardingWrapper> {
  final List<_SliderModel> mySlides = [
    _SliderModel(
      imageAssetPath: Image.asset('assets/images/logo.png'
      ,
        width: 150,
        height: 150,
      ),
      title: 'Welcome to Saudi Festivals',
      desc: 'Discover and join amazing cultural events!',
      minTitleFontSize: 20,
      miniDescFontSize: 14,
      titleStyle: const TextStyle(
          fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
      descStyle: const TextStyle(fontSize: 14, color: Colors.black87),
    ),
    _SliderModel(
      imageAssetPath: Image.asset('assets/images/logo.png'
        ,
        width: 150,
        height: 150,
      ),
      title: 'Book Your Spot',
      desc: 'Easily reserve a place at any festival.',
      minTitleFontSize: 20,
      miniDescFontSize: 14,
    ),
    _SliderModel(
      imageAssetPath: Image.asset('assets/images/logo.png'
        ,
        width: 150,
        height: 150,
      ),
      title: 'Stay Connected',
      desc: 'Get real-time updates and notifications.',
      minTitleFontSize: 20,
      miniDescFontSize: 14,
    ),
  ];

  final PageController _controller = PageController();

  @override
  Widget build(BuildContext context) {
    return OnBoardingScreen(
      label: const Text('Get Started'),
      function: () async {
        final settingsBox = Hive.box('settingsBox');
        await settingsBox.put('onboardingShown', true);
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => LoginPage()),
        );
      },
      mySlides: mySlides,
      controller: _controller,
      slideIndex: 0,
      statusBarColor: Colors.indigo.shade50, // softer status bar color to match bg
      startGradientColor: Colors.white,       // same as login page start
      endGradientColor:  Colors.indigo.shade400, // same as login page end
      skipStyle: const TextStyle(color: Colors.indigo), // use indigo to stand out
      pageIndicatorColorList: [
        Colors.indigo,
        Colors.indigo.shade200,
        Colors.indigo.shade400,
      ],
    );
  }


}

class _SliderModel {
  const _SliderModel({
    required this.imageAssetPath,
    this.title = "title",
    this.desc = "desc",
    this.miniDescFontSize = 12.0,
    this.minTitleFontSize = 15.0,
    this.descStyle,
    this.titleStyle,
  });

  final Image imageAssetPath;
  final String title;
  final TextStyle? titleStyle;
  final double minTitleFontSize;
  final String desc;
  final TextStyle? descStyle;
  final double miniDescFontSize;
}
