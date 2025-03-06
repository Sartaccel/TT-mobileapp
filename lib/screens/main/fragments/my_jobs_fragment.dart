import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:talent_turbo_new/screens/main/fragments/applied_jobs_fragment.dart';
import 'package:talent_turbo_new/screens/main/fragments/saved_jobs_fragment.dart';

class MyJobsFragment extends StatefulWidget {
  const MyJobsFragment({super.key});

  @override
  State<MyJobsFragment> createState() => _MyJobsFragmentState();
}

class _MyJobsFragmentState extends State<MyJobsFragment> {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Color(0xff001B3E),
      statusBarIconBrightness: Brightness.light,
    ));

    return Column(
      children: [
        // Top blue bar
        Container(
          width: MediaQuery.of(context).size.width,
          height: 40,
          decoration: const BoxDecoration(color: Color(0xff001B3E)),
        ),

        // App bar section
        Container(
          width: MediaQuery.of(context).size.width,
          height: 60,
          decoration: const BoxDecoration(color: Color(0xff001B3E)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(width: 50), // Empty space for alignment
              const Center(
                child: Text(
                  'My Jobs',
                  style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Lato',
                      fontWeight: FontWeight.w400,
                      fontSize: 16),
                ),
              ),
              SizedBox(width: MediaQuery.of(context).size.width * 0.08),
            ],
          ),
        ),

        // TabBar & Content (Fix: Removed Positioned)
        Expanded(
          child: Container(
            color: const Color(0xffF7f7f7),
            child: DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  const TabBar(
                    indicatorColor: Color(0xff004C99),
                    indicatorSize: TabBarIndicatorSize.tab,
                    unselectedLabelColor: Color(0xff333333),
                    labelStyle: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Lato',
                        fontSize: 16),
                    labelColor: Color(0xff004C99),
                    tabs: [
                      Tab(text: 'Saved'),
                      Tab(text: 'Applied'),
                    ],
                  ),

                  // TabBarView inside Expanded to avoid layout errors
                  Expanded(
                    child: TabBarView(
                      children: [
                        SavedJobsFragment(),
                        AppliedJobsFragment(),
                      ],
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
}
