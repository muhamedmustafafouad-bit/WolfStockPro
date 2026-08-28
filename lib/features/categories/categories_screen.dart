import 'package:flutter/material.dart';

import '../../models/category_model.dart';
import '../../repositories/category_repository.dart';
import 'add_category_dialog.dart';
import 'edit_category_dialog.dart';

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
    setState(() {
      _loading = true;
    });

    try {
      final data = await _repository.getCategories();

      if (!mounted) return;

      setState(() {
        _categories = data;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to load categories: $e',
          ),
        ),
      );
    }
  }

  Future<void> _addCategory() async {
    final added = await showDialog<bool>(
      context: context,
      builder: (_) => const AddCategoryDialog(),
    );

    if (added == true) {
      await _loadCategories();
    }
  }

  Future<void> _editCategory(CategoryModel category) async {
    final edited = await showDialog<bool>(
      context: context,
      builder: (_) => EditCategoryDialog(
        category: category,
      ),
    );

    if (edited == true) {
      await _loadCategories();
    }
  }

  Future<void> _deleteCategory(CategoryModel category) async {
    if (category.id == null) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Category'),
          content: Text(
            'Are you sure you want to delete "${category.name}"?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('CANCEL'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('DELETE'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    try {
      await _repository.deleteCategory(
        category.id!,
      );

      await _loadCategories();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to delete category: $e',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Categories',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _loadCategories,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: _addCategory,
        child: const Icon(Icons.add),
      ),

      body: _loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _categories.isEmpty
              ? RefreshIndicator(
                  onRefresh: _loadCategories,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: const [
                      SizedBox(height: 250),
                      Center(
                        child: Text(
                          'No categories found.',
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadCategories,
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(
                      top: 8,
                      bottom: 100,
                    ),
                    itemCount: _categories.length,
                    separatorBuilder: (_, __) {
                      return const Divider(
                        height: 1,
                      );
                    },
                    itemBuilder: (context, index) {
                      final category = _categories[index];

                      return ListTile(
                        leading: const CircleAvatar(
                          child: Icon(
                            Icons.category_outlined,
                          ),
                        ),

                        title: Text(
                          category.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        subtitle: category.description == null ||
                                category.description!.trim().isEmpty
                            ? null
                            : Text(
                                category.description!,
                              ),

                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              tooltip: 'Edit',
                              icon: const Icon(
                                Icons.edit_outlined,
                              ),
                              onPressed: () {
                                _editCategory(category);
                              },
                            ),

                            IconButton(
                              tooltip: 'Delete',
                              icon: const Icon(
                                Icons.delete_outline,
                              ),
                              onPressed: () {
                                _deleteCategory(category);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
