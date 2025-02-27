import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:talent_turbo_new/AppColors.dart';
import 'package:talent_turbo_new/AppConstants.dart';
import 'package:http/http.dart' as http;

class ResetNewPassword extends StatefulWidget {
  final id;
  const ResetNewPassword({super.key, required this.id});

  @override
  State<ResetNewPassword> createState() => _ResetNewPasswordState();
}

class _ResetNewPasswordState extends State<ResetNewPassword> {
  bool isLoading = false;

  bool _isPasswordValid = true;
  TextEditingController passwordController = TextEditingController();

  bool _isConfirmPasswordValid = true;
  TextEditingController confirmPasswordController = TextEditingController();
  bool confirmPasswordHide = true, passwordHide = true;
  String confirm_passwordErrorMSG = "Password cannot be empty";
  String passwordErrorMSG = "Password cannot be empty";

  Future<void> setNewPassword() async {
    final url = Uri.parse(
        AppConstants.BASE_URL + AppConstants.FORGOT_PASSWORD_UPDATE_PASSWORD);

    final bodyParams = {"id": widget.id, "password": passwordController.text};

    try {
      setState(() {
        isLoading = true;
      });
      final response = await http.post(url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(bodyParams));

      setState(() {
        isLoading = false;
      });

      if (response.statusCode == 200 || response.statusCode == 202) {
        var resOBJ = jsonDecode(response.body);

        // String statusMessage = resOBJ["status"];
        String statusMessage = resOBJ["message"];

        if (statusMessage.toLowerCase().contains('success')) {
          // Fluttertoast.showToast(
          //     msg: statusMessage,
          //     toastLength: Toast.LENGTH_SHORT,
          //     gravity: ToastGravity.BOTTOM,
          //     timeInSecForIosWeb: 1,
          //     backgroundColor: Colors.green,
          //     textColor: Colors.white,
          //     fontSize: 16.0);
          IconSnackBar.show(
            context,
            label: statusMessage,
            snackBarType: SnackBarType.success,
            backgroundColor: Color(0xff4CAF50),
            iconColor: Colors.white,
          );

          Navigator.pop(context);
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
            backgroundColor: Color(0xFFBA1A1A),
            iconColor: Colors.white,
          );
        }
      } else {
        if (kDebugMode) {
          print('${response.statusCode} :: ${response.body}');
        }
      }
    } catch (e) {
      setState(() {
        isLoading = true;
      });
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  void validatePassword() {
    if (passwordController.text.length < 8) {
      setState(() {
        _isPasswordValid = false;
        passwordErrorMSG = 'Password must be at-least 8 characters';
      });
    } else if (passwordController.text != confirmPasswordController.text) {
      setState(() {
        _isConfirmPasswordValid = false;
        confirm_passwordErrorMSG = 'Passwords do not match';
      });
      if (kDebugMode) {
        print('Not Equal passwords');
      }
    } else {
      setNewPassword();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset('assets/images/otp_img.png'),
                  Center(
                      child: Text(
                    'Create new password',
                    style: TextStyle(
                        fontFamily: 'Lato',
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  )),
                  SizedBox(
                    height: 40,
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        'New Password',
                        style: TextStyle(fontSize: 13, fontFamily: 'Lato'),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        width: (MediaQuery.of(context).size.width) - 20,
                        child: TextField(
                          controller: passwordController,
                          cursorColor: Color(0xff004C99),
                          obscureText: passwordHide,
                          style: TextStyle(fontSize: 14, fontFamily: 'Lato'),
                          decoration: InputDecoration(
                              suffixIcon: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      passwordHide = !passwordHide;
                                    });
                                  },
                                  icon: SvgPicture.asset(passwordHide
                                      ? 'assets/images/ic_hide_password.svg'
                                      : 'assets/images/ic_show_password.svg')),
                              hintText: 'Enter password',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                    color: _isPasswordValid
                                        ? Color(0xffd9d9d9)
                                        : Colors.red, // Default border color
                                    width: 1),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                    color: _isPasswordValid
                                        ? Color(0xff004C99)
                                        : Colors
                                            .red, // Border color when focused
                                    width: 1),
                              ),
                              errorText: _isPasswordValid
                                  ? null
                                  : passwordErrorMSG, // Display error message if invalid
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 10)),
                          onChanged: (value) {
                            // Validate the email here and update _isEmailValid
                            if (value.length < 8) {
                              setState(() {
                                _isPasswordValid = false;
                                passwordErrorMSG =
                                    'Password must be at-least 8 characters';
                              });
                            } else {
                              setState(() {
                                _isPasswordValid = true;
                              });
                            }
                          },
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        'Re-enter Password',
                        style: TextStyle(fontSize: 13, fontFamily: 'Lato'),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        width: (MediaQuery.of(context).size.width) - 20,
                        child: TextField(
                          controller: confirmPasswordController,
                          cursorColor: Color(0xff004C99),
                          obscureText: confirmPasswordHide,
                          style: TextStyle(fontSize: 14, fontFamily: 'Lato'),
                          decoration: InputDecoration(
                              suffixIcon: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      confirmPasswordHide =
                                          !confirmPasswordHide;
                                    });
                                  },
                                  icon: SvgPicture.asset(confirmPasswordHide
                                      ? 'assets/images/ic_hide_password.svg'
                                      : 'assets/images/ic_show_password.svg')),
                              hintText: 'Re-enter your password',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                    color: _isConfirmPasswordValid
                                        ? Color(0xffd9d9d9)
                                        : Color(
                                            0xffBA1A1A), // Default border color
                                    width: 1),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                    color: _isConfirmPasswordValid
                                        ? Color(0xff004C99)
                                        : Color(
                                            0xffBA1A1A), // Border color when focused
                                    width: 1),
                              ),
                              errorText: _isConfirmPasswordValid
                                  ? null
                                  : confirm_passwordErrorMSG, // Display error message if invalid
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 10)),
                          onChanged: (value) {
                            // Validate the email here and update _isEmailValid
                            setState(() {
                              _isConfirmPasswordValid = true;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 50),
                  InkWell(
                    onTap: () {
                      validatePassword();
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
                                            142, 234, 232, 232), // Grey stroke
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(Colors
                                                .white), // White rotating stroke
                                      ),
                                    );
                                  },
                                  onEnd: () =>
                                      {}, // Ensures smooth infinite animation
                                ),
                              )
                            : Text(
                                'Reset Password',
                                style: TextStyle(color: Colors.white),
                              ),
                      ),
                    ),
                  ),
                ],
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
                          ))))
                ],
              )),
        ],
      ),
    );
  }

  @override
  void dispose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
