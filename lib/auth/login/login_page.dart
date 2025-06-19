
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:demo/auth/signup/signup_page.dart';
import 'package:demo/models/login_controller/login_controller.dart';
import 'package:demo/pages/app.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void _submitForm(BuildContext context, LoginController loginController) {
    if (_formKey.currentState!.validate()) {
      loginController
          .loginUser(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        context: context,
      )
          .then((success) {
        if (success) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const App()),
          );
        } else {
          final snackBar = SnackBar(
            elevation: 0,
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.transparent,
            margin: const EdgeInsets.fromLTRB(16, 50, 16, 0), // تحركه للأعلى (50 من الأعلى)
            content: AwesomeSnackbarContent(
              title: 'Error!',
              message: loginController.error ?? 'Sorry try again',
              contentType: ContentType.failure,
            ),
            duration: const Duration(seconds: 3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          );

          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(snackBar);

        }
      });

    }
  }

  void _goToSignup(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) =>  SignupPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LoginController>(
      builder: (context, loginController, _) {
        return Scaffold(

          backgroundColor: Colors.indigo.shade50,
          body: Container(
            height: double.infinity,
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
            child: Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 60),
                      Image.asset(
                        'assets/images/logo.png',
                        width: 100,
                        height: 100,
                      ),
                      const SizedBox(height: 30),
                      const Text(
                        'Welcome Back',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Please login to continue',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 30),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _emailController,
                              decoration: _inputDecoration('Email', Icons.email),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Email is required';
                                } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}$')
                                    .hasMatch(value)) {
                                  return 'Enter a valid email';
                                }
                                return null;
                              },
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 20),
                            TextFormField(

                              controller: _passwordController,
                              obscureText: loginController.showPassword?false:true,
                              decoration:
                              InputDecoration(
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    loginController.togglePassword();
                                  }
                                  ,icon: loginController.showPassword? Icon(Icons.remove_red_eye_rounded)
                                  :Icon(Icons.password)
                                  ,
                                ),
                                labelText: 'password',
                                prefixIcon: Icon(Icons.lock),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),

                              )
                              ,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Password is required';
                                } else if (value.length < 6) {
                                  return 'Password must be at least 6 characters';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 30),
                            SizedBox(
                              width: double.infinity,
                              child:ElevatedButton(
                                onPressed: loginController.isLoading
                                    ? null
                                    : () {
                                  FocusScope.of(context).unfocus();  // هذا يخفي الكيبورد
                                  _submitForm(context, loginController);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.indigo,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 300),
                                  child: loginController.isLoading
                                      ? const Text(
                                    'Logging in...',
                                    key: ValueKey('loadingText'),
                                  )
                                      : const Text(
                                    'Login',
                                    style: TextStyle(fontSize: 16),
                                    key: ValueKey('normalText'),
                                  ),
                                ),
                              ),

                            ),
                            const SizedBox(height: 20),
                            TextButton(
                              onPressed: () => _goToSignup(context),
                              child: const Text(
                                "Don't have an account? Sign up",
                                style: TextStyle(color: Colors.indigo),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (loginController.isLoading)
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
