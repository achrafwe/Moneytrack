import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:moneytracker/screens/add_expense_screen.dart';
import 'package:moneytracker/screens/login_screen.dart';
import 'package:moneytracker/screens/home_screen.dart';
import 'package:moneytracker/screens/register_screen.dart';
import 'package:moneytracker/screens/commercial_home_screen.dart';
import 'package:moneytracker/services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Money Tracker',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            minimumSize: MaterialStateProperty.all<Size>(
              const Size(double.infinity, 55),
            ),
            shape: MaterialStateProperty.all<OutlinedBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(7),
              ),
            ),
            foregroundColor: MaterialStateProperty.all<Color>(
              Colors.white,
            ),
            backgroundColor: MaterialStateProperty.all<Color>(
              const Color(0xffff3851),
            ),
          ),
        ),
      ),
      home: AuthWrapper(),
      routes: {
        '/add_expense': (context) => AddExpenseScreen(),
        '/register': (context) => RegisterScreen(),
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (snapshot.hasData && snapshot.data != null) {
          User user = snapshot.data!;
          return FutureBuilder<bool>(
            future: _authService.isCommercial(user),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Scaffold(body: Center(child: CircularProgressIndicator()));
              } else if (snapshot.hasError) {
                return Scaffold(body: Center(child: Text('Erreur : ${snapshot.error}')));
              } else if (snapshot.data == true) {
                return CommercialHomeScreen();
              } else {
                return HomeScreen(user: user);
              }
            },
          );
        } else {
          return LoginScreen();
        }
      },
    );
  }
}
