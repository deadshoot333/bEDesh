import 'package:flutter/material.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController(text: '+880');
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          SizedBox(
            height: double.infinity,
            width: double.infinity,
            child: Image.asset(
              'assets/abroad8.jpg',
              fit: BoxFit.cover,
            ),
          ),

          // Dark overlay for contrast
          Container(
            color: Colors.black.withOpacity(0.4),
          ),

          // Centered Form in white container
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Create Account',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Full Name
                        TextFormField(
                          controller: _nameController,
                          decoration: _inputDecoration('Full Name', Icons.person),
                          validator: (value) => value!.isEmpty ? 'Enter full name' : null,
                        ),
                        const SizedBox(height: 16),

                        // Phone Number
                        TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: _inputDecoration('Phone Number', Icons.phone),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Enter phone number';
                            }
                            if (!value.startsWith('+880') || value.length < 14) {
                              return 'Enter valid +880 phone number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Password
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: _inputDecoration('Password', Icons.lock),
                          validator: (value) =>
                          value!.length < 6 ? 'Password must be at least 6 characters' : null,
                        ),
                        const SizedBox(height: 16),

                        // Confirm Password
                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: _obscurePassword,
                          decoration: _inputDecoration('Confirm Password', Icons.lock_outline),
                          validator: (value) {
                            if (value != _passwordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),

                        // Sign Up Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.lightBlueAccent,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                // Perform signup action
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Signing up...')),
                                );
                              }
                            },
                            child: const Text(
                              'Sign Up',
                              style: TextStyle(fontSize: 18, color: Colors.white),
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
        ],
      ),
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
