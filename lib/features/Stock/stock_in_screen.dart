import 'package:flutter/material.dart';

class StockInScreen extends StatefulWidget {
  const StockInScreen({super.key});

  @override
  State<StockInScreen> createState() => _StockInScreenState();
}

class _StockInScreenState extends State<StockInScreen> {

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
            items: const [],
            onChanged: (v) {},
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
            onPressed: () {

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Next step: Save to SQLite"),
                ),
              );

            },
          )
        ],
      ),
    );
  }
}
