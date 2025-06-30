
import 'package:flutter/material.dart';

import '../pages/chat_page.dart';
import '../pages/map_page.dart';
import '../pages/home.dart';
import '../pages/bookings_page.dart';
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
  int currentIndex=4;

  buttomNavBar(a){
    this.currentIndex=a;
    notifyListeners();
  }


}