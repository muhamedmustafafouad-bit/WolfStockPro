import 'package:flutter/material.dart';

import '../../models/stock_movement_model.dart';
import '../../repositories/stock_repository.dart';

class StockHistoryScreen extends StatefulWidget {
  const StockHistoryScreen({super.key});

  @override
  State<StockHistoryScreen> createState() =>
      _StockHistoryScreenState();
}

class _StockHistoryScreenState
    extends State<StockHistoryScreen> {

  final StockRepository _repository =
      StockRepository();

  List<StockMovementModel> _history = [];

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final data = await _repository.getHistory();

    if (!mounted) return;

    setState(() {
      _history = data;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Stock History"),
      ),

      body: _loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: _history.length,
              itemBuilder: (context, index) {

                final item = _history[index];

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),

                  child: ListTile(

                    leading: CircleAvatar(
                      child: Text(
                        item.movementType,
                      ),
                    ),

                    title: Text(
                      "Product ID: ${item.productId}",
                    ),

                    subtitle: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [

                        Text(
                          "Qty : ${item.quantity}",
                        ),

                        Text(
                          item.createdAt
                              .toString(),
                        ),

                        if (item.referenceNo != null)
                          Text(
                            item.referenceNo!,
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
