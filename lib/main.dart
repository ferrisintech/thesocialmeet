import 'package:animations/animations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:thesocialmeet/test/psycho_test.dart';
import 'auth/register.dart';
import 'dashboard.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //init Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final User user = FirebaseAuth.instance.currentUser!;
              if (user.metadata.creationTime == user.metadata.lastSignInTime) {
                // First-time registration
                return TestPage();
              }
              // Regular login
              return DashboardPage();
            } else {
              return RegisterPage();
            }
          },

/*
              return PageTransitionSwitcher(
                duration: const Duration(milliseconds: 1700),
                transitionBuilder: (child, animation, secAnimation) {
                  return FadeThroughTransition(
                    animation: animation,
                    secondaryAnimation: secAnimation,
                    child: child,
                  );
                },
                child: const DashboardPage(),
              );
            } else {
              return const RegisterPage();
            }
            */
          ),
    );
  }
}