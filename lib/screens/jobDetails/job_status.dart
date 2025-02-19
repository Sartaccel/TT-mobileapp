import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:talent_turbo_new/AppColors.dart';
import 'package:talent_turbo_new/AppConstants.dart';
import 'package:talent_turbo_new/Utils.dart';
import 'package:talent_turbo_new/models/referral_profile_model.dart';
import 'package:talent_turbo_new/models/user_data_model.dart';
import 'package:http/http.dart' as http;
class JobStatus extends StatefulWidget {
  final jobData;
  const JobStatus({super.key, required this.jobData});

  @override
  State<JobStatus> createState() => _JobStatusState();
}

class _JobStatusState extends State<JobStatus> {
  UserData? retrievedUserData;
  ReferralData? referralData;
  bool _isLoading = false;

  List<dynamic> statusList = [];

  String status = '';

  Future<void> fetchJobStatus() async {
    final url =
        Uri.parse(AppConstants.BASE_URL + AppConstants.APPLIED_JOBS_STATUS);

    final bodyParams = {
      "candidateId": retrievedUserData!.profileId.toString(),
      "jobId": widget.jobData['jobId']
    };

    if (kDebugMode) {
      print(jsonEncode(bodyParams));
    }

    try {
      setState(() {
        _isLoading = true;
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

        String statusMessage = resOBJ['message'];
        if (statusMessage.toLowerCase().contains('success')) {
          List<dynamic> tmpList = resOBJ['jobStatus'];
          if (kDebugMode) {
            print(tmpList.length);
          }

          setState(() {
            statusList = tmpList;
            status = tmpList[(tmpList.length) - 1]['statusName'];
          });
        }
      } else {}

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

// Helper method to build each timeline row
  Widget buildTimelineRow(String title, String date, bool isActive) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Circle icon
        Container(
          margin: EdgeInsets.only(right: 16),
          child: Icon(
            Icons.circle,
            size: 12,
            color: isActive ? Colors.blue : Colors.grey,
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
                fontWeight: FontWeight.bold,
                color: isActive ? Colors.black : Colors.grey,
              ),
            ),
            if (date.isNotEmpty)
              Text(
                date,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
          ],
        ),
      ],
    );
  }

