import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:talent_turbo_new/AppColors.dart';
import 'package:talent_turbo_new/Utils.dart';
import 'package:talent_turbo_new/models/candidate_profile_model.dart';
import 'package:talent_turbo_new/models/user_data_model.dart';
import 'package:talent_turbo_new/screens/main/fragments/home_fragment.dart';
import 'package:talent_turbo_new/screens/main/fragments/my_jobs_fragment.dart';
import 'package:talent_turbo_new/screens/main/fragments/my_referrals_fragment.dart';
import 'package:talent_turbo_new/screens/main/fragments/profile_fragment.dart';

class HomeContainer extends StatefulWidget {
  const HomeContainer({super.key});

  @override
  State<HomeContainer> createState() => _HomeContainerState();
}

class _HomeContainerState extends State<HomeContainer> {
  int oldScr = 0;
  int scr = 0;
  UserData? retrievedUserData;
  CandidateProfileModel? candidateProfileModel;

  Future<bool> _onWillPop() async {
    if (scr != 0 || oldScr != 0) {
      // If not on the Home screen, navigate back to Home
      setState(() {
        //scr = 0;
        scr = oldScr;
        oldScr = 0;
      });
      return false; // Prevent the default back navigation
    } else {
      // If on the Home screen, allow the back navigation (exit the app)
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get the screen size using MediaQuery
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Change the status bar color
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Color(0xff001B3E),
      statusBarIconBrightness: Brightness.light,
    ));
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Color(0xffF7F7F7),
        body: Stack(
          children: [
            scr == 0
                ? const HomeFragment()
                : (scr == 1
                    ? MyJobsFragment()
                    : (scr == 2
                        ? MyReferralsFragment()
                        : const ProfileFragment())),
            Positioned(
              bottom: 0,
              right: 0,
              left: 0,
              child: SafeArea(
                top: false,
                child: PhysicalModel(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24)),
                  elevation: 10,
                  color: const Color(0xFFFFFFFF),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.05,
                        vertical: screenHeight * 0.015),
                    height: screenHeight * 0.09,
                    width: screenWidth,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(24),
                          topRight: Radius.circular(24)),
                      border: Border(
                        top: BorderSide(
                          color: Color(0xffDBDBDB),
                          width: 1.0,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        InkWell(
                          onTap: () {
                            setState(() {
                              oldScr = scr;
                              scr = 0;
                            });
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              scr == 0
                                  ? SvgPicture.asset(
                                      'assets/images/ic_home_sel.svg')
                                  : SvgPicture.asset(
                                      'assets/images/ic_home.svg'),
                              SizedBox(
                                height: screenHeight * 0.005,
                              ),
                              Text(
                                'Home',
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'NunitoSans',
                                    fontSize: screenWidth * 0.03,
                                    color: AppColors.textColor),
                              )
                            ],
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            setState(() {
                              oldScr = scr;
                              scr = 1;
                            });
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              scr == 1
                                  ? SvgPicture.asset(
                                      'assets/images/ic_job_selected.svg')
                                  : SvgPicture.asset(
                                      'assets/images/ic_jobs.svg'),
                              SizedBox(
                                height: screenHeight * 0.005,
                              ),
                              Text(
                                'My Jobs',
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'NunitoSans',
                                    fontSize: screenWidth * 0.03,
                                    color: AppColors.textColor),
                              )
                            ],
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            setState(() {
                              oldScr = scr;
                              scr = 2;
                            });
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              scr == 2
                                  ? SvgPicture.asset(
                                      'assets/images/ic_referral_selected.svg')
                                  : SvgPicture.asset(
                                      'assets/images/ic_referrals.svg'),
                              SizedBox(
                                height: screenHeight * 0.005,
                              ),
                              Text(
                                'My Referrals',
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'NunitoSans',
                                    fontSize: screenWidth * 0.03,
                                    color: AppColors.textColor),
                              )
                            ],
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            setState(() {
                              oldScr = scr;
                              scr = 3;
                            });
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              scr == 3
                                  ? SvgPicture.asset(
                                      'assets/images/ic_profile_selected.svg')
                                  : SvgPicture.asset(
                                      'assets/images/ic_profile.svg'),
                              SizedBox(
                                height: screenHeight * 0.005,
                              ),
                              Text(
                                'Profile',
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'NunitoSans',
                                    fontSize: screenWidth * 0.03,
                                    color: AppColors.textColor),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
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
    fetchUserDataFromPref();
  }

  Future<void> fetchUserDataFromPref() async {
    UserData? _retrievedUserData = await getUserData();
    CandidateProfileModel? _candidateProfileModel =
        await getCandidateProfileData();
    setState(() {
      retrievedUserData = _retrievedUserData;
    });
  }
}
