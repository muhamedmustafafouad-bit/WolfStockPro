import 'package:flutter/material.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Categories"),
      ),
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
      body: const Center(
        child: Text(
          "No Categories Yet",
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
