import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/expense_model.dart';

class ExpenseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addExpense(ExpenseModel expense) async {
    await _firestore.collection('expenses').doc(expense.id).set(expense.toMap());
  }

  Stream<List<ExpenseModel>> getExpensesByUser(String userId) {
    return _firestore.collection('expenses')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => ExpenseModel.fromMap(doc.data()!)).toList());
  }
}
