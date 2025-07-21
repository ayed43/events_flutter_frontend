import 'package:demo/cubits/home_cobit/home_cubit.dart';
import 'package:demo/cubits/home_cobit/home_states.dart';
import 'package:demo/models/cache_controller/cache_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../constants.dart';

class StoreUserFavorites extends StatelessWidget {
  const StoreUserFavorites({super.key});

  @override
  Widget build(BuildContext context) {
    final cache = Provider.of<CacheController>(context, listen: false);

    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.indigo.withOpacity(0.2)),
            boxShadow: [
              BoxShadow(
                color: Colors.indigo.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(Icons.arrow_back_ios_new, color: Colors.indigo.shade700, size: 18),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: Text(
          'Choose Your Interests',
          style: TextStyle(
            color: Colors.indigo.shade800,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocConsumer<HomeCubit, HomeStates>(
        listener: (context, state) {},
        builder: (context, state) {
          final categories = HomeCubit.get(context).categories;

          if (state is! SuccessState || categories == null || categories.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.indigo.withOpacity(0.1),
                          Colors.indigoAccent.withOpacity(0.1),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.indigo.withOpacity(0.2)),
                    ),
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.indigo.shade600),
                      strokeWidth: 3,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Loading your interests...',
                    style: TextStyle(
                      color: Colors.indigo.shade600,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }

          return StatefulBuilder(
            builder: (context, setInnerState) {
              return _FavoriteSelector(categories: categories, cache: cache);
            },
          );
        },
      ),
    );
  }
}

class _FavoriteSelector extends StatefulWidget {
  final List categories;
  final CacheController cache;

  const _FavoriteSelector({
    required this.categories,
    required this.cache,
  });

  @override
  State<_FavoriteSelector> createState() => _FavoriteSelectorState();
}

class _FavoriteSelectorState extends State<_FavoriteSelector> {
  late Map<int, bool> selectedCategories;
  late Map<String, dynamic> favoriteData;

  @override
  void initState() {
    super.initState();

    // Initialize selected categories from the categories list based on isFav flag
    selectedCategories = {};
    favoriteData = {};

    // Initialize based on existing isFav flags
    for (var category in widget.categories) {
      if (category.id != null) {
        selectedCategories[category.id!] = category.isFav ?? false;
      }
    }

    updateFavoriteData();
  }

  // Helper function to update favorite data for server
  void updateFavoriteData() {
    favoriteData.clear();
    selectedCategories.forEach((categoryId, isSelected) {
      if (isSelected) {
        favoriteData[categoryId.toString()] = {
          'user_id': widget.cache.getCurrentUserId(),
          'category_id': categoryId,
        };
      }
    });
  }

