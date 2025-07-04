import 'package:demo/cubits/home_cobit/home_cubit.dart';
import 'package:demo/cubits/home_cobit/home_states.dart';
import 'package:demo/models/cache_controller/cache_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

class StoreUserFavorites extends StatelessWidget {
  const StoreUserFavorites({super.key});

  @override
  Widget build(BuildContext context) {
    final cache = Provider.of<CacheController>(context, listen: false);
    final Set<String> selectedCategoryNames = {};

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
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.indigo.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.indigo.withOpacity(0.2)),
                              ),
                              child: Text(
                                '${selectedCategoryNames.length} selected',
                                style: TextStyle(
                                  color: selectedCategoryNames.isEmpty
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
                            itemCount: categories.length,
                            itemBuilder: (context, index) {
                              final category = categories[index];
                              final name = category.name ?? '';
                              final isSelected = selectedCategoryNames.contains(name);

                              return GestureDetector(
                                onTap: () {
                                  setInnerState(() {
                                    if (isSelected) {
                                      selectedCategoryNames.remove(name);
                                    } else {
                                      selectedCategoryNames.add(name);
                                    }
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
                            gradient: selectedCategoryNames.isNotEmpty
                                ? LinearGradient(
                              colors: [
                                Colors.indigo.shade400,
                                Colors.indigoAccent.shade400,
                              ],
                            )
                                : null,
                            color: selectedCategoryNames.isEmpty
                                ? Colors.indigo.withOpacity(0.1)
                                : null,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: selectedCategoryNames.isNotEmpty
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
                              onTap: selectedCategoryNames.isEmpty
                                  ? null
                                  : () {
                                cache.setUserFav(selectedCategoryNames.toList());
                                cache.setIsFavOpen(true);

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
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      selectedCategoryNames.isEmpty
                                          ? 'Select at least one interest'
                                          : 'Continue with ${selectedCategoryNames.length} interest${selectedCategoryNames.length == 1 ? '' : 's'}',
                                      style: TextStyle(
                                        color: selectedCategoryNames.isEmpty
                                            ? Colors.indigo.shade400
                                            : Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    if (selectedCategoryNames.isNotEmpty) ...[
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
            },
          );
        },
      ),
    );
  }
}