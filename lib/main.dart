import 'package:final_project/firebase_options.dart';
import 'package:final_project/providers/auth_provider.dart';
import 'package:final_project/providers/todo_provider.dart';
import 'package:final_project/screens/login.dart';
import 'package:final_project/screens/home_page.dart';
import 'package:final_project/screens/signup.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: ((context) => TodoListProvider())),
        ChangeNotifierProvider(create: ((context) => AuthProvider())),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Final Project',
      home: const DefaultTabController(
        length: 3,
        child: AuthWrapper(),
      ),
      theme: ThemeData(
        primarySwatch: Colors.grey,
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  // This widget is the root of your application.
  // it is a futurebuilder because it will wait for the userData to be resolved
  // the userData is lifted to the 2nd most upper state, which is the AuthWrapper
  @override
  Widget build(BuildContext context) {
    if (context.watch<AuthProvider>().isAuthenticated) {
      return FutureBuilder<Map<String, dynamic>?>(
          future: context.watch<AuthProvider>().userJson,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text("Error encountered! ${snapshot.error}"),
              );
            } else if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            return HomePage(userData: snapshot.data);
          });
    } else {
      return const LoginPage();
    }
  }
}
