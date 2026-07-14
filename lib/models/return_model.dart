class ReturnModel {
  final int? id;
  final int visitId;
  final int salesPersonId;
  final String returnNumber;
  final String productName;
  final String productCode;
  final int quantity;
  final double unitPrice;
  final String unit;
  final String reason;
  final String condition;
  final String status;
  final int returnDate;
  final String? notes;
  final String? photoPath;

  ReturnModel({
    this.id,
    required this.visitId,
    required this.salesPersonId,
    required this.returnNumber,
    required this.productName,
    this.productCode = '',
    required this.quantity,
    required this.unitPrice,
    this.unit = 'pcs',
    required this.reason,
    this.condition = 'GOOD',
    this.status = 'PENDING',
    required this.returnDate,
    this.notes,
    this.photoPath,
  });

  double get totalAmount => quantity * unitPrice;

  Map<String, dynamic> toMap() => {
    'id': id,
    'visitId': visitId,
    'salesPersonId': salesPersonId,
    'returnNumber': returnNumber,
    'productName': productName,
    'productCode': productCode,
    'quantity': quantity,
    'unitPrice': unitPrice,
    'totalRefund': totalAmount,
    'unit': unit,
    'reason': reason,
    'condition': condition,
    'status': status,
    'returnDate': returnDate,
    'notes': notes,
    'photoPath': photoPath,
  };

  factory ReturnModel.fromMap(Map<String, dynamic> map) => ReturnModel(
    id: map['id'] as int?,
    visitId: map['visitId'] as int,
    salesPersonId: map['salesPersonId'] as int,
    returnNumber: map['returnNumber'] as String,
    productName: map['productName'] as String,
    productCode: map['productCode'] as String,
    quantity: map['quantity'] as int,
    unitPrice: map['unitPrice'] as double,
    unit: map['unit'] as String,
    reason: map['reason'] as String,
    condition: map['condition'] as String,
    status: map['status'] as String,
    returnDate: map['returnDate'] as int,
    notes: map['notes'] as String?,
    photoPath: map['photoPath'] as String?,
  );
}
