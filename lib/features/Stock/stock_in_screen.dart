import 'package:flutter/material.dart';

import '../../models/stock_movement_model.dart';
import '../../models/product_model.dart';
import '../../repositories/stock_repository.dart';
import '../../repositories/product_repository.dart';

class StockInScreen extends StatefulWidget {
  const StockInScreen({super.key});

  @override
  State<StockInScreen> createState() => _StockInScreenState();
}

class _StockInScreenState extends State<StockInScreen> {
  final StockRepository _stockRepository = StockRepository();
  final ProductRepository _productRepository = ProductRepository();

  final _qtyController = TextEditingController();
  final _referenceController = TextEditingController();
  final _notesController = TextEditingController();

  List<ProductModel> _products = [];

  int? _selectedProductId;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final products = await _productRepository.getProducts();

    if (!mounted) return;

    setState(() {
      _products = products;
    });
  }

  @override
  void dispose() {
    _qtyController.dispose();
    _referenceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveStock() async {
    if (_selectedProductId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Select a product"),
        ),
      );
      return;
    }

    final qty = double.tryParse(_qtyController.text) ?? 0;

    if (qty <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Invalid quantity"),
        ),
      );
      return;
    }

    setState(() {
      _saving = true;
    });

    await _stockRepository.addMovement(
      StockMovementModel(
        productId: _selectedProductId!,
        branchId: 1,
        movementType: "IN",
        quantity: qty,
        referenceNo: _referenceController.text,
        notes: _notesController.text,
        createdAt: DateTime.now(),
      ),
    );

    if (!mounted) return;

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Stock In"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 10),

          DropdownButtonFormField<int>(
            value: _selectedProductId,
            items: _products.map((product) {
              return DropdownMenuItem<int>(
                value: product.id,
                child: Text(product.name),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedProductId = value;
              });
            },
            decoration: const InputDecoration(
              labelText: "Product",
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 15),

          TextField(
            controller: _qtyController,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
            ),
            decoration: const InputDecoration(
              labelText: "Quantity",
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 15),

          TextField(
            controller: _referenceController,
            decoration: const InputDecoration(
              labelText: "Invoice No",
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 15),

          TextField(
            controller: _notesController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: "Notes",
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 25),

          FilledButton.icon(
            icon: const Icon(Icons.save),
            label: const Text("SAVE STOCK"),
            onPressed: _saving ? null : _saveStock,
          ),
        ],
      ),
    );
  }
}
