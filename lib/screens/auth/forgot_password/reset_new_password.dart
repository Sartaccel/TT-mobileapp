import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:talent_turbo_new/AppColors.dart';
import 'package:talent_turbo_new/AppConstants.dart';
import 'package:http/http.dart' as http;
import 'package:talent_turbo_new/screens/main/fragments/success_animation.dart';

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
  String confirm_passwordErrorMSG = '';
  String passwordErrorMSG = '';

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
        String statusMessage = resOBJ["message"];

        if (statusMessage.toLowerCase().contains('success')) {
          IconSnackBar.show(
            context,
            label: statusMessage,
            snackBarType: SnackBarType.success,
            backgroundColor: Color(0xff4CAF50),
            iconColor: Colors.white,
          );

          // Navigate to success animation page
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => SuccessAnimation()),
          );
        } else {
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
        isLoading = false;
      });
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  void validatePassword() {
    String password = passwordController.text.trim();
    String confirmPassword = confirmPasswordController.text.trim();

    setState(() {
      _isPasswordValid = password.isNotEmpty && password.length >= 8;
      _isConfirmPasswordValid =
          confirmPassword.isNotEmpty && password == confirmPassword;

      passwordErrorMSG = password.isEmpty
          ? 'Password is Required'
          : (password.length < 8 ? 'Must be Atleast 8 characters' : '');

      confirm_passwordErrorMSG = confirmPassword.isEmpty
          ? 'Password is Required'
          : (password != confirmPassword ? 'Password didn\'t match' : '');
    });

    if (_isPasswordValid && _isConfirmPasswordValid) {
      setNewPassword();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffFCFCFC),
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
            top: 120,
            child: Container(
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.4,
                    child: FittedBox(
                      child: SvgPicture.asset('assets/images/otp_img.svg'),
                      fit: BoxFit.contain,
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Center(
                      child: Text(
                    'Create new password',
                    style: TextStyle(
                        color: Color(0xff333333),
                        fontFamily: 'Lato',
                        fontSize: 16,
                        fontWeight: FontWeight.w700),
                  )),
                  SizedBox(
                    height: 20,
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 20,
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          left: MediaQuery.of(context).size.width * 0.015,
                        ),
                        child: Text(
                          'New Password',
                          style: TextStyle(
                              fontSize: 13,
                              fontFamily: 'Lato',
                              fontWeight: FontWeight.w500,
                              color: _isPasswordValid
                                  ? const Color(0xFF333333)
                                  : const Color(0xFFBA1A1A)),
                        ),
                      ),
                      SizedBox(height: 7),
                      Container(
                        width: (MediaQuery.of(context).size.width) - 20,
                        child: TextField(
                            controller: passwordController,
                            cursorColor: Color(0xff004C99),
                            obscureText: passwordHide,
                            enabled: !isLoading,
                            style: TextStyle(
                                fontSize: 14,
                                fontFamily: 'Lato',
                                color: Color(0xff333333)),
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
                              hintStyle: TextStyle(color: Color(0xff545454)),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                    color: _isPasswordValid
                                        ? Color(0xffd9d9d9)
                                        : Color(0xffBA1a1a),
                                    width: 1),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                    color: _isPasswordValid
                                        ? Color(0xff004C99)
                                        : Color(0xffBA1a1a),
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
                            onChanged: (value) {
                              setState(() {
                                _isPasswordValid = true;
                              });
                            }),
                      ),
                      SizedBox(height: 4),
                      Padding(
                        padding: EdgeInsets.only(top: 4, left: 0),
                        child: Text(
                          passwordErrorMSG.isNotEmpty
                              ? passwordErrorMSG
                              : 'Must be at least 8 characters',
                          style: TextStyle(
                            color: passwordErrorMSG.isNotEmpty
                                ? Color(0xFFBA1A1A)
                                : Color(0xFF545454),
                            fontSize: 12,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          left: MediaQuery.of(context).size.width * 0.015,
                        ),
                        child: Text(
                          'Re-enter Password',
                          style: TextStyle(
                              fontSize: 13,
                              fontFamily: 'Lato',
                              fontWeight: FontWeight.w500,
                              color: _isConfirmPasswordValid
                                  ? const Color(0xFF333333)
                                  : const Color(0xFFBA1A1A)),
                        ),
                      ),
                      SizedBox(height: 7),
                      Container(
                        width: (MediaQuery.of(context).size.width) - 20,
                        child: TextField(
                          controller: confirmPasswordController,
                          cursorColor: Color(0xff004C99),
                          obscureText: confirmPasswordHide,
                          enabled: !isLoading,
                          style: TextStyle(
                              fontSize: 14,
                              fontFamily: 'Lato',
                              color: Color(0xff333333)),
                          decoration: InputDecoration(
                            suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    confirmPasswordHide = !confirmPasswordHide;
                                  });
                                },
                                icon: SvgPicture.asset(confirmPasswordHide
                                    ? 'assets/images/ic_hide_password.svg'
                                    : 'assets/images/ic_show_password.svg')),
                            hintText: 'Re-enter your password',
                            hintStyle: TextStyle(color: Color(0xff545454)),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8)),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                  color: _isConfirmPasswordValid
                                      ? Color(0xffd9d9d9)
                                      : Color(0xffBA1A1A),
                                  width: 1),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                  color: _isConfirmPasswordValid
                                      ? Color(0xff004C99)
                                      : Color(0xffBA1A1A),
                                  width: 1),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 10),
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'[\p{L}\p{N}\p{P}\p{S}]', unicode: true),
                            ),
                            FilteringTextInputFormatter.deny(RegExp(r'\s')),
                            FilteringTextInputFormatter.deny(
                              RegExp(
                                  r'[\u{1F300}-\u{1F6FF}|\u{1F900}-\u{1F9FF}|\u{2600}-\u{26FF}|\u{2700}-\u{27BF}]',
                                  unicode: true),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _isConfirmPasswordValid = true;
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 4, left: 0),
                        child: Text(
                          confirm_passwordErrorMSG.isNotEmpty
                              ? confirm_passwordErrorMSG
                              : 'Both passwords must match',
                          style: TextStyle(
                            color: confirm_passwordErrorMSG.isNotEmpty
                                ? Color(0xFFBA1A1A)
                                : Color(0xFF545454),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 50),
                  InkWell(
                    onTap: () {
                      FocusScope.of(context).unfocus();
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
