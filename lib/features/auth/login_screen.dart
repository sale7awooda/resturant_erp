
// import 'package:flutter/material.dart';
// import 'package:starter_template/features/auth/forgot_password_screen.dart';
// import 'package:starter_template/features/auth/signup_screen.dart';
// import '../../core/services/auth_service.dart';

// class LoginScreen extends StatelessWidget {
//   final emailController = TextEditingController();
//   final passwordController = TextEditingController();
//   final authService = AuthService();

//   LoginScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Login')),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             TextField(controller: emailController, decoration: InputDecoration(labelText: 'Email')),
//             TextField(controller: passwordController, decoration: InputDecoration(labelText: 'Password'), obscureText: true),
//             ElevatedButton(
//               onPressed: () async {
//                 await authService.login(emailController.text, passwordController.text);
//               },
//               child: Text('Login'),
//             ),
//             TextButton(
//               onPressed: () {
//                 Navigator.push(context, MaterialPageRoute(builder: (_) => ForgotPasswordScreen()));
//               },
//               child: Text('Forgot Password?'),
//             ),
//             TextButton(
//               onPressed: () {
//                 Navigator.push(context, MaterialPageRoute(builder: (_) => SignupScreen()));
//               },
//               child: Text('Sign Up'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'auth_controller.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends ConsumerWidget {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final auth = ref.read(authControllerProvider);
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _emailCtrl, decoration: InputDecoration(labelText: 'Email')),
            TextField(controller: _passCtrl, decoration: InputDecoration(labelText: 'Password'), obscureText: true),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {},
              child: Text('Login'),
            ),
            TextButton(
              onPressed: () => context.go('/signup'),
              child: Text('Sign Up'),
            ),
            TextButton(
              onPressed: () => context.go('/forgot-password'),
              child: Text('Forgot Password?'),
            ),
          ],
        ),
      ),
    );
  }
}
