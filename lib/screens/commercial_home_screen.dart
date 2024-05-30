import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:moneytracker/services/auth_service.dart';
import 'package:moneytracker/models/user_model.dart';

class CommercialHomeScreen extends StatefulWidget {
  @override
  _CommercialHomeScreenState createState() => _CommercialHomeScreenState();
}

class _CommercialHomeScreenState extends State<CommercialHomeScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();
  UserModel? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
      var userData = userDoc.data() as Map<String, dynamic>?;
      setState(() {
        _currentUser = UserModel(
          uid: userData?['uid'],
          email: userData?['email'],
          role: userData?['role'],
          adresse: userData?['adresse'],
          numsalarier: userData?['numsalarier'],
          dateNaissance: userData?['dateNaissance'],
          teleportable: userData?['teleportable'],
          commercialId: userData != null && userData.containsKey('commercialId') ? userData['commercialId'] : null,
        );
      });
    }
  }

  Future<List<Map<String, dynamic>>> _fetchExpenses() async {
    QuerySnapshot expenseSnapshot = await _firestore.collection('expenses').get();
    return expenseSnapshot.docs.map((doc) {
      var data = doc.data() as Map<String, dynamic>?;
      return {
        'id': doc.id,
        'amount': data != null && data.containsKey('amount') ? data['amount'] : 'N/A',
        'type': data != null && data.containsKey('type') ? data['type'] : 'N/A',
        'status': data != null && data.containsKey('status') ? data['status'] : 'Pending',
        'numsalarier': data != null && data.containsKey('numsalarier') ? data['numsalarier'] : 'N/A',
      };
    }).toList();
  }

  Future<void> _updateExpenseStatus(String expenseId, String newStatus) async {
    await _firestore.collection('expenses').doc(expenseId).update({'status': newStatus});
  }

  void _logout() async {
    await _authService.signOut();
    Navigator.of(context).pushReplacementNamed('/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Commercial Home Screen'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: Column(
        children: [
          _currentUser == null
              ? Center(child: CircularProgressIndicator())
              : Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Email: ${_currentUser!.email}'),
                Text('Role: ${_currentUser!.role}'),
                Text('Adresse: ${_currentUser!.adresse}'),
                Text('Num Salarier: ${_currentUser!.numsalarier}'),
                Text('Date de Naissance: ${_currentUser!.dateNaissance}'),
                Text('Téléportable: ${_currentUser!.teleportable}'),
                if (_currentUser!.commercialId != null)
                  Text('Commercial ID: ${_currentUser!.commercialId}'),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _fetchExpenses(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Erreur : ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('Aucune dépense trouvée.'));
                } else {
                  List<Map<String, dynamic>> expenses = snapshot.data!;
                  return ListView.builder(
                    itemCount: expenses.length,
                    itemBuilder: (context, index) {
                      var expense = expenses[index];
                      var validStatuses = ['Pending', 'Approved', 'Rejected'];
                      var currentStatus = validStatuses.contains(expense['status']) ? expense['status'] : 'Pending';
                      return ListTile(
                        title: Text('Montant: ${expense['amount']}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Nature: ${expense['type']}'),
                            Text('Num Salarier: ${expense['numsalarier']}'),
                          ],
                        ),
                      trailing: DropdownButton<String>(
                          value: currentStatus,
                          items: validStatuses.map((status) => DropdownMenuItem<String>(
                            value: status,
                            child: Text(status),
                          )).toList(),
                          onChanged: (newStatus) {
                            if (newStatus != null) {
                              setState(() {
                                expense['status'] = newStatus;
                              });
                              _updateExpenseStatus(expense['id'], newStatus);
                            }
                          },
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
