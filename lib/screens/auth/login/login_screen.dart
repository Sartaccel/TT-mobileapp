import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_sign_in/google_sign_in.dart';
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
  final String clientId = '775fcwvghj3bpd';
  final String clientSecret = 'X8572A3w5LQ4aM3d';

  final List<String> scopes = <String>[
    'email',
    'https://www.googleapis.com/auth/contacts.readonly',
  ];

  final AuthService _authService = AuthService();
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<bool> _checkInternetConnection() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      if (mounted) {
        IconSnackBar.show(
          context,
          label: 'No internet connection, try again',
          snackBarType: SnackBarType.alert,
          backgroundColor: Color(0xff2D2D2D),
          iconColor: Colors.white,
        );
      }
      return false;
    }
    return true;
  }

  Future<void> emailSignIn() async {
    final url = Uri.parse(AppConstants.BASE_URL + AppConstants.LOGIN);
    final bodyParams = {
      "email": emailController.text,
      "password": passwordController.text
    };

    try {
      // Check internet connection first
      if (!await _checkInternetConnection()) return;

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
          } else if (statusMessage.toLowerCase().contains('password')) {
            setState(() {
              _isPasswordValid = false;
              passwordErrorMessage = 'Invalid password';
            });
          } else {
            if (mounted) {
              IconSnackBar.show(
                context,
                label: statusMessage,
                snackBarType: SnackBarType.alert,
                backgroundColor: Color(0xffBA1A1A),
                iconColor: Colors.white,
              );
            }
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
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
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
      // Check internet connection first
      if (!await _checkInternetConnection()) return;

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
        var resOBJ = jsonDecode(response.body);
        String statusMessage = resOBJ['message'] ?? '';

        if (!resOBJ['result']) {
          if (statusMessage.toLowerCase().contains('exists')) {
            setState(() {
              _isEmailValid = false;
              emailErrorMessage = 'User doesn\'t exists';
            });
          } else if (statusMessage.toLowerCase().contains('password')) {
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

          await saveUserData(userData);
          UserData? retrievedUserData = await getUserData();

          if (kDebugMode) {
            print('Saved Successfully');
            print('User Name: ${retrievedUserData!.name}');
          }

          fetchCandidateProfileData(
              retrievedUserData!.profileId, retrievedUserData!.token);
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
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Color(0x04FCFCFC),
      statusBarIconBrightness: Brightness.dark,
    ));
    return Scaffold(
      backgroundColor: Color(0xFFFCFCFC),
      body: Stack(
        children: [
          Positioned(
            right: 0,
            child: Image.asset('assets/images/Ellipse 1.png'),
          ),
          Positioned(
            top: 61,
            left: 0,
            child: Image.asset('assets/images/Ellipse 2.png'),
          ),
          Positioned(
              top: 0,
              left: 15,
              right: 15,
              bottom: 0,
              child: SafeArea(
                  child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height * 0.08),
                    Center(
                        child: Image.asset(
                      'assets/images/tt_logo_full_1.png',
                      height: MediaQuery.of(context).size.height * 0.095,
                    )),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                    Align(
                        alignment: Alignment.center,
                        child: Text(
                          'Login',
                          style: TextStyle(
                              color: Color(0xff333333),
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              fontFamily: 'Lato'),
                        )),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                    Padding(
                      padding: EdgeInsets.only(
                        left: MediaQuery.of(context).size.width * 0.015,
                      ),
                      child: Text('Email',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Lato',
                              color: _isEmailValid
                                  ? Color(0xff333333)
                                  : Color(0xffBA1A1A))),
                    ),
                    SizedBox(height: 7),
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: emailController,
                            cursorColor: Color(0xff004C99),
                            style: TextStyle(
                                fontSize: 14,
                                fontFamily: 'Lato',
                                color: Color(0xff545454)),
                            decoration: InputDecoration(
                                hintText: 'Enter your email',
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                      color: _isEmailValid
                                          ? Color(0xffD9D9D9)
                                          : Color(0xffBA1A1A),
                                      width: 1),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                      color: _isEmailValid
                                          ? Color(0xff004C99)
                                          : Color(0xffBA1A1A),
                                      width: 1),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 10)),
                            keyboardType: TextInputType.emailAddress,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'[\p{L}\p{N}\p{P}\p{S}]',
                                    unicode: true),
                              ),
                              FilteringTextInputFormatter.deny(
                                RegExp(r'\s'),
                              ),
                              FilteringTextInputFormatter.deny(
                                RegExp(
                                    r'[\u{1F300}-\u{1F6FF}|\u{1F900}-\u{1F9FF}|\u{2600}-\u{26FF}|\u{2700}-\u{27BF}]',
                                    unicode: true),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _isEmailValid = true;
                              });
                            },
                          ),
                          SizedBox(height: 4),
                          if (!_isEmailValid)
                            Padding(
                              padding: EdgeInsets.only(
                                left: 0,
                              ),
                              child: Text(
                                emailErrorMessage ?? '',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xffBA1A1A),
                                  fontFamily: 'Lato',
                                ),
                              ),
                            ),
                        ]),
                    SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        left: MediaQuery.of(context).size.width * 0.015,
                      ),
                      child: Text('Password',
                          style: TextStyle(
                              fontSize: 13,
                              fontFamily: 'Lato',
                              fontWeight: FontWeight.w500,
                              color: _isPasswordValid
                                  ? Color(0xff333333)
                                  : Color(0xffBA1A1A))),
                    ),
                    SizedBox(height: 7),
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            obscureText: passwordHide,
                            obscuringCharacter: '∗',
                            controller: passwordController,
                            cursorColor: Color(0xff004C99),
                            style: TextStyle(
                                fontSize: 14,
                                fontFamily: 'Lato',
                                color: Color(0xff545454)),
                            decoration: InputDecoration(
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    passwordHide = !passwordHide;
                                  });
                                },
                                icon: SvgPicture.asset(passwordHide
                                    ? 'assets/images/ic_hide_password.svg'
                                    : 'assets/images/ic_show_password.svg'),
                              ),
                              hintText: 'Enter your password',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                    color: _isPasswordValid
                                        ? Color(0xffD9D9D9)
                                        : Color(0xffBA1A1A),
                                    width: 1),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                    color: _isPasswordValid
                                        ? Color(0xff004C99)
                                        : Color(0xffBA1A1A),
                                    width: 1),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 10),
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'[\p{L}\p{N}\p{P}\p{S}]',
                                    unicode: true),
                              ),
                              FilteringTextInputFormatter.deny(RegExp(r'\s')),
                              FilteringTextInputFormatter.deny(
                                RegExp(
                                    r'[\u{1F300}-\u{1F6FF}|\u{1F900}-\u{1F9FF}|\u{2600}-\u{26FF}|\u{2700}-\u{27BF}]',
                                    unicode: true),
                              ),
                            ],
                            onChanged: (val) {
                              setState(() {
                                _isPasswordValid = true;
                              });
                            },
                          ),
                          SizedBox(height: 4),
                          if (!_isPasswordValid)
                            Padding(
                              padding: EdgeInsets.only(
                                left: 0,
                              ),
                              child: Text(
                                passwordErrorMessage ?? '',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xffBA1A1A),
                                  fontFamily: 'Lato',
                                ),
                              ),
                            ),
                        ]),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.03,
                    ),
                    Container(
                      width: (MediaQuery.of(context).size.width) - 15,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          InkWell(
                              onTap: () async {
                                if (!await _checkInternetConnection()) return;
                                Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder: (context, animation,
                                            secondaryAnimation) =>
                                        ForgotPasswordScreen(),
                                    transitionDuration: Duration.zero,
                                    reverseTransitionDuration: Duration.zero,
                                  ),
                                );
                              },
                              child: Text(
                                'Forgot Password?',
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  fontFamily: 'Lato',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textColor2,
                                ),
                              )),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.03,
                    ),
                    InkWell(
                      onTap: () async {
                        // Check internet connection first
                        if (!await _checkInternetConnection()) return;

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
                          await emailSignIn();
                          setState(() => isLoading = false);
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
                                    duration: Duration(seconds: 2),
                                    curve: Curves.linear,
                                    builder: (context, value, child) {
                                      return Transform.rotate(
                                        angle: value * 2 * 3.1416,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 4,
                                          value: 0.20,
                                          backgroundColor: const Color.fromARGB(
                                              142, 234, 232, 232),
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  Colors.white),
                                        ),
                                      );
                                    },
                                    onEnd: () => {},
                                  ),
                                )
                              : Text(
                                  'Login',
                                  style: TextStyle(color: Colors.white),
                                ),
                        ),
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                    InkWell(
                      onTap: () async {
                        // Check internet connection first
                        if (!await _checkInternetConnection()) return;

                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    MobileNumberLogin(),
                            transitionDuration: Duration.zero,
                            reverseTransitionDuration: Duration.zero,
                          ),
                        );
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
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.03,
                    ),
                    Container(
                        width: MediaQuery.of(context).size.width,
                        child: Text(
                          'Or Log in with your',
                          style: TextStyle(
                            color: AppColors.tertiaryColor,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        )),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.03,
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      child: Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            InkWell(
                              onTap: () async {
                                // Check internet connection first
                                if (!await _checkInternetConnection()) return;

                                await _googleAuthService.signOut();
                                final user =
                                    await _authService.signInWithGoogle();
                                if (user != null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            'Welcome ${user.displayName}!')),
                                  );

                                  await socialGoogleSignin(
                                      user.email!,
                                      user.displayName!,
                                      user.displayName!,
                                      "0");
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content:
                                            Text('Sign-in failed. Try again.')),
                                  );
                                }
                              },
                              child: PhysicalModel(
                                  elevation: 1,
                                  color: Color(0xffFCFCFC),
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    height: 50,
                                    width: 50,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                            color: Color(0xffD9D9D9))),
                                    child: Center(
                                      child: Image.asset(
                                        'assets/images/Google__G__Logo-512.webp',
                                        height: 35,
                                      ),
                                    ),
                                  )),
                            )
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.03,
                    ),
                    Container(
                      padding: EdgeInsets.all(10),
                      width: MediaQuery.of(context).size.width,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Don\'t have an account?',
                            style: TextStyle(
                                fontSize:
                                    MediaQuery.of(context).size.width > 360
                                        ? 13
                                        : 12,
                                fontFamily: 'NunitoSans',
                                color: const Color(0xFF333333),
                                fontWeight: FontWeight.w500),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          InkWell(
                              onTap: () async {
                                if (!await _checkInternetConnection()) return;
                                print(MediaQuery.of(context).size.width);
                                Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder: (context, animation,
                                            secondaryAnimation) =>
                                        RegisterNewUser(),
                                    transitionDuration: Duration.zero,
                                    reverseTransitionDuration: Duration.zero,
                                  ),
                                );
                              },
                              child: Text(
                                'Register for free',
                                style: TextStyle(
                                    fontSize:
                                        MediaQuery.of(context).size.width > 360
                                            ? 13
                                            : 12,
                                    fontFamily: 'NunitoSans',
                                    color: const Color(0xFF256EE8),
                                    fontWeight: FontWeight.w600),
                              )),
                        ],
                      ),
                    ),
                  ],
                ),
              ))),
        ],
      ),
    );
  }

  @override
  void initState() {
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

    try {
      if (!await _checkInternetConnection()) return;

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
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  HomeContainer(),
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero,
            ),
            (Route<dynamic> route) => route.isFirst,
          );
        }
      }
    } catch (e) {
      print(e);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchCandidateProfileData(int profileId, String token) async {
    final url = Uri.parse(AppConstants.BASE_URL +
        AppConstants.CANDIDATE_PROFILE +
        profileId.toString());

    try {
      if (!await _checkInternetConnection()) return;

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
          CandidateProfileModel candidateData =
              CandidateProfileModel.fromJson(data);

          await saveCandidateProfileData(candidateData);

          Navigator.pushAndRemoveUntil(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  HomeContainer(),
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero,
            ),
            (Route<dynamic> route) => false,
          );
        }
      }
    } catch (e) {
      print('Exception : ${e}');
      throw e;
    }
  }
}
