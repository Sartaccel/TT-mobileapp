import 'dart:async';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talent_turbo_new/AppColors.dart';
import 'package:talent_turbo_new/AppConstants.dart';
import 'package:talent_turbo_new/Utils.dart';
import 'package:talent_turbo_new/models/candidate_profile_model.dart';
import 'package:talent_turbo_new/models/login_data_model.dart';
import 'package:talent_turbo_new/models/user_data_model.dart';
import 'package:talent_turbo_new/screens/auth/auth_service.dart';
import 'package:talent_turbo_new/screens/auth/login/login_screen.dart';
import 'package:talent_turbo_new/screens/editPhoto/croppage.dart';
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
      // IconSnackBar.show(
      //   context,
      //   label: 'Could not launch ${filePath}',
      //   snackBarType: SnackBarType.alert,
      //   backgroundColor: Color(0xff2D2D2D),
      //   iconColor: Colors.white,
      // );
      throw 'Could not launch ${filePath}';
    }
  }

  Future<void> _showImagePickerBottomSheet(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      builder: (BuildContext context) {
        return SizedBox(
          height: 259,
          child: Column(
            children: [
              const SizedBox(height: 15),
              Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.25,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Upload & take a picture',
                style: GoogleFonts.lato(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () async {
                      Navigator.pop(context);
                      await _openCamera();
                      fetchProfileFromPref();
                    },
                    child: _buildOptionContainer(
                        'assets/images/camera (1).png', 'Camera'),
                  ),
                  GestureDetector(
                    onTap: () async {
                      Navigator.pop(context);
                      await _openGallery();
                      fetchProfileFromPref();
                    },
                    child: _buildOptionContainer(
                        'assets/images/files.png', 'Gallery'),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                "File types: png, jpg, jpeg  Max file size: 5MB",
                style: GoogleFonts.lato(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Color(0xff333333)),
              )
            ],
          ),
        );
      },
    );
  }

  Future<void> _openCamera() async {
    final ImagePicker _picker = ImagePicker();
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        final croppedImagePath = await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => Croppage(imagePath: image.path),
          ),
        );

        if (croppedImagePath != null) {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditPhotoPage(
                initialImagePath: croppedImagePath,
                isNewImage: true,
              ),
            ),
          );
          fetchProfileFromPref();
        }
      }
    } catch (e) {
      _showError('Failed to capture image: $e');
    }
  }

  Future<void> _openGallery() async {
    final ImagePicker _picker = ImagePicker();
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        final croppedImagePath = await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => Croppage(imagePath: image.path),
          ),
        );

        if (croppedImagePath != null) {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditPhotoPage(
                initialImagePath: croppedImagePath,
                isNewImage: true,
              ),
            ),
          );
          fetchProfileFromPref();
        }
      }
    } catch (e) {
      _showError('Failed to pick image: $e');
    }
  }

  Future<void> _uploadImage(File file) async {
    UserData? userData = await getUserData();
    if (userData == null) return;

    Dio dio = Dio();
    String url =
        AppConstants.BASE_URL + AppConstants.UPDATE_CANDIDATE_PROFILE_PICTURE;

    try {
      FormData formData = FormData.fromMap({
        "id": userData.profileId.toString(),
        "file": await MultipartFile.fromFile(
          file.path,
          filename: file.path.split('/').last,
        ),
        "type": "candidate"
      });

      await dio.post(
        url,
        data: formData,
        options: Options(
          headers: {
            'Authorization': userData.token,
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

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
                  'Profile picture updated!',
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
      fetchProfileFromPref();
    } catch (e) {
      IconSnackBar.show(
        context,
        label: 'Failed to upload image: $e',
        snackBarType: SnackBarType.alert,
        backgroundColor: Color(0xff2D2D2D),
        iconColor: Colors.white,
      );
    }
  }

  Widget _buildOptionContainer(String assetPath, String label) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 100,
            width: 143,
            color: const Color(0xFFEEEEEE),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(assetPath,
                    height: 26, width: 31, fit: BoxFit.cover),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: GoogleFonts.lato(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.black),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showError(String message) {
    IconSnackBar.show(
      context,
      label: message,
      snackBarType: SnackBarType.alert,
      backgroundColor: Color(0xff2D2D2D),
      iconColor: Colors.white,
    );
  }

  void showDeleteConfirmationDialog(
      BuildContext context, bool isConnectionAvailable) {
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
                  'Logout',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'lato',
                      color: Color(0xff333333)),
                ),
                SizedBox(height: 12),
                Text(
                  'Are you sure you want to log out?',
                  style: TextStyle(
                      height: 1.2,
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
                            onTap: () async {
                              if (!isConnectionAvailable) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        'No internet connection. Please try again later.'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }

                              SharedPreferences prefs =
                                  await SharedPreferences.getInstance();
                              await prefs.clear(); // Clears all stored data

                              await _googleAuthService.signOut();

                              // Ensure UI updates before navigating
                              (context as Element).markNeedsBuild();

                              Navigator.pushAndRemoveUntil(
                                context,
                                PageRouteBuilder(
                                  pageBuilder: (context, animation,
                                          secondaryAnimation) =>
                                      LoginScreen(),
                                  transitionDuration: Duration.zero,
                                  reverseTransitionDuration: Duration.zero,
                                ),
                                (Route<dynamic> route) => false,
                              );
                            },
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                  color: AppColors.primaryColor,
                                  borderRadius: BorderRadius.circular(7)),
                              child: Center(
                                child: Text(
                                  'Logout',
                                  style: TextStyle(
                                      color: Colors.white, fontFamily: 'lato'),
                                ),
                              ),
                            ),
                          ),
                        ),
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
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Color(0xff001B3E),
      statusBarIconBrightness: Brightness.light,
    ));
    return RefreshIndicator(
      onRefresh: fetchProfileFromPref,
      color: Color(0xffFCFCFC),
      child: Column(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 0.07,
            decoration: BoxDecoration(color: Color(0xff001B3E)),
          ),
          isConnectionAvailable
              ? Column(
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height * 0.265,
                      color: Color(0xffFCFCFC),
                      child: Stack(
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height * 0.1,
                            decoration: BoxDecoration(
                              color: Color(0xff001B3E),
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(10),
                                bottomRight: Radius.circular(10),
                              ),
                            ),
                          ),
                          Positioned(
                            top: MediaQuery.of(context).size.height * 0.035,
                            left: (MediaQuery.of(context).size.width -
                                    (MediaQuery.of(context).size.width *
                                        0.25)) /
                                2,
                            child: Stack(
                              alignment: Alignment.bottomRight,
                              children: [
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.25,
                                  height:
                                      MediaQuery.of(context).size.width * 0.25,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Colors.white, width: 3),
                                    shape: BoxShape.circle,
                                  ),
                                  child: InkWell(
                                    onTap: () async {
                                      if (candidateProfileModel == null ||
                                          candidateProfileModel?.imagePath ==
                                              null ||
                                          candidateProfileModel!
                                              .imagePath!.isEmpty) {
                                        await _showImagePickerBottomSheet(
                                            context);
                                      } else {
                                        await Navigator.push(
                                          context,
                                          PageRouteBuilder(
                                            pageBuilder: (context, animation,
                                                    secondaryAnimation) =>
                                                EditPhotoPage(),
                                            transitionDuration: Duration.zero,
                                            reverseTransitionDuration:
                                                Duration.zero,
                                          ),
                                        );
                                        fetchProfileFromPref();
                                      }
                                    },
                                    child: ClipOval(
                                      child: (candidateProfileModel != null &&
                                              candidateProfileModel!
                                                      .imagePath !=
                                                  null)
                                          ? CachedNetworkImage(
                                              imageUrl: candidateProfileModel!
                                                  .imagePath!,
                                              fit: BoxFit.cover,
                                              placeholder: (context, url) =>
                                                  SvgPicture.asset(
                                                'assets/icon/profile.svg',
                                                fit: BoxFit.cover,
                                              ),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      SvgPicture.asset(
                                                'assets/icon/profile.svg',
                                                fit: BoxFit.cover,
                                              ),
                                              fadeInDuration:
                                                  Duration(milliseconds: 300),
                                              fadeOutDuration:
                                                  Duration(milliseconds: 300),
                                            )
                                          : SvgPicture.asset(
                                              'assets/icon/profile.svg',
                                              fit: BoxFit.cover,
                                            ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  right: 0,
                                  bottom: 0,
                                  child: SvgPicture.asset(
                                      'assets/icon/DpEdit.svg',
                                      width: MediaQuery.of(context).size.width *
                                          0.07,
                                      height:
                                          MediaQuery.of(context).size.width *
                                              0.07),
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            top: MediaQuery.of(context).size.height * 0.165,
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
                    ),
                    Container(
                      color: Color(0xffFCFCFC),
                      height: MediaQuery.of(context).size.height - 350,
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            ListTile(
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder: (context, animation,
                                            secondaryAnimation) =>
                                        PersonalDetails(),
                                    transitionDuration: Duration.zero,
                                    reverseTransitionDuration: Duration.zero,
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
                                'assets/icon/ArrowRight.svg',
                                width: 24,
                                height: 24,
                              ),
                            ),
                            Divider(),
                            ListTile(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder: (context, animation,
                                            secondaryAnimation) =>
                                        Accountsettings(),
                                    transitionDuration: Duration.zero,
                                    reverseTransitionDuration: Duration.zero,
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
                                'assets/icon/ArrowRight.svg',
                                width: 24,
                                height: 24,
                              ),
                            ),
                            Divider(),
                            ListTile(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder: (context, animation,
                                            secondaryAnimation) =>
                                        MyRewards(),
                                    transitionDuration: Duration.zero,
                                    reverseTransitionDuration: Duration.zero,
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
                                'assets/icon/ArrowRight.svg',
                                width: 24,
                                height: 24,
                              ),
                            ),
                            Divider(),
                            ListTile(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder: (context, animation,
                                            secondaryAnimation) =>
                                        InviteAndEarn(),
                                    transitionDuration: Duration.zero,
                                    reverseTransitionDuration: Duration.zero,
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
                                'assets/icon/ArrowRight.svg',
                                width: 24,
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
                                'assets/icon/ArrowRight.svg',
                                width: 24,
                                height: 24,
                              ),
                            ),
                            Divider(),
                            ListTile(
                              onTap: () {
                                showDeleteConfirmationDialog(
                                    context, isConnectionAvailable);
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
                                'assets/icon/ArrowRight.svg',
                                width: 24,
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
                      SizedBox(height: 25),
                      Text(
                        'No Internet connection',
                        style: TextStyle(
                            fontFamily: 'Lato',
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Color(0xff333333)),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Connect to Wi-Fi or cellular data and try again.',
                        style: TextStyle(
                            fontFamily: 'Lato',
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                            color: Color(0xff545454)),
                      ),
                      SizedBox(height: 20),
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
    if (_candidateProfileModel?.imagePath != null) {
      precacheImage(NetworkImage(_candidateProfileModel!.imagePath!), context);
    }
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

    _connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      setState(() {
        isConnectionAvailable = results.contains(ConnectivityResult.mobile) ||
            results.contains(ConnectivityResult.wifi);
      });

      // if (!isConnectionAvailable) {
      //   IconSnackBar.show(
      //     context,
      //     label: 'No internet connection',
      //     snackBarType: SnackBarType.alert,
      //     backgroundColor: Color(0xff2D2D2D),
      //     iconColor: Colors.white,
      //   );
      // }
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
      // IconSnackBar.show(
      //   context,
      //   label: 'No internet connection',
      //   snackBarType: SnackBarType.alert,
      //   backgroundColor: Color(0xff2D2D2D),
      //   iconColor: Colors.white,
      // );

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
