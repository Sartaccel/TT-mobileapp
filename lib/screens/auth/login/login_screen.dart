import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:google_sign_in/google_sign_in.dart';

import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:talent_turbo_new/AppColors.dart';
import 'package:talent_turbo_new/AppConstants.dart';
import 'package:talent_turbo_new/Utils.dart';
import 'package:talent_turbo_new/models/candidate_profile_model.dart';
import 'package:talent_turbo_new/models/login_data_model.dart';
import 'package:talent_turbo_new/models/referral_profile_model.dart';
import 'package:talent_turbo_new/models/user_data_model.dart';
import 'package:talent_turbo_new/screens/auth/forgot_password/forgot_password_screen.dart';
import 'package:talent_turbo_new/screens/auth/login/login_with_mobile_screen.dart';
import 'package:talent_turbo_new/screens/auth/register/register_new_user.dart';
import 'package:http/http.dart' as http;
import 'package:talent_turbo_new/screens/main/home_container.dart';

import '../auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isEmailValid = true;
  TextEditingController emailController = TextEditingController();
  String emailErrorMessage = 'Email ID is Required';
  final AuthService _googleAuthService = AuthService();

  bool _isPasswordValid = true;
  bool passwordHide = true;
  final TextEditingController passwordController = TextEditingController();
  String passwordErrorMessage = 'Password is Required';

  bool isLoading = false;

  final String redirectUrl = 'https://dev.talentturbo.us/auth/linkedin';
  //final String redirectUrl = 'https://talentturbo.us/auth/linkedin';
  final String clientId = '775fcwvghj3bpd';
  final String clientSecret = 'X8572A3w5LQ4aM3d';

  final List<String> scopes = <String>[
    'email',
    'https://www.googleapis.com/auth/contacts.readonly',
  ];

  final AuthService _authService = AuthService();
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<void> emailSignIn() async {
  final url = Uri.parse(AppConstants.BASE_URL + AppConstants.LOGIN);

  final bodyParams = {
    "email": emailController.text,
    "password": passwordController.text
  };

  try {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      IconSnackBar.show(
        context,
        label: 'No internet connection',
        snackBarType: SnackBarType.alert,
        backgroundColor: Color(0xff2D2D2D),
        iconColor: Colors.white,
      );
      return; // Exit the function if no internet
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
      print(
          'Response code ${response.statusCode} :: Response => ${response.body}');
    }

    if (response.statusCode == 200) {
      var resOBJ = jsonDecode(response.body);

      String statusMessage = resOBJ['message'];

      if (!resOBJ['result']) {
        if (statusMessage.toLowerCase().contains('exists')) {
          setState(() {
            _isEmailValid = false;
            emailErrorMessage = 'User doesn\'t exist';
          });
        } else if (statusMessage.toLowerCase().contains('passwo')) {
          setState(() {
            _isPasswordValid = false;
            passwordErrorMessage = 'Invalid password';
          });
        } else {
          IconSnackBar.show(
            context,
            label: statusMessage,
            snackBarType: SnackBarType.alert,
            backgroundColor: Color(0xffBA1A1A),
            iconColor: Colors.white,
          );
        }
      } else {
        print(resOBJ.toString());

        final Map<String, dynamic> data = resOBJ['data'];
        UserData userData = UserData.fromJson(data);

        UserCredentials credentials = UserCredentials(
            username: emailController.text,
            password: passwordController.text);
        await credentials.saveCredentials();

        await saveUserData(userData);

        UserData? retrievedUserData = await getUserData();

        if (kDebugMode) {
          print('Saved Successfully');
          print('User Name: ${retrievedUserData!.name}');
        }

        fetchCandidateProfileData(
            retrievedUserData!.profileId, retrievedUserData!.token);
        Navigator.pushReplacementNamed(context, '/home');
      }
    }
  } catch (e) {
    print(e.toString());
  } finally {
    setState(() {
      isLoading = false;
    });
  }
}


  Future<void> socialGoogleSignin(
      String email, String fn, String ln, String mobile) async {
    final url = Uri.parse(AppConstants.BASE_URL + AppConstants.SOCIAL_LOGIN);

    final bodyParams = {
      "firstName": fn,
      "lastName": ln,
      "email": email,
      "phoneNumber": mobile,
      "countryCode": "+91",
      "priAccUserType": "candidate",
      "socialLoginProvider": "Google",
      "deviceType": "Android",
      "deviceToken": "",
      "deviceUuid": ""
    };

    try {
      var connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult.contains(ConnectivityResult.none)) {
        // Fluttertoast.showToast(
        //   msg: "No internet connection",
        //   toastLength: Toast.LENGTH_SHORT,
        //   gravity: ToastGravity.BOTTOM,
        //   timeInSecForIosWeb: 1,
        //   backgroundColor: const Color(0xff2D2D2D),
        //   textColor: Colors.white,
        //   fontSize: 16.0,
        // );
        IconSnackBar.show(
          context,
          label: 'No internet connection',
          snackBarType: SnackBarType.alert,
          backgroundColor: Color(0xff2D2D2D),
          iconColor: Colors.white,
        );
        return; // Exit the function if no internet
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
        print(
            'Response code Social ${response.statusCode} :: Response => ${response.body}');
      }

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('Trying to save - 1');
        }
        var resOBJ = jsonDecode(response.body);

        if (kDebugMode) {
          print('Trying to save - 2');
        }

        String statusMessage = resOBJ['message'] ?? '';

        if (kDebugMode) {
          print('Trying to save - 3');
        }

        if (!resOBJ['result']) {
          if (statusMessage.toLowerCase().contains('exists')) {
            setState(() {
              _isEmailValid = false;
              emailErrorMessage = 'User doesn\'t exists';
            });
          } else if (statusMessage.toLowerCase().contains('passwo')) {
            setState(() {
              _isPasswordValid = false;
              passwordErrorMessage = 'Invalid password';
            });
          } else {
            // Fluttertoast.showToast(
            //     msg: statusMessage,
            //     toastLength: Toast.LENGTH_SHORT,
            //     gravity: ToastGravity.BOTTOM,
            //     timeInSecForIosWeb: 1,
            //     backgroundColor: Colors.red,
            //     textColor: Colors.white,
            //     fontSize: 16.0);
            IconSnackBar.show(
              context,
              label: statusMessage,
              snackBarType: SnackBarType.alert,
              backgroundColor: Color(0xffBA1A1A),
              iconColor: Colors.white,
            );
          }
        } else {
          print(resOBJ.toString());

          if (kDebugMode) {
            print('Trying to save');
          }
          final Map<String, dynamic> data = resOBJ['data'];
          // Map the API response to UserData model

          UserData userData = UserData.fromJson(data);

          if (kDebugMode) {
            print('Stage 1');
          }
          //UserCredentials credentials = UserCredentials(username: emailController.text, password: passwordController.text);
          //await credentials.saveCredentials();

          await saveUserData(userData);

          if (kDebugMode) {
            print('Stage 2');
          }

          UserData? retrievedUserData = await getUserData();

          if (kDebugMode) {
            print('Stage 3');
          }
          if (kDebugMode) {
            print('Saved Successfully');
            print('User Name: ${retrievedUserData!.name}');
          }

          //fetchProfileData(retrievedUserData!.profileId, retrievedUserData!.token);
          fetchCandidateProfileData(
              retrievedUserData!.profileId, retrievedUserData!.token);

          // In Screen 3
        }
      }
    } catch (e) {
      print('exception :  => ' + e.toString());
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
  children: [
    // Fixed Background Decorations
    Positioned(
      right: 0,
      child: Image.asset('assets/images/Ellipse 1.png'),
    ),
    Positioned(
      top: 61,
      left: 0,
      child: Image.asset('assets/images/Ellipse 2.png'),
    ),

    // Scrollable Content (Logo + Login Form)
    Positioned.fill(
      child: SingleChildScrollView(
        physics: BouncingScrollPhysics(), // Smooth scrolling effect
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 50), // Adjust spacing
            Center(
              child: Image.asset(
                'assets/images/tt_logo_full_1.png',
                width: 220,
                height: 100,
              ),
            ),
            
            
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      'Login',
                      style: TextStyle(
                        color: AppColors.textColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        fontFamily: 'Lato',
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  
                  Text(
                    'Email',
                    style: TextStyle(
                        fontSize: 13,
                        fontFamily: 'Lato',
                        color: Color(0xff333333)),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: emailController,
                    style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Lato',
                        color: Color(0xff333333)),
                    decoration: InputDecoration(
                        hintText: 'Enter your email',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                              color: _isEmailValid
                                  ? Color(0xffD9D9D9)
                                  : Color(0xffBA1A1A), // Default border color
                              width: 1),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                              color: _isEmailValid
                                  ? Color(0xff004C99)
                                  : Color(0xffBA1A1A), // Border color when focused
                              width: 1),
                        ),
                        errorText: _isEmailValid
                            ? null
                            : emailErrorMessage, // Display error message if invalid
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 10, horizontal: 10)),
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (value) {
                      // Validate the email here and update _isEmailValid
                      setState(() {
                        _isEmailValid = true;
                      });
                    },
                  ),
              
                  SizedBox(
                    height: 20,
                  ),
                  Text('Password',
                      style: TextStyle(fontSize: 13, fontFamily: 'Lato')),
                  SizedBox(
                    height: 10,
                  ),
                  TextField(
                    obscureText: passwordHide,
                    controller: passwordController,
                    style: TextStyle(fontSize: 14, fontFamily: 'Lato'),
                    decoration: InputDecoration(
                        suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                passwordHide = !passwordHide;
                              });
                            },
                            //icon: Icon( passwordHide?Icons.visibility :Icons.visibility_off)),
                            icon: SvgPicture.asset(passwordHide
                                ? 'assets/images/ic_hide_password.svg'
                                : 'assets/images/ic_show_password.svg')),
                        hintText: 'Enter your password',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                              color: _isPasswordValid
                                  ? Color(0xffD9D9D9)
                                  : Color(0xffBA1A1A), // Default border color
                              width: 1),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                              color: _isPasswordValid
                                  ? Color(0xff004C99)
                                  : Color(0xffBA1A1A), // Border color when focused
                              width: 1),
                        ),
                        errorText: _isPasswordValid
                            ? null
                            : passwordErrorMessage, // Display error message if invalid
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 10, horizontal: 10)),
                    onChanged: (val) {
                      setState(() {
                        _isPasswordValid = true;
                      });
                    },
                  ),
              
                  SizedBox(
                    height: 30,
                  ),
                  Container(
                    width: (MediaQuery.of(context).size.width) - 15,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          ForgotPasswordScreen()));
                            },
                            child: Text(
                              'Forgot Password?',
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                fontFamily: 'Lato',
                                fontWeight: FontWeight.w600,
                                color: AppColors.textColor2,
                              ),
                            )),
                      ],
                    ),
                  ),
                SizedBox(
                  height: 30,
                ),
              
                  
                 InkWell(
  onTap: isLoading
      ? null
      : () {
          if (emailController.text.trim().isEmpty ||
              !validateEmail(emailController.text) ||
              passwordController.text.trim().isEmpty) {
            if (emailController.text.trim().isEmpty) {
              setState(() {
                _isEmailValid = false;
                emailErrorMessage = 'Email ID is Required';
              });
            } else if (!validateEmail(emailController.text)) {
              setState(() {
                _isEmailValid = false;
                emailErrorMessage = 'Email ID is Required';
              });
            }

            if (passwordController.text.trim().isEmpty) {
              setState(() {
                _isPasswordValid = false;
                passwordErrorMessage = 'Password is Required';
              });
            }
          } else {
            setState(() => isLoading = true);
            emailSignIn().then((_) {
              setState(() => isLoading = false);
            });
          }
        },
  child: Container(
    width: MediaQuery.of(context).size.width,
    height: 44,
    margin: EdgeInsets.symmetric(horizontal: 0),
    padding: EdgeInsets.symmetric(horizontal: 10),
    decoration: BoxDecoration(
      color: AppColors.primaryColor,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Center(
      child: isLoading
          ? SizedBox(
  height: 24,
  width: 24,
  child: TweenAnimationBuilder<double>(
    tween: Tween<double>(begin: 0, end: 5),
    duration: Duration(seconds: 2), // Faster rotation (Reduced duration)
    curve: Curves.linear,
    builder: (context, value, child) {
      return Transform.rotate(
        angle: value * 2 * 3.1416, // Full rotation effect
        child: CircularProgressIndicator(
          strokeWidth: 4,
          value: 0.20, // 1/5 of the circle
          backgroundColor: const Color.fromARGB(142, 234, 232, 232), // Grey stroke
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white), // White rotating stroke
        ),
      );
    },
    onEnd: () => {}, // Ensures smooth infinite animation
  ),
) : Text(
              'Login',
              style: TextStyle(color: Colors.white),
            ),
    ),
  ),
),

