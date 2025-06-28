import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shimmer/shimmer.dart';
import 'package:talent_turbo_new/AppColors.dart';
import 'package:talent_turbo_new/AppConstants.dart';
import 'package:talent_turbo_new/Utils.dart';
import 'package:talent_turbo_new/models/candidate_profile_model.dart';
import 'package:talent_turbo_new/models/referral_profile_model.dart';
import 'package:talent_turbo_new/models/user_data_model.dart';
import 'package:http/http.dart' as http;
import 'package:talent_turbo_new/screens/main/home_container.dart';
import '../../jobDetails/job_status.dart';

class AppliedJobsFragment extends StatefulWidget {
  const AppliedJobsFragment({super.key});

  @override
  State<AppliedJobsFragment> createState() => _AppliedJobsFragmentState();
}

class _AppliedJobsFragmentState extends State<AppliedJobsFragment> {
  bool isLoading = false;
  ReferralData? referralData;
  CandidateProfileModel? candidateProfileModel;

  UserData? retrievedUserData;

  List<dynamic> jobList = [];
  bool isConnectionAvailable = true;

  Future<void> getAppliedJobsList() async {
    final url =
        Uri.parse(AppConstants.BASE_URL + AppConstants.APPLIED_JOBS_LIST);
    final bodyParams = {
      "jobTitle": '',
      "candidateId": candidateProfileModel!.id.toString(),
      "companyName": ''
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
        var resOBJ = jsonDecode(response.body);

        setState(() {
          jobList = resOBJ['jobList'];
        });

        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print(e.toString());
    } finally {
      setState(() {
        isLoading = false;
      });
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

  Future<bool> saveJob(int? jobId, int status) async {
    if (jobId == null) {
      if (kDebugMode) print('Job ID is null');
      return false;
    }

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

      return response.statusCode == 200 || response.statusCode == 202;
    } catch (e) {
      if (kDebugMode) print("Error: $e");
      return false;
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
              child: Icon(Icons.close, color: Colors.white, size: 22),
            ),
          ],
        ),
      ),
    );

    fToast.showToast(
      child: Transform.translate(
        offset: Offset(0, -MediaQuery.of(context).size.height * 0.045),
        child: toast,
      ),
      gravity: ToastGravity.BOTTOM,
      toastDuration: const Duration(seconds: 1),
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
      child: Transform.translate(
        offset: Offset(0, -MediaQuery.of(context).size.height * 0.045),
        child: toast,
      ),
      gravity: ToastGravity.BOTTOM,
      toastDuration: const Duration(seconds: 3),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Color(0xff001B3E),
      statusBarIconBrightness: Brightness.light,
    ));
    return isLoading
        ? Shimmer.fromColors(
            baseColor: Color(0xffE6E6E6),
            highlightColor: Color(0xffF2F2F2),
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: 6,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 1,
                              color: Color(0xffE6E6E6),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width * 0.11,
                            height: MediaQuery.of(context).size.width * 0.11,
                            decoration: BoxDecoration(
                              color: Color(0xffE6E6E6),
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width * 0.62,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: Color(0xffE6E6E6),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              SizedBox(height: 10),
                              Container(
                                width: MediaQuery.of(context).size.width * 0.45,
                                height: 15,
                                decoration: BoxDecoration(
                                  color: Color(0xffE6E6E6),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              SizedBox(height: 10),
                              Container(
                                width: MediaQuery.of(context).size.width * 0.70,
                                height: 15,
                                decoration: BoxDecoration(
                                  color: Color(0xffE6E6E6),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              SizedBox(height: 10),
                              Row(
                                children: [
                                  Container(
                                    width: MediaQuery.of(context).size.width *
                                        0.33,
                                    height: 15,
                                    decoration: BoxDecoration(
                                      color: Color(0xffE6E6E6),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Container(
                                    width: MediaQuery.of(context).size.width *
                                        0.33,
                                    height: 15,
                                    decoration: BoxDecoration(
                                      color: Color(0xffE6E6E6),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                              Container(
                                width: MediaQuery.of(context).size.width * 0.27,
                                height: 15,
                                decoration: BoxDecoration(
                                  color: Color(0xffE6E6E6),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ],
                          ),
                          Spacer(),
                          Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: Color(0xffE6E6E6),
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          )
        : jobList.isNotEmpty
            ? RefreshIndicator(
                onRefresh: getAppliedJobsList,
                child: ListView.builder(
                  padding: const EdgeInsets.only(bottom: 95),
                  itemCount: jobList.length,
                  itemBuilder: (context, index) {
                    final screenWidth = MediaQuery.of(context).size.width;
                    final isSmallScreen = screenWidth < 400;
                    final isMediumScreen =
                        screenWidth >= 400 && screenWidth < 600;

                    return InkWell(
                      onTap: () {
                        if (kDebugMode) print('Job data: ${jobList[index]}');
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    JobStatus(
                              jobData: jobList[index],
                              isFromSaved: false,
                            ),
                            transitionDuration: Duration.zero,
                            reverseTransitionDuration: Duration.zero,
                          ),
                        );
                      },
                      child: Container(
                        margin: EdgeInsets.symmetric(
                            vertical: isSmallScreen ? 4 : 5),
                        padding: EdgeInsets.all(isSmallScreen ? 12 : 15),
                        decoration: BoxDecoration(
                          border:
                              Border.all(width: 0.5, color: Color(0xffE6E6E6)),
                          color: Color(0xffFCFCFC),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        constraints: BoxConstraints(
                            minHeight: isSmallScreen ? 150 : 170),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Company Logo and Details
                            Expanded(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: isSmallScreen ? 36 : 38,
                                    height: isSmallScreen ? 36 : 38,
                                    child: Image(
                                      image: jobList[index]['logo'] != null &&
                                              jobList[index]['logo'].isNotEmpty
                                          ? NetworkImage(jobList[index]['logo'])
                                              as ImageProvider<Object>
                                          : const AssetImage(
                                              'assets/images/tt_logo_resized.png'),
                                      fit: BoxFit.contain,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Image.asset(
                                          'assets/images/tt_logo_resized.png',
                                          height: isSmallScreen ? 30 : 32,
                                          width: isSmallScreen ? 30 : 32,
                                        );
                                      },
                                    ),
                                  ),
                                  SizedBox(width: isSmallScreen ? 10 : 15),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        // Job Title
                                        Text(
                                          jobList[index]['jobTitle'] ??
                                              'Unknown',
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontFamily: 'Lato',
                                            fontSize: isSmallScreen ? 14 : 16,
                                            color: Color(0xff333333),
                                          ),
                                        ),

                                        // Company Name
                                        SizedBox(height: isSmallScreen ? 2 : 4),
                                        Text(
                                          jobList[index]['companyName'] ??
                                              'Unknown',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w400,
                                            fontFamily: 'Lato',
                                            fontSize: isSmallScreen ? 12 : 13,
                                            color: Color(0xff545454),
                                          ),
                                        ),

                                        // Skills
                                        SizedBox(height: isSmallScreen ? 2 : 4),
                                        Row(
                                          children: [
                                            SvgPicture.asset(
                                              'assets/icon/bulb.svg',
                                              height: isSmallScreen ? 18 : 20,
                                              width: isSmallScreen ? 18 : 20,
                                            ),
                                            SizedBox(width: 5),
                                            Flexible(
                                              child: Builder(
                                                builder: (context) {
                                                  String skillStr =
                                                      jobList[index]
                                                              ['skills'] ??
                                                          '';
                                                  List<String> skills = skillStr
                                                      .split(',')
                                                      .map((s) => s.trim())
                                                      .where(
                                                          (s) => s.isNotEmpty)
                                                      .toList();

                                                  String displaySkills;
                                                  if (skills.length > 3) {
                                                    displaySkills =
                                                        '${skills.take(3).join(', ')} +${skills.length - 3}';
                                                  } else {
                                                    displaySkills =
                                                        skills.join(', ');
                                                  }

                                                  return Text(
                                                    'Skills: $displaySkills',
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontSize: isSmallScreen
                                                          ? 12
                                                          : 14,
                                                      color: Color(0xff545454),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          ],
                                        ),

                                        SizedBox(height: isSmallScreen ? 2 : 4),
                                        Wrap(
                                          spacing: isSmallScreen ? 8 : 12,
                                          runSpacing: isSmallScreen ? 4 : 6,
                                          children: [
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                SvgPicture.asset(
                                                  'assets/icon/circum_medical-case.svg',
                                                  height:
                                                      isSmallScreen ? 18 : 20,
                                                  width:
                                                      isSmallScreen ? 18 : 20,
                                                ),
                                                SizedBox(width: 4),
                                                Text(
                                                  jobList[index]['workType'] ??
                                                      'Fulltime',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w400,
                                                    fontSize:
                                                        isSmallScreen ? 12 : 14,
                                                    color: Color(0xff545454),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                SvgPicture.asset(
                                                  'assets/icon/location-black.svg',
                                                  height:
                                                      isSmallScreen ? 18 : 20,
                                                  width:
                                                      isSmallScreen ? 18 : 20,
                                                ),
                                                SizedBox(width: 4),
                                                Container(
                                                  width:
                                                      isSmallScreen ? 120 : 150,
                                                  child: Text(
                                                    jobList[index]
                                                            ['location'] ??
                                                        'Not disclosed',
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontSize: isSmallScreen
                                                          ? 12
                                                          : 14,
                                                      color: Color(0xff545454),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),

                                        // Application Status
                                        SizedBox(height: isSmallScreen ? 2 : 4),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: getStatusBackgroundColor(
                                                jobList[index]['statusName']),
                                            borderRadius:
                                                BorderRadius.circular(3),
                                          ),
                                          child: Text(
                                            getFilteredStatus(
                                                jobList[index]['statusName']),
                                            style: TextStyle(
                                              fontWeight: FontWeight.w400,
                                              fontSize: isSmallScreen ? 12 : 14,
                                              color: getStatusTextColor(
                                                  jobList[index]['statusName']),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(
                                        left: isSmallScreen ? 4 : 8),
                                    child: InkWell(
                                      onTap: () async {
                                        bool isSaved = (jobList[index]
                                                ['isFavorite'] ==
                                            "1");
                                        int? jobId = jobList[index]['jobId'] ??
                                            jobList[index]['id'];

                                        if (jobId == null) {
                                          if (kDebugMode)
                                            print(
                                                'Job ID is null, cannot save');
                                          return;
                                        }

                                        setState(() {
                                          jobList[index]['isFavorite'] =
                                              isSaved ? "0" : "1";
                                        });

                                        bool success = await saveJob(
                                            jobId, isSaved ? 0 : 1);

                                        if (!success) {
                                          setState(() {
                                            jobList[index]['isFavorite'] =
                                                isSaved ? "1" : "0";
                                          });
                                        } else {
                                          if (jobList[index]['isFavorite'] ==
                                              "1") {
                                            showJobSavedToast(context);
                                          } else {
                                            showJobRemovedToast(context, () {
                                              setState(() {
                                                jobList[index]['isFavorite'] =
                                                    "1";
                                              });
                                              saveJob(jobId!, 1);
                                            });
                                          }
                                        }
                                      },
                                      child: TweenAnimationBuilder<double>(
                                        duration: Duration(milliseconds: 400),
                                        tween: Tween<double>(
                                          begin: jobList[index]['isFavorite'] ==
                                                  "1"
                                              ? 0
                                              : 1,
                                          end: jobList[index]['isFavorite'] ==
                                                  "1"
                                              ? 1
                                              : 0,
                                        ),
                                        builder: (context, value, child) {
                                          return Stack(
                                            alignment: Alignment.topCenter,
                                            children: [
                                              Icon(
                                                Icons.bookmark_border_rounded,
                                                size: isSmallScreen ? 22 : 25,
                                                color: Colors.black54,
                                              ),
                                              ClipRect(
                                                child: Align(
                                                  alignment:
                                                      Alignment.topCenter,
                                                  heightFactor: value,
                                                  child: Icon(
                                                    Icons.bookmark,
                                                    size:
                                                        isSmallScreen ? 22 : 25,
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
                            SizedBox(width: isSmallScreen ? 4 : 8),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              )
            : isConnectionAvailable
                ? Center(
                    child: Transform.translate(
                      offset: Offset(0, -60),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SvgPicture.asset('assets/icon/appliedjob.svg'),
                          SizedBox(height: 25),
                          Text(
                            'No Jobs Applied yet',
                            style: TextStyle(
                                fontFamily: 'Lato',
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Color(0xff333333)),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'You haven\'t applied to any jobs yet.\nStart exploring and apply to opportunities to \ntrack their status here.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontFamily: 'Lato',
                                fontWeight: FontWeight.w400,
                                fontSize: 14,
                                color: Color(0xff545454)),
                          ),
                          SizedBox(height: 20),
                          InkWell(
                            onTap: () => Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder:
                                    (context, animation, secondaryAnimation) =>
                                        HomeContainer(),
                                transitionDuration: Duration.zero,
                                reverseTransitionDuration: Duration.zero,
                              ),
                            ),
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
                                  'Explore jobs',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : Center(
                    child: Transform.translate(
                      offset: Offset(0, -60),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SvgPicture.asset('assets/icon/noInternet.svg',
                              height:
                                  MediaQuery.of(context).size.height * 0.22),
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
                              getAppliedJobsList();
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
                  );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchProfileFromPref();
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
    getAppliedJobsList();
  }
}
