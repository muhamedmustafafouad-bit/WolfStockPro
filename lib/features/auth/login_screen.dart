import 'package:flutter/material.dart';

import '../../models/user_model.dart';
import '../../services/auth_service.dart';

import '../dashboard/dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  final _authService = AuthService();

  bool _isLoading = false;
  bool _obscurePassword = true;

  String? _errorMessage;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    FocusScope.of(context).unfocus();

    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter username and password.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final UserModel? user = await _authService.login(
        username,
        password,
      );

      if (!mounted) return;

      if (user == null) {
        setState(() {
          _errorMessage = 'Invalid username or password.';
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _isLoading = false;
      });

      Navigator.of(context).pushReplacement(
  MaterialPageRoute(
    builder: (_) => DashboardScreen(
      user: user,
    ),
  ),
);

      // Dashboard will be connected here next.
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = 'Login error. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 450,
              ),
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.15),
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Icon(
                      Icons.inventory_2_rounded,
                      size: 58,
                      color: Theme.of(context)
                          .colorScheme
                          .primary,
                    ),
                  ),

                  const SizedBox(height: 28),

                  const Text(
                    'WolfStock Pro',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Multi-Branch Inventory Management',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey.shade400,
                    ),
                  ),

                  const SizedBox(height: 45),

                  TextField(
                    controller: _usernameController,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: 'Username',
                      prefixIcon: const Icon(
                        Icons.person_outline,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    onSubmitted: (_) => _login(),
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(
                        Icons.lock_outline,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword =
                                !_obscurePassword;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),

                  if (_errorMessage != null) ...[
                    const SizedBox(height: 16),

                    Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.redAccent,
                      ),
                    ),
                  ],

                  const SizedBox(height: 28),

                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: FilledButton(
                      onPressed:
                          _isLoading ? null : _login,
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child:
                                  CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'LOGIN',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  Text(
                    'WolfStock Pro v1.0.0',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    'L0N3WOLF',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade700,
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
}
