import 'package:flutter/material.dart';
import 'database/database_helper.dart';
import 'features/auth/login_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the WolfStock Pro database
  await DatabaseHelper.instance.database;

  runApp(const WolfStockProApp());
}

class WolfStockProApp extends StatelessWidget {
  const WolfStockProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WolfStock Pro',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFF0B0F14),
      ),

      home: const LoginScreen(),
    );
  }
}

class StartupScreen extends StatelessWidget {
  const StartupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.inventory_2_rounded,
              size: 90,
              color: Colors.blue,
            ),

            const SizedBox(height: 24),

            const Text(
              'WolfStock Pro',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Multi-Branch Inventory System',
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade400,
              ),
            ),

            const SizedBox(height: 40),

            const CircularProgressIndicator(),

            const SizedBox(height: 20),

            Text(
              'Initializing database...',
              style: TextStyle(
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
