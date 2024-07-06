import 'package:flutter/material.dart';

import 'package:hive/hive.dart';

import '../../domain/models/userdata_model.dart';
import 'login.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({Key? key}) : super(key: key);

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade900,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              margin: EdgeInsets.all(16.0),
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10.0,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    
                   
                    SizedBox(height: 20),
                    Text("Sign Up",
                        style: TextStyle(fontSize: 24, color: Colors.blue)),
                    SizedBox(height: 20),
                    _buildTextField(
                        controller: firstNameController, hintText: 'First Name'),
                    SizedBox(height: 20),
                    _buildTextField(
                        controller: lastNameController, hintText: 'Last Name'),
                    SizedBox(height: 20),
                    _buildTextField(
                        controller: emailController,
                        hintText: 'Email',
                        inputType: TextInputType.emailAddress),
                    SizedBox(height: 20),
                    _buildTextField(
                        controller: passwordController,
                        hintText: 'Password',
                        isPassword: true),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _signup,
                      child: Text('Sign Up'),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white, backgroundColor: Colors.blue,
                        padding:
                            EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      ),
                    ),
                    SizedBox(height: 20),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(context,
                            MaterialPageRoute(builder: (context) => LoginPage()));
                      },
                      child: RichText(
                        text: TextSpan(
                          text: 'Already have an account?',
                          style: TextStyle(color: Colors.black),
                          children: <TextSpan>[
                            TextSpan(
                              text: ' Login Now',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      {required TextEditingController controller,
      required String hintText,
      bool isPassword = false,
      TextInputType inputType = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: inputType,
      decoration: InputDecoration(
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        filled: true,
        fillColor: Colors.lightBlue[50],
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '$hintText is required';
        }
        if (hintText == 'Email' && !RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
          return 'Enter a valid email';
        }
        return null;
      },
    );
  }

  void _signup() async {
    if (_formKey.currentState!.validate()) {
      final userBox = Hive.box<UserModel>('users');
      String email = emailController.text.trim();
      
      if (userBox.values.any((user) => user.email == email)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User already exists')),
        );
        return;
      }

      final newUser = UserModel(
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        email: email,
        password: passwordController.text.trim(),
      );

      await userBox.add(newUser);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sign up successful')),
      );

      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => LoginPage()));
    }
  }
}
