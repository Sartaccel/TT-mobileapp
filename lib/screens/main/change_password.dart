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
  UserCredentials? loadedCredentials;

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

  bool get hasChanges {
    return old_passwordController.text.isNotEmpty ||
        new_passwordController.text.isNotEmpty ||
        confirm_passwordController.text.isNotEmpty;
  }

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
        String statusMessage = resOBJ["message"];

        if (statusMessage.toLowerCase().contains('success')) {
          // IconSnackBar.show(
          //   context,
          //   label: statusMessage,
          //   snackBarType: SnackBarType.success,
          //   backgroundColor: Color(0xff4CAF50),
          //   iconColor: Colors.white,
          // );

          // Update stored credentials with new password
          if (loadedCredentials != null) {
            loadedCredentials!.password = new_passwordController.text;
            await loadedCredentials!.saveCredentials();
          }
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
                  SvgPicture.asset('assets/icon/success.svg'),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Password changed !',
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
          Navigator.pop(context);
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
        // IconSnackBar.show(
        //   context,
        //   label: 'Failed to update password. Please try again.',
        //   snackBarType: SnackBarType.fail,
        //   backgroundColor: Color(0xFFBA1A1A),
        //   iconColor: Colors.white,
        // );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (kDebugMode) {
        print(e.toString());
      }
      // IconSnackBar.show(
      //   context,
      //   label: 'An error occurred. Please try again.',
      //   snackBarType: SnackBarType.fail,
      //   backgroundColor: Color(0xFFBA1A1A),
      //   iconColor: Colors.white,
      // );
    }
  }

  @override
  Widget build(BuildContext context) {
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
                          if (hasChanges) {
                            showDiscardConfirmationDialog(context);
                          } else {
                            Navigator.pop(context);
                          }
                        },
                      ),
                      InkWell(
                          onTap: () {
                            if (hasChanges) {
                              showDiscardConfirmationDialog(context);
                            } else {
                              Navigator.pop(context);
                            }
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
                              )))),
                    ],
                  ),
                  Text(
                    'Change Password',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Text(
                      '           ',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20),
                  // Old Password Field
                  _buildPasswordField(
                    label: 'Current Password',
                    controller: old_passwordController,
                    isPasswordValid: _isOldPasswordValid,
                    errorMessage: old_passwordErrorMessage,
                    isHidden: old_passwordHide,
                    onToggleVisibility: () {
                      setState(() {
                        old_passwordHide = !old_passwordHide;
                      });
                    },
                    onChanged: (val) {
                      setState(() {
                        _isOldPasswordValid = true;
                      });
                    },
                  ),

                  SizedBox(height: 20),
                  // New Password Field
                  _buildPasswordField(
                    label: 'New Password',
                    controller: new_passwordController,
                    isPasswordValid: _isNewPasswordValid,
                    errorMessage: new_passwordErrorMessage,
                    isHidden: new_passwordHide,
                    onToggleVisibility: () {
                      setState(() {
                        new_passwordHide = !new_passwordHide;
                      });
                    },
                    onChanged: (val) {
                      setState(() {
                        _isNewPasswordValid = true;
                      });
                    },
                  ),

                  SizedBox(height: 20),
                  // Confirm Password Field
                  _buildPasswordField(
                    label: 'Confirm New Password',
                    controller: confirm_passwordController,
                    isPasswordValid: _isConfirmPasswordValid,
                    errorMessage: confirm_passwordErrorMessage,
                    isHidden: confirm_passwordHide,
                    onToggleVisibility: () {
                      setState(() {
                        confirm_passwordHide = !confirm_passwordHide;
                      });
                    },
                    onChanged: (val) {
                      setState(() {
                        _isConfirmPasswordValid = true;
                      });
                    },
                  ),

                  SizedBox(height: 40),
                  // Confirm Button
                  InkWell(
                    onTap: () async {
                      // Validate all fields
                      bool isValid = true;

                      if (old_passwordController.text.trim().isEmpty) {
                        setState(() {
                          _isOldPasswordValid = false;
                          old_passwordErrorMessage = 'Password is required';
                          isValid = false;
                        });
                      } else if (loadedCredentials != null &&
                          loadedCredentials!.password !=
                              old_passwordController.text) {
                        setState(() {
                          _isOldPasswordValid = false;
                          old_passwordErrorMessage = 'Wrong password';
                          isValid = false;
                        });
                      }

                      if (new_passwordController.text.trim().isEmpty) {
                        setState(() {
                          _isNewPasswordValid = false;
                          new_passwordErrorMessage = 'Password is required';
                          isValid = false;
                        });
                      } else if (new_passwordController.text.length < 8) {
                        setState(() {
                          _isNewPasswordValid = false;
                          new_passwordErrorMessage =
                              'Password must be at least 8 characters';
                          isValid = false;
                        });
                      } else if (loadedCredentials != null &&
                          loadedCredentials!.password ==
                              new_passwordController.text) {
                        setState(() {
                          _isNewPasswordValid = false;
                          new_passwordErrorMessage =
                              'New password can\'t be the same as the old password';
                          isValid = false;
                        });
                      }

                      if (confirm_passwordController.text.trim().isEmpty) {
                        setState(() {
                          _isConfirmPasswordValid = false;
                          confirm_passwordErrorMessage = 'Password is required';
                          isValid = false;
                        });
                      } else {
                        if (new_passwordController.text !=
                            confirm_passwordController.text) {
                          setState(() {
                            _isConfirmPasswordValid = false;
                            confirm_passwordErrorMessage =
                                'New Password didn\'t match';
                            _isNewPasswordValid = false;
                            new_passwordErrorMessage = '';
                            isValid = false;
                          });
                        }
                      }

                      if (isValid && !isLoading) {
                        await setNewPassword();
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

  void showDiscardConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          insetPadding: EdgeInsets.zero,
          child: Container(
            width: MediaQuery.of(context).size.width - 35,
            padding: EdgeInsets.fromLTRB(22, 15, 22, 22),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              color: Colors.white,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Discard changes?',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'lato',
                      color: Color(0xff333333)),
                ),
                SizedBox(height: 12),
                Text(
                  'Are you sure you want to discard all changes?',
                  style: TextStyle(
                      height: 1.4,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'lato',
                      color: Color(0xff333333)),
                ),
                SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.60,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Expanded(
                          flex: 1,
                          child: InkWell(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Container(
                              height: 50,
                              margin: EdgeInsets.only(right: 15),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(
                                      width: 1, color: AppColors.primaryColor),
                                  borderRadius: BorderRadius.circular(10)),
                              child: Center(
                                child: Text(
                                  'Cancel',
                                  style: TextStyle(
                                      color: AppColors.primaryColor,
                                      fontFamily: 'lato'),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                            flex: 1,
                            child: InkWell(
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.pop(context);
                              },
                              child: Container(
                                height: 50,
                                decoration: BoxDecoration(
                                    color: AppColors.primaryColor,
                                    borderRadius: BorderRadius.circular(10)),
                                child: Center(
                                  child: Text(
                                    'Discard',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'lato'),
                                  ),
                                ),
                              ),
                            )),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required bool isPasswordValid,
    required String errorMessage,
    required bool isHidden,
    required VoidCallback onToggleVisibility,
    required ValueChanged<String> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding:
              EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.015),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontFamily: 'Lato',
              color: isPasswordValid ? Color(0xff333333) : Color(0xffBA1A1A),
            ),
          ),
        ),
        SizedBox(height: 7),
        TextField(
          obscureText: isHidden,
          obscuringCharacter: '∗',
          controller: controller,
          cursorColor: Color(0xff004C99),
          style: TextStyle(
            fontSize: 14,
            fontFamily: 'Lato',
            color: Color(0xff333333),
          ),
          decoration: InputDecoration(
            suffixIcon: IconButton(
              onPressed: onToggleVisibility,
              icon: SvgPicture.asset(
                isHidden
                    ? 'assets/images/ic_hide_password.svg'
                    : 'assets/images/ic_show_password.svg',
              ),
            ),
            hintText: 'Enter your password',
            hintStyle: TextStyle(color: Color(0xff545454)),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: isPasswordValid ? Color(0xffd9d9d9) : Color(0xffBA1A1A),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: isPasswordValid ? Color(0xff004C99) : Color(0xffBA1A1A),
                width: 1,
              ),
            ),
            contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          ),
          inputFormatters: [
            LengthLimitingTextInputFormatter(20),
            FilteringTextInputFormatter.allow(
              RegExp(r'[\p{L}\p{N}\p{P}\p{S}]', unicode: true),
            ),
            FilteringTextInputFormatter.deny(RegExp(r'\s')),
            FilteringTextInputFormatter.deny(
              RegExp(
                r'[\u{1F600}-\u{1F64F}'
                r'\u{1F300}-\u{1F5FF}'
                r'\u{1F680}-\u{1F6FF}'
                r'\u{1F1E0}-\u{1F1FF}'
                r'\u{2600}-\u{26FF}'
                r'\u{2700}-\u{27BF}]',
                unicode: true,
              ),
            ),
          ],
          onChanged: onChanged,
        ),
        SizedBox(height: 4),
        if (!isPasswordValid)
          Padding(
            padding: EdgeInsets.only(left: 0),
            child: Text(
              errorMessage,
              style: TextStyle(
                fontSize: 12,
                color: Color(0xffBA1A1A),
                fontFamily: 'Lato',
              ),
            ),
          ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    fetchProfileFromPref();
    loadCredentials();
  }

  Future<void> fetchProfileFromPref() async {
    UserData? _retrievedUserData = await getUserData();
    setState(() {
      retrievedUserData = _retrievedUserData;
    });
  }

  Future<void> loadCredentials() async {
    UserCredentials? credentials = await UserCredentials.loadCredentials();
    setState(() {
      loadedCredentials = credentials;
    });
  }
}
