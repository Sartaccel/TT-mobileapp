import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';
import 'package:flutter_svg/flutter_svg.dart';
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

  @override
  void initState() {
    super.initState();
    fetchProfileFromPref();
  }

  Future<void> fetchProfileFromPref() async {
    referralData = await getReferralProfileData();
    retrievedUserData = await getUserData();
    setState(() {});
  }

  void _shareApp(String refCode) {
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

    if (retrievedUserData?.token == null || retrievedUserData!.token.isEmpty) {
      IconSnackBar.show(
        context,
        label: 'User not logged in. Try again.',
        snackBarType: SnackBarType.alert,
      );
      return;
    }

    final bodyParams = {"jobId": jobId};

    setState(() => isLoading = true);

    try {
      if (kDebugMode) {
        print('🛰️ Invoking API to generate referral code...');
        print('🔗 POST URL: $url');
        print('🔐 Token: ${retrievedUserData!.token}');
        print('📦 Payload: $bodyParams');
      }

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': retrievedUserData!.token,
        },
        body: jsonEncode(bodyParams),
      );

      if (kDebugMode) {
        print('📬 Response Status Code: ${response.statusCode}');
        print('📨 Response Body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final resObj = jsonDecode(response.body);
        final referralCode = resObj['referralCode'].toString();

        if (kDebugMode) print('✅ Referral Code Received: $referralCode');

        _shareApp(referralCode);
      } else {
        final resObj = jsonDecode(response.body);
        final errorMessage =
            resObj['message'] ?? 'Failed to generate invite link!';

        if (kDebugMode) print('❌ API Error: $errorMessage');

        IconSnackBar.show(
          context,
          label: errorMessage,
          snackBarType: SnackBarType.alert,
          backgroundColor: Colors.red,
          iconColor: Colors.white,
        );
      }
    } catch (e) {
      if (kDebugMode) print('🔥 Exception during API call: $e');

      IconSnackBar.show(
        context,
        label: 'Something went wrong. Please try again.',
        snackBarType: SnackBarType.alert,
      );
    }

    setState(() => isLoading = false);
  }

  Widget buildTimelineRow(String title, bool isActive, {bool showLine = true}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 30,
          height: 80,
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              if (showLine)
                Positioned(
                  top: 15,
                  child: Container(
                    height: 65,
                    width: 2,
                    color: isActive ? AppColors.primaryColor : Colors.grey,
                  ),
                ),
              Container(
                width: 17,
                height: 17,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isActive ? AppColors.primaryColor : Colors.grey,
                    width: 2.5,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Transform.translate(
            offset: Offset(0, -MediaQuery.of(context).size.width * 0.015),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: isActive ? Colors.black : Colors.grey,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: const Color(0xff001B3E),
      statusBarIconBrightness: Brightness.light,
    ));

    return Scaffold(
      backgroundColor: const Color(0xffFCFCFC),
      body: SafeArea(
        child: Column(
          children: [
            // AppBar
            Container(
              height: 60,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              color: const Color(0xff001B3E),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new,
                            color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Text(
                        'Back',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ],
                  ),
                  const Text(
                    'Invite and Earn',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w400,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(width: 50),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SvgPicture.asset(
                      'assets/images/ic_invite.svg',
                      width: MediaQuery.of(context).size.width * 0.43,
                      height: MediaQuery.of(context).size.width * 0.43,
                    ),
                    const SizedBox(height: 40),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          buildTimelineRow('Invite your friends.', true),
                          buildTimelineRow(
                              'They register using your link.', true),
                          buildTimelineRow(
                              'You get paid when they get jobs.', true,
                              showLine: false),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Invite Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: InkWell(
                onTap: () => getRefCode(731),
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: isLoading
                        ? SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Invite',
                            style: TextStyle(color: Colors.white),
                          ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