SizedBox(height: 20),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (BuildContext con) =>
                                    MobileNumberLogin()));
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: 44,
                        margin: EdgeInsets.symmetric(horizontal: 0),
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                            border: Border.all(color: AppColors.primaryColor),
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10)),
                        child: Center(
                          child: Text(
                            'Login with OTP',
                            style: TextStyle(color: AppColors.primaryColor),
                          ),
                        ),
                      ),
                    ),
              
                  //  Container( width: MediaQuery.of(context).size.width,child: Text('Or Log in with your', style: TextStyle(color: AppColors.tertiaryColor), textAlign: TextAlign.center,)),
              
                  // SizedBox(height: 30,),
                  /* Container(
                width: MediaQuery.of(context).size.width,
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        onTap: () async {
                          await _googleAuthService.signOut();
                          //await _googleSignIn.disconnect();
              
                          final user = await _authService.signInWithGoogle();
                          if (user != null) {
                            // ignore: use_build_context_synchronously
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Welcome ${user.displayName}!')),
                            );
              
                            socialGoogleSignin(user.email!, user.displayName!, user.displayName!, "0");
                          } else {
                            // ignore: use_build_context_synchronously
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Sign-in failed. Try again.')),
                            );
                          }
                        },
                        child: PhysicalModel(elevation: 1,color: Colors.white,borderRadius: BorderRadius.circular(8) ,child: Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(8),border: Border.all(color: Color(0xffD9D9D9))),
                         // child: Center(child: Image.asset('assets/images/Google_G_Logo-512.webp', height: 35,),),
                          //child: Center(child: SvgPicture.asset('assets/images/ic_google.svg', height: 220,),),
                        )),
                      )
                     /* SizedBox(width: 53,),
                      InkWell(
                        onTap: (){
                          print('LinkedIn Test');
                          showDialog(
                            context: context,
                            builder: (context) {
                              return LinkedInUserWidget(
                                redirectUrl: redirectUrl,
                                clientId: clientId,
                                clientSecret: clientSecret,
                                onGetUserProfile: (UserSucceededAction linkedInUser) {
                                  print('Access token: ${linkedInUser.user.token}');
                                  print('First name: ${linkedInUser.user.givenName}');
                                  print('Last name: ${linkedInUser.user.familyName}');
                                },
                                onError: (UserFailedAction e) {
                                  print('Error: ${e.toString()}');
                                },
                              );
                            },
                          );
                        },
                        child: PhysicalModel(elevation: 1,color: Colors.white,borderRadius: BorderRadius.circular(8) ,child: Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(8),border: Border.all(color: Color(0xffD9D9D9))),
                          child: Center(child: Image.asset('assets/images/LinkedIn_icon_circle.svg.png', height: 35,),),
                          //child: Center(child: SvgPicture.asset('assets/images/ic_linked.svg', ),),
                        )),
                      )
              
                      */
                    ],
                  ),
                ),
              ),*/
              
                  SizedBox(
                    height: 30,
                  ),
                  Container(
                    padding: EdgeInsets.all(10),
                    width: MediaQuery.of(context).size.width,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Don’t have an account?',
                          style: TextStyle(
                              fontSize:
                                  MediaQuery.of(context).size.width > 360
                                      ? 13
                                      : 12,
                              fontFamily: 'NunitoSans',
                              color: AppColors.textColor,
                              fontWeight: FontWeight.w600),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        InkWell(
                            onTap: () {
                              print(MediaQuery.of(context).size.width);
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          RegisterNewUser()));
                            },
                            child: Text(
                              'Register for free',
                              style: TextStyle(
                                  fontSize:
                                      MediaQuery.of(context).size.width > 360
                                          ? 13
                                          : 12,
                                  fontFamily: 'NunitoSans',
                                  color: AppColors.textColor2,
                                  fontWeight: FontWeight.w600),
                            )),
                      ],
                    ),
                  ),
              
                  SizedBox(
                    height: 0,
                  ),
                ],
              ))
        ],
      ),
      )
    )
  ]
      )
    );
  }

  @override
  void initState() {
  
    //emailController.text = 'gayathrikabi15@gmail.com';
    //passwordController.text='changeme';

    //emailController.text = 'gayathri7251+50@gmail.com';
    //passwordController.text='changeme';

    super.initState();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();

    super.dispose();
  }

  Future<void> fetchProfileData(int profileId, String token) async {
    final url = Uri.parse(AppConstants.BASE_URL +
        AppConstants.REFERRAL_PROFILE +
        profileId.toString());
    //final url = Uri.parse(AppConstants.BASE_URL + AppConstants.CANDIDATE_PROFILE + profileId.toString());

    try {
      setState(() {
        isLoading = true;
      });

      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json', 'Authorization': token},
      );

      if (kDebugMode) {
        print(
            'Response code ${response.statusCode} :: Response => ${response.body}');
      }

      if (response.statusCode == 200) {
        var resOBJ = jsonDecode(response.body);

        String statusMessage = resOBJ['message'];

        if (statusMessage.toLowerCase().contains('success')) {
          final Map<String, dynamic> data = resOBJ['data'];
          ReferralData referralData = ReferralData.fromJson(data);

          await saveReferralProfileData(referralData);

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => HomeContainer()),
            (Route<dynamic> route) => route.isFirst, // This will keep Screen 1
          );
        }
      } else {}

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> fetchCandidateProfileData(int profileId, String token) async {
    //final url = Uri.parse(AppConstants.BASE_URL + AppConstants.REFERRAL_PROFILE + profileId.toString());
    final url = Uri.parse(AppConstants.BASE_URL +
        AppConstants.CANDIDATE_PROFILE +
        profileId.toString());

    try {
      setState(() {
        isLoading = true;
      });

      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json', 'Authorization': token},
      );

      if (kDebugMode) {
        print(
            'Response code ${response.statusCode} :: Response => ${response.body}');
      }

      if (response.statusCode == 200) {
        var resOBJ = jsonDecode(response.body);

        String statusMessage = resOBJ['message'];

        if (statusMessage.toLowerCase().contains('success')) {
          final Map<String, dynamic> data = resOBJ['data'];
          //ReferralData referralData = ReferralData.fromJson(data);
          CandidateProfileModel candidateData =
              CandidateProfileModel.fromJson(data);

          await saveCandidateProfileData(candidateData);

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => HomeContainer()),
            (Route<dynamic> route) => false, // This will keep Screen 1
          );
        }
      } else {}

      /*setState(() {
        isLoading = false;
      });*/
    } catch (e) {
      print('Exception : ${e}');
      throw e;
    }
  }
}