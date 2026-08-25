class SupplierModel {
  final int? id;
  final String name;
  final String? contactPerson;
  final String? phone;
  final String? email;
  final String? address;

  SupplierModel({
    this.id,
    required this.name,
    this.contactPerson,
    this.phone,
    this.email,
    this.address,
  });

  factory SupplierModel.fromMap(Map<String, dynamic> map) {
    return SupplierModel(
      id: map['id'],
      name: map['name'],
      contactPerson: map['contact_person'],
      phone: map['phone'],
      email: map['email'],
      address: map['address'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'contact_person': contactPerson,
      'phone': phone,
      'email': email,
      'address': address,
    };
  }
}
