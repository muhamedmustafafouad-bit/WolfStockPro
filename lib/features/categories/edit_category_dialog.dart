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

class _EditCategoryDialogState extends State<EditCategoryDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;

  final CategoryRepository _repository = CategoryRepository();

  bool _saving = false;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(
      text: widget.category.name,
    );

    _descriptionController = TextEditingController(
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
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (widget.category.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to update category: invalid category ID.',
          ),
        ),
      );
      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      await _repository.updateCategory(
        CategoryModel(
          id: widget.category.id,
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
        ),
      );

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _saving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to update category: $e',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Edit Category',
      ),

      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Category Name',
                  hintText: 'Enter category name',
                  prefixIcon: Icon(
                    Icons.category_outlined,
                  ),
                ),
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return 'Category name is required';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 12),

              TextFormField(
                controller: _descriptionController,
                textInputAction: TextInputAction.done,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Optional description',
                  prefixIcon: Icon(
                    Icons.description_outlined,
                  ),
                  alignLabelWithHint: true,
                ),
              ),
            ],
          ),
        ),
      ),

      actions: [
        TextButton(
          onPressed: _saving
              ? null
              : () {
                  Navigator.pop(context, false);
                },
          child: const Text(
            'Cancel',
          ),
        ),

        FilledButton.icon(
          onPressed: _saving ? null : _save,
          icon: _saving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
              : const Icon(
                  Icons.save_outlined,
                ),
          label: Text(
            _saving ? 'Saving...' : 'Save',
          ),
        ),
      ],
    );
  }
}
