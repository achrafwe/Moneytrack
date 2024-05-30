import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: AddExpenseScreen(),
    );
  }
}

class AddExpenseScreen extends StatefulWidget {
  @override
  _AddExpenseScreenState createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _departureController = TextEditingController();
  final _arrivalController = TextEditingController();
  final _typeController = TextEditingController();
  final _amountController = TextEditingController();
  XFile? _receiptImage;

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);

    if (image != null) {
      print("Image path: ${image.path}");
    } else {
      print("No image selected");
    }

    setState(() {
      _receiptImage = image;
    });
  }

  Future<String> _uploadImage(XFile image) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception("No user is signed in");
    }

    final storageRef = FirebaseStorage.instance
        .ref()
        .child('receipts')
        .child('${user.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg');

    print("Uploading to path: ${storageRef.fullPath}");

    try {
      final uploadTask = await storageRef.putFile(File(image.path));
      print("Upload state: ${uploadTask.state}");
      if (uploadTask.state == TaskState.success) {
        final downloadUrl = await storageRef.getDownloadURL();
        print("Download URL: $downloadUrl");
        return downloadUrl;
      } else {
        throw Exception("Upload failed");
      }
    } catch (e) {
      print("Upload failed: $e");
      throw e;
    }
  }

  void _submitExpense() async {
    if (_formKey.currentState!.validate()) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        try {
          String receiptUrl = '';
          if (_receiptImage != null) {
            receiptUrl = await _uploadImage(_receiptImage!);
          }

          await FirebaseFirestore.instance.collection('expenses').add({
            'userId': user.uid,
            'departureCity': _departureController.text,
            'arrivalCity': _arrivalController.text,
            'type': _typeController.text,
            'amount': double.parse(_amountController.text),
            'status': 'pending',
            'receiptUrl': receiptUrl,
          });
          Navigator.pop(context);
        } catch (e) {
          print("Error adding expense: $e");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to add expense: $e')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No user is signed in')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Expense'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _departureController,
                decoration: InputDecoration(labelText: 'Departure City'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a departure city';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _arrivalController,
                decoration: InputDecoration(labelText: 'Arrival City'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter an arrival city';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _typeController,
                decoration: InputDecoration(labelText: 'Type (e.g., lunch, dinner)'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter the type of expense';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter an amount';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _pickImage,
                child: Text('Take Receipt Photo'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitExpense,
                child: Text('Submit Expense'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
