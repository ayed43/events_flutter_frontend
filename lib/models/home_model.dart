
import 'package:flutter/material.dart';
import 'package:demo/pages/chat_page.dart';
import 'package:demo/pages/events_page.dart';
import 'package:demo/pages/home.dart';
import 'package:demo/pages/notifications_page.dart';
import 'package:demo/pages/settings_page.dart';

class HomeController extends ChangeNotifier{

  bool isDark=false;
  changeMode(){
    isDark=!isDark;
    notifyListeners();

  }
  List <Widget> pages=[
    HomePage(),
    EventsPage(),
    SettingsPage(),
    NotificationsPage(),
    ChatPage()
  ];
  int currentIndex=1;

  buttomNavBar(a){
    this.currentIndex=a;
    notifyListeners();
  }


}