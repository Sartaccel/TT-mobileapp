import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:talent_turbo_new/AppConstants.dart';
import 'package:talent_turbo_new/Utils.dart';
import 'package:talent_turbo_new/models/referral_profile_model.dart';
import 'package:talent_turbo_new/models/user_data_model.dart';
import 'package:talent_turbo_new/screens/jobDetails/job_status.dart';
import 'package:talent_turbo_new/screens/jobDetails/postSubmission.dart';
import 'package:talent_turbo_new/screens/main/fragments/applied_jobs_fragment.dart';
import 'package:talent_turbo_new/screens/main/fragments/saved_jobs_fragment.dart';
import 'package:http/http.dart' as http;

class MyJobsFragment extends StatefulWidget {
  const MyJobsFragment({super.key});

  @override
  State<MyJobsFragment> createState() => _MyJobsFragmentState();
}

class _MyJobsFragmentState extends State<MyJobsFragment> {
  @override
  Widget build(BuildContext context) {
    // Change the status bar color
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Color(0xff001B3E),
      statusBarIconBrightness: Brightness.light,
    ));
    return Column(
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
                    icon: Container(),
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
                            '',
                            style: TextStyle(
                                fontFamily: 'Lato',
                                fontSize: 16,
                                color: Colors.white),
                          ))))
                ],
              ),
              Text(
                'My Jobs',
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
        DefaultTabController(
            length: 2,
            child: Column(
              children: [
                TabBar(
                    indicatorColor: Colors.blue,
                    unselectedLabelColor: Color(0xff333333),
                    labelStyle: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Lato',
                        fontSize: 16),
                    labelColor: Color(0xff004C99),
                    tabs: [
                      Tab(
                        text: 'Saved',
                      ),
                      Tab(
                        text: 'Applied',
                      ),
                    ]),
                Container(
                  height: (MediaQuery.of(context).size.height) - 230,
                  child: TabBarView(children: [
                    SavedJobsFragment(),
                    AppliedJobsFragment(),
                  ]),
                )
              ],
            )),
      ],
    );
  }
}
