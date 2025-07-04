import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:talent_turbo_new/AppColors.dart';
import 'package:talent_turbo_new/AppConstants.dart';
import 'package:talent_turbo_new/Utils.dart';
import 'package:http/http.dart' as http;
import 'package:talent_turbo_new/screens/auth/forgot_password/forgot_password_otp_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  bool isLoading = false;

  bool _isEmailValid = true;
  TextEditingController emailController = TextEditingController();
  String emailErrorMessage = 'Email ID is Required';

  Future<void> sendPasswordRestOTP() async {
    final url = Uri.parse(AppConstants.BASE_URL + AppConstants.FORGOT_PASSWORD);
    final bodyParams = {
      "email": emailController.text,
    };

    try {
      var connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        // Fluttertoast.showToast(
        //   msg: "No internet connection",
        //   toastLength: Toast.LENGTH_SHORT,
        //   gravity: ToastGravity.BOTTOM,
        //   timeInSecForIosWeb: 1,
        //   backgroundColor: Color(0xff2D2D2D),
        //   textColor: Colors.white,
        //   fontSize: 16.0,
        // );
        IconSnackBar.show(
          context,
          label: 'No internet connection, try again',
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

      var resOBJ = jsonDecode(response.body);

      String statusMessage = resOBJ['message'];
      String status = resOBJ['status'];

      if (response.statusCode == 200) {
        if (status.toLowerCase().trim().contains('ok') ||
            statusMessage.toLowerCase().trim().contains('successfully')) {
          // IconSnackBar.show(
          //   context,
          //   label: statusMessage,
          //   snackBarType: SnackBarType.success,
          //   backgroundColor: Color(0xff4CAF50),
          //   iconColor: Colors.white,
          // );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              backgroundColor: Color(0xff2D2D2D),
              elevation: 10,
              margin: EdgeInsets.only(bottom: 30, left: 15, right: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              content: Row(
                children: [
                  SvgPicture.asset('assets/icon/send.svg'),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      statusMessage,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  GestureDetector(
                    onTap: () =>
                        ScaffoldMessenger.of(context).hideCurrentSnackBar(),
                    child: Icon(Icons.close_rounded, color: Colors.white),
                  )
                ],
              ),
              duration: Duration(seconds: 3),
            ),
          );

          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  ForgotPasswordOTPScreen(email: emailController.text),
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero,
            ),
          );
        } else {
          // Fluttertoast.showToast(
          //     msg: statusMessage,
          //     toastLength: Toast.LENGTH_SHORT,
          //     gravity: ToastGravity.BOTTOM,
          //     timeInSecForIosWeb: 1,
          //     backgroundColor: AppColors.primaryColor,
          //     textColor: Colors.white,
          //     fontSize: 16.0);
          IconSnackBar.show(
            context,
            label: statusMessage,
            snackBarType: SnackBarType.success,
            backgroundColor: Color(0xff004C99),
            iconColor: Colors.white,
          );
        }
      } else if (response.statusCode == 400) {
        if (statusMessage.toLowerCase().contains('not found')) {
          setState(() {
            _isEmailValid = false;
            emailErrorMessage = statusMessage;
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
      }
    } catch (e) {
      print('Error : ${e}');
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
            left: 0,
            bottom: 0,
            child: Image.asset('assets/images/ellipse_bottom.png'),
          ),
          Positioned(
            top: 100,
            bottom: 0,
            child: SingleChildScrollView(
              child: Container(
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.4,
                      child: FittedBox(
                        child: SvgPicture.asset(
                            'assets/images/forgot_password.svg'),
                        fit: BoxFit.contain,
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      'Reset Your Password',
                      style: TextStyle(
                          color: Color(0xff333333),
                          fontFamily: 'Lato',
                          fontSize: 16,
                          fontWeight: FontWeight.w700),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          colors: [Color(0xff545454), Color(0xff004C99)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ).createShader(
                            Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
                        blendMode: BlendMode.srcIn,
                        child: Text(
                          'Please enter the email address associated with your account',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            color: Color(0xff545454),
                            fontSize: 14,
                            fontFamily: 'Lato',
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 60,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                            left: MediaQuery.of(context).size.width * 0.015,
                          ),
                          child: Text(
                            'Email',
                            style: TextStyle(
                                fontSize: 13,
                                fontFamily: 'Lato',
                                color: _isEmailValid
                                    ? Color(0xff333333)
                                    : Color(0xffBA1A1A)),
                          ),
                        ),
                        SizedBox(height: 7),
                        TextField(
                          controller: emailController,
                          cursorColor: Color(0xff004C99),
                          style: TextStyle(
                              fontSize: 14,
                              fontFamily: 'Lato',
                              color: Color(0xff333333)),
                          decoration: InputDecoration(
                              hintText: 'Enter your email',
                              hintStyle: TextStyle(color: Color(0xff545454)),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                    color: _isEmailValid
                                        ? Color(0xffd9d9d9)
                                        : Color(
                                            0xffBA1A1A), // Default border color
                                    width: 1),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                    color: _isEmailValid
                                        ? Color(0xff004C99)
                                        : Color(
                                            0xffBA1A1A), // Border color when focused
                                    width: 1),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 10)),
                          keyboardType: TextInputType.emailAddress,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'[\p{L}\p{N}\p{P}\p{S}]', unicode: true),
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
                            // Validate the email here and update _isEmailValid
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
                      ],
                    ),
                    SizedBox(height: 60),
                    InkWell(
                      onTap: () {
                        if (emailController.text.trim().isEmpty ||
                            !validateEmail(emailController.text)) {
                          if (emailController.text.trim().isEmpty) {
                            setState(() {
                              _isEmailValid = false;
                              emailErrorMessage = 'Email ID is Required';
                            });
                          } else if (!validateEmail(emailController.text)) {
                            setState(() {
                              _isEmailValid = false;
                              emailErrorMessage = 'Enter a valid email address';
                            });
                          }
                        } else {
                          sendPasswordRestOTP();
                        }
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: 44,
                        margin: EdgeInsets.symmetric(horizontal: 0),
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                            color: AppColors.primaryColor,
                            borderRadius: BorderRadius.circular(10)),
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
                                        angle: value *
                                            2 *
                                            3.1416, // Full rotation effect
                                        child: CircularProgressIndicator(
                                          strokeWidth: 4,
                                          value: 0.20, // 1/5 of the circle
                                          backgroundColor: const Color.fromARGB(
                                              142,
                                              234,
                                              232,
                                              232), // Grey stroke
                                          valueColor: AlwaysStoppedAnimation<
                                                  Color>(
                                              Colors
                                                  .white), // White rotating stroke
                                        ),
                                      );
                                    },
                                    onEnd: () =>
                                        {}, // Ensures smooth infinite animation
                                  ),
                                )
                              : Text(
                                  'Send Code',
                                  style: TextStyle(color: Colors.white),
                                ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: 44,
                        margin: EdgeInsets.symmetric(horizontal: 0),
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(10)),
                        child: Center(
                          child: Text(
                            'Back to Login',
                            style: TextStyle(color: AppColors.primaryColor),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 40,
            left: 0,
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back_ios_new),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    height: 50,
                    child: Center(
                      child: Text(
                        'Back',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
