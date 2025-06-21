
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/signup_controller/signup_controller.dart';
import '../login/login_page.dart';


class SignupPage extends StatelessWidget {
  SignupPage({super.key});

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  void _submitSignup(BuildContext context, SignupController signupController) {
    if (_formKey.currentState!.validate()) {
      signupController
          .registerUser(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        confirmPassword: _confirmPasswordController.text.trim(),
        context: context,
      )
          .then((success) {
        if (success) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) =>  LoginPage()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(signupController.error ?? 'Signup failed')),
          );
        }
      });
    }
  }

  void _goToLogin(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) =>  LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SignupController>(
      builder: (context, signupController, _) {
        return Scaffold(
          backgroundColor: Colors.indigo.shade50,
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [

                  Colors.white,
                  Color(0xFFB4FFF7), // Cyan// White
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            height: double.infinity,
            child: Stack(
              children: [
                SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Column(
                      children: [
                        const SizedBox(height: 60),

                        Image.asset(
                          'assets/images/logo.png',
                          width: 100,
                          height: 100,
                        ),
                        const SizedBox(height: 30),
                        const Text(
                          'Create Account',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo,
                          ),
                        ),
                        const SizedBox(height: 30),
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              TextFormField(
                                controller: _nameController,
                                decoration: _inputDecoration('Full Name', Icons.person),
                                validator: (value) => value == null || value.isEmpty
                                    ? 'Name is required'
                                    : null,
                              ),
                              const SizedBox(height: 15),
                              TextFormField(
                                controller: _emailController,
                                decoration: _inputDecoration('Email', Icons.email),
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Email is required';
                                  } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}$')
                                      .hasMatch(value)) {
                                    return 'Enter a valid email';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 25),
                              TextFormField(
                                controller: _passwordController,
                                obscureText: true,
                                decoration: _inputDecoration('Password', Icons.lock),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Password is required';
                                  } else if (value.length < 6) {
                                    return 'Password must be at least 6 characters';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 25),
                              TextFormField(
                                controller: _confirmPasswordController,
                                obscureText: true,
                                decoration: _inputDecoration('Confirm Password', Icons.lock_outline),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please confirm your password';
                                  } else if (value != _passwordController.text) {
                                    return 'Passwords do not match';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 30),

                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: signupController.isLoading
                                      ? null
                                      : () => _submitSignup(context, signupController),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.indigo,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 300),
                                    child: signupController.isLoading
                                        ? const Text(
                                      'Please wait...',
                                      key: ValueKey('loadingText'),
                                    )
                                        : const Text(
                                      'Sign Up',
                                      style: TextStyle(fontSize: 16,color: Colors.white),
                                      key: ValueKey('normalText'),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              TextButton(
                                onPressed: () => _goToLogin(context),
                                child: const Text(
                                  'Already have an account? Login',
                                  style: TextStyle(color: Colors.indigo),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                if (signupController.isLoading)
                  const Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: LinearProgressIndicator(
                      color: Colors.indigo,
                      backgroundColor: Colors.white,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}
