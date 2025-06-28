import 'dart:convert';
import 'dart:ui';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shimmer/shimmer.dart';
import 'package:talent_turbo_new/AppColors.dart';
import 'package:talent_turbo_new/AppConstants.dart';
import 'package:talent_turbo_new/Utils.dart';
import 'package:talent_turbo_new/models/referral_profile_model.dart';
import 'package:talent_turbo_new/models/user_data_model.dart';
import 'package:talent_turbo_new/screens/jobDetails/job_apply.dart';
import 'package:http/http.dart' as http;

class Jobdetails extends StatefulWidget {
  final dynamic jobData;
  final bool isFromSaved;

  const Jobdetails(
      {super.key, required this.jobData, required this.isFromSaved});

  @override
  State<Jobdetails> createState() => _JobdetailsState();
}

class _JobdetailsState extends State<Jobdetails> {
  bool isLoading = true;
  bool isReferLoading = false;
  ReferralData? referralData;
  UserData? retrievedUserData;

  bool isSaved = false;

  List<dynamic> eligibilityList = [];
  List<dynamic> technologyList = [];
  List<dynamic> skillList = [];
  List<String> userSkills = [];

  void _shareApp(String refCode) {
    //final String appUrl = "https://play.google.com/store/apps/details?id=com.android.referral.talentturbo";
    final String appUrl =
        "https://play.google.com/store/apps/details?id=com.android.referral.talentturbo&referrer=$refCode";
    Share.share(
      "💼 ${rawJobData?['data']?['jobTitle'] ?? widget.jobData['jobTitle'] ?? 'Job'} position available at ${widget.jobData['companyName'] ?? 'a company'}! \n\nDon't miss this chance—apply today: Download now at $appUrl. \n\nUse my referral code $refCode while signing up. \n\n#GetHired #Jobs #TalentTurbo",
      subject: 'Try this awesome app!',
    );
  }

  bool isConnectionAvailable = true;

  var rawJobData = null;

  Future<void> getJobData() async {
    final jobId = widget.jobData['jobId'] ?? widget.jobData['id'];
    if (jobId == null) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    final url = Uri.parse(
        AppConstants.BASE_URL + AppConstants.VIEW_JOB + jobId.toString());

    try {
      setState(() {
        isLoading = true;
      });

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': retrievedUserData?.token ?? ''
        },
      );

      if (kDebugMode) {
        print(
            'Response code ${response.statusCode} :: Response => ${response.body}');
      }

