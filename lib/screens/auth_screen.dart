import 'package:flutter/material.dart';
import '../controllers/auth_services.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passController = TextEditingController();
  final AuthServices _authService = AuthServices();

  bool isLogin = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isLogin ? "Login" : "Sign Up")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(controller: emailController, decoration: const InputDecoration(labelText: "Email")),
            TextField(
              controller: passController,
              decoration: const InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final email = emailController.text.trim();
                final pass = passController.text.trim();
                if (isLogin) {
                  final user = await _authService.signIn(email, pass);
                  if (user != null) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Logged in as ${user.email}")));
                  }
                } else {
                  final user = await _authService.signUp(email, pass);
                  if (user != null) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Signed up as ${user.email}")));
                  }
                }
              },
              child: Text(isLogin ? "Login" : "Sign Up"),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  isLogin = !isLogin;
                });
              },
              child: Text(isLogin ? "Don't have an account? Sign Up" : "Already have an account? Login"),
            )
          ],
        ),
      ),
    );
  }
}
