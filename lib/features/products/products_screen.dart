import 'package:flutter/material.dart';

import '../../models/product_model.dart';
import '../../repositories/product_repository.dart';

class ProductsScreen extends StatefulWidget {
  final int branchId;

  const ProductsScreen({
    super.key,
    this.branchId = 1,
  });

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final ProductRepository _repository = ProductRepository();

  final TextEditingController _searchController =
      TextEditingController();

  List<ProductModel> _products = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _loading = true;
    });

    try {
      final products = await _repository.getProducts(
        branchId: widget.branchId,
      );

      if (!mounted) return;

      setState(() {
        _products = products;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
      });

      _showMessage(
        'Unable to load products.',
        isError: true,
      );
    }
  }

  Future<void> _search(String value) async {
    if (value.trim().isEmpty) {
      await _loadProducts();
      return;
    }

    try {
      final results = await _repository.searchProducts(
        value,
        branchId: widget.branchId,
      );

      if (!mounted) return;

      setState(() {
        _products = results;
      });
    } catch (e) {
      _showMessage(
        'Search failed.',
        isError: true,
      );
    }
  }

  Future<void> _deleteProduct(ProductModel product) async {
    if (product.id == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Product'),
          content: Text(
            'Are you sure you want to remove "${product.name}"?',
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

    if (confirmed != true) return;

    await _repository.deleteProduct(product.id!);

    await _loadProducts();

    _showMessage('Product removed.');
  }

  void _showMessage(
    String message, {
    bool isError = false,
  }) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            isError ? Colors.redAccent : null,
      ),
    );
  }

  Color _stockColor(
    BuildContext context,
    ProductModel product,
  ) {
    if (product.isOutOfStock) {
      return Colors.redAccent;
    }

    if (product.isLowStock) {
      return Colors.orangeAccent;
    }

    return Theme.of(context).colorScheme.primary;
  }

  String _stockLabel(ProductModel product) {
    if (product.isOutOfStock) {
      return 'OUT OF STOCK';
    }

    if (product.isLowStock) {
      return 'LOW STOCK';
    }

    return 'IN STOCK';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Products',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _loadProducts,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showMessage(
            'Add Product screen is next.',
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Product'),
      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              16,
              16,
              16,
              8,
            ),
            child: TextField(
              controller: _searchController,
              onChanged: _search,
              decoration: InputDecoration(
                hintText: 'Search name, SKU or barcode...',
                prefixIcon: const Icon(
                  Icons.search,
                ),
                suffixIcon:
                    _searchController.text.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              _searchController.clear();
                              _loadProducts();
                              setState(() {});
                            },
                            icon: const Icon(
                              Icons.clear,
                            ),
                          )
                        : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),

          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : _products.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _loadProducts,
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(
                            12,
                            8,
                            12,
                            100,
                          ),
                          itemCount: _products.length,
                          itemBuilder: (context, index) {
                            return _buildProductCard(
                              _products[index],
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 80,
              color: Colors.grey.shade600,
            ),

            const SizedBox(height: 20),

            const Text(
              'No Products',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Your inventory is currently empty.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade500,
              ),
            ),

            const SizedBox(height: 24),

            FilledButton.icon(
              onPressed: () {
                _showMessage(
                  'Add Product screen is next.',
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Add First Product'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(
    ProductModel product,
  ) {
    final stockColor = _stockColor(
      context,
      product,
    );

    return Card(
      margin: const EdgeInsets.only(
        bottom: 10,
      ),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest,
                borderRadius:
                    BorderRadius.circular(12),
              ),
              child: product.imagePath != null &&
                      product.imagePath!.isNotEmpty
                  ? ClipRRect(
                      borderRadius:
                          BorderRadius.circular(12),
                      child: Image.asset(
                        product.imagePath!,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (_, __, ___) {
                          return const Icon(
                            Icons.inventory_2,
                            size: 30,
                          );
                        },
                      ),
                    )
                  : const Icon(
                      Icons.inventory_2,
                      size: 30,
                    ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow:
                        TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 5),

                  if (product.sku != null &&
                      product.sku!.isNotEmpty)
                    Text(
                      'SKU: ${product.sku}',
                      style: TextStyle(
                        fontSize: 12,
                        color:
                            Colors.grey.shade500,
                      ),
                    ),

                  if (product.barcode != null &&
                      product.barcode!.isNotEmpty)
                    Text(
                      'Barcode: ${product.barcode}',
                      style: TextStyle(
                        fontSize: 12,
                        color:
                            Colors.grey.shade500,
                      ),
                    ),

                  const SizedBox(height: 7),

                  Row(
                    children: [
                      Text(
                        '${product.quantity} ${product.unit}',
                        style: TextStyle(
                          fontWeight:
                              FontWeight.bold,
                          color: stockColor,
                        ),
                      ),

                      const SizedBox(width: 8),

                      Container(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: stockColor
                              .withOpacity(0.12),
                          borderRadius:
                              BorderRadius.circular(
                            6,
                          ),
                        ),
                        child: Text(
                          _stockLabel(product),
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight:
                                FontWeight.bold,
                            color: stockColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  _showMessage(
                    'Edit Product is next.',
                  );
                }

                if (value == 'delete') {
                  _deleteProduct(product);
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: 'edit',
                  child: ListTile(
                    leading: Icon(
                      Icons.edit_outlined,
                    ),
                    title: Text('Edit'),
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: ListTile(
                    leading: Icon(
                      Icons.delete_outline,
                    ),
                    title: Text('Delete'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
