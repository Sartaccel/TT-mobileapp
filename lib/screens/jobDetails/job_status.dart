import 'dart:convert';
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
import 'package:http/http.dart' as http;

class JobStatus extends StatefulWidget {
  final jobData;
  final bool isFromSaved;
  const JobStatus(
      {super.key, required this.jobData, required this.isFromSaved});

  @override
  State<JobStatus> createState() => _JobStatusState();
}

class _JobStatusState extends State<JobStatus> {
  UserData? retrievedUserData;
  ReferralData? referralData;
  bool isLoading = false;
  bool isReferLoading = false;

  List<dynamic> statusList = [];
  bool isConnectionAvailable = true;

  var rawJobData = null;

  String status = '';
  int currentStepIndex = -1;

  String latestStatusName = '';

  void _shareApp(String refCode) {
    //final String appUrl = "https://play.google.com/store/apps/details?id=com.android.referral.talentturbo";
    final String appUrl =
        "https://play.google.com/store/apps/details?id=com.android.referral.talentturbo&referrer=$refCode";
    Share.share(
      "💼 ${rawJobData['data']['jobTitle'] ?? 'N/A'} position available at ${widget.jobData['companyName'] ?? 'N/A'}! \n\nDon’t miss this chance—apply today: Download now at $appUrl. \n\nUse my referral code $refCode while signing up. \n\n#GetHired #Jobs #TalentTurbo",
      subject: 'Try this awesome app!',
    );
  }

  // Added status mapping
  final Map<String, String> statusMapping = {
    "Talent Identified": "Applied",
    "Shortlisted": "Shortlist",
    "Interview Completed": "Interview",
    "Offer Given": "Selected"
  };

  // Added timeline steps
  final List<Map<String, String>> timelineSteps = [
    {'statusName': 'Applied', 'createdAt': '', 'displayName': 'Applied'},
    {'statusName': 'Shortlist', 'createdAt': '', 'displayName': 'Shortlist'},
    {'statusName': 'Interview', 'createdAt': '', 'displayName': 'Interview'},
    {'statusName': 'Selected', 'createdAt': '', 'displayName': 'Selected'},
  ];

  String getFilteredStatus(dynamic statusName) {
    final status = statusName?.toString().trim();
    switch (status) {
      case 'Talent Identified':
        return 'Applied';
      case 'Interview Scheduled':
        return 'Shortlist';
      case 'Interview Completed':
        return 'Interview';
      case 'Candidate Hired':
        return 'Selected';
      case 'Talent Rejected':
        return 'Not selected';
      default:
        return 'Applied';
    }
  }

  Color getStatusBackgroundColor(dynamic statusName) {
    final status = getFilteredStatus(statusName);
    switch (status) {
      case 'Selected':
        return Color(0xFFE0FBE1);
      case 'Not selected':
        return Color(0xFFEEEEEE);
      default:
        return Color(0xFFE0EDFB);
    }
  }

  Color getStatusTextColor(dynamic statusName) {
    final status = getFilteredStatus(statusName);
    switch (status) {
      case 'Selected':
        return Color(0xFF367C39);
      case 'Not selected':
        return Color(0xFF333333);
      default:
        return Color(0xFF004C99);
    }
  }

