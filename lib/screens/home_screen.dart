import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import '../services/expense_service.dart';
//import '../widgets/expense_list.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(context, '/add-expense');
            },
          ),
        ],
      ),
      //body: StreamProvider<List<ExpenseModel>>.value(
        //value: ExpenseService().getExpensesByUser(user.uid),
        //initialData: [],
        //child: ExpenseList(),
      //),
    );
  }
}
