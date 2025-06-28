import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:talent_turbo_new/AppColors.dart';
import 'package:talent_turbo_new/AppConstants.dart';
import 'package:talent_turbo_new/Utils.dart';
import 'package:talent_turbo_new/models/candidate_profile_model.dart';
import 'package:talent_turbo_new/models/job_list_model.dart';
import 'package:talent_turbo_new/screens/jobDetails/JobDetails.dart';
import 'package:talent_turbo_new/screens/main/SearchAndFilter.dart';
import 'package:talent_turbo_new/screens/main/job_search_filter.dart';
import 'package:talent_turbo_new/screens/main/notifications.dart';
import '../../../models/user_data_model.dart';
import 'package:http/http.dart' as http;

class HomeFragment extends StatefulWidget {
  const HomeFragment({super.key});

  @override
  State<HomeFragment> createState() => _HomeFragmentState();
}

class _HomeFragmentState extends State<HomeFragment>
    with SingleTickerProviderStateMixin {
  UserData? retrievedUserData;
  CandidateProfileModel? candidateProfileModel;

  String jobSearchTerm = '';
  String exp_search = '0';
  String emp_search = '';

  bool isLoading = true;
  bool isConnectionAvailable = true;
  bool isShowingSearchResults = false;

  List<dynamic> jobList = [];
  bool hasFilters = false;

  final FToast fToast = FToast();
  double _currentBottomPosition = 0.1;
  final List<double> _activeToastPositions = [];

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Color(0xff001B3E),
      statusBarIconBrightness: Brightness.light,
    ));

    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;

    return Stack(
      children: [
        // Header Section
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            color: Color(0xff001B3E),
            child: Column(
              children: [
                SizedBox(height: 60),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 25),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 0.77,
                        height: 40,
                        padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          color: Colors.white,
                        ),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: () async {
                                    await Navigator.push(
                                      context,
                                      PageRouteBuilder(
                                        pageBuilder: (context, animation,
                                                secondaryAnimation) =>
                                            Searchandfilter(),
                                        transitionDuration: Duration.zero,
                                        reverseTransitionDuration:
                                            Duration.zero,
                                      ),
                                    );
                                    String? pref_value =
                                        await getStringFromPreferences(
                                            "search");
                                    setState(() {
                                      jobSearchTerm = pref_value!;
                                      isShowingSearchResults =
                                          jobSearchTerm.isNotEmpty;
                                      fetchAllJobs();
                                    });
                                  },
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SvgPicture.asset(
                                        'assets/icon/Search.svg',
                                        width: 26,
                                        height: 26,
                                      ),
                                      SizedBox(width: 10),
                                      Flexible(
                                        child: Text(
                                          jobSearchTerm.isEmpty
                                              ? 'Search for jobs or skills'
                                              : jobSearchTerm,
                                          style: TextStyle(
                                              color: Color(0xff7D7C7C)),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              jobSearchTerm.isEmpty
                                  ? Container()
                                  : InkWell(
                                      onTap: () {
                                        setState(() {
                                          jobSearchTerm = '';
                                          fetchAllJobs();
                                        });
                                      },
                                      child: Icon(
                                        Icons.cancel,
                                        color: Color(0xff818385),
                                      ),
                                    ),
                            ],
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      NotificationScreen(),
                              transitionDuration: Duration.zero,
                              reverseTransitionDuration: Duration.zero,
                            ),
                          );
                        },
                        child: Stack(
                          children: [
                            jobSearchTerm.isEmpty
                                ? SvgPicture.asset(
                                    'assets/icon/Notify.svg',
                                    width: 28,
                                    height: 28,
                                  )
                                : SizedBox(
                                    width: 26,
                                    height: 26,
                                    child: InkWell(
                                      onTap: () async {
                                        await Navigator.push(
                                            context,
                                            PageRouteBuilder(
                                              pageBuilder: (context, animation,
                                                      secondaryAnimation) =>
                                                  JobSearchFilter(),
                                              transitionDuration: Duration.zero,
                                              reverseTransitionDuration:
                                                  Duration.zero,
                                            ));

                                        String? pref_filt =
                                            await getStringFromPreferences(
                                                "searchExp");
                                        exp_search = pref_filt ?? '';

                                        String? pref_emp_filt =
                                            await getStringFromPreferences(
                                                "searchEmpType");
                                        emp_search = pref_emp_filt ?? '';

                                        if (emp_search == 'Full time') {
                                          setState(() {
                                            emp_search = 'Fulltime';
                                          });
                                        }

                                        setState(() {
                                          if ((emp_search != null &&
                                                  emp_search != "") ||
                                              (exp_search != null &&
                                                  exp_search != "0")) {
                                            hasFilters = true;
                                          } else {
                                            hasFilters = false;
                                          }
                                        });

                                        fetchAllJobs();
                                      },
                                      child: Stack(
                                        children: [
                                          SvgPicture.asset(
                                              'assets/images/ic_filter.svg'),
                                          hasFilters
                                              ? Positioned(
                                                  left: 3,
                                                  top: 1,
                                                  child: SvgPicture.asset(
                                                      'assets/images/ic_filter_on.svg'))
                                              : Container(),
                                        ],
                                      ),
                                    ),
                                  )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),

        // Main Content Section
        Positioned(
          top: 120,
          left: 0,
          right: 0,
          bottom: MediaQuery.of(context).size.height * 0.09,
          child: RefreshIndicator(
            onRefresh: fetchAllJobs,
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Greeting Section
                  if (jobSearchTerm.isEmpty && isConnectionAvailable)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hi, ${candidateProfileModel?.candidateName}',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Color(0xff333333)),
                          ),
                          SizedBox(height: 5),
                          Text(
                            jobSearchTerm.isEmpty
                                ? 'Recent job list'
                                : 'Search results for ${jobSearchTerm}',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: Color(0xff333333)),
                          ),
                        ],
                      ),
                    ),

                  // Loading Shimmer
                  if (isLoading)
                    Shimmer.fromColors(
                      baseColor: Color(0xffE6E6E6),
                      highlightColor: Color(0xffF2F2F2),
                      child: Column(
                        children: List.generate(
                            6,
                            (index) => Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 8, horizontal: 15),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.11,
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.11,
                                            decoration: BoxDecoration(
                                              color: Color(0xffE6E6E6),
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
                                                    0.62,
                                                height: 20,
                                                decoration: BoxDecoration(
                                                  color: Color(0xffE6E6E6),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                              ),
                                              SizedBox(height: 10),
                                              Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.45,
                                                height: 15,
                                                decoration: BoxDecoration(
                                                  color: Color(0xffE6E6E6),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                              ),
                                              SizedBox(height: 10),
                                              Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.70,
                                                height: 15,
                                                decoration: BoxDecoration(
                                                  color: Color(0xffE6E6E6),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                              ),
                                              SizedBox(height: 10),
                                              Row(
                                                children: [
                                                  Container(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.33,
                                                    height: 15,
                                                    decoration: BoxDecoration(
                                                      color: Color(0xffE6E6E6),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                    ),
                                                  ),
                                                  SizedBox(width: 10),
                                                  Container(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.33,
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
                                              SizedBox(height: 10),
                                              Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.27,
                                                height: 15,
                                                decoration: BoxDecoration(
                                                  color: Color(0xffE6E6E6),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
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
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                )),
                      ),
                    ),

                  // Job List
                  if (!isLoading && isConnectionAvailable && jobList.length > 0)
                    Column(
                      children: jobList
                          .map((job) => _buildJobItem(job, isSmallScreen))
                          .toList(),
                    ),

                  // Empty State
                  if (!isLoading && jobList.isEmpty && isConnectionAvailable)
                    Padding(
                      padding: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height * 0.15,
                      ),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SvgPicture.asset(
                              'assets/icon/noSearch.svg',
                              height: MediaQuery.of(context).size.height * 0.22,
                            ),
                            SizedBox(height: 40),
                            Text(
                              'No result found',
                              style: TextStyle(
                                  fontFamily: 'Lato',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Color(0xff333333)),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'We couldn\'t find any jobs matching \n "${jobSearchTerm[0].toUpperCase()}${jobSearchTerm.substring(1)}"',
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
                                  pageBuilder: (context, animation,
                                          secondaryAnimation) =>
                                      Searchandfilter(),
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
                                    'Search again',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  // No Internet State
                  if (!isLoading && !isConnectionAvailable)
                    Padding(
                      padding: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height * 0.2),
                      child: Center(
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
                                fetchAllJobs();
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
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildJobItem(dynamic job, bool isSmallScreen) {
    return Container(
      margin: EdgeInsets.symmetric(
        vertical: isSmallScreen ? 4 : 4,
        horizontal: isSmallScreen ? 0 : 0,
      ),
      padding: EdgeInsets.all(isSmallScreen ? 10 : 15),
      decoration: BoxDecoration(
        border: Border.all(width: 1, color: Color(0xffE6E6E6)),
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
            child: InkWell(
              onTap: () async {
                await Navigator.pushAndRemoveUntil(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        Jobdetails(jobData: job, isFromSaved: false),
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
                  ),
                  (Route<dynamic> route) => route.isFirst,
                );
                loadCachedJobs();
              },
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: isSmallScreen ? 55 : 60,
                    height: isSmallScreen ? 55 : 60,
                    child: Image(
                      image: job['logo'] != null && job['logo'].isNotEmpty
                          ? NetworkImage(job['logo']) as ImageProvider<Object>
                          : const AssetImage(
                              'assets/images/tt_logo_resized.png'),
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          job['jobTitle'],
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Lato',
                            fontSize: isSmallScreen ? 15 : 16,
                            color: Color(0xff333333),
                          ),
                        ),
                        SizedBox(height: isSmallScreen ? 3 : 4),
                        Text(
                          job['companyName'].toString().trim(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontFamily: 'Lato',
                            fontSize: 13,
                            color: Color(0xff545454),
                          ),
                        ),
                        SizedBox(height: isSmallScreen ? 3 : 4),
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
                                  String skillStr = job['skillSet'] ?? '';
                                  List<String> rawSkills = skillStr
                                      .split(',')
                                      .map((s) => s.trim())
                                      .where((s) => s.isNotEmpty)
                                      .toList();

                                  List<String> skills = [];
                                  Set<String> seen = {};

                                  for (var skill in rawSkills) {
                                    String lower = skill.toLowerCase();
                                    if (!seen.contains(lower)) {
                                      seen.add(lower);
                                      skills.add(skill);
                                    }
                                  }

                                  String displaySkills;
                                  if (skills.length > 3) {
                                    displaySkills =
                                        '${skills.take(3).join(', ')} +${skills.length - 3}';
                                  } else {
                                    displaySkills = skills.join(', ');
                                  }

                                  return Text(
                                    'Skills: $displaySkills',
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: isSmallScreen ? 13 : 14,
                                      color: Color(0xff545454),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: isSmallScreen ? 3 : 4),
                        Wrap(
                          spacing: isSmallScreen ? 10 : 12,
                          runSpacing: isSmallScreen ? 5 : 6,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SvgPicture.asset(
                                  'assets/images/ic_suitcase.svg',
                                  height: isSmallScreen ? 18 : 20,
                                  width: isSmallScreen ? 18 : 20,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  job['workType'],
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: isSmallScreen ? 13 : 14,
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
                                  height: isSmallScreen ? 18 : 20,
                                  width: isSmallScreen ? 18 : 20,
                                ),
                                SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    job['location'] ?? 'N/A',
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: isSmallScreen ? 13 : 14,
                                      color: Color(0xff545454),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: isSmallScreen ? 3 : 4),
                        checkExpiry(job['dueDate'] ?? '1990-01-01')
                            ? Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xffFFBE2E0),
                                  borderRadius: BorderRadius.circular(4),
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
                                processDate(job['createdDate'] ?? '2024-10-27'),
                                style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontFamily: 'lato',
                                  fontSize: isSmallScreen ? 13 : 14,
                                  color: const Color(0xff545454),
                                ),
                              ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bookmark Button
          Padding(
            padding: EdgeInsets.only(left: 0),
            child: InkWell(
              onTap: () async {
                bool isSaved = (job['isFavorite'] == "1");
                int? jobId = job['jobId'] ?? job['id'];

                if (jobId != null) {
                  setState(() {
                    job['isFavorite'] = isSaved ? "0" : "1";
                  });

                  bool success = await saveJob(jobId, isSaved ? 0 : 1);

                  if (!success) {
                    setState(() {
                      job['isFavorite'] = isSaved ? "1" : "0";
                    });
                  } else {
                    if (job['isFavorite'] == "1") {
                      showJobSavedToast(context);
                    } else {
                      showJobRemovedToast(context, () {
                        setState(() {
                          job['isFavorite'] = "1";
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
                  begin: job['isFavorite'] == "1" ? 0 : 1,
                  end: job['isFavorite'] == "1" ? 1 : 0,
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
    );
  }

  // Helper methods (keep all your existing helper methods here)
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
    final toastWidth = screenWidth * 0.92;

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
                  overflow: TextOverflow.ellipsis,
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

  void _showSnackBar(BuildContext context, String message, Color color) {
    // Your snackbar implementation
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
        return true;
      } else {
        if (mounted) {
          _showSnackBar(context, 'Something went wrong. Please try again.',
              Color(0xff2D2D2D));
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) print("Error: $e");
      if (mounted) {
        _showSnackBar(context, 'Network error. Please check your connection.',
            Color(0xff2D2D2D));
      }
      return false;
    }
  }

  Future<void> fetchAllJobs() async {
    final url = Uri.parse(AppConstants.BASE_URL + AppConstants.ALL_JOBS_LIST);
    final bodyParams = {
      "jobTitle": jobSearchTerm,
      "jobCode": "",
      "companyName": "",
      "experience": exp_search,
      "workType": emp_search,
      "skillSet": ""
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
        bool status = resOBJ['status'];
        String statusMessage = resOBJ['message'];

        if (statusMessage.toLowerCase().contains('success') && status == true) {
          final List<dynamic> jsonResponse = (resOBJ['jobList']);
          final activeJobs =
              jsonResponse.where((job) => !isJobExpired(job)).toList();
          setState(() {
            jobList = activeJobs;
          });
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    } finally {
      var connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult.contains(ConnectivityResult.none)) {
        setState(() {
          isConnectionAvailable = false;
        });
      } else {
        setState(() {
          isConnectionAvailable = true;
        });
      }
      setState(() {
        isLoading = false;
      });
    }
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

  bool isJobExpired(Map<String, dynamic> job) {
    final dueDate = job['dueDate'] ?? '1990-01-01';
    return checkExpiry(dueDate);
  }

  Future<void> loadCachedJobs() async {
    final prefs = await SharedPreferences.getInstance();
    final jobListString = prefs.getString('jobList');

    if (jobListString != null && mounted) {
      final cachedJobs = jsonDecode(jobListString) as List<dynamic>;
      final activeJobs = cachedJobs.where((job) => !isJobExpired(job)).toList();
      setState(() {
        jobList = activeJobs;
        isLoading = false;
      });
    } else if (mounted) {
      setState(() => isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUserDataFromPref();
  }

  Future<void> fetchUserDataFromPref() async {
    UserData? _retrievedUserData = await getUserData();
    CandidateProfileModel? _candidateProfileModel =
        await getCandidateProfileData();

    setState(() {
      retrievedUserData = _retrievedUserData;
      candidateProfileModel = _candidateProfileModel;

      if (kDebugMode) {
        print("User Email: ${retrievedUserData?.email}");
      }

      fetchAllJobs();
    });
  }
}
