import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:lottie/lottie.dart';
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
     
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              margin: const EdgeInsets.all(16.0),
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.0),
               
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    
                      Container(
                width: 250,
                height: 250,
                child: Lottie.asset('animation/animation.json'),
              ),
                    const SizedBox(height: 0),
                    const Text(
                      "Sign Up",
                      style: TextStyle(fontSize: 30, color: Color(0xFF0D47A1),),
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                        controller: firstNameController, hintText: 'First Name'),
                    const SizedBox(height: 20),
                    _buildTextField(
                        controller: lastNameController, hintText: 'Last Name'),
                    const SizedBox(height: 20),
                    _buildTextField(
                        controller: emailController,
                        hintText: 'Email',
                        inputType: TextInputType.emailAddress),
                    const SizedBox(height: 20),
                    _buildTextField(
                        controller: passwordController,
                        hintText: 'Password',
                        isPassword: true),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _signup,
                      child: const Text('Sign Up'),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor:  Color(0xFF0D47A1),
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      ),
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(context,
                            MaterialPageRoute(builder: (context) => LoginPage()));
                      },
                      child: RichText(
                        text: const TextSpan(
                          text: 'Already have an account?',
                          style: TextStyle( color: Color(0xFF0D47A1),),
                          children: <TextSpan>[
                            TextSpan(
                              text: ' Login Now',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                color: Color(0xFF0D47A1)),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    bool isPassword = false,
    TextInputType inputType = TextInputType.text,
  }) {
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
          const SnackBar(content: Text('User already exists')),
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
        const SnackBar(content: Text('Sign up successful')),
      );

      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => LoginPage()));
    }
  }
}
