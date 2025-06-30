import 'package:demo/cubits/chat_cubit/chat_cubit.dart';
import 'package:demo/cubits/home_cobit/home_cubit.dart';
import 'package:demo/cubits/home_cobit/home_states.dart';
import 'package:demo/models/cache_controller/cache_controller.dart';
import 'package:demo/pages/second.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:iconsax/iconsax.dart';

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
          MultiBlocProvider
            (
            providers: [
              BlocProvider<HomeCubit>(
                create: (BuildContext context) => HomeCubit()..getData(),
              ),
              BlocProvider<ChatCubit>(create: (context) => ChatCubit()..getProviders(),)
            ],

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
                    elevation: 0,
                    backgroundColor: Colors.transparent,
                    flexibleSpace: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.indigo, Colors.indigoAccent],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                    title: const Text(
                      'Saudi Festivals App',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.settings_power, color: Colors.white,size: 30,),
                        tooltip: 'Logout',
                        onPressed: () {
                          // app.logout();
                          // Navigator.of(context).pushAndRemoveUntil(
                          //   MaterialPageRoute(builder: (_) => LoginPage()),
                          //       (route) => false,
                          // );
                        },
                      ),
                    ],
                  ),


                  body: home.pages[home.currentIndex],
                  bottomNavigationBar: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildNavItem(
                              icon: Icons.home_filled,
                              label: 'Home',
                              index: 0,
                              currentIndex: home.currentIndex,
                              onTap: () => home.buttomNavBar(0),
                            ),
                            _buildNavItem(
                              icon: Icons.party_mode,
                              label: 'Events',
                              index: 1,
                              currentIndex: home.currentIndex,
                              onTap: () => home.buttomNavBar(1),
                            ),
                            _buildNavItem(
                              icon: Icons.location_on_outlined,
                              label: 'Map',
                              index: 2,
                              currentIndex: home.currentIndex,
                              onTap: () => home.buttomNavBar(2),
                              isCenter: true,
                            ),
                            _buildNavItem(
                              icon: Icons.my_location_rounded,
                              label: 'Bookings',
                              index: 3,
                              currentIndex: home.currentIndex,
                              onTap: () => home.buttomNavBar(3),
                            ),
                            _buildNavItem(
                              icon: Icons.chat,
                              label: 'Chats',
                              index: 4,
                              currentIndex: home.currentIndex,
                              onTap: () => home.buttomNavBar(4),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },



            ),
          );
      },
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required int currentIndex,
    required VoidCallback onTap,
    bool isCenter = false,

  }) {
    final isSelected = currentIndex == index;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(isCenter ? 12.0 : 8.0),
              decoration: BoxDecoration(
                color: isCenter
                    ? Colors.black
                    : (isSelected ? Colors.indigo.withOpacity(0.1) : Colors.transparent),
                shape: BoxShape.circle,
                border: isCenter
                    ? null
                    : (isSelected
                    ? Border.all(color: Colors.indigo.withOpacity(0.3), width: 1)
                    : null),
              ),
              child: Icon(
                icon,
                color: isCenter
                    ? Colors.white
                    : (isSelected ? Colors.indigo : Colors.grey[600]),
                size: isCenter ? 28.0 : 24.0,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.indigo : Colors.grey[600],
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
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