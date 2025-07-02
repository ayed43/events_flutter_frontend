
import 'package:demo/cubits/home_cobit/home_cubit.dart';
import 'package:demo/pages/bookings_page.dart';
import 'package:flutter/material.dart';

import '../pages/chat_page.dart';
import '../pages/map_page.dart';
import '../pages/home.dart';
import '../pages/events_page.dart';


class AppController extends ChangeNotifier{

  bool isDark=false;
  changeMode(){
    isDark=!isDark;
    notifyListeners();

  }
  List <Widget> pages=[

    EventsPage(),
    HomePage(),
    MapsPage(),
    BookingsPage(),
    ChatPage()
  ];
  int currentIndex=0;

  buttomNavBar(a,context){
    if (a==0){
      HomeCubit.get(context).getData();
    }
    this.currentIndex=a;
    notifyListeners();
  }


}