  Future<void> fetchJobStatus() async {
    final url =
        Uri.parse(AppConstants.BASE_URL + AppConstants.APPLIED_JOBS_STATUS);

    final bodyParams = {
      "candidateId": retrievedUserData!.profileId.toString(),
      "jobId": widget.jobData['jobId'],
      "skills": widget.jobData['skills']
    };

    if (kDebugMode) {
      print(jsonEncode(bodyParams));
    }

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
        var resOBJ = jsonDecode(response.body);
        if (resOBJ['message'].toLowerCase().contains('success') &&
            resOBJ['jobStatus'] != null) {
          List<dynamic> tmpList = resOBJ['jobStatus'];
          int updatedCurrentStepIndex = -1;
          String updatedStatusName = '';

          for (var status in tmpList) {
            if (statusMapping.containsKey(status['statusName'])) {
              String mappedStatus = statusMapping[status['statusName']]!;
              int stepIndex = timelineSteps.indexWhere(
                (step) => step['statusName'] == mappedStatus,
              );

              if (stepIndex != -1) {
                timelineSteps[stepIndex]['createdAt'] =
                    status['createdAt'] ?? "";
                if (stepIndex > updatedCurrentStepIndex) {
                  updatedCurrentStepIndex = stepIndex;
                  updatedStatusName = status['statusName']; // ✅ Capture latest
                }
              }
            }
          }

          if (kDebugMode) {
            print(
                "🟡 API Status: ${tmpList.map((s) => s['statusName']).toList()}");
            print("🟣 Mapped Steps: $timelineSteps");
            print("🔴 Current Step Index: $updatedCurrentStepIndex");
            print("🟢 Timeline After API: $timelineSteps");
          }

          setState(() {
            statusList = tmpList;
            currentStepIndex = updatedCurrentStepIndex;
            latestStatusName = updatedStatusName; // ✅ Update new status
          });
        } else {
          print("⚠️ No status tracking available for this job.");
        }
      }
    } catch (e) {
      if (kDebugMode) print(e.toString());
    } finally {
      bool hasConnection = !(await Connectivity().checkConnectivity())
          .contains(ConnectivityResult.none);

      setState(() {
        isLoading = false;
        isConnectionAvailable = hasConnection;
      });
    }
  }

  bool checkExpiry(String dateString) {
    DateTime providedDate = DateFormat("yyyy-MM-dd").parse(dateString);
    DateTime currentDate = DateTime.now();
    currentDate =
        DateTime(currentDate.year, currentDate.month, currentDate.day);

    providedDate =
        DateTime(providedDate.year, providedDate.month, providedDate.day);

    return providedDate.isBefore(currentDate);
  }

  Future<void> getRefCode(int? jobId) async {
    if (jobId == null) {
      IconSnackBar.show(
        context,
        label: 'Invalid job ID!',
        snackBarType: SnackBarType.alert,
        backgroundColor: Color(0xFF2D2D2D),
        iconColor: Colors.white,
      );
      return;
    }

    if (retrievedUserData == null || retrievedUserData!.token == null) {
      IconSnackBar.show(
        context,
        label: 'User not authenticated!',
        snackBarType: SnackBarType.alert,
        backgroundColor: Color(0xffBA1A1A),
        iconColor: Colors.white,
      );
      return;
    }

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
          'Authorization': retrievedUserData!.token!,
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
    } catch (e, stack) {
      if (kDebugMode) {
        print('Error occurred in getRefCode: $e');
        print(stack);
      }
      IconSnackBar.show(
        context,
        label: 'Something went wrong.',
        snackBarType: SnackBarType.alert,
        backgroundColor: Color(0xFF2D2D2D),
        iconColor: Colors.white,
      );
    } finally {
      setState(() {
        isReferLoading = false;
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

    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: Color(0xFF2D2D2D),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.bookmark_rounded, color: Color(0xff004C99), size: 24),
          SizedBox(width: MediaQuery.of(context).size.width * 0.01),
          const Text(
            "Job saved !",
            style: TextStyle(
                color: Colors.white, fontSize: 14, fontFamily: 'lato'),
          ),
          SizedBox(width: MediaQuery.of(context).size.width * 0.535),
          GestureDetector(
            onTap: () {
              fToast.removeCustomToast();
              _activeToastPositions.remove(position);
              if (_activeToastPositions.isEmpty) {
                _resetToastPositions();
              }
            },
            child: Icon(Icons.close, color: Colors.white, size: 22),
          ),
        ],
      ),
    );

    fToast.showToast(
      child: Transform.translate(
        offset: Offset(0, -MediaQuery.of(context).size.height * 0.03),
        child: toast,
      ),
      gravity: ToastGravity.BOTTOM,
      toastDuration: Duration(seconds: 2),
    );
  }

  void showJobRemovedToast(BuildContext context, VoidCallback onUndo) {
    fToast.init(context);
    fToast.removeQueuedCustomToasts();

    final position = _currentBottomPosition;
    _activeToastPositions.add(position);
    _currentBottomPosition += 0.05;

    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
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
                fontFamily: 'lato',
              ),
            ),
          ),
          const SizedBox(width: 8.0),
          GestureDetector(
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
                      fontFamily: 'lato',
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
    );

    fToast.showToast(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height * 0.03,
        ),
        child: toast,
      ),
      gravity: ToastGravity.BOTTOM,
      toastDuration: const Duration(seconds: 3),
    );
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
      body: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
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
                  'Application Status',
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
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                color: Color(0xffFCFCFC),
                padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 5),
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          border:
                              Border.all(width: 0, color: Color(0xffFCFCFC)),
                          color: Color(0xffFCFCFC)),
                      width: MediaQuery.of(context).size.width,
                      height: 225,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Image(
                            image: widget.jobData['logo'] != null &&
                                    widget.jobData['logo'].isNotEmpty
                                ? NetworkImage(
                                    widget.jobData['logo'],
                                  ) as ImageProvider<Object>
                                : const AssetImage(
                                    'assets/images/tt_logo_resized.png'),
                            height: 60,
                            width: 60,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return Image.asset(
                                  'assets/images/tt_logo_resized.png',
                                  height: 32,
                                  width: 32);
                            },
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width - 155,
                                  child: Text(
                                    widget.jobData['jobTitle'],
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                    style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontFamily: 'Lato',
                                        fontSize: 16,
                                        color: Color(0xff333333)),
                                  ),
                                ),
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width - 155,
                                  child: Text(
                                    widget.jobData['companyName'],
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontFamily: 'Lato',
                                        fontSize: 14,
                                        color: Color(0xff545454)),
                                  ),
                                ),
                                SizedBox(height: 10),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SvgPicture.asset(
                                      'assets/icon/bulb.svg',
                                      height: 20,
                                      width: 20,
                                      color: Colors.black,
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Flexible(
                                      child: Builder(
                                        builder: (context) {
                                          String skillStr =
                                              widget.jobData['skills'] ?? '';
                                          List<String> skills = skillStr
                                              .split(',')
                                              .map((s) => s.trim())
                                              .where((s) => s.isNotEmpty)
                                              .toList();

                                          String displaySkills;
                                          if (skills.length > 3) {
                                            displaySkills =
                                                '${skills.take(3).join(', ')} +${skills.length - 3}';
                                          } else {
                                            displaySkills = skills.join(', ');
                                          }

                                          return Text(
                                            'Skills : $displaySkills',
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                            style: TextStyle(
                                                fontWeight: FontWeight.w400,
                                                fontSize: 14,
                                                fontFamily: 'Lato',
                                                color: Color(0xff545454)),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 7),
                                Wrap(
                                  spacing: 12,
                                  runSpacing: 6,
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SvgPicture.asset(
                                          'assets/icon/circum_medical-case.svg',
                                          height: 20,
                                          width: 20,
                                          color: Colors.black,
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                          widget.jobData['workType'] ??
                                              'Fulltime',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w400,
                                              fontSize: 14,
                                              fontFamily: 'Lato',
                                              color: Color(0xff545454)),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SvgPicture.asset(
                                          'assets/icon/location-black.svg',
                                          height: 20,
                                          width: 20,
                                          color: Colors.black,
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Flexible(
                                            fit: FlexFit.loose,
                                            child: Text(
                                              widget.jobData['location'] ?? '',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 14,
                                                  fontFamily: 'Lato',
                                                  color: Color(0xff545454)),
                                            )),
                                      ],
                                    ),
                                  ],
                                ),
                                // Container(
                                //   padding: EdgeInsets.symmetric(
                                //       horizontal: 6, vertical: 2),
                                //   decoration: BoxDecoration(
                                //     color: Color(0xffE0EDFB),
                                //     borderRadius: BorderRadius.circular(3),
                                //   ),
                                //   child: Text(
                                //     (status.isEmpty) ? 'Applied' : status,
                                //     style: TextStyle(
                                //       fontWeight: FontWeight.w400,
                                //       fontSize: 14,
                                //       color: Color(0xff004C99),
                                //     ),
                                //   ),
                                // )
                                SizedBox(height: 7),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: getStatusBackgroundColor(
                                        widget.jobData['statusName']),
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                  child: Text(
                                    getFilteredStatus(
                                        widget.jobData['statusName']),
                                    style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 14,
                                      fontFamily: 'Lato',
                                      color: getStatusTextColor(
                                          widget.jobData['statusName']),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 0),
                            child: InkWell(
                              onTap: () async {
                                bool isSaved =
                                    (widget.jobData['isFavorite'] == "1");
                                int? jobId = widget.jobData['jobId'] ??
                                    widget.jobData['id'];

                                if (jobId != null) {
                                  setState(() {
                                    widget.jobData['isFavorite'] =
                                        isSaved ? "0" : "1";
                                  });

                                  bool success =
                                      await saveJob(jobId, isSaved ? 0 : 1);

                                  if (!success) {
                                    setState(() {
                                      widget.jobData['isFavorite'] =
                                          isSaved ? "1" : "0";
                                    });
                                  } else {
                                    if (widget.jobData['isFavorite'] == "1") {
                                      showJobSavedToast(context);
                                    } else {
                                      showJobRemovedToast(context, () {
                                        setState(() {
                                          widget.jobData['isFavorite'] = "1";
                                        });
                                        saveJob(jobId, 1);
                                      });
                                    }
                                  }
                                }
                              },
                              child: TweenAnimationBuilder<double>(
                                duration: Duration(milliseconds: 400),
                                tween: Tween<double>(
                                  begin: widget.jobData['isFavorite'] == "1"
                                      ? 0
                                      : 1,
                                  end: widget.jobData['isFavorite'] == "1"
                                      ? 1
                                      : 0,
                                ),
                                builder: (context, value, child) {
                                  return Stack(
                                    alignment: Alignment.topCenter,
                                    children: [
                                      Icon(
                                        Icons.bookmark_border_rounded,
                                        size: 30,
                                        color: Colors.black54,
                                      ),
                                      ClipRect(
                                        child: Align(
                                          alignment: Alignment.topCenter,
                                          heightFactor: value,
                                          child: Icon(
                                            Icons.bookmark,
                                            size: 30,
                                            color: Color(0xff004C99),
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
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: 1,
                      color: Color(0xffE6E6E6),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    isLoading
                        ? SizedBox(
                            child: Shimmer.fromColors(
                              baseColor: Color(0xffE6E6E6),
                              highlightColor: Color(0xffF2F2F2),
                              child: SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.4,
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: 1,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 8, horizontal: 15),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            width: 75,
                                            height: 25,
                                            decoration: BoxDecoration(
                                              color: Color(0xffE6E6E6),
                                              shape: BoxShape.rectangle,
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                          ),
                                          SizedBox(height: 35),
                                          Row(
                                            children: [
                                              Container(
                                                width: 15,
                                                height: 15,
                                                decoration: BoxDecoration(
                                                  color: Color(0xffE6E6E6),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                              ),
                                              SizedBox(width: 10),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    width: 65,
                                                    height: 15,
                                                    decoration: BoxDecoration(
                                                      color: Color(0xffE6E6E6),
                                                      shape: BoxShape.rectangle,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                    ),
                                                  ),
                                                  SizedBox(height: 10),
                                                  Container(
                                                    width: 75,
                                                    height: 15,
                                                    decoration: BoxDecoration(
                                                      color: Color(0xffE6E6E6),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 45),
                                          Row(
                                            children: [
                                              Container(
                                                width: 15,
                                                height: 15,
                                                decoration: BoxDecoration(
                                                  color: Color(0xffE6E6E6),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                              ),
                                              SizedBox(width: 10),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    width: 95,
                                                    height: 15,
                                                    decoration: BoxDecoration(
                                                      color: Color(0xffE6E6E6),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                    ),
                                                  ),
                                                  SizedBox(height: 10),
                                                  Container(
                                                    width: 75,
                                                    height: 15,
                                                    decoration: BoxDecoration(
                                                      color: Color(0xffE6E6E6),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 45),
                                          Row(
                                            children: [
                                              Container(
                                                width: 15,
                                                height: 15,
                                                decoration: BoxDecoration(
                                                  color: Color(0xffE6E6E6),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                              ),
                                              SizedBox(width: 10),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    width: 85,
                                                    height: 15,
                                                    decoration: BoxDecoration(
                                                      color: Color(0xffE6E6E6),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                    ),
                                                  ),
                                                  SizedBox(height: 10),
                                                  Container(
                                                    width: 75,
                                                    height: 15,
                                                    decoration: BoxDecoration(
                                                      color: Color(0xffE6E6E6),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 45),
                                          Row(
                                            children: [
                                              Container(
                                                width: 15,
                                                height: 15,
                                                decoration: BoxDecoration(
                                                  color: Color(0xffE6E6E6),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                              ),
                                              SizedBox(width: 10),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    width: 70,
                                                    height: 15,
                                                    decoration: BoxDecoration(
                                                      color: Color(0xffE6E6E6),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                    ),
                                                  ),
                                                  SizedBox(height: 10),
                                                  Container(
                                                    width: 75,
                                                    height: 15,
                                                    decoration: BoxDecoration(
                                                      color: Color(0xffE6E6E6),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          )
                        : Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              spacing: 5,
                              children: [
                                Container(
                                  margin: EdgeInsets.symmetric(horizontal: 5),
                                  child: Text(
                                    'Status',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontFamily: 'Lato',
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xff333333),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 20),
                                Column(
                                  children: List.generate(timelineSteps.length,
                                      (index) {
                                    bool isCompleted = index < currentStepIndex;
                                    bool isCurrent = index == currentStepIndex;
                                    bool isLast =
                                        index == timelineSteps.length - 1;

                                    bool isSelected = timelineSteps[index]
                                                ['statusName']
                                            ?.toLowerCase() ==
                                        'selected';

                                    return Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Circle and line
                                        Column(
                                          children: [
                                            Container(
                                              width: 17,
                                              height: 17,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: isCompleted
                                                    ? Color(0xFF004C99)
                                                    : isCurrent && isSelected
                                                        ? Color(0xFF4CAF50)
                                                        : Colors.transparent,
                                                border: Border.all(
                                                  color: isCurrent
                                                      ? isSelected
                                                          ? Color(0xFF4CAF50)
                                                          : Color(0xFFBA1A1A)
                                                      : Color(0xffD9D9D9),
                                                  width: 3,
                                                ),
                                              ),
                                            ),
                                            if (!isLast)
                                              Container(
                                                width: 3,
                                                height: 70,
                                                color: isCompleted
                                                    ? Color(0xFF004C99)
                                                    : isCurrent
                                                        ? isSelected
                                                            ? Color(0xFF4CAF50)
                                                            : Color(0xFFBA1A1A)
                                                        : Color(0xffD9D9D9),
                                              ),
                                          ],
                                        ),
                                        SizedBox(width: 15),
                                        // Status Text
                                        Transform.translate(
                                          offset: Offset(
                                              0,
                                              -MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.01),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                (timelineSteps[index][
                                                                'statusName'] ==
                                                            'Selected' &&
                                                        (timelineSteps[index][
                                                                    'createdAt'] ??
                                                                '')
                                                            .isEmpty)
                                                    ? 'Not yet selected'
                                                    : (timelineSteps[index]
                                                            ['displayName'] ??
                                                        timelineSteps[index]
                                                            ['statusName'] ??
                                                        ''),
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight:
                                                      isCompleted || isCurrent
                                                          ? FontWeight.bold
                                                          : FontWeight.normal,
                                                  color: isCurrent
                                                      ? Color(0xFF333333)
                                                      : isCompleted
                                                          ? Color(0xFF333333)
                                                          : Color(0xff7D7C7C),
                                                ),
                                              ),
                                              if (timelineSteps[index]
                                                          ['createdAt'] !=
                                                      null &&
                                                  timelineSteps[index]
                                                          ['createdAt']!
                                                      .isNotEmpty)
                                                Text(
                                                  timelineSteps[index]
                                                      ['createdAt']!,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Color(0xff7D7C7C),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    );
                                  }),
                                ),
                              ],
                            ),
                          ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: 25, left: 15, right: 15),
            child: InkWell(
              onTap: () {
                if (isReferLoading) return;
                checkExpiry(widget.jobData['dueDate'] ?? '1990-01-01')
                    ? IconSnackBar.show(
                        context,
                        label: 'Cannot share an expired job !!!',
                        snackBarType: SnackBarType.alert,
                        backgroundColor: Color(0xff2D2D2D),
                        iconColor: Colors.white,
                      )
                    : getRefCode(widget.isFromSaved
                        ? widget.jobData['jobId']
                        : widget.jobData['id']);
              },
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: 44,
                padding: EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.primaryColor),
                  color: Color(0xFFFCFCFC),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: isReferLoading
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
                                  backgroundColor: const Color(0x8ECAD9E8),
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      AppColors.primaryColor),
                                ),
                              );
                            },
                          ),
                        )
                      : Text(
                          'Refer',
                          style: TextStyle(color: AppColors.primaryColor),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    fetchUserDataFromPref();
  }

  Future<void> fetchUserDataFromPref() async {
    UserData? _retrievedUserData = await getUserData();
    ReferralData? _referralData = await getReferralProfileData();

    setState(() {
      retrievedUserData = _retrievedUserData;
      referralData = _referralData;
    });

    await fetchJobStatus();

    // Only fallback if no steps updated
    if (currentStepIndex == -1 &&
        widget.jobData['statusName'] != null &&
        widget.jobData['statusName'].toString().isNotEmpty) {
      String rawStatus = widget.jobData['statusName'];
      String? mappedStatus = statusMapping[rawStatus];

      if (mappedStatus != null) {
        int stepIndex = timelineSteps.indexWhere(
          (step) => step['statusName'] == mappedStatus,
        );

        if (stepIndex != -1) {
          setState(() {
            currentStepIndex = stepIndex;
          });
        }
      }
    }
  }
}