// Helper method to build vertical lines between steps
  Widget buildVerticalLine(bool isActive) {
    return Container(
      margin: EdgeInsets.fromLTRB(5, 0, 0, 0),
      height: 50,
      width: 1.5,
      color: isActive ? Colors.blue : Colors.grey,
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
              color: Colors.white,
              padding: EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 5),
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                        border: Border.all(width: 0, color: Colors.white),
                        color: Colors.white),
                    width: MediaQuery.of(context).size.width,
                    height: 150,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        //Image.asset('assets/images/ic_comp_logo.png', height: 32, width: 32, ),
                        Image(
                          image: widget.jobData['logo'] != null &&
                                  widget.jobData['logo'].isNotEmpty
                              ? NetworkImage(
                                  widget.jobData['logo'],
                                ) as ImageProvider<Object>
                              : const AssetImage(
                                  'assets/images/tt_logo_resized.png'),
                          height: 40,
                          width: 40,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            // Fallback to asset if network image fails
                            return Image.asset(
                                'assets/images/tt_logo_resized.png',
                                height: 32,
                                width: 32);
                          },
                        ),
                        SizedBox(
                          width: 15,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              fit: FlexFit.loose,
                              child: Container(
                                width: MediaQuery.of(context).size.width - 155,
                                child: Text(
                                  widget.jobData['jobTitle'],
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontFamily: 'Lato',
                                      fontSize: 16,
                                      color: Color(0xff333333)),
                                ),
                              ),
                            ),
                            Flexible(
                                fit: FlexFit.loose,
                                child: Container(
                                  width:
                                      MediaQuery.of(context).size.width - 155,
                                  child: Text(
                                    widget.jobData['companyName'],
                                    //'jkkkkkhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhdddddddddddddddd',
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontFamily: 'Lato',
                                        fontSize: 13,
                                        color: Color(0xff545454)),
                                  ),
                                )),
                            Container(
                              width: MediaQuery.of(context).size.width - 150,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Image.asset(
                                    'assets/images/ic_skills.png',
                                    height: 14,
                                    width: 14,
                                    color: Colors.black,
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  //Flexible(fit: FlexFit.loose, child: Text('Skills : Interaction Design · Research.......................................', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: FontWeight.w400, fontSize: 14, color: Color(0xff545454)),)),
                                  Flexible(
                                      fit: FlexFit.loose,
                                      child: Text(
                                        'Skills : ${widget.jobData['skills']}',
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        style: TextStyle(
                                            fontWeight: FontWeight.w400,
                                            fontSize: 14,
                                            color: Color(0xff545454)),
                                      )),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                Row(
                                  children: [
                                    Image.asset(
                                      'assets/images/ic_work_type.png',
                                      height: 14,
                                      width: 14,
                                      color: Colors.black,
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                      widget.jobData['workType'] ?? 'Fulltime',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w400,
                                          fontSize: 14,
                                          color: Color(0xff545454)),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  width: 20,
                                ),
                                Container(
                                  width: 100,
                                  child: Row(
                                    children: [
                                      Image.asset(
                                        'assets/images/ic_location.png',
                                        height: 14,
                                        width: 14,
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
                                                color: Color(0xff545454)),
                                          )),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                           
                           
                            
                          ],
                        ),

                        //Icon(Icons.bookmark_border_rounded, size: 25,)
                        SizedBox(
                          width: 25,
                        )
                      ],
                    ),
                  ),

                  SizedBox(height: 0,),
                  Container(width:MediaQuery.of(context).size.width ,height: 1, color: Color(0xffE6E6E6),),

                  SizedBox(height: 30,),

                 _isLoading ?
                      Center(
                   child: Container(
                     width: MediaQuery.of(context).size.width,
                     child: Center(
                       child: Column(
                         children: [
                           SizedBox(height: 30,),
                           LoadingAnimationWidget.fourRotatingDots(
                             color: AppColors.primaryColor,
                             size: 40,
                           ),
                         ],
                       ),
                     ),
                   ),
                 )
                     : Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                          margin: EdgeInsets.symmetric(horizontal: 15),
                          child: Text('Status', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xff333333)),)),

                      SizedBox(height: 0,),
              Padding(
  padding: const EdgeInsets.all(16.0),
  child: ListView.builder(
    physics: NeverScrollableScrollPhysics(),
    shrinkWrap: true,
    itemCount: 4, // Ensure exactly 4 steps
    itemBuilder: (context, index) {
      Map<String, String> statusMapping = {
        "Talent Identified": "Applied",
        "Shortlisted": "Shortlisted",
        "Interview Completed": "Interview",
        "Offer Given": "Selection"
      };

      List<Map<String, String>> timelineSteps = [
        {"statusName": "Applied", "createdAt": ""},
        {"statusName": "Shortlisted", "createdAt": ""},
        {"statusName": "Interview", "createdAt": ""},
        {"statusName": "Selection", "createdAt": ""},
      ];

      bool isActive = index == 0; // "Applied" is always active

      // Update from API statusList if available
      if (statusList.isNotEmpty) {
        for (var status in statusList) {
          if (statusMapping.containsKey(status['statusName'])) {
            int stepIndex = timelineSteps.indexWhere(
                (step) => step['statusName'] == statusMapping[status['statusName']]);
            if (stepIndex != -1) {
              timelineSteps[stepIndex]["createdAt"] = status['createdAt'] ?? "";
              if (index == stepIndex) {
                isActive = true; // Mark as active if present in API
              }
            }
          }
        }
      }

      return Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  // Timeline Status Circle
                  Container(
                    width: 15,
                    height: 15,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isActive ? const Color(0XFF004C99) : Colors.grey[400]!,
                        width: 2,
                      ),
                      color: Colors.transparent, // Transparent fill color for all circles
                    ),
                  ),
                  // Vertical Line (except last item)
                  if (index != 3)
                    Container(
                      width: 3, // Thicker line
                      height: 77,
                      color: isActive ? Color(0XFF004C99) : Colors.grey[300],
                    ),
                ],
              ),
              SizedBox(width: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    timelineSteps[index]['statusName']!,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isActive ? Color(0XFF004C99) : Colors.grey[600],
                    ),
                  ),
                  if (timelineSteps[index]['createdAt']!.isNotEmpty)
                    Text(
                      timelineSteps[index]['createdAt']!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                    ),
                ],
              ),
            ],
          ),
    
        ],
      );
    },
  ),
),

],
 ),
],
              ),
            ),
          )),

          /*InkWell(
            onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (BuildContext context)=> HomeContainer()));
            },
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: 50,
              margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              padding: EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(border: Border.all(color: AppColors.primaryColor) , color: Colors.white,borderRadius: BorderRadius.circular(10)),
              child: Center(child: Text('Refer', style: TextStyle(color: Color(0xff004C99), fontWeight: FontWeight.w600, fontSize: 16),),),
            ),
          ),*/
        ],
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
    ReferralData? _referralData = await getReferralProfileData();

    setState(() {
      retrievedUserData = _retrievedUserData;
      referralData = _referralData;
      //print(retrievedUserData?.email);
      fetchJobStatus();
    });
  }
}
