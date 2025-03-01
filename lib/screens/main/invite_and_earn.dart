import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:share_plus/share_plus.dart';
import 'package:talent_turbo_new/AppColors.dart';
import 'package:talent_turbo_new/AppConstants.dart';
import 'package:talent_turbo_new/Utils.dart';
import 'package:talent_turbo_new/models/referral_profile_model.dart';
import 'package:talent_turbo_new/models/user_data_model.dart';
import 'package:http/http.dart' as http;

class InviteAndEarn extends StatefulWidget {
  const InviteAndEarn({super.key});

  @override
  State<InviteAndEarn> createState() => _InviteAndEarnState();
}

class _InviteAndEarnState extends State<InviteAndEarn> {
  bool isLoading = false;
  ReferralData? referralData;
  UserData? retrievedUserData;

  Widget buildTimelineRow(String title, bool isActive) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Circle icon
        Container(
          margin: EdgeInsets.only(right: 16),
          child: Icon(
            Icons.circle,
            size: 12,
            color: isActive ? AppColors.primaryColor : Colors.grey,
          ),
        ),
        // Title and date
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: isActive ? Colors.black : Colors.grey,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _shareApp(String refCode) {
    //final String appUrl = "https://play.google.com/store/apps/details?id=com.android.referral.talentturbo";
    final String appUrl =
        "https://play.google.com/store/apps/details?id=com.android.referral.talentturbo&referrer=$refCode";
    Share.share(
      "Say goodbye to endless job searches—find the perfect role with TalentTurbo app! 🛠️ Download now at $appUrl. \n\nUse my referral code $refCode while signing up. \n\n#GetHired #Jobs #TalentTurbo",
      subject: 'Try this awesome app!',
    );
  }

  Future<void> getRefCode(int jobId) async {
    final url =
        Uri.parse(AppConstants.BASE_URL + AppConstants.GET_REF_CODE_SHARE);

    final bodyParams = {
      "jobId": jobId,
    };

    try {
      setState(() {
        isLoading = true;
      });

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': retrievedUserData!.token
        },
        body: jsonEncode(bodyParams),
      );

      if (kDebugMode) {
        print(
            'Response code ${response.statusCode} :: Response => ${response.body}');
      }

      if (response.statusCode == 200) {
        var resObj = jsonDecode(response.body);

        _shareApp(resObj['referralCode'].toString());
      } else {
        // Fluttertoast.showToast(
        //     msg: 'Failed to generate invite link.',
        //     toastLength: Toast.LENGTH_SHORT,
        //     gravity: ToastGravity.BOTTOM,
        //     timeInSecForIosWeb: 1,
        //     backgroundColor: Colors.red,
        //     textColor: Colors.white,
        //     fontSize: 16.0);
        IconSnackBar.show(
          context,
          label: 'Failed to generate invite link !',
          snackBarType: SnackBarType.alert,
          backgroundColor: Color(0xffBA1A1A),
          iconColor: Colors.white,
        );
      }

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      if (kDebugMode) print(e);

      setState(() {
        isLoading = false;
      });
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
      body: Column(
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
                Text(
                  'Invite and Earn',
                  style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Lato',
                      fontWeight: FontWeight.w400,
                      fontSize: 16),
                ),
                SizedBox(
                  width: 80,
                )
              ],
            ),
          ),
          SizedBox(
            height: 20,
          ),
          SingleChildScrollView(
            child: Container(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SvgPicture.asset('assets/images/ic_invite.svg'),
                SizedBox(
                  height: 50,
                ),
                Container(
                  width: 300,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildTimelineRow('Invite your friend', true),
                      Container(
                        margin: EdgeInsets.fromLTRB(5, 0, 0, 0),
                        height: 40,
                        width: 2,
                        color: AppColors.primaryColor,
                      ),
                      buildTimelineRow('They signup with your link', true),
                      Container(
                        margin: EdgeInsets.fromLTRB(5, 0, 0, 0),
                        height: 40,
                        width: 2,
                        color: AppColors.primaryColor,
                      ),
                      buildTimelineRow('Get paid when they get jobs', true),
                    ],
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
              ],
            )),
          ),
          SizedBox(
            height: 40,
          ),
          InkWell(
            onTap: () {
              getRefCode(731);
            },
            child: Container(
              width: MediaQuery.of(context).size.width - 50,
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
                              angle: value * 2 * 3.1416, // Full rotation effect
                              child: CircularProgressIndicator(
                                strokeWidth: 4,
                                value: 0.20, // 1/5 of the circle
                                backgroundColor: const Color.fromARGB(
                                    142, 234, 232, 232), // Grey stroke
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white), // White rotating stroke
                              ),
                            );
                          },
                          onEnd: () => {}, // Ensures smooth infinite animation
                        ),
                      )
                    : Text(
                        'Invite',
                        style: TextStyle(color: Colors.white),
                      ),
              ),
            ),
          )
        ],
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
    ReferralData? _referralData = await getReferralProfileData();
    UserData? _retrievedUserData = await getUserData();
    setState(() {
      referralData = _referralData;
      retrievedUserData = _retrievedUserData;
    });
  }
}
