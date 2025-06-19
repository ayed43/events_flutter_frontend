
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:demo/models/home_model.dart';
import 'package:demo/pages/second.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return  Consumer<HomeController>(builder: (context, value, child) {
      return Scaffold(
          appBar: AppBar(

            actions: [

              IconButton(onPressed: () {
                value.changeMode();
              }, icon: value.isDark?Icon(Icons.sunny): Icon(Icons.dark_mode_outlined))
            ],
            backgroundColor: Colors.indigo,
            title: Text('this is app Bar'),),
          body: value.pages[value.currentIndex]
          ,
        bottomNavigationBar: BottomNavigationBar(
          onTap: (v) {
            value.buttomNavBar(v);
          },
          selectedLabelStyle: TextStyle(color: Colors.indigo),
         unselectedLabelStyle: TextStyle(color:Colors.black),
         selectedItemColor: Colors.indigo,
          unselectedItemColor: Colors.black,
          currentIndex: value.currentIndex,
          items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_filled),label: 'Home',),
            BottomNavigationBarItem(icon: Icon(Icons.party_mode,color: Colors.indigo),label: 'Events',),
            BottomNavigationBarItem(icon: Icon(Icons.settings,color:Colors.indigo),label: 'Settings',),
            BottomNavigationBarItem(icon: Icon(Icons.park_outlined,color:Colors.indigo),label: 'Notifications',),
            BottomNavigationBarItem(icon: Icon(Icons.chat,color: Colors.indigo,),label: 'Chats',)



          ],

        ),
      );
    },);

  }
}

class MyText extends StatelessWidget {
final  String text;
  MyText(this.text);

  @override
  Widget build(BuildContext context) {
    return  Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListTile(title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
        Text(this.text),Icon(Icons.running_with_errors_rounded)
      ],),onTap: () {
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return SecondPage();
      },));
      },)
    );
  }
}

