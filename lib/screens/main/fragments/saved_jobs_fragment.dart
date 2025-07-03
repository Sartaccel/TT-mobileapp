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
import 'package:intl/intl.dart';
import 'package:talent_turbo_new/screens/jobDetails/JobDetails.dart';
import 'package:talent_turbo_new/screens/main/home_container.dart';

class SavedJobsFragment extends StatefulWidget {
  const SavedJobsFragment({super.key});

  @override
  State<SavedJobsFragment> createState() => _SavedJobsFragmentState();
}

class _SavedJobsFragmentState extends State<SavedJobsFragment> {
  bool isLoading = false;
  ReferralData? referralData;
  CandidateProfileModel? candidateProfileModel;

  UserData? retrievedUserData;

  List<dynamic> jobList = [];
  bool isConnectionAvailable = true;

  Future<void> getAppliedJobsList() async {
    final url = Uri.parse(AppConstants.BASE_URL + AppConstants.GET_FAV_NEW);

    try {
      setState(() {
        isLoading = true;
      });

      final response = await http.get(
        url,
        headers: {'Authorization': retrievedUserData!.token},
      );

      if (kDebugMode) {
        print(
            'Response code ${response.statusCode} :: Response => ${response.body}');
      }

      if (response.statusCode == 200) {
        var resOBJ = jsonDecode(response.body);

        setState(() {
          jobList = resOBJ['favJobs'];
          isLoading = false;
        });

        if (kDebugMode) {
          print('jobList : ${jobList.length}');
        }
      }
    } catch (e) {
      print(e.toString());
      setState(() {
        isLoading = false;
      });
    } finally {
      var connectivityResult = await Connectivity().checkConnectivity();
      setState(() {
        isConnectionAvailable = connectivityResult != ConnectivityResult.none;
      });
    }
  }

  final FToast fToast = FToast();

  double _currentBottomPosition = 0.1;
  final List<double> _activeToastPositions = [];

  void _resetToastPositions() {
    _currentBottomPosition = 0.1;
    _activeToastPositions.clear();
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
    try {
      DateTime providedDate = DateFormat("yyyy-MM-dd").parse(dateString);
      DateTime endOfDay = DateTime(
        providedDate.year,
        providedDate.month,
        providedDate.day,
        23,
        59,
        59,
      );
      return DateTime.now().isAfter(endOfDay);
    } catch (e) {
      return true;
    }
  }

  Future<void> removeJob(int jobId) async {
    if (retrievedUserData == null) {
      if (kDebugMode) print("Error: User data is null.");
      return;
    }

    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      if (mounted) {
        // IconSnackBar.show(
        //   context,
        //   label: 'No internet connection, try again',
        //   snackBarType: SnackBarType.alert,
        //   backgroundColor: Color(0xff2D2D2D),
        //   iconColor: Colors.white,
        // );
      }
      return;
    }

    final url =
        Uri.parse(AppConstants.BASE_URL + AppConstants.SAVE_JOB_TO_FAV_NEW);
    final bodyParams = {"jobId": jobId, "isFavorite": 0};

    try {
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

      if (response.statusCode == 200 || response.statusCode == 202) {
        if (mounted) {
          // fToast.init(context);
          // Widget toast = Container(
          //   padding:
          //       const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          //   decoration: BoxDecoration(
          //     color: Colors.green,
          //     borderRadius: BorderRadius.circular(12.0),
          //   ),
          //   child: Row(
          //     mainAxisSize: MainAxisSize.min,
          //     children: [
          //       Icon(Icons.check_circle, color: Colors.white, size: 24),
          //       SizedBox(width: 12),
          //       Text(
          //         "Removed successfully",
          //         style: TextStyle(
          //           color: Colors.white,
          //           fontSize: 14,
          //           fontFamily: 'lato',
          //         ),
          //       ),
          //     ],
          //   ),
          // );

          // fToast.showToast(
          //   child: toast,
          //   gravity: ToastGravity.BOTTOM,
          //   toastDuration: Duration(seconds: 2),
          // );
        }
      } else {
        if (mounted) {
          IconSnackBar.show(
            context,
            label: 'Failed to remove. Please try again.',
            snackBarType: SnackBarType.fail,
            backgroundColor: Color(0xff2D2D2D),
            iconColor: Colors.white,
          );
        }
      }
    } catch (e) {
      if (kDebugMode) print("Error: $e");
      if (mounted) {
        // IconSnackBar.show(
        //   context,
        //   label: 'No internet connection, try again',
        //   snackBarType: SnackBarType.alert,
        //   backgroundColor: Color(0xff2D2D2D),
        //   iconColor: Colors.white,
        // );
      }
    }
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
              itemCount: 6,
              padding: EdgeInsets.zero,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child:
                                Container(height: 1, color: Color(0xffE6E6E6)),
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