      if (response.statusCode == 200) {
        var resOBJ = jsonDecode(response.body);

        setState(() {
          rawJobData = resOBJ;
          eligibilityList = resOBJ['data']?['eligibilityData'] ?? [];
          technologyList = resOBJ['data']?['technologyList'] ?? [];
          skillList = resOBJ['data']?['skillList'] ?? [];
        });
      }
    } catch (e) {
      print(e.toString());
      setState(() {
        isLoading = false;
      });
    } finally {
      var connectivityResult = await Connectivity().checkConnectivity();
      setState(() {
        isLoading = false;
        isConnectionAvailable = connectivityResult != ConnectivityResult.none;
      });
    }
  }

  Future<bool> saveJob(int jobId, int status) async {
    final url =
        Uri.parse(AppConstants.BASE_URL + AppConstants.SAVE_JOB_TO_FAV_NEW);
    final bodyParams = {"jobId": jobId, "isFavorite": status};

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': retrievedUserData?.token ?? '',
        },
        body: jsonEncode(bodyParams),
      );

      if (kDebugMode) {
        print(
            'Response code: ${response.statusCode} :: Response => ${response.body}');
      }

      if (response.statusCode == 200 || response.statusCode == 202) {
        return true; // ✅ Return success
      } else {
        if (kDebugMode) {
          print('Something went wrong. Please try again.');
        }
        return false; // ❌ Return failure
      }
    } catch (e) {
      if (kDebugMode) print("Error: $e");

      return false; // ❌ Return failure
    }
  }

  String getFormattedExperience(dynamic experience) {
    double expValue = 0;
    if (experience is String) {
      expValue = double.tryParse(experience) ?? 0;
    } else if (experience is num) {
      expValue = experience.toDouble();
    }

    if (expValue == 0) {
      return 'Fresher';
    } else {
      return '${expValue.floor()}+ Years';
    }
  }

  String _formatSalary(dynamic salary) {
    if (salary is num) {
      if (salary % 1 == 0) {
        return salary.toInt().toString();
      } else {
        return salary.toStringAsFixed(2);
      }
    }
    return salary.toString();
  }

  final FToast fToast = FToast();

  double _currentBottomPosition = 0.1;
  final List<double> _activeToastPositions = [];

  void _resetToastPositions() {
    _currentBottomPosition = 0.1;
    _activeToastPositions.clear();
  }

  void showJobSavedToast(BuildContext context) {
    fToast.init(context);
    fToast.removeQueuedCustomToasts();

    final position = _currentBottomPosition;
    _activeToastPositions.add(position);
    _currentBottomPosition += 0.05;

    final screenWidth = MediaQuery.of(context).size.width;
    final toastWidth = screenWidth * 0.95;

    Widget toast = SizedBox(
      width: toastWidth,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: const Color(0xFF2D2D2D),
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            const Icon(Icons.bookmark_rounded,
                color: Color(0xff004C99), size: 24),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                "Job saved!",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontFamily: 'Lato',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                fToast.removeCustomToast();
                _activeToastPositions.remove(position);
                if (_activeToastPositions.isEmpty) {
                  _resetToastPositions();
                }
              },
              child: const Icon(Icons.close, color: Colors.white, size: 22),
            ),
          ],
        ),
      ),
    );

    fToast.showToast(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height * 0.045,
        ),
        child: toast,
      ),
      gravity: ToastGravity.BOTTOM,
      toastDuration: const Duration(seconds: 2),
    );
  }

  void showJobRemovedToast(BuildContext context, VoidCallback onUndo) {
    fToast.init(context);
    fToast.removeQueuedCustomToasts();

    final position = _currentBottomPosition;
    _activeToastPositions.add(position);
    _currentBottomPosition += 0.05;

    final screenWidth = MediaQuery.of(context).size.width;
    final toastWidth = screenWidth * 0.95;

    Widget toast = SizedBox(
      width: toastWidth,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: const Color(0xFF2D2D2D),
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            const Icon(Icons.bookmark_border_rounded,
                color: Colors.white, size: 24),
            const SizedBox(width: 8.0),
            const Expanded(
              child: Text(
                "Job removed!",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontFamily: 'Lato',
                ),
              ),
            ),
            const SizedBox(width: 8.0),
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                fToast.removeCustomToast();
                _activeToastPositions.remove(position);
                if (_activeToastPositions.isEmpty) {
                  _resetToastPositions();
                }
                onUndo();
              },
              child: IntrinsicWidth(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Undo",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Lato',
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      height: 1,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );

    fToast.showToast(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height * 0.045,
        ),
        child: toast,
      ),
      gravity: ToastGravity.BOTTOM,
      toastDuration: const Duration(seconds: 3),
    );
  }

  bool checkExpiry(String dateString) {
    // Parse the date string
    DateTime providedDate = DateFormat("yyyy-MM-dd").parse(dateString);

    // Get the current date at midnight
    DateTime currentDate = DateTime.now();
    currentDate =
        DateTime(currentDate.year, currentDate.month, currentDate.day);

    // Reset providedDate to midnight as well
    providedDate =
        DateTime(providedDate.year, providedDate.month, providedDate.day);

    // Compare the dates
    return providedDate.isBefore(currentDate);
  }

  Future<void> getRefCode(int jobId) async {
    final url =
        Uri.parse(AppConstants.BASE_URL + AppConstants.GET_REF_CODE_SHARE);

    final bodyParams = {
      "jobId": jobId,
    };

    try {
      setState(() {
        isReferLoading = true;
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
        IconSnackBar.show(
          context,
          label: 'Failed to share JOB.',
          snackBarType: SnackBarType.alert,
          backgroundColor: Color(0xFFBA1A1A),
          iconColor: Colors.white,
        );
      }
    } catch (e) {
      if (kDebugMode) print(e);
    } finally {
      setState(() {
        isReferLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Color(0xff001B3E),
      statusBarIconBrightness: Brightness.light,
    ));

    final jobTitle = rawJobData?['data']?['jobTitle'] ??
        widget.jobData['jobTitle'] ??
        'No Title';
    final companyName = widget.jobData['companyName'] ?? 'No Company';
    final logo = widget.jobData['logo'] ?? '';
    final location = widget.jobData['location'] ?? 'Location Not Disclosed';
    final workType = widget.jobData['workType'] ?? 'N/A';
    final jobDescription =
        widget.jobData['jobDescription'] ?? 'No description available';
    final dueDate = widget.jobData['dueDate'] ?? '1990-01-01';
    final jobCode = widget.jobData['jobCode'] ?? 'TT-JB-XXXX';
    final createdDate = widget.jobData['createdDate'] ?? '1990-01-01';
    final salary = widget.jobData['salary'] ?? 0;
    final isFavorite = widget.jobData['isFavorite'] == "1";
    final jobId = widget.jobData['jobId'] ?? widget.jobData['id'];

    return Scaffold(
      backgroundColor: Color(0xffFCFCFC),
      body: Stack(
        children: [
          Column(
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
                      'Job Details',
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
              isLoading
                  ? Expanded(
                      child: Shimmer.fromColors(
                        baseColor: Color(0xffE6E6E6),
                        highlightColor: Color(0xffF2F2F2),
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: 1,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: EdgeInsets.all(15),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Circular profile placeholder
                                  Row(
                                    children: [
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.11,
                                        height:
                                            MediaQuery.of(context).size.width *
                                                0.11,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.43,
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.03,
                                            decoration: BoxDecoration(
                                              color: Color(0xffE6E6E6),
                                              shape: BoxShape.rectangle,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                          SizedBox(height: 5),
                                          Container(
                                            width: 250,
                                            height: 15,
                                            decoration: BoxDecoration(
                                              color: Color(0xffE6E6E6),
                                              shape: BoxShape.rectangle,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                          SizedBox(height: 5),
                                          Container(
                                            width: 300,
                                            height: 15,
                                            decoration: BoxDecoration(
                                              color: Color(0xffE6E6E6),
                                              shape: BoxShape.rectangle,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Spacer(),
                                      Container(
                                        width: 25,
                                        height: 25,
                                        decoration: BoxDecoration(
                                          color: Color(0xffE6E6E6),
                                          shape: BoxShape.rectangle,
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 15),
                                  Row(
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.43,
                                            height: 75,
                                            decoration: BoxDecoration(
                                              color: Color(0xffE6E6E6),
                                              shape: BoxShape.rectangle,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                          SizedBox(height: 15),
                                          Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.43,
                                            height: 75,
                                            decoration: BoxDecoration(
                                              color: Color(0xffE6E6E6),
                                              shape: BoxShape.rectangle,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(width: 25),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.43,
                                            height: 75,
                                            decoration: BoxDecoration(
                                              color: Color(0xffE6E6E6),
                                              shape: BoxShape.rectangle,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                          SizedBox(height: 15),
                                          Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.43,
                                            height: 75,
                                            decoration: BoxDecoration(
                                              color: Color(0xffE6E6E6),
                                              shape: BoxShape.rectangle,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Container(
                                    width: MediaQuery.of(context).size.width,
                                    height: 1,
                                    color: Color(0xffE6E6E6),
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Container(
                                    width: 170,
                                    height: 30,
                                    decoration: BoxDecoration(
                                      color: Color(0xffE6E6E6),
                                      shape: BoxShape.rectangle,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  SizedBox(height: 15),
                                  Row(
                                    children: [
                                      Container(
                                        width: 250,
                                        height: 30,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.rectangle,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                      SizedBox(width: 15),
                                      Container(
                                        width: 190,
                                        height: 30,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.rectangle,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 15),
                                  Row(
                                    children: [
                                      Container(
                                        width: 180,
                                        height: 30,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.rectangle,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                      SizedBox(width: 15),
                                      Container(
                                        width: 150,
                                        height: 30,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.rectangle,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 15),
                                  Row(
                                    children: [
                                      Container(
                                        width: 120,
                                        height: 30,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.rectangle,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                      SizedBox(width: 15),
                                      Container(
                                        width: 140,
                                        height: 30,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.rectangle,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                      SizedBox(width: 15),
                                      Container(
                                        width: 160,
                                        height: 30,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.rectangle,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 15),
                                  Container(
                                    width: 185,
                                    height: 30,
                                    decoration: BoxDecoration(
                                      color: Color(0xffE6E6E6),
                                      shape: BoxShape.rectangle,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Container(
                                    width: MediaQuery.of(context).size.width,
                                    height: 1,
                                    color: Color(0xffE6E6E6),
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Container(
                                    width: 250,
                                    height: 30,
                                    decoration: BoxDecoration(
                                      color: Color(0xffE6E6E6),
                                      shape: BoxShape.rectangle,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 15,
                                  ),
                                  Container(
                                    width:
                                        MediaQuery.of(context).size.width * 1.0,
                                    height: 45,
                                    decoration: BoxDecoration(
                                      color: Color(0xffE6E6E6),
                                      shape: BoxShape.rectangle,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 15,
                                  ),
                                  Container(
                                    width:
                                        MediaQuery.of(context).size.width * 1.0,
                                    height: 78,
                                    decoration: BoxDecoration(
                                      color: Color(0xffE6E6E6),
                                      shape: BoxShape.rectangle,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 15,
                                  ),
                                  Container(
                                    width:
                                        MediaQuery.of(context).size.width * 1.0,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: Color(0xffE6E6E6),
                                      shape: BoxShape.rectangle,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 15,
                                  ),
                                  Container(
                                    width: MediaQuery.of(context).size.width,
                                    height: 1,
                                    color: Color(0xffE6E6E6),
                                  ),
                                  SizedBox(
                                    height: 15,
                                  ),
                                  Container(
                                    width: 200,
                                    height: 30,
                                    decoration: BoxDecoration(
                                      color: Color(0xffE6E6E6),
                                      shape: BoxShape.rectangle,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 15,
                                  ),
                                  Container(
                                    width:
                                        MediaQuery.of(context).size.width * 1.0,
                                    height: 83,
                                    decoration: BoxDecoration(
                                      color: Color(0xffE6E6E6),
                                      shape: BoxShape.rectangle,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 15,
                                  ),
                                  Container(
                                    width:
                                        MediaQuery.of(context).size.width * 1.0,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: Color(0xffE6E6E6),
                                      shape: BoxShape.rectangle,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 15,
                                  ),
                                  Container(
                                    width:
                                        MediaQuery.of(context).size.width * 1.0,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: Color(0xffE6E6E6),
                                      shape: BoxShape.rectangle,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 15,
                                  ),
                                  Container(
                                    width: MediaQuery.of(context).size.width,
                                    height: 1,
                                    color: Color(0xffE6E6E6),
                                  ),
                                  SizedBox(
                                    height: 15,
                                  ),
                                  Container(
                                    width: 130,
                                    height: 30,
                                    decoration: BoxDecoration(
                                      color: Color(0xffE6E6E6),
                                      shape: BoxShape.rectangle,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 15,
                                  ),
                                  Container(
                                    width: 270,
                                    height: 30,
                                    decoration: BoxDecoration(
                                      color: Color(0xffE6E6E6),
                                      shape: BoxShape.rectangle,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 15,
                                  ),
                                  Container(
                                    width: MediaQuery.of(context).size.width,
                                    height: 1,
                                    color: Color(0xffE6E6E6),
                                  ),
                                  SizedBox(
                                    height: 15,
                                  ),
                                  Container(
                                    width: 130,
                                    height: 30,
                                    decoration: BoxDecoration(
                                      color: Color(0xffE6E6E6),
                                      shape: BoxShape.rectangle,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 15,
                                  ),
                                  Container(
                                    width: 270,
                                    height: 30,
                                    decoration: BoxDecoration(
                                      color: Color(0xffE6E6E6),
                                      shape: BoxShape.rectangle,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    )
                  : rawJobData != null
                      ? Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(15),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Flexible(
                                            child: Row(
                                              children: [
                                                Image(
                                                  image: logo.isNotEmpty
                                                      ? NetworkImage(logo)
                                                          as ImageProvider
                                                      : AssetImage(
                                                          'assets/images/tt_logo_resized.png'),
                                                  height: 60,
                                                  width: 60,
                                                  fit: BoxFit.contain,
                                                  errorBuilder: (context, error,
                                                      stackTrace) {
                                                    return Image.asset(
                                                        'assets/images/tt_logo_resized.png',
                                                        height: 40,
                                                        width: 40);
                                                  },
                                                ),
                                                const SizedBox(width: 10),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        jobTitle ?? '',
                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          fontFamily: 'Lato',
                                                          fontSize: 18,
                                                          color:
                                                              Color(0xff333333),
                                                        ),
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Text(
                                                        companyName ?? '',
                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          fontFamily: 'Lato',
                                                          fontSize: 14,
                                                          color:
                                                              Color(0xff545454),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(right: 15),
                                            child: InkWell(
                                              onTap: () async {
                                                if (jobId == null) return;
                                                bool newIsFavorite =
                                                    !isFavorite;
                                                setState(() {
                                                  widget.jobData['isFavorite'] =
                                                      newIsFavorite ? "1" : "0";
                                                });

                                                bool success = await saveJob(
                                                    jobId,
                                                    newIsFavorite ? 1 : 0);

                                                if (!success) {
                                                  setState(() {
                                                    widget.jobData[
                                                            'isFavorite'] =
                                                        isFavorite ? "1" : "0";
                                                  });
                                                } else {
                                                  if (newIsFavorite) {
                                                    showJobSavedToast(context);
                                                  } else {
                                                    showJobRemovedToast(context,
                                                        () {
                                                      setState(() {
                                                        widget.jobData[
                                                            'isFavorite'] = "1";
                                                      });
                                                      saveJob(jobId, 1);
                                                    });
                                                  }
                                                }
                                              },
                                              child:
                                                  TweenAnimationBuilder<double>(
                                                duration:
                                                    Duration(milliseconds: 400),
                                                tween: Tween<double>(
                                                  begin: isFavorite ? 0 : 1,
                                                  end: isFavorite ? 1 : 0,
                                                ),
                                                builder:
                                                    (context, value, child) {
                                                  return Stack(
                                                    alignment:
                                                        Alignment.topCenter,
                                                    children: [
                                                      Icon(
                                                        Icons
                                                            .bookmark_border_rounded,
                                                        size: 25,
                                                        color: Colors.black54,
                                                      ),
                                                      ClipRect(
                                                        child: Align(
                                                          alignment: Alignment
                                                              .topCenter,
                                                          heightFactor: value,
                                                          child: Icon(
                                                            Icons.bookmark,
                                                            size: 25,
                                                            color: Color(
                                                                0xff004C99),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),

                                      Container(
                                        margin:
                                            EdgeInsets.fromLTRB(67, 15, 0, 0),
                                        child: Row(
                                          children: [
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 6, vertical: 8),
                                              decoration: BoxDecoration(
                                                  color: Color(0xffEEEEEE),
                                                  borderRadius:
                                                      BorderRadius.circular(5)),
                                              child: Text(
                                                jobCode ?? 'TT-JB-9571',
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color: Color(0xff545454),
                                                    fontWeight: FontWeight.w400,
                                                    fontFamily: 'lato'),
                                              ),
                                            ),
                                            SizedBox(
                                              width: 20,
                                            ),
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 5, vertical: 8),
                                              decoration: BoxDecoration(
                                                  color: Color(0xffEEEEEE),
                                                  borderRadius:
                                                      BorderRadius.circular(5)),
                                              child: Text(
                                                'Posted ${processDate(createdDate).replaceFirst('-', '')}',
                                                style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Color(0xff545454),
                                                    fontWeight: FontWeight.w400,
                                                    fontFamily: 'lato'),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      SizedBox(
                                        height: 20,
                                      ),
                                      GridView.count(
                                        shrinkWrap: true,
                                        physics: NeverScrollableScrollPhysics(),
                                        crossAxisCount: 2,
                                        mainAxisSpacing: 20,
                                        crossAxisSpacing: 16,
                                        childAspectRatio: 157 / 70,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 0),
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                              color: Color(0xffEEEEEE),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Center(
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  SvgPicture.asset(
                                                      'assets/images/ic_worktype.svg'),
                                                  SizedBox(height: 3),
                                                  Text(
                                                    'Employment type',
                                                    style: TextStyle(
                                                      fontFamily: 'Lato',
                                                      color: Color(0xff333333),
                                                      fontSize: 10 *
                                                          MediaQuery.of(context)
                                                              .textScaleFactor,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                    ),
                                                  ),
                                                  SizedBox(height: 3),
                                                  Text(
                                                    workType,
                                                    style: TextStyle(
                                                      fontFamily: 'Lato',
                                                      color: Color(0xff333333),
                                                      fontSize: 11 *
                                                          MediaQuery.of(context)
                                                              .textScaleFactor,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Container(
                                            decoration: BoxDecoration(
                                              color: Color(0xffEEEEEE),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Center(
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  SvgPicture.asset(
                                                      'assets/images/ic_experience.svg'),
                                                  SizedBox(height: 3),
                                                  Text(
                                                    'Experience',
                                                    style: TextStyle(
                                                      fontFamily: 'Lato',
                                                      color: Color(0xff333333),
                                                      fontSize: 10 *
                                                          MediaQuery.of(context)
                                                              .textScaleFactor,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                    ),
                                                  ),
                                                  SizedBox(height: 3),
                                                  Text(
                                                    '${((rawJobData['data']['experience'] ?? 1) < 1) ? '0–1 year' : '${(rawJobData['data']['experience']).toInt()}+ years'}',
                                                    style: TextStyle(
                                                      fontFamily: 'Lato',
                                                      color: Color(0xff333333),
                                                      fontSize: 11 *
                                                          MediaQuery.of(context)
                                                              .textScaleFactor,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Container(
                                            decoration: BoxDecoration(
                                              color: Color(0xffEEEEEE),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Center(
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  SvgPicture.asset(
                                                      'assets/images/ic_onsite.svg'),
                                                  SizedBox(height: 3),
                                                  Text(
                                                    'Work type',
                                                    style: TextStyle(
                                                      fontFamily: 'Lato',
                                                      color: Color(0xff333333),
                                                      fontSize: 10 *
                                                          MediaQuery.of(context)
                                                              .textScaleFactor,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                    ),
                                                  ),
                                                  SizedBox(height: 3),
                                                  Text(
                                                    workType,
                                                    style: TextStyle(
                                                      fontFamily: 'Lato',
                                                      color: Color(0xff333333),
                                                      fontSize: 11 *
                                                          MediaQuery.of(context)
                                                              .textScaleFactor,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Container(
                                            decoration: BoxDecoration(
                                              color: Color(0xffEEEEEE),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Center(
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  SvgPicture.asset(
                                                      'assets/images/ic_job_location.svg'),
                                                  SizedBox(height: 3),
                                                  Text(
                                                    'Location',
                                                    style: TextStyle(
                                                      fontFamily: 'Lato',
                                                      color: Color(0xff333333),
                                                      fontSize: 10 *
                                                          MediaQuery.of(context)
                                                              .textScaleFactor,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                    ),
                                                  ),
                                                  SizedBox(height: 3),
                                                  Text(
                                                    location ?? 'N/A',
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      fontFamily: 'Lato',
                                                      color: Color(0xff333333),
                                                      fontSize: 11 *
                                                          MediaQuery.of(context)
                                                              .textScaleFactor,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),

                                      SizedBox(
                                        height: 30,
                                      ),
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        height: 1,
                                        color: Color(0xffE6E6E6),
                                      ),

                                      SizedBox(
                                        height: 20,
                                      ),
                                      Text(
                                        'Skills required:',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xff333333),
                                            fontSize: 18,
                                            fontFamily: 'Lato'),
                                      ),
                                      SizedBox(
                                        height: 20,
                                      ),
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        child: Wrap(
                                          spacing: 8.0,
                                          runSpacing: 12.0,
                                          children: () {
                                            Set<String> seenSkillsLower = {};
                                            List<Widget> skillWidgets = [];

                                            for (var tech in technologyList) {
                                              List<dynamic> skills =
                                                  tech['technologySkillData'] ??
                                                      [];

                                              for (var skill in skills) {
                                                final String skillName =
                                                    skill['skillName'] ?? '';
                                                final String skillNameLower =
                                                    skillName.toLowerCase();

                                                if (seenSkillsLower.contains(
                                                    skillNameLower)) continue;

                                                seenSkillsLower
                                                    .add(skillNameLower);

                                                final bool isMatched =
                                                    userSkills
                                                        .map((e) =>
                                                            e.toLowerCase())
                                                        .contains(
                                                            skillNameLower);

                                                skillWidgets.add(
                                                  Container(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 10,
                                                            vertical: 8),
                                                    decoration: BoxDecoration(
                                                      color: isMatched
                                                          ? Color(0xffF0F6FF)
                                                          : Color(0xffEEEEEE),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              7.0),
                                                    ),
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        if (isMatched)
                                                          SvgPicture.asset(
                                                            'assets/images/ic_tick.svg',
                                                            height: 12,
                                                            width: 18,
                                                          ),
                                                        if (isMatched)
                                                          SizedBox(width: 10),
                                                        Text(
                                                          skillName,
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            fontFamily: 'Lato',
                                                            color: isMatched
                                                                ? Color(
                                                                    0xff004C99)
                                                                : Color(
                                                                    0xff333333),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              }
                                            }

                                            return skillWidgets;
                                          }(),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 20,
                                      ),
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        height: 1,
                                        color: Color(0xffE6E6E6),
                                      ),

                                      SizedBox(
                                        height: 20,
                                      ),
                                      Text(
                                        'Job description:',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xff333333),
                                            fontSize: 18,
                                            fontFamily: 'Lato'),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),

                                      //Job Description
                                      /* Container(
                          width: MediaQuery.of(context).size.width,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 10.0), // Adjust padding if needed
                                    child: Icon(
                                      Icons.brightness_1, // You can use any icon you prefer for the bullet
                                      size: 8, // Small size for the bullet
                                      color: Colors.black, // Adjust color if necessary
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: RichText(text: TextSpan(
                                      children: [
                                        TextSpan(text: 'Lead Generation: ', style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xff333333), // Make sure to set color when using TextSpan
                                        ),),
                                        TextSpan(
                                          text:
                                          'Identify and research potential clients and market opportunities to generate new business leads.',
                                          style: TextStyle(
                                            height: 1.5,
                                            fontSize: 16,
                                            fontWeight: FontWeight.normal,
                                            color: Color(0xff333333), // Make sure to set color when using TextSpan
                                          ),
                                        ),
                                      ]
                                    )),
                                  )
                                ],
                              ),
                              SizedBox(height: 15,),

                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 10.0), // Adjust padding if needed
                                    child: Icon(
                                      Icons.brightness_1, // You can use any icon you prefer for the bullet
                                      size: 8, // Small size for the bullet
                                      color: Colors.black, // Adjust color if necessary
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: RichText(text: TextSpan(
                                        children: [
                                          TextSpan(text: 'Lead Generation: ', style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xff333333), // Make sure to set color when using TextSpan
                                          ),),
                                          TextSpan(
                                            text:
                                            'Identify and research potential clients and market opportunities to generate new business leads.',
                                            style: TextStyle(
                                              height: 1.5,
                                              fontSize: 16,
                                              fontWeight: FontWeight.normal,
                                              color: Color(0xff333333), // Make sure to set color when using TextSpan
                                            ),
                                          ),
                                        ]
                                    )),
                                  )
                                ],
                              ),
                              SizedBox(height: 15,),

                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 10.0), // Adjust padding if needed
                                    child: Icon(
                                      Icons.brightness_1, // You can use any icon you prefer for the bullet
                                      size: 8, // Small size for the bullet
                                      color: Colors.black, // Adjust color if necessary
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: RichText(text: TextSpan(
                                        children: [
                                          TextSpan(text: 'Lead Generation: ', style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xff333333), // Make sure to set color when using TextSpan
                                          ),),
                                          TextSpan(
                                            text:
                                            'Identify and research potential clients and market opportunities to generate new business leads.',
                                            style: TextStyle(
                                              height: 1.5,
                                              fontSize: 16,
                                              fontWeight: FontWeight.normal,
                                              color: Color(0xff333333), // Make sure to set color when using TextSpan
                                            ),
                                          ),
                                        ]
                                    )),
                                  )
                                ],
                              ),
                              SizedBox(height: 15,),

                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 10.0), // Adjust padding if needed
                                    child: Icon(
                                      Icons.brightness_1, // You can use any icon you prefer for the bullet
                                      size: 8, // Small size for the bullet
                                      color: Colors.black, // Adjust color if necessary
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: RichText(text: TextSpan(
                                        children: [
                                          TextSpan(text: 'Lead Generation: ', style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xff333333), // Make sure to set color when using TextSpan
                                          ),),
                                          TextSpan(
                                            text:
                                            'Identify and research potential clients and market opportunities to generate new business leads.',
                                            style: TextStyle(
                                              height: 1.5,
                                              fontSize: 16,
                                              fontWeight: FontWeight.normal,
                                              color: Color(0xff333333), // Make sure to set color when using TextSpan
                                            ),
                                          ),
                                        ]
                                    )),
                                  )
                                ],
                              ),
                              SizedBox(height: 15,),


                            ],
                          ),
                        ),*/
                                      jobDescription.toString().trim().isEmpty
                                          ? Text("No description available")
                                          : Html(
                                              data: jobDescription
                                                      ?.toString()
                                                      .trim() ??
                                                  'No description available',
                                              style: {
                                                "body": Style(
                                                  fontSize: FontSize(11 *
                                                      MediaQuery.of(context)
                                                          .textScaleFactor),
                                                  textAlign: TextAlign.left,
                                                  color: Color(0xff333333),
                                                ),
                                                "p": Style(
                                                  fontSize: FontSize(14.0 *
                                                      MediaQuery.of(context)
                                                          .textScaleFactor),
                                                  textAlign: TextAlign.left,
                                                  color: Color(0xff333333),
                                                ),
                                              },
                                            ),

                                      SizedBox(
                                        height: 20,
                                      ),
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        height: 1,
                                        color: Color(0xffE6E6E6),
                                      ),

                                      SizedBox(
                                        height: 20,
                                      ),
                                      Text(
                                        'Qualifications: ',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xff333333),
                                            fontSize: 18,
                                            fontFamily: 'Lato'),
                                      ),
                                      SizedBox(
                                        height: 20,
                                      ),
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 10.5),
                                                  child: Icon(
                                                    Icons.brightness_1,
                                                    size: 8 *
                                                        MediaQuery.of(context)
                                                            .textScaleFactor,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                                SizedBox(width: 8),
                                                Expanded(
                                                  child: RichText(
                                                      text: TextSpan(children: [
                                                    TextSpan(
                                                      text: 'Experience: ',
                                                      style: TextStyle(
                                                        fontSize: 14 *
                                                            MediaQuery.of(
                                                                    context)
                                                                .textScaleFactor,
                                                        fontFamily: 'lato',
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color:
                                                            Color(0xff333333),
                                                      ),
                                                    ),
                                                    TextSpan(
                                                      text:
                                                          getFormattedExperience(
                                                              rawJobData['data']
                                                                  [
                                                                  'experience']),
                                                      style: TextStyle(
                                                        height: 1.5,
                                                        fontSize: 14 *
                                                            MediaQuery.of(
                                                                    context)
                                                                .textScaleFactor,
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        color:
                                                            Color(0xff333333),
                                                      ),
                                                    ),
                                                  ])),
                                                )
                                              ],
                                            ),
                                            SizedBox(
                                              height: 15,
                                            ),
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 10.5),
                                                  child: Icon(
                                                    Icons.brightness_1,
                                                    size: 8 *
                                                        MediaQuery.of(context)
                                                            .textScaleFactor,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                                SizedBox(width: 8),
                                                Expanded(
                                                  child: RichText(
                                                      text: TextSpan(children: [
                                                    TextSpan(
                                                      text: 'Education: ',
                                                      style: TextStyle(
                                                        fontSize: 14 *
                                                            MediaQuery.of(
                                                                    context)
                                                                .textScaleFactor,
                                                        fontFamily: 'lato',
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color:
                                                            Color(0xff333333),
                                                      ),
                                                    ),
                                                    TextSpan(
                                                      text: eligibilityList
                                                                  .length >
                                                              0
                                                          ? eligibilityList[0]
                                                              ['dataName']
                                                          : ' No preference ',
                                                      style: TextStyle(
                                                        height: 1.5,
                                                        fontSize: 14 *
                                                            MediaQuery.of(
                                                                    context)
                                                                .textScaleFactor,
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        color:
                                                            Color(0xff333333),
                                                      ),
                                                    ),
                                                  ])),
                                                )
                                              ],
                                            ),
                                            SizedBox(
                                              height: 15,
                                            ),
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 10.5),
                                                  child: Icon(
                                                    Icons.brightness_1,
                                                    size: 8 *
                                                        MediaQuery.of(context)
                                                            .textScaleFactor,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                                SizedBox(width: 8),
                                                Expanded(
                                                  child: RichText(
                                                    text: TextSpan(
                                                      children: [
                                                        TextSpan(
                                                          text: 'Technology: ',
                                                          style: TextStyle(
                                                            fontSize: 14 *
                                                                MediaQuery.of(
                                                                        context)
                                                                    .textScaleFactor,
                                                            fontFamily: 'lato',
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Color(
                                                                0xff333333),
                                                          ),
                                                        ),
                                                        TextSpan(
                                                          text: technologyList
                                                                  .isNotEmpty
                                                              ? technologyList
                                                                  .map((tech) =>
                                                                      tech[
                                                                          'technologyName'] ??
                                                                      'Unknown')
                                                                  .join(', ')
                                                              : 'No preference',
                                                          style: TextStyle(
                                                            height: 1.5,
                                                            fontSize: 14 *
                                                                MediaQuery.of(
                                                                        context)
                                                                    .textScaleFactor,
                                                            fontFamily: 'lato',
                                                            fontWeight:
                                                                FontWeight
                                                                    .normal,
                                                            color: Color(
                                                                0xff333333),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        height: 20,
                                      ),
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        height: 1,
                                        color: Color(0xffE6E6E6),
                                      ),
                                      SizedBox(
                                        height: 20,
                                      ),
                                      Text(
                                        'Salary: ',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xff333333),
                                            fontSize: 18,
                                            fontFamily: 'Lato'),
                                      ),
                                      SizedBox(
                                        height: 20,
                                      ),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 10.0),
                                          ),
                                          SizedBox(width: 10),
                                          Expanded(
                                            child: RichText(
                                                text: TextSpan(children: [
                                              TextSpan(
                                                text: 'Est. ',
                                                style: TextStyle(
                                                  fontSize: 14 *
                                                      MediaQuery.of(context)
                                                          .textScaleFactor,
                                                  fontFamily: 'lato',
                                                  fontWeight: FontWeight.w400,
                                                  color: Color(0xff333333),
                                                ),
                                              ),
                                              TextSpan(
                                                text:
                                                    ' ${rawJobData['data']['currency']} ${_formatSalary(salary)}',
                                                style: TextStyle(
                                                  height: 1.5,
                                                  fontSize: 14 *
                                                      MediaQuery.of(context)
                                                          .textScaleFactor,
                                                  fontWeight: FontWeight.w400,
                                                  fontFamily: 'lato',
                                                  color: Color(0xff333333),
                                                ),
                                              ),
                                            ])),
                                          )
                                        ],
                                      ),

                                      SizedBox(
                                        height: 20,
                                      ),
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        height: 1,
                                        color: Color(0xffE6E6E6),
                                      ),
                                      SizedBox(
                                        height: 20,
                                      ),
                                      Text(
                                        'Valid till: ',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xff333333),
                                            fontSize: 18,
                                            fontFamily: 'Lato'),
                                      ),
                                      SizedBox(height: 20),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 8.0),
                                            // child: Icon(
                                            //   Icons.calendar_month,
                                            //   size: 12,
                                            //   color: Colors.black,
                                            // ),
                                          ),
                                          SizedBox(width: 8),
                                          Expanded(
                                            child: RichText(
                                              text: TextSpan(
                                                children: [
                                                  TextSpan(
                                                    text: checkExpiry(dueDate ??
                                                            '1990-01-01')
                                                        ? 'Expired'
                                                        : _formatDate(dueDate ??
                                                            '1990-01-01'),
                                                    style: TextStyle(
                                                      height: 1.5,
                                                      fontSize: 14 *
                                                          MediaQuery.of(context)
                                                              .textScaleFactor,
                                                      fontFamily: 'Lato',
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color: Color(0xff333333),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          )
                                        ],
                                      ),

                                      SizedBox(height: 85),
                                      // Container(
                                      //   width: MediaQuery.of(context).size.width,
                                      //   height: 1,
                                      //   color: Color(0xffE6E6E6),
                                      // ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : Expanded(
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SvgPicture.asset('assets/icon/noInternet.svg',
                                    height: MediaQuery.of(context).size.height *
                                        0.22),
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
                                    getJobData();
                                  },
                                  child: Container(
                                    width:
                                        MediaQuery.of(context).size.width - 50,
                                    height: 44,
                                    margin: EdgeInsets.symmetric(horizontal: 0),
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 10),
                                    decoration: BoxDecoration(
                                        color: AppColors.primaryColor,
                                        borderRadius:
                                            BorderRadius.circular(10)),
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
                          ),
                        ),
            ],
          ),
          isConnectionAvailable
              ? Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: SafeArea(
                    bottom: true,
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 25),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.95),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Apply Button
                          InkWell(
                            onTap: () {
                              if (!checkExpiry(dueDate) &&
                                  isConnectionAvailable) {
                                Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder: (context, animation,
                                            secondaryAnimation) =>
                                        JobApply(jobData: widget.jobData),
                                    transitionDuration: Duration.zero,
                                    reverseTransitionDuration: Duration.zero,
                                  ),
                                );
                              }
                            },
                            child: Container(
                              width:
                                  (MediaQuery.of(context).size.width / 2) - 20,
                              height: 44,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                color: checkExpiry(widget.jobData['dueDate'] ??
                                        '01-01-1990')
                                    ? Colors.redAccent
                                    : AppColors.primaryColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Center(
                                child: Text(
                                  'Apply',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ),

                          // Refer Button
                          InkWell(
                            onTap: () {
                              if (isReferLoading) return;
                              checkExpiry(dueDate)
                                  ? IconSnackBar.show(
                                      context,
                                      label: 'Cannot share an expired job !!!',
                                      snackBarType: SnackBarType.alert,
                                      backgroundColor: Color(0xff2D2D2D),
                                      iconColor: Colors.white,
                                    )
                                  : getRefCode(jobId);
                            },
                            child: Container(
                              width:
                                  (MediaQuery.of(context).size.width / 2) - 20,
                              height: 44,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                border:
                                    Border.all(color: AppColors.primaryColor),
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: isReferLoading
                                    ? SizedBox(
                                        height: 24,
                                        width: 24,
                                        child: TweenAnimationBuilder<double>(
                                          tween:
                                              Tween<double>(begin: 0, end: 5),
                                          duration: Duration(seconds: 2),
                                          curve: Curves.linear,
                                          builder: (context, value, child) {
                                            return Transform.rotate(
                                              angle: value * 2 * 3.1416,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 4,
                                                value: 0.20,
                                                backgroundColor:
                                                    const Color(0x8ECAD9E8),
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                            Color>(
                                                        AppColors.primaryColor),
                                              ),
                                            );
                                          },
                                          onEnd: () => {},
                                        ),
                                      )
                                    : Text(
                                        'Refer',
                                        style: TextStyle(
                                            color: AppColors.primaryColor),
                                      ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : Container()
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
    print(widget.jobData);

    ReferralData? _referralData = await getReferralProfileData();
    UserData? _retrievedUserData = await getUserData();
    setState(() {
      referralData = _referralData;
      retrievedUserData = _retrievedUserData;
      isSaved = widget.isFromSaved || (widget.jobData['isFavorite'] == "1");
      getJobData();
    });
  }
}

String _formatDate(String dateStr) {
  try {
    DateTime date = DateTime.parse(dateStr);
    return DateFormat('dd-MMM-yyyy').format(date);
  } catch (e) {
    return dateStr;
  }
}
