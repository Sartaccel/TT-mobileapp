import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:talent_turbo_new/auto_login_swwitcher.dart';
import 'package:talent_turbo_new/screens/auth/forgot_password/forgot_password_otp_screen.dart';
import 'package:talent_turbo_new/screens/auth/forgot_password/forgot_password_screen.dart';
import 'package:talent_turbo_new/screens/auth/login/login_screen.dart';
import 'package:talent_turbo_new/screens/auth/login/login_with_mobile_screen.dart';
import 'package:talent_turbo_new/screens/auth/login_otp/login_otp_screen.dart';
import 'package:talent_turbo_new/screens/auth/register/register_new_user.dart';
import 'package:talent_turbo_new/screens/jobDetails/JobDetails.dart';
import 'package:talent_turbo_new/screens/jobDetails/companyDetails.dart';
import 'package:talent_turbo_new/screens/jobDetails/job_apply.dart';
import 'package:talent_turbo_new/screens/jobDetails/job_status.dart';
import 'package:talent_turbo_new/screens/jobDetails/postSubmission.dart';
import 'package:talent_turbo_new/screens/main/AccountSettings.dart';
import 'package:talent_turbo_new/screens/main/AddDeleteSkills.dart';
import 'package:talent_turbo_new/screens/main/AddEducation.dart';
import 'package:talent_turbo_new/screens/main/AddEmployment.dart';
import 'package:talent_turbo_new/screens/main/SearchAndFilter.dart';
import 'package:talent_turbo_new/screens/main/edit_personal_details.dart';
import 'package:talent_turbo_new/screens/main/fragments/profile_fragment.dart';
import 'package:talent_turbo_new/screens/main/home_container.dart';
import 'package:talent_turbo_new/screens/main/notification_settings.dart';
import 'package:talent_turbo_new/screens/main/personal_details.dart';
import 'package:talent_turbo_new/screens/main/rewards.dart';
import 'package:talent_turbo_new/screens/onboarding/onboarding_container.dart';
import 'package:talent_turbo_new/test_screens/otp_test_screen.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'TalentTurbo',

      //home: const MyHomePage(title: 'Flutter Demo Home Page3'),
      home: AutoLoginSwitcher(),
      //home: ForgotPasswordOTPScreen(email: 'dsds'),
      debugShowCheckedModeBanner: false,
    );
  }
}
