import 'package:demo/cubits/chat_cubit/chat_cubit.dart';
import 'package:demo/cubits/home_cobit/home_cubit.dart';
import 'package:demo/cubits/home_cobit/home_states.dart';
import 'package:demo/models/cache_controller/cache_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';

import '../auth/login/login_page.dart';
import '../models/app_controller.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> with TickerProviderStateMixin {
  bool _locationRequested = false;
  bool _initialLocationDetected = false;
  late AnimationController _navAnimationController;
  late AnimationController _appBarAnimationController;

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers
    _navAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _appBarAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    // Request location once when app starts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestLocationOnce();
      _navAnimationController.forward();
      _appBarAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _navAnimationController.dispose();
    _appBarAnimationController.dispose();
    super.dispose();
  }

  Future<void> _requestLocationOnce() async {
    if (_locationRequested) return;
    _locationRequested = true;

    final cacheController = Provider.of<CacheController>(context, listen: false);

    // Check if location was already saved (app restart scenario)
    if (cacheController.hasLocationData) {
      _initialLocationDetected = true;
      return;
    }

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

      // Show success message ONLY for initial detection
      if (mounted && !_initialLocationDetected) {
        _initialLocationDetected = true;
        _showModernSnackBar(
          'Location detected successfully!',
          Icons.location_on,
          Colors.green,
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.indigo.shade400, Colors.indigoAccent.shade400],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.location_on, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              const Text('Location', style: TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
          content: Text(message, style: TextStyle(color: Colors.grey.shade700)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                backgroundColor: Colors.indigo.withOpacity(0.1),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text('OK', style: TextStyle(color: Colors.indigo.shade600, fontWeight: FontWeight.w600)),
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

      if (mounted) {
        _showModernSnackBar(
          'Location updated!',
          Icons.refresh,
          Colors.blue,
        );
      }

    } catch (e) {
      if (mounted) {
        _showModernSnackBar(
          'Failed to refresh location',
          Icons.error,
          Colors.red,
        );
      }
    }
  }

  void _showModernSnackBar(String message, IconData icon, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(

      SnackBar(
        content: Container(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.indigo.shade600,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
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
                backgroundColor: const Color(0xFFFAFAFE),


                // Enhanced AppBar
                appBar: PreferredSize(
                  preferredSize: const Size.fromHeight(80),
                  child: AnimatedBuilder(
                    animation: _appBarAnimationController,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, -20 * (1 - _appBarAnimationController.value)),
                        child: Opacity(
                          opacity: _appBarAnimationController.value,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.indigo.shade600,
                                  Colors.indigo.shade500,
                                  Colors.indigoAccent.shade400,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(24),
                                bottomRight: Radius.circular(24),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.indigo.withOpacity(0.3),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: SafeArea(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                child: Row(
                                  children: [
                                    // App Title with Icon - Very Compact
                                    Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.celebration,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    const Expanded(
                                      child: Text(
                                        'Saudi Festivals',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),

                                    // Location Menu - Ultra Compact
                                    Container(
                                      width: 32,
                                      height: 32,
                                      margin: const EdgeInsets.only(right: 20),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: PopupMenuButton<String>(
                                        padding: EdgeInsets.zero,
                                        iconSize: 16,
                                        icon: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            Icon(
                                              cacheController.hasLocationData
                                                  ? Icons.location_on
                                                  : Icons.location_off,
                                              color: Colors.white,
                                              size: 16,
                                            ),
                                            if (cacheController.hasLocationData)
                                              Positioned(
                                                right: 4,
                                                top: 4,
                                                child: Container(
                                                  width: 4,
                                                  height: 4,
                                                  decoration: const BoxDecoration(
                                                    color: Colors.greenAccent,
                                                    shape: BoxShape.circle,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                        onSelected: (value) {
                                          switch (value) {
                                            case 'refresh':
                                              _refreshLocation();
                                              break;
                                            case 'clear':
                                              cacheController.clearLocationData();
                                              _showModernSnackBar(
                                                'Location cleared',
                                                Icons.clear,
                                                Colors.orange,
                                              );
                                              break;
                                          }
                                        },
                                        itemBuilder: (context) => [
                                          PopupMenuItem(
                                            value: 'refresh',
                                            height: 40,
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(Icons.refresh, color: Colors.blue.shade600, size: 16),
                                                const SizedBox(width: 6),
                                                const Text('Refresh', style: TextStyle(fontSize: 12)),
                                              ],
                                            ),
                                          ),
                                          PopupMenuItem(
                                            value: 'clear',
                                            height: 40,
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(Icons.clear, color: Colors.red.shade600, size: 16),
                                                const SizedBox(width: 6),
                                                const Text('Clear', style: TextStyle(fontSize: 12)),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Logout Button - Ultra Compact
                                    Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: IconButton(
                                        padding: EdgeInsets.zero,
                                        iconSize: 16,
                                        icon: const Icon(
                                          Icons.power_settings_new_rounded,
                                          color: Colors.white,
                                        ),
                                        onPressed: () {
                                          _showLogoutDialog(cacheController);
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                body: home.pages[home.currentIndex],

                // Enhanced Bottom Navigation Bar
                bottomNavigationBar: AnimatedBuilder(
                  animation: _navAnimationController,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, 100 * (1 - _navAnimationController.value)),
                      child: Container(
                        margin: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.indigo.withOpacity(0.15),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: SafeArea(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildCompactNavItem(
                                  icon: Icons.home_rounded,
                                  label: 'Home',
                                  index: 0,
                                  currentIndex: home.currentIndex,
                                  onTap: () => home.buttomNavBar(0, context),
                                ),
                                _buildCompactNavItem(
                                  icon: Icons.celebration_rounded,
                                  label: 'Events',
                                  index: 1,
                                  currentIndex: home.currentIndex,
                                  onTap: () => home.buttomNavBar(1, context),
                                ),
                                _buildCompactNavItem(
                                  icon: Icons.location_on_outlined,
                                  label: 'Map',
                                  index: 2,
                                  currentIndex: home.currentIndex,
                                  onTap: () => home.buttomNavBar(2, context),

                                  hasLocationIndicator: cacheController.hasLocationData,
                                ),
                                _buildCompactNavItem(
                                  icon: Icons.bookmark_rounded,
                                  label: 'Bookings',
                                  index: 3,
                                  currentIndex: home.currentIndex,
                                  onTap: () => home.buttomNavBar(3, context),
                                ),
                                _buildCompactNavItem(
                                  icon: Icons.chat_bubble_rounded,
                                  label: 'Chats',
                                  index: 4,
                                  currentIndex: home.currentIndex,
                                  onTap: () => home.buttomNavBar(4, context),
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
          ),
        );
      },
    );
  }

  void _showLogoutDialog(CacheController cacheController) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.red.shade400, Colors.red.shade600],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.logout_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            const Text('Logout', style: TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Cancel', style: TextStyle(color: Colors.grey.shade600)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              cacheController.logout();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => LoginPage()),
                    (route) => false,
              );
            },
            style: TextButton.styleFrom(
              backgroundColor: Colors.red.withOpacity(0.1),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Logout', style: TextStyle(color: Colors.red.shade600, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactNavItem({
    required IconData icon,
    required String label,
    required int index,
    required int currentIndex,
    required VoidCallback onTap,
    bool hasLocationIndicator = false,
  }) {
    final isSelected = currentIndex == index;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.indigo.withOpacity(0.1)
                        : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: isSelected ? Colors.indigo.shade600 : Colors.grey.shade600,
                    size: 22,
                  ),
                ),

                // Location indicator for Map tab
                if (hasLocationIndicator && index == 2)
                  Positioned(
                    right: 4,
                    top: 4,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1),
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 2),

            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.indigo.shade600 : Colors.grey.shade600,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}