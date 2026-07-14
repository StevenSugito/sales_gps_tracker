class OrderModel {
  final int? id;
  final int visitId;
  final int salesPersonId;
  final String orderNumber;
  final String productName;
  final String productCode;
  final int quantity;
  final double unitPrice;
  final String unit;
  final String status;
  final String paymentType;
  final int orderDate;
  final String? notes;
  final String? photoPath;

  OrderModel({
    this.id,
    required this.visitId,
    required this.salesPersonId,
    required this.orderNumber,
    required this.productName,
    this.productCode = '',
    required this.quantity,
    required this.unitPrice,
    this.unit = 'pcs',
    this.status = 'PENDING',
    this.paymentType = 'CASH',
    required this.orderDate,
    this.notes,
    this.photoPath,
  });

  double get totalAmount => quantity * unitPrice;

  Map<String, dynamic> toMap() => {
    'id': id,
    'visitId': visitId,
    'salesPersonId': salesPersonId,
    'orderNumber': orderNumber,
    'productName': productName,
    'productCode': productCode,
    'quantity': quantity,
    'unitPrice': unitPrice,
    'totalPrice': totalAmount,
    'unit': unit,
    'status': status,
    'paymentType': paymentType,
    'orderDate': orderDate,
    'notes': notes,
    'photoPath': photoPath,
  };

  factory OrderModel.fromMap(Map<String, dynamic> map) => OrderModel(
    id: map['id'] as int?,
    visitId: map['visitId'] as int,
    salesPersonId: map['salesPersonId'] as int,
    orderNumber: map['orderNumber'] as String,
    productName: map['productName'] as String,
    productCode: map['productCode'] as String,
    quantity: map['quantity'] as int,
    unitPrice: map['unitPrice'] as double,
    unit: map['unit'] as String,
    status: map['status'] as String,
    paymentType: map['paymentType'] as String,
    orderDate: map['orderDate'] as int,
    notes: map['notes'] as String?,
    photoPath: map['photoPath'] as String?,
  );
}
