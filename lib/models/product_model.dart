class ProductModel {
  final int? id;
  final String? barcode;
  final String? sku;
  final String name;
  final String? description;
  final int? categoryId;
  final int? supplierId;
  final String unit;
  final double costPrice;
  final double sellingPrice;
  final double minimumStock;
  final String? imagePath;
  final bool active;
  final double quantity;

  ProductModel({
    this.id,
    this.barcode,
    this.sku,
    required this.name,
    this.description,
    this.categoryId,
    this.supplierId,
    this.unit = 'pcs',
    this.costPrice = 0,
    this.sellingPrice = 0,
    this.minimumStock = 0,
    this.imagePath,
    this.active = true,
    this.quantity = 0,
  });

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'] as int?,
      barcode: map['barcode'] as String?,
      sku: map['sku'] as String?,
      name: map['name'] ?? '',
      description: map['description'] as String?,
      categoryId: map['category_id'] as int?,
      supplierId: map['supplier_id'] as int?,
      unit: map['unit'] ?? 'pcs',
      costPrice: _toDouble(map['cost_price']),
      sellingPrice: _toDouble(map['selling_price']),
      minimumStock: _toDouble(map['minimum_stock']),
      imagePath: map['image_path'] as String?,
      active: map['active'] == 1,
      quantity: _toDouble(map['quantity']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'barcode': barcode,
      'sku': sku,
      'name': name,
      'description': description,
      'category_id': categoryId,
      'supplier_id': supplierId,
      'unit': unit,
      'cost_price': costPrice,
      'selling_price': sellingPrice,
      'minimum_stock': minimumStock,
      'image_path': imagePath,
      'active': active ? 1 : 0,
    };
  }

  bool get isLowStock => quantity <= minimumStock;

  bool get isOutOfStock => quantity <= 0;

  static double _toDouble(dynamic value) {
    if (value == null) return 0;

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value.toString()) ?? 0;
  }
}
