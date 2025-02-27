import 'dart:async';


import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talent_turbo_new/AppColors.dart';
import 'package:talent_turbo_new/Utils.dart';
import 'package:talent_turbo_new/models/candidate_profile_model.dart';
import 'package:talent_turbo_new/models/login_data_model.dart';
import 'package:talent_turbo_new/models/user_data_model.dart';
import 'package:talent_turbo_new/screens/auth/auth_service.dart';
import 'package:talent_turbo_new/screens/auth/login/login_screen.dart';
import 'package:talent_turbo_new/screens/editPhoto/editphoto.dart';
import 'package:talent_turbo_new/screens/main/AccountSettings.dart';
import 'package:talent_turbo_new/screens/main/invite_and_earn.dart';
import 'package:talent_turbo_new/screens/main/personal_details.dart';
import 'package:talent_turbo_new/screens/main/rewards.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileFragment extends StatefulWidget {
  const ProfileFragment({super.key});

  @override
  State<ProfileFragment> createState() => _ProfileFragmentState();
}

class _ProfileFragmentState extends State<ProfileFragment> {
  final AuthService _googleAuthService = AuthService();
  CandidateProfileModel? candidateProfileModel;
  UserData? retrievedUserData;

  bool isConnectionAvailable = true;

  Future<void> _launchTermsURL() async {
    final String? filePath = 'https://main.talentturbo.us/terms-of-service';

    if (filePath != null && await canLaunchUrl(Uri.parse(filePath))) {
      //await launchUrlString(filePath, mode: LaunchMode.externalApplication);
      await launchUrl(Uri.parse(filePath));
      //await launch(filePath, forceSafariVC: false, forceWebView: false);
    } else {
      // Fluttertoast.showToast(
      //     msg: 'Could not launch ${filePath}',
      //     toastLength: Toast.LENGTH_SHORT,
      //     gravity: ToastGravity.BOTTOM,
      //     timeInSecForIosWeb: 1,
      //     backgroundColor: Color(0xff2D2D2D),
      //     textColor: Colors.white,
      //     fontSize: 16.0);
      IconSnackBar.show(
        context,
        label: 'Could not launch ${filePath}',
        snackBarType: SnackBarType.alert,
        backgroundColor: Color(0xff2D2D2D),
        iconColor: Colors.white,
      );
      throw 'Could not launch ${filePath}';
    }
  }