                    return InkWell(
                      onTap: () async {
                        await Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation,
                                    secondaryAnimation) =>
                                Jobdetails(
                                    jobData: jobList[index], isFromSaved: true),
                            transitionDuration: Duration.zero,
                            reverseTransitionDuration: Duration.zero,
                          ),
                        );
                        getAppliedJobsList();
                      },
                      child: Container(
                        margin: EdgeInsets.symmetric(
                            vertical: isSmallScreen ? 4 : 4),
                        padding: EdgeInsets.all(isSmallScreen ? 10 : 15),
                        decoration: BoxDecoration(
                          border:
                              Border.all(width: 0.5, color: Color(0xffE6E6E6)),
                          color: Color(0xffFCFCFC),
                        ),
                        constraints: BoxConstraints(
                          minHeight: isSmallScreen ? 140 : 160,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: isSmallScreen ? 40 : 60,
                                    height: isSmallScreen ? 40 : 60,
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
                                          fit: BoxFit.contain,
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
                                        Text(
                                          jobList[index]['jobTitle'],
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontFamily: 'Lato',
                                            fontSize: isSmallScreen ? 14 : 16,
                                            color: Color(0xff333333),
                                          ),
                                        ),
                                        SizedBox(height: isSmallScreen ? 2 : 4),
                                        Text(
                                          jobList[index]['companyName'],
                                          style: TextStyle(
                                            fontWeight: FontWeight.w400,
                                            fontFamily: 'Lato',
                                            fontSize: isSmallScreen ? 12 : 13,
                                            color: Color(0xff545454),
                                          ),
                                        ),
                                        SizedBox(height: isSmallScreen ? 2 : 4),
                                        Row(
                                          children: [
                                            SvgPicture.asset(
                                              'assets/images/ic_idea.svg',
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
                                                  'assets/images/ic_suitcase.svg',
                                                  height:
                                                      isSmallScreen ? 18 : 20,
                                                  width:
                                                      isSmallScreen ? 18 : 20,
                                                ),
                                                SizedBox(width: 4),
                                                Text(
                                                  jobList[index]['workType'] ??
                                                      'N/A',
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
                                                  'assets/images/ic_location.svg',
                                                  height:
                                                      isSmallScreen ? 18 : 20,
                                                  width:
                                                      isSmallScreen ? 18 : 20,
                                                ),
                                                SizedBox(width: 4),
                                                Flexible(
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
                                        checkExpiry(jobList[index]['dueDate'] ??
                                                '1990-01-01')
                                            ? Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 2),
                                                decoration: BoxDecoration(
                                                  color:
                                                      const Color(0xffFEE4E2),
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                                child: const Text(
                                                  'Job Expired',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Color(0xffBA1A1A),
                                                    fontWeight: FontWeight.w500,
                                                    fontFamily: 'lato',
                                                  ),
                                                ),
                                              )
                                            : Text(
                                                processDate(jobList[index]
                                                        ['jobCreatedDate'] ??
                                                    '1990-01-01'),
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w400,
                                                  fontFamily: 'lato',
                                                  fontSize:
                                                      isSmallScreen ? 12 : 14,
                                                  color:
                                                      const Color(0xff545454),
                                                ),
                                              ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 0),
                              child: InkWell(
                                onTap: () {
                                  var jobData = jobList[index];
                                  int? jobId = jobData.containsKey('jobId')
                                      ? jobData['jobId']
                                      : jobData['id'];

                                  if (jobId == null) {
                                    if (kDebugMode)
                                      print("Error: jobId is null");
                                    return;
                                  }

                                  setState(() {
                                    jobList.removeAt(index);
                                  });

                                  removeJob(jobId);

                                  showJobRemovedToast(context, () {
                                    setState(() {
                                      jobList.insert(index, jobData);
                                    });
                                  });
                                },
                                child: TweenAnimationBuilder<double>(
                                  duration: Duration(milliseconds: 400),
                                  tween: Tween<double>(
                                    begin: jobList[index]['isFavorite'] == "1"
                                        ? 0
                                        : 1,
                                    end: jobList[index]['isFavorite'] == "1"
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
                                            alignment: Alignment.topCenter,
                                            heightFactor: value,
                                            child: Icon(
                                              Icons.bookmark,
                                              size: isSmallScreen ? 22 : 25,
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
                          SvgPicture.asset('assets/icon/savedjob.svg'),
                          SizedBox(height: 25),
                          Text(
                            'No saved jobs yet',
                            style: TextStyle(
                                fontFamily: 'Lato',
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Color(0xff333333)),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'It looks like you haven\'t saved any jobs! \nStart exploring and tap the save icon to keep \nyour favorites here.',
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
                              color: Color(0xff333333),
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Connect to Wi-Fi or cellular data and try again.',
                            style: TextStyle(
                              fontFamily: 'Lato',
                              fontWeight: FontWeight.w400,
                              fontSize: 14,
                              color: Color(0xff545454),
                            ),
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
                                borderRadius: BorderRadius.circular(8),
                              ),
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
    super.initState();
    fetchProfileFromPref();
  }

  Future<void> fetchProfileFromPref() async {
    CandidateProfileModel? _candidateProfileModel =
        await getCandidateProfileData();
    UserData? _retrievedUserData = await getUserData();

    setState(() {
      candidateProfileModel = _candidateProfileModel;
      retrievedUserData = _retrievedUserData;
    });
    getAppliedJobsList();
  }
}
