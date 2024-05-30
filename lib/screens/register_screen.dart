import 'package:flutter/material.dart';
import 'package:moneytracker/services/auth_service.dart';
import 'package:moneytracker/exception/auth_exception_handler.dart';
import 'package:fluttertoast/fluttertoast.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _adresseController = TextEditingController();
  final TextEditingController _numsalarierController = TextEditingController();
  final TextEditingController _teleportableController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _commercialIdController = TextEditingController();

  String _selectedRole = 'commercial';

  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: 'Email'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter your email';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
                DropdownButtonFormField<String>(
                  value: _selectedRole,
                  decoration: InputDecoration(labelText: 'Role'),
                  items: <String>['commercial', 'agentsalarier']
                      .map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedRole = newValue!;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a role';
                    }
                    return null;
                  },
                ),
                if (_selectedRole == 'agentsalarier')
                  TextFormField(
                    controller: _commercialIdController,
                    decoration: InputDecoration(labelText: 'Commercial ID'),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter your Commercial ID';
                      }
                      return null;
                    },
                  ),
                TextFormField(
                  controller: _adresseController,
                  decoration: InputDecoration(labelText: 'Adresse'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter your adresse';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _numsalarierController,
                  decoration: InputDecoration(labelText: 'Numéro de Salarier'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter your numéro de salarier';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _teleportableController,
                  decoration: InputDecoration(labelText: 'Téléportable'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter your téléportable';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _dobController,
                  decoration: InputDecoration(labelText: 'Date de Naissance'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter your date de naissance';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _register,
                  child: Text('Register'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _register() async {
    if (_formKey.currentState!.validate()) {
      AuthResultStatus status = await _authService.registerWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
        role: _selectedRole,
        teleportable: _teleportableController.text,
        adresse: _adresseController.text,
        numsalarier: _numsalarierController.text,
        dateNaissance: _dobController.text,
        commercialId: _selectedRole == 'agentsalarier' ? _commercialIdController.text : null,
      );

      if (status == AuthResultStatus.successful) {
        Fluttertoast.showToast(
          msg: 'Registration successful',
          backgroundColor: Colors.green,
        );
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        final errorMsg = AuthExceptionHandler.generateExceptionMessage(status);
        Fluttertoast.showToast(msg: errorMsg);
      }
    }
  }
}
