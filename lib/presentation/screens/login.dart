import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive/hive.dart';

import 'package:velocity_x/velocity_x.dart';

import '../../domain/models/userdata_model.dart';
import '../widgets/bottom_navbar.dart';
import 'signup.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isChecked = false;

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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Animation Placeholder (to be replaced with a real animation)
                  Container(
                    height: 100,
                    child: Icon(
                      Icons.money,
                      color: Colors.green,
                      size: 100,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text("Login",
                      style: TextStyle(fontSize: 24, color: Colors.blue)),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Remember Me", style: TextStyle(color: Colors.black)),
                      Checkbox(
                        value: isChecked,
                        onChanged: (value) {
                          setState(() {
                            isChecked = value ?? false;
                          });
                        },
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: const Text(
                      "Forgot Password? Reset Now",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _login,
                    child: Text('Login'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white, backgroundColor: Colors.blue,
                      padding:
                          EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    ),
                  ),
                  SizedBox(height: 20),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SignupPage()));
                    },
                    child: RichText(
                      text: TextSpan(
                        text: 'Don\'t have an account?',
                        style: TextStyle(color: Colors.black),
                        children: <TextSpan>[
                          TextSpan(
                            text: ' Sign Up Now',
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

  void _login() {
    final userBox = Hive.box<UserModel>('users');
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    final user = userBox.values.firstWhere(
        (user) => user.email == email && user.password == password,
        orElse: () => UserModel(firstName: '', lastName: '', email: '', password: ''));

    if (user.email.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login successful')),
      );
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => Bottom()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid email or password')),
      );
    }
  }
}
