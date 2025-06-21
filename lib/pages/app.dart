import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:demo/auth/login/login_page.dart';
import 'package:demo/models/app_controller/app_controller.dart';
import 'package:demo/models/home_model.dart';
import 'package:demo/pages/second.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<HomeController, AppController>(
      builder: (context, home, app, child) {
        final userName = app.user?['name'] ?? 'Guest';

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.indigo,
            title: Text('Welcome $userName'),
            actions: [
              // Theme toggle
              IconButton(
                icon: home.isDark
                    ? const Icon(Icons.sunny)
                    : const Icon(Icons.dark_mode_outlined),
                onPressed: home.changeMode,
              ),
              // Logout
              IconButton(
                icon: const Icon(Icons.logout),
                tooltip: 'Logout',
                onPressed: () {
                  app.logout();
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) =>  LoginPage()),
                        (route) => false,
                  );
                },
              ),
            ],
          ),
          body: home.pages[home.currentIndex],
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: home.currentIndex,
            onTap: home.buttomNavBar,
            selectedLabelStyle: const TextStyle(color: Colors.indigo),
            unselectedLabelStyle: const TextStyle(color: Colors.black),
            selectedItemColor: Colors.indigo,
            unselectedItemColor: Colors.black,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
              BottomNavigationBarItem(icon: Icon(Icons.party_mode), label: 'Events'),
              BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
              BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Notifications'),
              BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chats'),
            ],
          ),
        );
      },
    );
  }
}

class MyText extends StatelessWidget {
  final String text;
  const MyText(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(text),
            const Icon(Icons.running_with_errors_rounded),
          ],
        ),
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const SecondPage()));
        },
      ),
    );
  }
}
