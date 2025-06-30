import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:talent_turbo_new/data/preference.dart';
import 'package:talent_turbo_new/screens/main/home_container.dart';
import 'package:talent_turbo_new/screens/onboarding/onboarding_container.dart';
import 'firebase_options.dart';
import './PushNotificationservice.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SharedPreferences via Preference
  await Preference.init();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // 🔔 Init Push Notifications
  FirebaseMessaging.onBackgroundMessage(
      PushNotificationService.backgroundHandler);
  await PushNotificationService.init();

  // Get initial screen
  final initialScreen = getInitialScreen();

  runApp(MyApp(initialScreen: initialScreen));
}

Widget getInitialScreen() {
  debugPrint("Token on launch: ${Preference.token}");
  debugPrint("IsLogined on launch: ${Preference.isLogined}");

  if (Preference.token.isNotEmpty && Preference.isLogined) {
    return const HomeContainer(); // Go to home if token and isLogined are valid
  } else {
    return const OnboardingContainer(); // Otherwise, show onboarding
  }
}

class MyApp extends StatelessWidget {
  final Widget initialScreen;
  const MyApp({super.key, required this.initialScreen});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TalentTurbo',
      home: initialScreen,
      debugShowCheckedModeBanner: false,
    );
  }
}
