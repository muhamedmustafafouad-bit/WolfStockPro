import '../../models/stock_movement_model.dart';
import '../../repositories/stock_repository.dart';
import '../../repositories/product_repository.dart';
import '../../models/product_model.dart';
import 'package:flutter/material.dart';

class StockInScreen extends StatefulWidget {
  const StockInScreen({super.key});

  @override
  State<StockInScreen> createState() => _StockInScreenState();
}

class _StockInScreenState extends State<StockInScreen> {

  final StockRepository _stockRepository = StockRepository();
final ProductRepository _productRepository = ProductRepository();

List<ProductModel> _products = [];

int? _selectedProductId;

bool _saving = false;
  final _qtyController = TextEditingController();

  final _referenceController = TextEditingController();

  final _notesController = TextEditingController();

  @override
  void dispose() {
    _qtyController.dispose();
    _referenceController.dispose();
    _notesController.dispose();
    super.dispose();
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
            items: _products.map((product) {
  return DropdownMenuItem(
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
            ),
          ),

          const SizedBox(height: 15),

          TextField(
            controller: _qtyController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: "Quantity",
            ),
          ),

          const SizedBox(height: 15),

          TextField(
            controller: _referenceController,
            decoration: const InputDecoration(
              labelText: "Invoice No",
            ),
          ),

          const SizedBox(height: 15),

          TextField(
            controller: _notesController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: "Notes",
            ),
          ),

          const SizedBox(height: 25),

          FilledButton.icon(
            icon: const Icon(Icons.save),
            label: const Text("SAVE STOCK"),
            onPressed: _saving
    ? null
    : () async {

        if (_selectedProductId == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Select a product"),
            ),
          );
          return;
        }

        final qty =
            double.tryParse(_qtyController.text) ?? 0;

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
      },
            },
          )
        ],
      ),
    );
  }
}
