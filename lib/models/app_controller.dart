
import 'package:flutter/material.dart';

import '../pages/chat_page.dart';
import '../pages/events_page.dart';
import '../pages/home.dart';
import '../pages/notifications_page.dart';
import '../pages/settings_page.dart';


class AppController extends ChangeNotifier{

  bool isDark=false;
  changeMode(){
    isDark=!isDark;
    notifyListeners();

  }
  List <Widget> pages=[
    HomePage(),
    MapsPage(),
    SettingsPage(),
    NotificationsPage(),
    ChatPage()
  ];
  int currentIndex=0;

  buttomNavBar(a){
    this.currentIndex=a;
    notifyListeners();
  }


}