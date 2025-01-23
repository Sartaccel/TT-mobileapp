import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:talent_turbo_new/AppColors.dart';
import 'package:talent_turbo_new/Utils.dart';
import 'package:talent_turbo_new/models/candidate_profile_model.dart';
import 'package:talent_turbo_new/models/login_data_model.dart';
import 'package:talent_turbo_new/models/user_data_model.dart';
import 'package:talent_turbo_new/screens/auth/login/login_screen.dart';
import 'package:talent_turbo_new/screens/main/home_container.dart';
import 'package:talent_turbo_new/screens/onboarding/onboarding_container.dart';

import 'AppConstants.dart';
import 'package:http/http.dart' as http;

class AutoLoginSwitcher extends StatefulWidget {
  const AutoLoginSwitcher({super.key});

  @override
  State<AutoLoginSwitcher> createState() => _AutoLoginSwitcherState();
}

class _AutoLoginSwitcherState extends State<AutoLoginSwitcher> {

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child:  Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/images/tt_logo_resized.png'),
            SizedBox(height: 30,),
            LoadingAnimationWidget.fourRotatingDots(
              color: AppColors.primaryColor,
              size: 40,
            ),
          ],
        ),
      ),
    );
  }



  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    fetchProfileFromPref();


  }

  Future<void> fetchCandidateProfileData(int profileId, String token) async {
    //final url = Uri.parse(AppConstants.BASE_URL + AppConstants.REFERRAL_PROFILE + profileId.toString());
    final url = Uri.parse(AppConstants.BASE_URL + AppConstants.CANDIDATE_PROFILE + profileId.toString());



    try {

      var connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult.contains(ConnectivityResult.none)) {
        Fluttertoast.showToast(
          msg: "No internet connection",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Color(0xff2D2D2D),
          textColor: Colors.white,
          fontSize: 16.0,
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
              (Route<dynamic> route) => false,
        );
      }

      setState(() {
        isLoading = true;
      });

      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json', 'Authorization': token},
      );

      if(kDebugMode) {
        print('Response code ${response.statusCode} :: Response => ${response
            .body}');
      }

      if(response.statusCode == 200) {
        var resOBJ = jsonDecode(response.body);

        String statusMessage = resOBJ['message'];

        if(statusMessage.toLowerCase().contains('success')){

          final Map<String, dynamic> data = resOBJ['data'];
          //ReferralData referralData = ReferralData.fromJson(data);
          CandidateProfileModel candidateData = CandidateProfileModel.fromJson(data);

          await saveCandidateProfileData(candidateData);

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => HomeContainer()),
                (Route<dynamic> route) => false, // This will keep Screen 1
          );

        }

      } else{

      }

      setState(() {
        isLoading = false;
      });
    }
    catch(e){
      print(e);
    }
  }

  Future<void> emailSignIn(String email, String password) async {
    final url = Uri.parse(AppConstants.BASE_URL + AppConstants.LOGIN);

    final bodyParams = {
      "email" : email,
      "password" : password
    };

    try{
 var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none)) {
      Fluttertoast.showToast(
        msg: "No internet connection",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Color(0xff2D2D2D),
        textColor: Colors.white,
        fontSize: 16.0,
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
            (Route<dynamic> route) => false,
      );
    }
      setState(() {
        isLoading = true;
      });

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(bodyParams),
      );


      if(kDebugMode) {
        print('Response code ${response.statusCode} :: Response => ${response
            .body}');
      }

      if(response.statusCode ==200){
        var resOBJ = jsonDecode(response.body);

        String statusMessage = resOBJ['message'];

        {
          print(resOBJ.toString());

          final Map<String, dynamic> data = resOBJ['data'];

          UserData userData = UserData.fromJson(data);


          UserCredentials credentials = UserCredentials(username: email, password: password);


          await saveUserData(userData);

          UserData? retrievedUserData = await getUserData();

          if(kDebugMode){
            print('Saved Successfully');
            print('User Name: ${retrievedUserData!.name}');
          }

          //fetchProfileData(retrievedUserData!.profileId, retrievedUserData!.token);
          fetchCandidateProfileData(retrievedUserData!.profileId, retrievedUserData!.token);




        }


      }



    }catch(e){
      print(e.toString());
    } finally{
      setState(() {
        isLoading = false;
      });
    }
  }


  Future<void> fetchProfileFromPref() async {

    UserCredentials? loadedCredentials = await UserCredentials.loadCredentials();
    if (loadedCredentials != null) {
      print('Loaded credentials: ${loadedCredentials.username}');
      emailSignIn(loadedCredentials.username, loadedCredentials.password);

    } else {
      print('No Creds');
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => OnboardingContainer()),
            (Route<dynamic> route) => false,
      );
    }

  }

}
