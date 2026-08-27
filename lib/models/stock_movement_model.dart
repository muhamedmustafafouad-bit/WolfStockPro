class StockMovementModel {
  final int? id;
  final int productId;
  final int branchId;
  final int? userId;
  final String movementType;
  final double quantity;
  final String? referenceNo;
  final String? notes;
  final DateTime createdAt;

  StockMovementModel({
    this.id,
    required this.productId,
    required this.branchId,
    this.userId,
    required this.movementType,
    required this.quantity,
    this.referenceNo,
    this.notes,
    required this.createdAt,
  });

  factory StockMovementModel.fromMap(Map<String, dynamic> map) {
    return StockMovementModel(
      id: map['id'],
      productId: map['product_id'],
      branchId: map['branch_id'],
      userId: map['user_id'],
      movementType: map['movement_type'],
      quantity: (map['quantity'] as num).toDouble(),
      referenceNo: map['reference_no'],
      notes: map['notes'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'product_id': productId,
      'branch_id': branchId,
      'user_id': userId,
      'movement_type': movementType,
      'quantity': quantity,
      'reference_no': referenceNo,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
