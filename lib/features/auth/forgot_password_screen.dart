
// import 'package:flutter/material.dart';
// import '../../core/services/auth_service.dart';

// class ForgotPasswordScreen extends StatelessWidget {
//   final emailController = TextEditingController();
//   final authService = AuthService();

//   ForgotPasswordScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Forgot Password')),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             TextField(controller: emailController, decoration: InputDecoration(labelText: 'Email')),
//             ElevatedButton(
//               onPressed: () async {
//                 await authService.resetPassword(emailController.text);
//               },
//               child: Text('Reset Password'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_template/core/services/auth_service.dart';
// import 'auth_controller.dart';

class ForgotPasswordScreen extends ConsumerWidget {
  final _emailCtrl = TextEditingController();

  ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.read(authControllerProvider);
    return Scaffold(
      appBar: AppBar(title: Text('Forgot Password')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _emailCtrl, decoration: InputDecoration(labelText: 'Email')),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => auth.resetPassword(_emailCtrl.text),
              child: Text('Send Reset Link'),
            ),
          ],
        ),
      ),
    );
  }
}