 void showDeleteConfirmationDialog(BuildContext context, bool isConnectionAvailable) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
        actionsPadding: EdgeInsets.fromLTRB(20, 0, 20, 20),
        contentPadding: EdgeInsets.fromLTRB(22, 15, 15, 22),
        title: Text(
          'Logout',
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xff333333)),
        ),
        content: Container(
          width: MediaQuery.of(context).size.width,
          child: Text(
            'Are you sure you want to log out?',
            style: TextStyle(
                height: 1.2,
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Color(0xff333333)),
          ),
        ),
        actions: [
          InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Container(
              height: 40,
              width: 100,
              decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(width: 1, color: AppColors.primaryColor),
                  borderRadius: BorderRadius.circular(7)),
              child: Center(
                child: Text(
                  'Cancel',
                  style: TextStyle(color: AppColors.primaryColor),
                ),
              ),
            ),
          ),
          InkWell(
            onTap: () async {
              if (!isConnectionAvailable) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('No internet connection. Please try again later.'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.clear();  // Clears all stored data

              await _googleAuthService.signOut();

              // Ensure UI updates before navigating
              (context as Element).markNeedsBuild();

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
                (Route<dynamic> route) => false,
              );
            },
            child: Container(
              height: 40,
              width: 100,
              decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  borderRadius: BorderRadius.circular(7)),
              child: Center(
                child: Text(
                  'Logout',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      );
    },
  );
}



  final String appUrl =
      "https://play.google.com/store/apps/details?id=com.android.referral.talentturbo";

  void _shareApp() {
    Share.share(
      "Say goodbye to endless job searches—find the perfect role with TalentTurbo app! 🛠️ Download now: $appUrl #JobsNearMe",
      subject: 'Try this awesome app!',
    );
  }

  @override
  Widget build(BuildContext context) {
    // Change the status bar color
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Color(0xff001B3E),
      statusBarIconBrightness:
          Brightness.light, 
    ));
    return RefreshIndicator(
      onRefresh: fetchProfileFromPref,
      color: Color(0xffFCFCFC),
      child: Column(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: 40,
            decoration: BoxDecoration(color: Color(0xff001B3E)),
          ),
          isConnectionAvailable
              ? Column(
                  children: [
                    Container(
                      height: 270,
                      color: Color(0xffFCFCFC),
                      child: Stack(
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width,
                            height: 100,
                            decoration: BoxDecoration(
                              color: Color(0xff001B3E),
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(10),
                                bottomRight: Radius.circular(10),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 50,
                            left: (MediaQuery.of(context).size.width / 2) - 50,
                            child: Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                border:
                                    Border.all(color: Colors.white, width: 2),
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: InkWell(
                                onTap: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          EditPhotoPage(),
                                    ),
                                  );
                                  fetchProfileFromPref();
                                },
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(50),
                                  child: (candidateProfileModel != null &&
                                          candidateProfileModel!.imagePath !=
                                              null)
                                      ? Image.network(
                                          candidateProfileModel!.imagePath!,
                                          height: 100,
                                          width: 100,
                                          fit: BoxFit.cover,
                                        )
                                      : Image.asset(
                                          'assets/images/profile.jfif',
                                          height: 100,
                                          width: 100,
                                          fit: BoxFit.cover,
                                        ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            left: (MediaQuery.of(context).size.width / 2) + 20,
                            top: 130,
                            child: SvgPicture.asset('assets/icon/DpEdit.svg'),
                          ),
                          Stack(
                            children: [
                              Positioned(
                                top: 170,
                                left: 0,
                                right: 0,
                                child: Center(
                                  child: Column(
                                    children: [
                                      Text(
                                        '${candidateProfileModel?.candidateName ?? 'N/A'}',
                                        style: TextStyle(
                                          fontFamily: 'NunitoSans',
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xff333333),
                                          fontSize: 16,
                                        ),
                                        textAlign: TextAlign.center,
                                        overflow: TextOverflow.clip,
                                        maxLines: 1,
                                      ),
                                      SizedBox(height: 5),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.location_on,
                                            size: 17,
                                          ),
                                          Text(
                                            '${candidateProfileModel?.location ?? 'Location not updated'}',
                                            style: TextStyle(
                                              fontFamily: 'NunitoSans',
                                              fontWeight: FontWeight.w400,
                                              color: Color(0xff333333),
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      color: Color(0xffFCFCFC),
                      height: MediaQuery.of(context).size.height - 400,
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            ListTile(
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        PersonalDetails(),
                                  ),
                                );
                                fetchProfileFromPref();
                              },
                              leading: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Color(0xffF7F7F7),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: SvgPicture.asset(
                                    'assets/icon/PDnotes.svg',
                                    width: 28,
                                    height: 28,
                                  ),
                                ),
                              ),
                              title: Text(
                                'Personal Details',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xff333333),
                                ),
                              ),
                              trailing: SvgPicture.asset(
                                'assets/icon/ArrowRight.svg', // Update with your correct path
                                width: 24, // Adjust size as needed
                                height: 24,
                              ),
                            ),
                            Divider(),
                            ListTile(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        Accountsettings(),
                                  ),
                                );
                              },
                              leading: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Color(0xffF7F7F7),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: SvgPicture.asset(
                                    'assets/icon/Setting.svg',
                                    width: 26,
                                    height: 26,
                                  ),
                                ),
                              ),
                              title: Text(
                                'Settings',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xff333333),
                                ),
                              ),
                              trailing: SvgPicture.asset(
                                'assets/icon/ArrowRight.svg', // Update with your correct path
                                width: 24, // Adjust size as needed
                                height: 24,
                              ),
                            ),
                            Divider(),
                            ListTile(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        MyRewards(),
                                  ),
                                );
                              },
                              leading: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Color(0xffF7F7F7),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: SvgPicture.asset(
                                    'assets/icon/gift.svg',
                                    width: 24,
                                    height: 24,
                                  ),
                                ),
                              ),
                              title: Text(
                                'My Rewards',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xff333333),
                                ),
                              ),
                              trailing: SvgPicture.asset(
                                'assets/icon/ArrowRight.svg', // Update with your correct path
                                width: 24, // Adjust size as needed
                                height: 24,
                              ),
                            ),
                            Divider(),
                            ListTile(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        InviteAndEarn(),
                                  ),
                                );
                              },
                              leading: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Color(0xffF7F7F7),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: SvgPicture.asset(
                                    'assets/icon/invite.svg',
                                    width: 24,
                                    height: 24,
                                  ),
                                ),
                              ),
                              title: Text(
                                'Invite & Earn',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xff333333),
                                ),
                              ),
                              trailing: SvgPicture.asset(
                                'assets/icon/ArrowRight.svg', // Update with your correct path
                                width: 24, // Adjust size as needed
                                height: 24,
                              ),
                            ),
                            Divider(),
                            ListTile(
                              onTap: _launchTermsURL,
                              leading: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Color(0xffF7F7F7),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: SvgPicture.asset(
                                    'assets/icon/notes.svg',
                                    width: 24,
                                    height: 24,
                                  ),
                                ),
                              ),
                              title: Text(
                                'Terms & Conditions',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xff333333),
                                ),
                              ),
                              trailing: SvgPicture.asset(
                                'assets/icon/ArrowRight.svg', // Update with your correct path
                                width: 24, // Adjust size as needed
                                height: 24,
                              ),
                            ),
                            Divider(),
                            ListTile(
                              onTap: () {
                                showDeleteConfirmationDialog(context,isConnectionAvailable);
                              },
                              leading: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Color(0xffF7F7F7),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: SvgPicture.asset(
                                    'assets/icon/Logout.svg',
                                    width: 24,
                                    height: 24,
                                  ),
                                ),
                              ),
                              title: Text(
                                'Logout',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xffBA1A1A),
                                ),
                              ),
                              trailing: SvgPicture.asset(
                                'assets/icon/ArrowRight.svg', // Update with your correct path
                                width: 24, // Adjust size as needed
                                height: 24,
                              ),
                            ),
                            Divider(),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              : Expanded(
                  child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset('assets/icon/noInternet.svg'),
                      Text(
                        'No Internet connection',
                        style: TextStyle(
                            fontFamily: 'Lato',
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Color(0xff333333)),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Text(
                        'Connect to Wi-Fi or cellular data and try again.',
                        style: TextStyle(
                            fontFamily: 'Lato',
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                            color: Color(0xff545454)),
                      ),
                      SizedBox(height: 30),
                      InkWell(
                        onTap: () {
                          checkInternetAvailability();
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width - 50,
                          height: 44,
                          margin: EdgeInsets.symmetric(horizontal: 0),
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                              color: AppColors.primaryColor,
                              borderRadius: BorderRadius.circular(8)),
                          child: Center(
                            child: Text(
                              'Try Again',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ))
        ],
      ),
    );
  }

  Future<void> fetchProfileFromPref() async {
    //ReferralData? _referralData = await getReferralProfileData();
    CandidateProfileModel? _candidateProfileModel =
        await getCandidateProfileData();
    UserData? _retrievedUserData = await getUserData();
    setState(() {
      //referralData = _referralData;
      candidateProfileModel = _candidateProfileModel;
      retrievedUserData = _retrievedUserData;
    });
  }

late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

@override
void initState() {
  super.initState();
  fetchProfileFromPref();
  checkInternetAvailability();

  _connectivitySubscription = Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
    setState(() {
      isConnectionAvailable = results.contains(ConnectivityResult.mobile) || results.contains(ConnectivityResult.wifi);
    });

    if (!isConnectionAvailable) {
      IconSnackBar.show(
        context,
        label: 'No internet connection',
        snackBarType: SnackBarType.alert,
        backgroundColor: Color(0xff2D2D2D),
        iconColor: Colors.white,
      );
    }
  });
}

@override
void dispose() {
  _connectivitySubscription.cancel();
  super.dispose();
}



  Future<void> checkInternetAvailability() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none)) {
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
        label: 'No internet connection',
        snackBarType: SnackBarType.alert,
        backgroundColor: Color(0xff2D2D2D),
        iconColor: Colors.white,
      );

      setState(() {
        isConnectionAvailable = false;
      });

      //return;  // Exit the function if no internet
    } else {
      setState(() {
        isConnectionAvailable = true;
      });
    }
  }
}
