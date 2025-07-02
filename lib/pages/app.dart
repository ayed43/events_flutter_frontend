import 'package:demo/cubits/chat_cubit/chat_cubit.dart';
import 'package:demo/cubits/home_cobit/home_cubit.dart';
import 'package:demo/cubits/home_cobit/home_states.dart';
import 'package:demo/models/cache_controller/cache_controller.dart';
import 'package:demo/pages/second.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:iconsax/iconsax.dart';
import 'package:geolocator/geolocator.dart';

import '../auth/login/login_page.dart';
import '../models/app_controller.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  bool _locationRequested = false;

  @override
  void initState() {
    super.initState();
    // Request location once when app starts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestLocationOnce();
    });
  }

  Future<void> _requestLocationOnce() async {
    if (_locationRequested) return;
    _locationRequested = true;

    final cacheController = Provider.of<CacheController>(context, listen: false);

    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showLocationDialog('Location services are disabled. Please enable them in settings.');
        return;
      }

      // Check permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showLocationDialog('Location permissions denied. Some features may not work properly.');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showLocationDialog('Location permissions permanently denied. Please enable them in settings.');
        return;
      }

      // Get current position once
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Save to CacheController
      cacheController.saveLocation(position.latitude, position.longitude);

      print('Location saved: Lat: ${position.latitude}, Lng: ${position.longitude}');

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Location saved successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }

    } catch (e) {
      print('Error getting location: $e');
      _showLocationDialog('Failed to get location: $e');
    }
  }

  void _showLocationDialog(String message) {
    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Location'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  // Manual location refresh function
  Future<void> _refreshLocation() async {
    final cacheController = Provider.of<CacheController>(context, listen: false);

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      cacheController.saveLocation(position.latitude, position.longitude);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Location refreshed successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to refresh location: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AppController, CacheController>(
      builder: (context, home, cacheController, child) {
        final userName = cacheController.user?['name'] ?? 'Guest';

        return MultiBlocProvider(
          providers: [
            BlocProvider<HomeCubit>(
              create: (BuildContext context) => HomeCubit()..getData(),
            ),
            BlocProvider<ChatCubit>(
              create: (context) => ChatCubit()..getProviders(),
            )
          ],
          child: BlocConsumer<HomeCubit, HomeStates>(
            listener: (context, state) {
              var cubit = HomeCubit.get(context);
              if (state is InitialState) {
                cubit.getData();
              }
            },
            builder: (context, state) {
              return Scaffold(
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
                  title: Row(
                    children: [
                      const Text(
                        'Saudi Festivals App',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const Spacer(),
                      // Location status indicator
                      if (cacheController.hasLocationData)
                        // Container(
                        //   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        //   decoration: BoxDecoration(
                        //     color: Colors.green.withOpacity(0.2),
                        //     borderRadius: BorderRadius.circular(12),
                        //     border: Border.all(color: Colors.green, width: 1),
                        //   ),
                        //   child: Row(
                        //     mainAxisSize: MainAxisSize.min,
                        //     children: [
                        //       Icon(
                        //         Icons.location_on,
                        //         color: Colors.green,
                        //         size: 16,
                        //       ),
                        //       const SizedBox(width: 4),
                        //       Text(
                        //         'SAVED',
                        //         style: TextStyle(
                        //           color: Colors.green,
                        //           fontSize: 12,
                        //           fontWeight: FontWeight.bold,
                        //         ),
                        //       ),
                        //     ],
                        //   ),
                        // ),
                        Container()
                    ],
                  ),
                  actions: [
                    // Location control button
                    PopupMenuButton<String>(
                      icon: Icon(
                        cacheController.hasLocationData
                            ? Icons.location_on
                            : Icons.location_off,
                        color: cacheController.hasLocationData ? Colors.green : Colors.grey,
                        size: 28,
                      ),
                      onSelected: (value) {
                        switch (value) {
                          case 'refresh':
                            _refreshLocation();
                            break;
                          case 'clear':
                            cacheController.clearLocationData();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Location data cleared')),
                            );
                            break;
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'refresh',
                          child: Row(
                            children: [
                              Icon(Icons.refresh, color: Colors.blue),
                              SizedBox(width: 8),
                              Text('Refresh Location'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'clear',
                          child: Row(
                            children: [
                              Icon(Icons.clear, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Clear Location'),
                            ],
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.settings_power,
                        color: Colors.white,
                        size: 35,
                      ),
                      tooltip: 'Logout',
                      onPressed: () {
                        cacheController.logout();
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (_) => LoginPage()),
                              (route) => false,
                        );
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
                            hasLocationIndicator: cacheController.hasLocationData,
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
    bool hasLocationIndicator = false,
  }) {
    final isSelected = currentIndex == index;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
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
                // Location indicator for Map tab
                if (hasLocationIndicator && index == 2)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
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