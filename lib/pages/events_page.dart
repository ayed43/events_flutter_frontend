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
  String? _selectedCategoryId; // null means "All Categories"
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

  List<dynamic> _getFilteredEvents(List<dynamic> events, List<dynamic> userFavCategories, List<dynamic> categories) {
    List<dynamic> filteredEvents = events;

    // First filter by category if selected
    if (_selectedCategoryId != null) {
      filteredEvents = events.where((event) =>
      event.categoryId.toString() == _selectedCategoryId).toList();
    }

    // Then apply favorites filter
    if (_showOnlyFavorites) {
      return filteredEvents.where((event) =>
          userFavCategories.contains(_getCategoryNameById(event.categoryId, categories))).toList();
    }

    // Sort events: favorites first, then others (only if no category filter)
    if (_selectedCategoryId == null) {
      final favoriteEvents = filteredEvents.where((event) =>
          userFavCategories.contains(_getCategoryNameById(event.categoryId, categories))).toList();
      final otherEvents = filteredEvents.where((event) =>
      !userFavCategories.contains(_getCategoryNameById(event.categoryId, categories))).toList();

      return [...favoriteEvents, ...otherEvents];
    }

    return filteredEvents;
  }

  bool _isEventFavorite(dynamic event, List<dynamic> userFavCategories, List<dynamic> categories) {
    return userFavCategories.contains(_getCategoryNameById(event.categoryId, categories));
  }

  String _getCategoryNameById(int categoryId, List<dynamic> categories) {
    try {
      final category = categories.firstWhere((cat) => cat.id == categoryId);
      return category.name ?? '';
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeCubit, HomeStates>(
      builder: (context, state) {
        final events = HomeCubit.get(context).events;
        final categories = HomeCubit.get(context).categories ?? [];
        final userFavCategories = CacheController().getUserFav();
        final filteredEvents = _getFilteredEvents(events, userFavCategories, categories);
        final favoriteCount = events.where((event) =>
            userFavCategories.contains(_getCategoryNameById(event.categoryId, categories))).length;

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
                              _getFilterStatusText(filteredEvents.length, favoriteCount),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.indigo.shade800,
                              ),
                            ),
                            Text(
                              _getFilterSubtitleText(events.length, filteredEvents.length, favoriteCount),
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

                  const SizedBox(height: 16),

                  // Category Filter Dropdown
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.indigo.withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.category_outlined, color: Colors.indigo.shade600, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Category:',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.indigo.shade700,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedCategoryId,
                              isExpanded: true,
                              hint: Text(
                                'All Categories',
                                style: TextStyle(
                                  color: Colors.indigo.shade400,
                                  fontSize: 14,
                                ),
                              ),
                              style: TextStyle(
                                color: Colors.indigo.shade800,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              icon: Icon(Icons.expand_more, color: Colors.indigo.shade400),
                              items: [
                                DropdownMenuItem<String>(
                                  value: null,
                                  child: Row(
                                    children: [
                                      Icon(Icons.all_inclusive, color: Colors.indigo.shade400, size: 18),
                                      const SizedBox(width: 8),
                                      const Text('All Categories'),
                                    ],
                                  ),
                                ),
                                ...categories.map<DropdownMenuItem<String>>((category) {
                                  final isUserFavorite = userFavCategories.contains(category.name);
                                  return DropdownMenuItem<String>(
                                    value: category.id.toString(),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: isUserFavorite
                                                ? Colors.indigo.withOpacity(0.1)
                                                : Colors.grey.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Icon(
                                            isUserFavorite ? Icons.favorite : Icons.category,
                                            color: isUserFavorite
                                                ? Colors.indigo.shade600
                                                : Colors.grey.shade600,
                                            size: 14,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            category.name ?? 'Unknown',
                                            style: TextStyle(
                                              fontWeight: isUserFavorite ? FontWeight.w600 : FontWeight.normal,
                                            ),
                                          ),
                                        ),
                                        if (isUserFavorite)
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: Colors.indigo.shade100,
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              'Fav',
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.indigo.shade600,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ],
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedCategoryId = newValue;
                                });
                              },
                            ),
                          ),
                        ),

                        // Clear category filter button
                        if (_selectedCategoryId != null)
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedCategoryId = null;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Icon(
                                Icons.clear,
                                color: Colors.red.shade600,
                                size: 16,
                              ),
                            ),
                          ),
                      ],
                    ),
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

                  if (_selectedCategoryId != null && filteredEvents.isEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.filter_list_off, color: Colors.blue.shade600, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'No events found for this category. Try selecting a different category.',
                              style: TextStyle(
                                color: Colors.blue.shade700,
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
                    final isFavorite = _isEventFavorite(event, userFavCategories, categories);
                    final categoryName = _getCategoryNameById(event.categoryId, categories);

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
                                        if (categoryName.isNotEmpty) ...[
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: isFavorite
                                                  ? Colors.indigo.withOpacity(0.1)
                                                  : Colors.grey.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              categoryName,
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

  String _getFilterStatusText(int filteredCount, int favoriteCount) {
    if (_selectedCategoryId != null && _showOnlyFavorites) {
      return 'Favorite Events in Category';
    } else if (_selectedCategoryId != null) {
      return 'Events by Category';
    } else if (_showOnlyFavorites) {
      return 'Your Favorite Events';
    } else {
      return 'All Events';
    }
  }

  String _getFilterSubtitleText(int totalEvents, int filteredCount, int favoriteCount) {
    if (_selectedCategoryId != null && _showOnlyFavorites) {
      return '$filteredCount favorite events in this category';
    } else if (_selectedCategoryId != null) {
      return '$filteredCount events in this category';
    } else if (_showOnlyFavorites) {
      return '$favoriteCount events match your interests';
    } else {
      return '$filteredCount total events • $favoriteCount favorites';
    }
  }
}
