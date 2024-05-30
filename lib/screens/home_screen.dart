import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatelessWidget {
  final User user;

  HomeScreen({required this.user});

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('expenses')
            .where('userId', isEqualTo: user.uid)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            print('Error: ${snapshot.error}');
            return Center(child: Text('Something went wrong: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No expenses found'));
          }

          // Group expenses by departure and arrival city
          Map<String, List<Map<String, dynamic>>> groupedExpenses = {};
          snapshot.data!.docs.forEach((DocumentSnapshot document) {
            Map<String, dynamic> data = document.data() as Map<String, dynamic>;
            String route = '${data['departureCity']} to ${data['arrivalCity']}';
            if (!groupedExpenses.containsKey(route)) {
              groupedExpenses[route] = [];
            }
            groupedExpenses[route]!.add(data);
          });

          return ListView(
            children: groupedExpenses.entries.map((entry) {
              String route = entry.key;
              List<Map<String, dynamic>> expenses = entry.value;
              double totalAmount = expenses.fold(0, (sum, item) => sum + item['amount']);

              return Card(
                margin: EdgeInsets.all(10),
                child: ExpansionTile(
                  title: Text(route),
                  subtitle: Text('Total: \$${totalAmount.toStringAsFixed(2)}'),
                  children: [
                    DataTable(
                      columns: [
                        DataColumn(label: Text('Receipt')),
                        DataColumn(label: Text('Amount')),
                        DataColumn(label: Text('Statut')),
                      ],
                      rows: expenses.map((data) {
                        return DataRow(cells: [


                          DataCell(data['receiptUrl'] != ''
                              ? Image.network(data['receiptUrl'], height: 50)
                              : Text('No receipt')),
                          DataCell(Text('\$${data['amount'].toStringAsFixed(2)}')),
                          DataCell(Text(data['status'])),
                        ]);
                      }).toList(),
                    ),
                  ],
                ),
              );
            }).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/add_expense');
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
