import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
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
  String emailErrorMessage = 'Email cannot be empty';

  Future<void> sendPasswordRestOTP() async {

    final url = Uri.parse(AppConstants.BASE_URL + AppConstants.FORGOT_PASSWORD);
    final bodyParams = {
      "email" : emailController.text,
    };

    try{
 var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      Fluttertoast.showToast(
        msg: "No internet connection",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Color(0xff2D2D2D),
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return;  // Exit the function if no internet
    }
      setState(() {
        isLoading = true;
      });

      final response = await http.post(url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(bodyParams),
      );

      if(kDebugMode) {
        print('Response code ${response.statusCode} :: Response => ${response
            .body}');
      }

      var resOBJ = jsonDecode(response.body);

      String statusMessage = resOBJ['message'];
      String status = resOBJ['status'];


      if(response.statusCode ==200){

        if(status.toLowerCase().trim().contains('ok') || statusMessage.toLowerCase().trim().contains('successfully')){
          Fluttertoast.showToast(
              msg: statusMessage,
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.green,
              textColor: Colors.white,
              fontSize: 16.0);

          Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => ForgotPasswordOTPScreen(email: emailController.text,)));
        }

        else {
          Fluttertoast.showToast(
              msg: statusMessage,
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: AppColors.primaryColor,
              textColor: Colors.white,
              fontSize: 16.0);
        }
      } else if(response.statusCode == 400){
        if(statusMessage.toLowerCase().contains('not found')){
            setState(() {
              _isEmailValid = false;
              emailErrorMessage = statusMessage;
            });
        } else{
          Fluttertoast.showToast(
              msg: statusMessage,
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0);
        }
      }

    }catch(e){

      print('Error : ${e}');

    }finally{
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
          Positioned(right: 0,child: Image.asset('assets/images/Ellipse 1.png'),),
          Positioned(left: 0, bottom: 0 ,child: Image.asset('assets/images/ellipse_bottom.png'),),

          Positioned(
            top: 100,
            bottom: 0,
            child: SingleChildScrollView(
              child: Container( width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    Image.asset('assets/images/forgot_password.png'),

                    SizedBox(height: 80,),
                    Text('Reset Your Password', style: TextStyle(fontFamily: 'Lato', fontSize: 20, fontWeight: FontWeight.bold),),

                    SizedBox(height: 40,),
                    Padding(padding: EdgeInsets.symmetric(horizontal: 40),child: Text('Please enter the address associated with your account', textAlign: TextAlign.center , style: TextStyle(fontWeight: FontWeight.w400, color: Color(0xff545454) , fontSize: 14, fontFamily: 'Lato'),)),
                    SizedBox(height: 10,),


                    SizedBox(height: 50,),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                      Text('Email', style: TextStyle(fontSize: 13, fontFamily: 'Lato'),),
                      SizedBox(height: 10,),
                      TextField(
                        controller: emailController,
                        style: TextStyle(fontSize: 14, fontFamily: 'Lato'),
                        decoration: InputDecoration(
                            hintText: 'Enter your email',
                            border: OutlineInputBorder(),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: _isEmailValid ? Colors.grey : Colors.red, // Default border color
                                  width: 1
                              ),
                            ),

                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: _isEmailValid ? Colors.blue : Colors.red, // Border color when focused
                                  width: 1
                              ),
                            ),

                            errorText: _isEmailValid ? null : emailErrorMessage, // Display error message if invalid
                            contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10)
                        ),
                        keyboardType: TextInputType.emailAddress,
                        onChanged: (value) {
                          // Validate the email here and update _isEmailValid
                          setState(() {
                            _isEmailValid = true;
                          });
                        },
                      ),
                    ],),


                    //Loading
                    Container(
                      width: MediaQuery.of(context).size.width,
                      child: Center(
                        child: Visibility(
                          visible: isLoading,
                          child: Column(
                            children: [
                              SizedBox(height: 30,),
                              LoadingAnimationWidget.fourRotatingDots(
                                color: AppColors.primaryColor,
                                size: 40,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 50),
                    InkWell(

                      onTap: (){
                        if(emailController.text.trim().isEmpty || !validateEmail(emailController.text)){
                          if(emailController.text.trim().isEmpty){
                            setState(() {
                              _isEmailValid = false;
                              emailErrorMessage = 'Email cannot be empty';
                            });
                          } else if(!validateEmail(emailController.text)){
                            setState(() {
                              _isEmailValid = false;
                              emailErrorMessage = 'Enter a valid email address';
                            });
                          }
                        } else{
                          sendPasswordRestOTP();
                        }
                      },

                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: 44,
                        margin: EdgeInsets.symmetric(horizontal: 0),
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(color: AppColors.primaryColor,borderRadius: BorderRadius.circular(10)),
                        child: Center(child: Text('Send Code', style: TextStyle(color: Colors.white),),),
                      ),
                    ),

                    SizedBox(height: 20,),
                    InkWell(
                      onTap: (){
                        Navigator.pop(context);
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: 44,
                        margin: EdgeInsets.symmetric(horizontal: 0),
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(color: Colors.transparent,borderRadius: BorderRadius.circular(10)),
                        child: Center(child: Text('Back to Login', style: TextStyle(color: AppColors.primaryColor),),),
                      ),
                    ),

                  ],
                ),
              ),
            ),
          ),

          Positioned(top: 40,left: 0,child: Row( children: [ IconButton(icon:  Icon(Icons.arrow_back_ios_new), onPressed: (){Navigator.pop(context);},), InkWell(onTap: (){Navigator.pop(context);},child: Container(height: 50, child: Center(child: Text('Back', style: TextStyle(fontSize: 16),)))) ],)),

        ],
      ),
    );
  }
}
