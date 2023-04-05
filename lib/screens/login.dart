import 'package:final_project/providers/auth_provider.dart';
import 'package:final_project/screens/signup.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// will display the login screen
// call the approriate functions such as login and signup
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(left: 40.0, right: 40.0),
          child: Form(
            child: ListView(
              children: [
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    hintText: 'Email',
                  ),
                ),
                TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    hintText: 'Password',
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: ElevatedButton(
                    onPressed: () async {
                      final success = await context.read<AuthProvider>().logIn(
                            emailController.text,
                            passwordController.text,
                          );

                      // login not successful
                      if (success != null) {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(SnackBar(content: Text(success)));
                      }
                    },
                    child: const Text('Log In'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const SignupPage(),
                        ),
                      );
                    },
                    child: const Text('Sign Up'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
