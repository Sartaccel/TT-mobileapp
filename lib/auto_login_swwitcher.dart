/*import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talent_turbo_new/AppColors.dart';
import 'package:talent_turbo_new/Utils.dart';
import 'package:talent_turbo_new/models/candidate_profile_model.dart';
import 'package:talent_turbo_new/models/login_data_model.dart';
import 'package:talent_turbo_new/models/user_data_model.dart';
import 'package:talent_turbo_new/screens/auth/login/login_screen.dart';
import 'package:talent_turbo_new/screens/main/home_container.dart';
import 'package:talent_turbo_new/screens/onboarding/onboarding_container.dart';
import 'package:http/http.dart' as http;
import '../AppConstants.dart';

class AutoLoginSwitcher extends StatefulWidget {
  const AutoLoginSwitcher({super.key});

  @override
  State<AutoLoginSwitcher> createState() => _AutoLoginSwitcherState();
}

class _AutoLoginSwitcherState extends State<AutoLoginSwitcher> {
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchProfileFromPref();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/images/tt_logo_resized.png'),
            const SizedBox(height: 30),
            LoadingAnimationWidget.fourRotatingDots(
              color: AppColors.primaryColor,
              size: 40,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> fetchProfileFromPref() async {
    UserCredentials? loadedCredentials = await UserCredentials.loadCredentials();

    if (loadedCredentials == null) {
      print('No stored credentials, redirecting to onboarding.');
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => OnboardingContainer()),
        (Route<dynamic> route) => false,
      );
      return;
    }

    print('Loaded credentials: ${loadedCredentials.username}');

    if (await Connectivity().checkConnectivity() == ConnectivityResult.none) {
      // No internet, try offline login
      UserData? storedUser = await getUserData();
      if (storedUser != null) {
        print('Offline mode: Using stored user data.');
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => HomeContainer()),
          (Route<dynamic> route) => false,
        );
        return;
      } else {
        print('No stored user data, redirecting to login.');
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
          (Route<dynamic> route) => false,
        );
        return;
      }
    }

    // If online, proceed with login attempt
    emailSignIn(loadedCredentials.username, loadedCredentials.password);
  }

  Future<void> emailSignIn(String email, String password) async {
    final url = Uri.parse(AppConstants.BASE_URL + AppConstants.LOGIN);
    final bodyParams = {"email": email, "password": password};

    try {
      if (await Connectivity().checkConnectivity() == ConnectivityResult.none) {
        Fluttertoast.showToast(
          msg: "No internet connection",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: const Color(0xff2D2D2D),
          textColor: Colors.white,
          fontSize: 16.0,
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
          (Route<dynamic> route) => false,
        );
        return;
      }

      setState(() {
        isLoading = true;
      });

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(bodyParams),
      );

      if (kDebugMode) {
        print('Response code ${response.statusCode} :: Response => ${response.body}');
      }

      if (response.statusCode == 200) {
        var resOBJ = jsonDecode(response.body);
        String statusMessage = resOBJ['message'];

        if (statusMessage.toLowerCase().contains('success')) {
          final Map<String, dynamic> data = resOBJ['data'];
          UserData userData = UserData.fromJson(data);

          await saveUserData(userData);
          fetchCandidateProfileData(userData.profileId, userData.token);
        } else {
          print('Login failed: $statusMessage');
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen()),
            (Route<dynamic> route) => false,
          );
        }
      } else {
        print('Server error, status code: ${response.statusCode}');
      }
    } catch (e) {
      print("Login error: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchCandidateProfileData(int profileId, String token) async {
    final url = Uri.parse(AppConstants.BASE_URL + AppConstants.CANDIDATE_PROFILE + profileId.toString());

    try {
      if (await Connectivity().checkConnectivity() == ConnectivityResult.none) {
        Fluttertoast.showToast(
          msg: "No internet connection",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: const Color(0xff2D2D2D),
          textColor: Colors.white,
          fontSize: 16.0,
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
          (Route<dynamic> route) => false,
        );
        return;
      }

      setState(() {
        isLoading = true;
      });

      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json', 'Authorization': token},
      );

      if (kDebugMode) {
        print('Response code ${response.statusCode} :: Response => ${response.body}');
      }

      if (response.statusCode == 200) {
        var resOBJ = jsonDecode(response.body);
        if (resOBJ['message'].toLowerCase().contains('success')) {
          final Map<String, dynamic> data = resOBJ['data'];
          CandidateProfileModel candidateData = CandidateProfileModel.fromJson(data);
          await saveCandidateProfileData(candidateData);

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => HomeContainer()),
            (Route<dynamic> route) => false,
          );
        }
      }
    } catch (e) {
      print("Profile fetch error: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> saveUserData(UserData userData) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userDataJson = jsonEncode(userData.toJson());
    await prefs.setString('userData', userDataJson);
  }

  Future<UserData?> getUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userDataJson = prefs.getString('userData');
    if (userDataJson != null) {
      Map<String, dynamic> userMap = jsonDecode(userDataJson);
      return UserData.fromJson(userMap);
    }
    return null;
  }
}
*/