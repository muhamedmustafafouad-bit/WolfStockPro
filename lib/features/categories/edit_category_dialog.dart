import 'package:flutter/material.dart';

import '../../models/category_model.dart';
import '../../repositories/category_repository.dart';

class EditCategoryDialog extends StatefulWidget {
  final CategoryModel category;

  const EditCategoryDialog({
    super.key,
    required this.category,
  });

  @override
  State<EditCategoryDialog> createState() =>
      _EditCategoryDialogState();
}

class _EditCategoryDialogState
    extends State<EditCategoryDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _descriptionController;

  final CategoryRepository _repository =
      CategoryRepository();

  @override
  void initState() {
    super.initState();

    _nameController =
        TextEditingController(text: widget.category.name);

    _descriptionController =
        TextEditingController(
      text: widget.category.description ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    await _repository.updateCategory(
      CategoryModel(
        id: widget.category.id,
        name: _nameController.text.trim(),
        description:
            _descriptionController.text.trim(),
      ),
    );

    if (!mounted) return;

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Edit Category"),

      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "Category Name",
              ),
              validator: (v) =>
                  v == null || v.isEmpty
                      ? "Required"
                      : null,
            ),

            const SizedBox(height: 12),

            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: "Description",
              ),
            ),
          ],
        ),
      ),

      actions: [
        TextButton(
          onPressed: () =>
              Navigator.pop(context),
          child: const Text("Cancel"),
        ),

        FilledButton(
          onPressed: _save,
          child: const Text("Save"),
        ),
      ],
    );
  }
}
