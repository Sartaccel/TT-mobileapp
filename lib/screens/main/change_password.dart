import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:talent_turbo_new/AppConstants.dart';
import 'package:talent_turbo_new/Utils.dart';
import 'package:talent_turbo_new/models/login_data_model.dart';
import 'package:http/http.dart' as http;
import 'package:talent_turbo_new/models/user_data_model.dart';

import '../../AppColors.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({super.key});

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  UserData? retrievedUserData;

  bool _isOldPasswordValid = true;
  bool old_passwordHide = true;
  String old_passwordErrorMessage = 'Invalid password';

  bool _isNewPasswordValid = true;
  bool new_passwordHide = true;
  String new_passwordErrorMessage = 'Invalid password';

  bool _isConfirmPasswordValid = true;
  bool confirm_passwordHide = true;
  String confirm_passwordErrorMessage = 'Invalid password';

  bool isLoading = false;

  TextEditingController old_passwordController = TextEditingController();
  TextEditingController new_passwordController = TextEditingController();
  TextEditingController confirm_passwordController = TextEditingController();

  Future<void> setNewPassword() async {
    final url = Uri.parse(
        AppConstants.BASE_URL + AppConstants.FORGOT_PASSWORD_UPDATE_PASSWORD);

    final bodyParams = {
      "id": retrievedUserData!.accountId.toString(),
      "password": new_passwordController.text
    };

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

  @override
  Widget build(BuildContext context) {
    // Change the status bar color
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Color(0xff001B3E),
      statusBarIconBrightness: Brightness.light,
    ));
    return Scaffold(
      backgroundColor: Color(0xffFCFCFC),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: 40,
              decoration: BoxDecoration(color: Color(0xff001B3E)),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              height: 60,
              decoration: BoxDecoration(color: Color(0xff001B3E)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                        ),
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
                                style: TextStyle(
                                    fontFamily: 'Lato',
                                    fontSize: 16,
                                    color: Colors.white),
                              ))))
                    ],
                  ),
                  SizedBox(
                    width: 80,
                  )
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      left: MediaQuery.of(context).size.width * 0.015,
                    ),
                    child: Text('Old Password',
                        style: TextStyle(
                            fontSize: 13,
                            fontFamily: 'Lato',
                            color: _isOldPasswordValid
                                ? Color(0xff333333)
                                : Color(0xffBA1A1A))),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextField(
                    obscureText: old_passwordHide,
                    controller: old_passwordController,
                    cursorColor: Color(0xff004C99),
                    style: TextStyle(fontSize: 14, fontFamily: 'Lato'),
                    decoration: InputDecoration(
                        suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                old_passwordHide = !old_passwordHide;
                              });
                            },
                            //icon: Icon( old_passwordHide?Icons.visibility :Icons.visibility_off)),
                            icon: SvgPicture.asset(old_passwordHide
                                ? 'assets/images/ic_hide_password.svg'
                                : 'assets/images/ic_show_password.svg')),
                        hintText: 'Enter your password',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                              color: _isOldPasswordValid
                                  ? Color(0xffd9d9d9)
                                  : Color(0xffBA1A1A), // Default border color
                              width: 1),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                              color: _isOldPasswordValid
                                  ? Color(0xff004C99)
                                  : Color(
                                      0xffBA1A1A), // Border color when focused
                              width: 1),
                        ),
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 10)),
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
                    onChanged: (val) {
                      setState(() {
                        _isOldPasswordValid = true;
                      });
                    },
                  ),
                  if (!_isOldPasswordValid)
                    Padding(
                      padding: EdgeInsets.only(
                        left: 0,
                      ),
                      child: Text(
                        old_passwordErrorMessage ?? '',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xffBA1A1A),
                          fontFamily: 'Lato',
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
                    child: Text('New Password',
                        style: TextStyle(
                            fontSize: 13,
                            fontFamily: 'Lato',
                            color: _isNewPasswordValid
                                ? Color(0xff333333)
                                : Color(0xffBA1A1A))),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextField(
                    obscureText: new_passwordHide,
                    controller: new_passwordController,
                    cursorColor: Color(0xff004C99),
                    style: TextStyle(fontSize: 14, fontFamily: 'Lato'),
                    decoration: InputDecoration(
                        suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                new_passwordHide = !new_passwordHide;
                              });
                            },
                            //icon: Icon( new_passwordHide?Icons.visibility :Icons.visibility_off)),
                            icon: SvgPicture.asset(new_passwordHide
                                ? 'assets/images/ic_hide_password.svg'
                                : 'assets/images/ic_show_password.svg')),
                        hintText: 'Enter your password',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                              color: _isNewPasswordValid
                                  ? Color(0xffd9d9d9)
                                  : Color(0xffBA1A1A), // Default border color
                              width: 1),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                              color: _isNewPasswordValid
                                  ? Color(0xff004C99)
                                  : Color(
                                      0xffBA1A1A), // Border color when focused
                              width: 1),
                        ),
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 10)),
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
                    onChanged: (val) {
                      setState(() {
                        _isNewPasswordValid = true;
                      });
                    },
                  ),
                  if (!_isNewPasswordValid)
                    Padding(
                      padding: EdgeInsets.only(
                        left: 0,
                      ),
                      child: Text(
                        new_passwordErrorMessage ?? '',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xffBA1A1A),
                          fontFamily: 'Lato',
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
                    child: Text('Confirm New Password',
                        style: TextStyle(
                            fontSize: 13,
                            fontFamily: 'Lato',
                            color: _isConfirmPasswordValid
                                ? Color(0xff333333)
                                : Color(0xffBA1A1A))),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextField(
                    obscureText: confirm_passwordHide,
                    controller: confirm_passwordController,
                    cursorColor: Color(0xff004C99),
                    style: TextStyle(fontSize: 14, fontFamily: 'Lato'),
                    decoration: InputDecoration(
                        suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                confirm_passwordHide = !confirm_passwordHide;
                              });
                            },
                            //icon: Icon( confirm_passwordHide?Icons.visibility :Icons.visibility_off)),
                            icon: SvgPicture.asset(confirm_passwordHide
                                ? 'assets/images/ic_hide_password.svg'
                                : 'assets/images/ic_show_password.svg')),
                        hintText: 'Enter your password',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                              color: _isConfirmPasswordValid
                                  ? Color(0xffd9d9d9)
                                  : Color(0xffBA1A1A), // Default border color
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
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 10)),
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
                    onChanged: (val) {
                      setState(() {
                        _isConfirmPasswordValid = true;
                      });
                    },
                  ),
                  if (!_isConfirmPasswordValid)
                    Padding(
                      padding: EdgeInsets.only(
                        left: 0,
                      ),
                      child: Text(
                        confirm_passwordErrorMessage ?? '',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xffBA1A1A),
                          fontFamily: 'Lato',
                        ),
                      ),
                    ),
                  SizedBox(
                    height: 30,
                  ),
                  SizedBox(height: 30),
                  InkWell(
                    onTap: () async {
                      UserCredentials? loadedCredentials =
                          await UserCredentials.loadCredentials();

                      if (old_passwordController.text.trim().isEmpty ||
                          new_passwordController.text.trim().isEmpty ||
                          confirm_passwordController.text.trim().isEmpty ||
                          new_passwordController.text.length < 8 ||
                          new_passwordController.text !=
                              confirm_passwordController.text) {
                        if (old_passwordController.text.trim().isEmpty) {
                          setState(() {
                            _isOldPasswordValid = false;
                            old_passwordErrorMessage =
                                'Password cannot be empty';
                          });
                        }

                        if (new_passwordController.text.trim().isEmpty) {
                          setState(() {
                            _isNewPasswordValid = false;
                            new_passwordErrorMessage =
                                'Password cannot be empty';
                          });
                        }

                        if (confirm_passwordController.text.trim().isEmpty) {
                          setState(() {
                            _isConfirmPasswordValid = false;
                            confirm_passwordErrorMessage =
                                'Password cannot be empty';
                          });
                        } else if (new_passwordController.text.length < 8) {
                          setState(() {
                            _isNewPasswordValid = false;
                            new_passwordErrorMessage =
                                'Password must be at least 8 characters in length';
                          });
                        }

                        if (new_passwordController.text !=
                            confirm_passwordController.text) {
                          setState(() {
                            // _isNewPasswordValid =false;
                            //new_passwordErrorMessage = 'New password do not match';

                            _isConfirmPasswordValid = false;
                            confirm_passwordErrorMessage =
                                'New password do not match';
                          });
                        }
                      } else if (loadedCredentials != null &&
                          loadedCredentials.password !=
                              old_passwordController.text) {
                        setState(() {
                          _isOldPasswordValid = false;
                          old_passwordErrorMessage = 'Wrong password';
                        });
                      } else if (loadedCredentials != null &&
                          loadedCredentials.password ==
                              new_passwordController.text) {
                        setState(() {
                          _isOldPasswordValid = false;
                          _isNewPasswordValid = false;
                          _isConfirmPasswordValid = false;

                          old_passwordErrorMessage =
                              'Old and new passwords cannot be same';
                          new_passwordErrorMessage =
                              'Old and new passwords cannot be same';
                          confirm_passwordErrorMessage =
                              'Old and new passwords cannot be same';
                        });
                      } else {
                        setNewPassword();
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
                                'Confirm',
                                style: TextStyle(color: Colors.white),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
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

  Future<void> fetchProfileFromPref() async {
    UserData? _retrievedUserData = await getUserData();
    setState(() {
      retrievedUserData = _retrievedUserData;
    });
  }
}
