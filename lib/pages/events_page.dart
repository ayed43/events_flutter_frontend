import 'package:demo/constants.dart';
import 'package:demo/cubits/home_cobit/home_cubit.dart';
import 'package:demo/cubits/home_cobit/home_states.dart';
import 'package:demo/models/cache_controller/cache_controller.dart';
import 'package:demo/pages/details_page/details_page.dart';
import 'package:demo/pages/store_user_favorites.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> with TickerProviderStateMixin {
  bool _checkedFavorites = false;
  bool _showOnlyFavorites = false;
  late AnimationController _filterAnimationController;
  late Animation<double> _filterAnimation;

  @override
  void initState() {
    super.initState();
    _filterAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _filterAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _filterAnimationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _filterAnimationController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_checkedFavorites) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkFavorites();
      });
      _checkedFavorites = true;
    }
  }

  Future<void> _checkFavorites() async {
    final cache = Provider.of<CacheController>(context, listen: false);
    final isFavOpen = cache.getIsFavOpen();

    if (!isFavOpen) {
      final homeCubit = HomeCubit.get(context);

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: homeCubit,
            child: const StoreUserFavorites(),
          ),
        ),
      );
      setState(() {});
    }
  }

  void _toggleFilter() {
    setState(() {
      _showOnlyFavorites = !_showOnlyFavorites;
    });

    if (_showOnlyFavorites) {
      _filterAnimationController.forward();
    } else {
      _filterAnimationController.reverse();
    }
  }

  List<dynamic> _getFilteredEvents(List<dynamic> events, List<dynamic> userFavCategories) {
    if (_showOnlyFavorites) {
      return events.where((event) =>
          userFavCategories.contains(event.categoryName)).toList();
    }

    // Sort events: favorites first, then others
    final favoriteEvents = events.where((event) =>
        userFavCategories.contains(event.categoryName)).toList();
    final otherEvents = events.where((event) =>
    !userFavCategories.contains(event.categoryName)).toList();

    return [...favoriteEvents, ...otherEvents];
  }

  bool _isEventFavorite(dynamic event, List<dynamic> userFavCategories) {
    return userFavCategories.contains(event.categoryName);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeCubit, HomeStates>(
      builder: (context, state) {
        final events = HomeCubit.get(context).events;
        final userFavCategories = CacheController().getUserFav();
        final filteredEvents = _getFilteredEvents(events, userFavCategories);
        final favoriteCount = events.where((event) =>
            userFavCategories.contains(event.categoryName)).length;

        if (events.isEmpty) {
          return RefreshIndicator(
            onRefresh: () async {
              HomeCubit.get(context).getData();
            },
            child: const SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: SizedBox(
                height: 500,
                child: Center(child: Text('No events available')),
              ),
            ),
          );
        }

        return Column(
          children: [
            // Enhanced Filter Header
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.indigo.shade50,
                    Colors.indigoAccent.shade100,
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.indigo.withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.indigo.shade400, Colors.indigoAccent.shade400],
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.filter_list, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _showOnlyFavorites ? 'Your Favorite Events' : 'All Events',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.indigo.shade800,
                              ),
                            ),
                            Text(
                              _showOnlyFavorites
                                  ? '$favoriteCount events match your interests'
                                  : '${filteredEvents.length} total events • $favoriteCount favorites',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.indigo.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Filter Toggle Button
                      GestureDetector(
                        onTap: _toggleFilter,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            gradient: _showOnlyFavorites
                                ? LinearGradient(
                              colors: [Colors.indigo.shade500, Colors.indigoAccent.shade400],
                            )
                                : null,
                            color: _showOnlyFavorites ? null : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _showOnlyFavorites ? Colors.transparent : Colors.indigo.withOpacity(0.3),
                            ),
                            boxShadow: _showOnlyFavorites ? [
                              BoxShadow(
                                color: Colors.indigo.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ] : null,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              AnimatedRotation(
                                turns: _showOnlyFavorites ? 0.5 : 0,
                                duration: const Duration(milliseconds: 300),
                                child: Icon(
                                  _showOnlyFavorites ? Icons.favorite : Icons.favorite_border,
                                  color: _showOnlyFavorites ? Colors.white : Colors.indigo.shade600,
                                  size: 16,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _showOnlyFavorites ? 'Show All' : 'Favorites',
                                style: TextStyle(
                                  color: _showOnlyFavorites ? Colors.white : Colors.indigo.shade600,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Filter indicator
                  if (_showOnlyFavorites && favoriteCount == 0) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.orange.shade600, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'No events match your interests. Try updating your preferences!',
                              style: TextStyle(
                                color: Colors.orange.shade700,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Events List
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  HomeCubit.get(context).getData();
                },
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredEvents.length,
                  itemBuilder: (context, index) {
                    final event = filteredEvents[index];
                    final imageUrl = '$serverUrl/storage/${event.image}';
                    final date = DateFormat.yMMMMd()
                        .add_jm()
                        .format(DateTime.parse(event.startTime));
                    final isFavorite = _isEventFavorite(event, userFavCategories);

                    return InkWell(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) {
                          return DetailsPage(event);
                        }));
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: isFavorite && !_showOnlyFavorites
                              ? Border.all(color: Colors.indigo.withOpacity(0.3), width: 2)
                              : null,
                          boxShadow: [
                            BoxShadow(
                              color: isFavorite && !_showOnlyFavorites
                                  ? Colors.indigo.withOpacity(0.1)
                                  : Colors.black.withOpacity(0.1),
                              blurRadius: isFavorite && !_showOnlyFavorites ? 12 : 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Card(
                          margin: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Event Image with Favorite Badge
                              Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(16)),
                                    child: Image.network(
                                      imageUrl,
                                      height: 180,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) =>
                                          Container(
                                            height: 180,
                                            color: Colors.grey.shade200,
                                            child:
                                            const Icon(Icons.broken_image, size: 60),
                                          ),
                                    ),
                                  ),

                                  // Favorite Badge
                                  if (isFavorite)
                                    Positioned(
                                      top: 12,
                                      right: 12,
                                      child: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [Colors.indigo.shade400, Colors.indigoAccent.shade400],
                                          ),
                                          borderRadius: BorderRadius.circular(20),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.indigo.withOpacity(0.3),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(Icons.favorite, color: Colors.white, size: 14),
                                            const SizedBox(width: 4),
                                            Text(
                                              'Preferred',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                ],
                              ),

                              // Event Info
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Title with Category
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            event.name,
                                            style: const TextStyle(
                                                fontSize: 20, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        if (event.categoryName != null) ...[
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: isFavorite
                                                  ? Colors.indigo.withOpacity(0.1)
                                                  : Colors.grey.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              event.categoryName,
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w600,
                                                color: isFavorite
                                                    ? Colors.indigo.shade600
                                                    : Colors.grey.shade600,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 8),

                                    // Description
                                    Text(
                                      event.description,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(color: Colors.black87),
                                    ),
                                    const SizedBox(height: 12),

                                    // Date and location
                                    Row(
                                      children: [
                                        const Icon(Icons.calendar_today,
                                            size: 16, color: Colors.grey),
                                        const SizedBox(width: 4),
                                        Text(date, style: const TextStyle(fontSize: 14)),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        const Icon(Icons.location_on,
                                            size: 16, color: Colors.grey),
                                        const SizedBox(width: 4),
                                        Text('City ID: ${event.cityName}',
                                            style: const TextStyle(fontSize: 14)),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        const Icon(Icons.event_seat,
                                            size: 16, color: Colors.grey),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${event.availableSeats} / ${event.capacity} seats available',
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),

                                    // Booking status
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            gradient: event.booked
                                                ? null
                                                : const LinearGradient(
                                              colors: [
                                                Colors.indigo,
                                                Colors.indigoAccent
                                              ],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                            color: event.booked
                                                ? Colors.green.shade100
                                                : null,
                                            borderRadius: BorderRadius.circular(20),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(0.05),
                                                blurRadius: 4,
                                                offset: const Offset(2, 2),
                                              )
                                            ],
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 6),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  event.booked
                                                      ? Icons.check_circle_rounded
                                                      : Icons.circle,
                                                  color: event.booked
                                                      ? Colors.green
                                                      : Colors.white,
                                                  size: 16,
                                                ),
                                                const SizedBox(width: 6),
                                                Text(
                                                  event.booked ? 'Booked' : 'Available',
                                                  style: TextStyle(
                                                    color: event.booked
                                                        ? Colors.green.shade700
                                                        : Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
      listener: (context, state) {},
    );
  }
}