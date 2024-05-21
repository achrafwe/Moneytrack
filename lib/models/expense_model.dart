class ExpenseModel {
  final String id;
  final String userId;
  final String category;
  final double amount;
  final DateTime date;
  final String receiptUrl;

  ExpenseModel({
    required this.id,
    required this.userId,
    required this.category,
    required this.amount,
    required this.date,
    required this.receiptUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'category': category,
      'amount': amount,
      'date': date.toIso8601String(),
      'receiptUrl': receiptUrl,
    };
  }

  factory ExpenseModel.fromMap(Map<String, dynamic> map) {
    return ExpenseModel(
      id: map['id'],
      userId: map['userId'],
      category: map['category'],
      amount: map['amount'],
      date: DateTime.parse(map['date']),
      receiptUrl: map['receiptUrl'],
    );
  }
}
