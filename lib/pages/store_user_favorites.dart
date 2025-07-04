import 'package:demo/cubits/home_cobit/home_cubit.dart';
import 'package:demo/models/cache_controller/cache_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class StoreUserFavorites extends StatefulWidget {
  const StoreUserFavorites({Key? key}) : super(key: key);

  @override
  _StoreUserFavoritesState createState() => _StoreUserFavoritesState();
}

class _StoreUserFavoritesState extends State<StoreUserFavorites> {
  final Set<int> _selectedCategoryIds = {};

  @override
  Widget build(BuildContext context) {
    final categories = HomeCubit.get(context).categories;
    final cache = Provider.of<CacheController>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Your Interests'),
      ),
      body: categories == null || categories.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = _selectedCategoryIds.contains(category.id);

          return ListTile(
            title: Text(category.name!),
            trailing: Icon(
              isSelected
                  ? Icons.check_circle
                  : Icons.radio_button_unchecked,
              color: isSelected ? Colors.green : Colors.grey,
            ),
            onTap: () {
              setState(() {
                if (isSelected) {
                  _selectedCategoryIds.remove(category.id);
                } else {
                  _selectedCategoryIds.add(category.id!);
                }
              });
            },
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          child: const Text('Finish'),
          onPressed: () {
            // Save to Hive
            cache.setUserFav(_selectedCategoryIds.toList());
            cache.setIsFavOpen(true);

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Preferences saved successfully')),
            );

            Navigator.pop(context); // Or navigate somewhere else
          },
        ),
      ),
    );
  }
}
