import '../../models/category_model.dart';
import '../../repositories/category_repository.dart';
import 'package:flutter/material.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final CategoryRepository _repository = CategoryRepository();

  List<CategoryModel> _categories = [];

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final data = await _repository.getCategories();

    if (!mounted) return;

    setState(() {
      _categories = data;
      _loading = false;
    });
  }
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Add Category (Coming Soon)"),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: _loading
    ? const Center(
        child: CircularProgressIndicator(),
      )
    : ListView.builder(
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];

          return ListTile(
            leading: const Icon(Icons.category),

            title: Text(category.name),

            subtitle: Text(
              category.description ?? '',
            ),

            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
                if (category.id != null) {
                  await _repository.deleteCategory(
                    category.id!,
                  );

                  _loadCategories();
                }
              },
            ),
          );
        },
      )
    );
  }
}