  // API call to save favorites to server
  Future<bool> saveFavoritesToServer() async {
    try {
      // Get selected category IDs
      final selectedCategoryIds = selectedCategories.entries
          .where((entry) => entry.value)
          .map((entry) => entry.key)
          .toList();

      if (selectedCategoryIds.isEmpty) {
        return false;
      }

      // Get user token
      final token = widget.cache.token;
      if (token == null) {
        print('No token available');
        return false;
      }

      // Prepare the request
      final url = Uri.parse('$serverUrl/api/favorites/categories');
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final body = json.encode({
        'category_ids': selectedCategoryIds,
      });

      print('Sending request to: $url');
      print('Request body: $body');

      // Make the API call
      final response = await http.post(
        url,
        headers: headers,
        body: body,
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print('Success: ${responseData['message']}');
        return true;
      } else {
        print('Error: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Exception occurred: $e');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get count of selected categories
    int selectedCount = selectedCategories.values
        .where((selected) => selected)
        .length;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white,
            Color(0xFFF8F9FF),
            Color(0xFFF3F4FF),
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Header section
            Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.indigo.shade400,
                          Colors.indigoAccent.shade400,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(47),
                      ),
                      child: Icon(
                        Icons.favorite_rounded,
                        size: 40,
                        color: Colors.indigo.shade600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'What sparks your interest?',
                    style: TextStyle(
                      color: Colors.indigo.shade700,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.indigo.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.indigo.withOpacity(0.2)),
                    ),
                    child: Text(
                      '$selectedCount selected',
                      style: TextStyle(
                        color: selectedCount == 0
                            ? Colors.indigo.shade400
                            : Colors.indigo.shade600,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Categories grid
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GridView.builder(
                  physics: const BouncingScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.3,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: widget.categories.length,
                  itemBuilder: (context, index) {
                    final category = widget.categories[index];
                    final name = category.name ?? '';
                    final categoryId = category.id;

                    if (categoryId == null) return const SizedBox.shrink();

                    final isSelected = selectedCategories[categoryId] ?? false;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedCategories[categoryId] = !isSelected;
                          updateFavoriteData();
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOutCubic,
                        decoration: BoxDecoration(
                          gradient: isSelected
                              ? LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.indigo.shade400,
                              Colors.indigoAccent.shade400,
                            ],
                          )
                              : null,
                          color: isSelected ? null : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? Colors.transparent
                                : Colors.indigo.withOpacity(0.2),
                            width: 1,
                          ),
                          boxShadow: [
                            if (isSelected)
                              BoxShadow(
                                color: Colors.indigo.withOpacity(0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            if (!isSelected)
                              BoxShadow(
                                color: Colors.indigo.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                          ],
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Colors.white.withOpacity(0.3)
                                      : Colors.indigo.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Icon(
                                  isSelected
                                      ? Icons.check_circle_rounded
                                      : Icons.circle_outlined,
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.indigo.shade600,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                name,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.indigo.shade700,
                                  fontSize: 14,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w500,
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

            // Bottom button
            Container(
              padding: const EdgeInsets.all(20),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: selectedCount > 0
                      ? LinearGradient(
                    colors: [
                      Colors.indigo.shade400,
                      Colors.indigoAccent.shade400,
                    ],
                  )
                      : null,
                  color: selectedCount == 0
                      ? Colors.indigo.withOpacity(0.1)
                      : null,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: selectedCount > 0
                      ? [
                    BoxShadow(
                      color: Colors.indigo.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ]
                      : null,
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: selectedCount == 0
                        ? null
                        : () async {
                      // Show loading indicator
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) {
                          return Center(
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.indigo.shade600),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Saving your preferences...',
                                    style: TextStyle(
                                      color: Colors.indigo.shade700,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );

                      // Update favorite data before saving
                      updateFavoriteData();

                      // Save to server first
                      bool serverSuccess = await saveFavoritesToServer();

                      // Close loading dialog
                      Navigator.of(context).pop();

                      if (serverSuccess) {
                        // Save to local cache only if server request was successful
                        widget.cache.setUserFavoriteData(favoriteData);

                        // Also save selected category IDs for backward compatibility
                        final selectedCategoryIds = selectedCategories.entries
                            .where((entry) => entry.value)
                            .map((entry) => entry.key)
                            .toList();
                        widget.cache.setUserFavoriteCategoryIds(
                            selectedCategoryIds);

                        // Mark favorites as completed (won't show this page again)
                        widget.cache.markFavoritesCompleted();

                        // Show success message
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.check_circle_outline,
                                    color: Colors.green.shade600,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Preferences saved successfully',
                                  style: TextStyle(
                                    color: Colors.green.shade700,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            backgroundColor: Colors.green.shade50,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: Colors.green.shade200),
                            ),
                          ),
                        );

                        Navigator.pop(context);
                      } else {
                        // Show error message
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.error_outline,
                                    color: Colors.red.shade600,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Failed to save preferences. Please try again.',
                                  style: TextStyle(
                                    color: Colors.red.shade700,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            backgroundColor: Colors.red.shade50,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: Colors.red.shade200),
                            ),
                          ),
                        );
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            selectedCount == 0
                                ? 'Select at least one interest'
                                : 'Continue with $selectedCount interest${selectedCount ==
                                1 ? '' : 's'}',
                            style: TextStyle(
                              color: selectedCount == 0
                                  ? Colors.indigo.shade400
                                  : Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (selectedCount > 0) ...[
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.arrow_forward_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }}