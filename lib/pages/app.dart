import 'package:demo/cubits/home_cobit/home_cubit.dart';
import 'package:demo/cubits/home_cobit/home_states.dart';
import 'package:demo/models/cache_controller/cache_controller.dart';
import 'package:demo/pages/second.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import '../auth/login/login_page.dart';
import '../models/app_controller.dart';


class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {

    return Consumer2<AppController, CacheController>(
      builder: (context, home, app, child) {
        final userName = app.user?['name'] ?? 'Guest';

        return
          BlocProvider
            (create: (BuildContext context)=>HomeCubit()..getData(),
          child: BlocConsumer<HomeCubit,HomeStates>(
            listener: (context, state) {
              var cubit=HomeCubit.get(context);
              if (state is InitialState){
                cubit.getData();
              }
            },
            builder: (context, state) {
              return    Scaffold(

                appBar: AppBar(

                  title: Text('Saudi Fastivals App',style: TextStyle(color:Colors.indigo,fontSize: 24,fontWeight: FontWeight.bold),),
                  actions: [
                    // Theme toggle
                    // IconButton(
                    //   icon: home.isDark
                    //       ? const Icon(Icons.sunny)
                    //       : const Icon(Icons.dark_mode_outlined),
                    //   onPressed: home.changeMode,
                    // ),
                    // Logout


                    IconButton(
                      icon: const Icon(Icons.logout,color: Colors.indigo,),
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
                // floatingActionButton: FloatingActionButton(onPressed:
                //     () {
                //   HomeCubit.get(context).getData();
                //   final cache = CacheController(); // not recommended without provider unless you pass it
                //
                //   final token = cache.token;
                //   print(token);
                //   //     final raw = _authBox.get('user');
                //   //     print(raw);
                // },child: Icon(Icons.add),),
                body: home.pages[home.currentIndex],
                bottomNavigationBar: BottomNavigationBar(
                  currentIndex: home.currentIndex,
                  onTap: home.buttomNavBar,
                  selectedLabelStyle: const TextStyle(color: Colors.indigo,),
                  unselectedLabelStyle: const TextStyle(color: Colors.black),
                  selectedItemColor: Colors.indigo,
                  unselectedItemColor: Colors.black,
                  items: const [
                    BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
                    BottomNavigationBarItem(icon: Icon(Icons.party_mode), label: 'Events'),
                    BottomNavigationBarItem(icon: Icon(Icons.location_on_outlined), label: 'Map'),
                    BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Notifications'),
                    BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chats'),
                  ],
                ),
              );
            },



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
