import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import '../models/expense_model.dart';
import '../services/expense_service.dart';

class AddExpenseScreen extends StatefulWidget {
  @override
  _AddExpenseScreenState createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  String _category = 'repas';
  double _amount = 0.0;
  File? _receiptImage;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    setState(() {
      if (pickedFile != null) {
        _receiptImage = File(pickedFile.path);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserModel>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Add Expense')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                value: _category,
                onChanged: (value) {
                  setState(() {
                    _category = value!;
                  });
                },
                items: [
                  DropdownMenuItem(
                    child: Text('Repas'),
                    value: 'repas',
                  ),
                  DropdownMenuItem(
                    child: Text('Hôtel'),
                    value: 'hotel',
                  ),
                ],
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.number,
                onSaved: (value) {
                  _amount = double.parse(value!);
                },
              ),
              SizedBox(height: 20),
              _receiptImage == null
                  ? Text('No image selected.')
                  : Image.file(_receiptImage!),
              ElevatedButton(
                onPressed: _pickImage,
                child: Text('Pick Receipt Image'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate() && _receiptImage != null) {
                    _formKey.currentState!.save();
                    final expense = ExpenseModel(
                      id: DateTime.now().toString(),
                      userId: user.uid,
                      category: _category,
                      amount: _amount,
                      date: DateTime.now(),
                      receiptUrl: '', // Upload image and get URL
                    );
                    await ExpenseService().addExpense(expense);
                    Navigator.pop(context);
                  }
                },
                child: Text('Add Expense'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
