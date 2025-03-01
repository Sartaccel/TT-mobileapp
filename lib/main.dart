import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talent_turbo_new/screens/main/fragments/success_animation.dart';
import 'package:talent_turbo_new/screens/main/home_container.dart';
import 'package:talent_turbo_new/screens/onboarding/onboarding_container.dart';
import 'firebase_options.dart';
import 'models/user_data_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Check user session before launching the app
  Widget initialScreen = await getInitialScreen();

  runApp(MyApp(initialScreen: initialScreen));
}

Future<Widget> getInitialScreen() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? userDataJson = prefs.getString('userData');

  if (userDataJson != null) {
    return HomeContainer(); // If user is logged in, go to home screen
  } else {
    return OnboardingContainer(); // Otherwise, go to onboarding screen
  }
}

class MyApp extends StatefulWidget {
  final Widget initialScreen;
  const MyApp({super.key, required this.initialScreen});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Talent Turbo',
      home: widget.initialScreen,
      debugShowCheckedModeBanner: false,
    );
  }
}
