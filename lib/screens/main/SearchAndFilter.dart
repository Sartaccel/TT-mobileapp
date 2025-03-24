import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talent_turbo_new/Utils.dart';
import 'package:talent_turbo_new/models/user_data_model.dart';

class Searchandfilter extends StatefulWidget {
  const Searchandfilter({super.key});

  @override
  State<Searchandfilter> createState() => _SearchandfilterState();
}

class _SearchandfilterState extends State<Searchandfilter> {
  UserData? retrievedUserData;
  bool isLoading = false;
  String selectedJob = '', searchedJob = '';
  List<String> jobSuggestions = [];
  final TextEditingController searchController = TextEditingController();
  final FocusNode searchFocusNode = FocusNode();
  final Dio dio = Dio();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _retrieveUserData();
  }

  Future<UserData?> getUserDataFromStorage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userDataJson = prefs.getString('userData');
    if (userDataJson != null) {
      Map<String, dynamic> userDataMap = jsonDecode(userDataJson);
      return UserData(
        email: userDataMap['email'],
        userType: userDataMap['userType'],
        name: userDataMap['name'],
        token: userDataMap['token'],
        accountId: userDataMap['accountId'],
        profileId: userDataMap['profileId'],
      );
    }
    return null;
  }

  Future<void> _retrieveUserData() async {
    UserData? userData = await getUserDataFromStorage();
    if (mounted) {
      setState(() {
        retrievedUserData = userData;
      });
    }
  }

  void fetchJobTitles(String query) {
    if (retrievedUserData?.token == null) return;

    // Immediate UI update: Show loading state
    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }

    // Cancel any previous debounce timer
    _debounce?.cancel();

    // Debounce the API call
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      final url =
          'https://mobileapi.talentturbo.us/api/v1/jobresource/get/job/titles';
      final headers = {'Authorization': retrievedUserData!.token};
      final data = FormData.fromMap({'jobTitle': query});

      try {
        final response =
            await dio.post(url, options: Options(headers: headers), data: data);

        if (response.statusCode == 200 && response.data['status'] == true) {
          final jobTitles = List<String>.from(response.data['jobTitles'] ?? []);
          if (mounted) {
            setState(() {
              jobSuggestions = jobTitles;
              isLoading = false; // Set loading to false after data is fetched
            });
          }
        }
      } catch (e) {
        print("Error: $e");
        if (mounted) {
          setState(
              () => isLoading = false); // Set loading to false in case of error
        }
      } finally {
        if (mounted) {
          setState(() => isLoading = false); // Ensure loading is set to false
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Color(0xff001B3E),
      statusBarIconBrightness: Brightness.light,
    ));

    return Scaffold(
      backgroundColor: const Color(0xfff7f7f7),
      body: Column(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: 40,
            color: const Color(0xff001B3E),
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            height: 60,
            color: const Color(0xff001B3E),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new,
                          color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      child: const SizedBox(
                        height: 50,
                        child: Center(
                          child: Text('Back',
                              style:
                                  TextStyle(fontSize: 16, color: Colors.white)),
                        ),
                      ),
                    ),
                  ],
                ),
                const Text('Job Search',
                    style: TextStyle(color: Colors.white, fontSize: 16)),
                const SizedBox(width: 90),
              ],
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            color: const Color(0xff001B3E),
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width - 50,
                  height: 40,
                  child: Autocomplete<String>(
                    optionsViewBuilder: (context, onSelected, options) {
                      return Padding(
                        padding: const EdgeInsets.only(
                            top: 10), // Gap outside the box
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Material(
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xfffcfcfc),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              width: MediaQuery.of(context).size.width - 50,
                              constraints: const BoxConstraints(maxHeight: 230),
                              child: ListView.builder(
                                padding: EdgeInsets.zero,
                                itemCount: options.length,
                                shrinkWrap: true,
                                itemBuilder: (context, index) {
                                  final String option =
                                      options.elementAt(index);
                                  return ListTile(
                                    leading: SvgPicture.asset(
                                      'assets/icon/Search.svg',
                                      width: 22,
                                      height: 22,
                                    ),
                                    title: Text(
                                      option,
                                      style: const TextStyle(
                                          fontSize: 12,
                                          fontFamily: 'Lato',
                                          color: Color(0xff333333)),
                                    ),
                                    onTap: () {
                                      onSelected(option);
                                    },
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      if (textEditingValue.text.isEmpty) {
                        return jobSuggestions;
                      }

                      return jobSuggestions.where(
                        (title) => title
                            .toLowerCase()
                            .startsWith(textEditingValue.text.toLowerCase()),
                      );
                    },
                    onSelected: (String selection) {
                      setState(() {
                        selectedJob = selection;
                        searchedJob = selection;
                      });
                      saveStringToPreferences("search", selection);
                    },
                    fieldViewBuilder:
                        (context, controller, focusNode, onFieldSubmitted) {
                      searchController.text = controller.text;
                      return TextField(
                        cursorColor: const Color(0xff004C99),
                        controller: controller,
                        focusNode: focusNode,
                        onChanged: (value) {
                          // Immediate response: Update UI and trigger API call
                          setState(() {
                            searchedJob = value;
                            isLoading = true;
                          });
                          fetchJobTitles(value);
                        },
                        decoration: InputDecoration(
                          prefixIcon: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: SvgPicture.asset(
                              'assets/icon/Search.svg',
                              width: 22,
                              height: 22,
                            ),
                          ),
                          suffixIcon: isLoading
                              ? Padding(
                                  padding: const EdgeInsets.all(15.0),
                                  child: SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.001,
                                    height: MediaQuery.of(context).size.width *
                                        0.001,
                                    child: CircularProgressIndicator(
                                      strokeWidth:
                                          MediaQuery.of(context).size.width *
                                              0.05,
                                      valueColor:
                                          const AlwaysStoppedAnimation<Color>(
                                              Color(0xff004C99)),
                                    ),
                                  ),
                                )
                              : null,
                          filled: true,
                          fillColor: Colors.white,
                          hintText: 'Search for job or skills',
                          hintStyle: TextStyle(color: Color(0xff7D7C7C)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 0, horizontal: 15),
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'[a-zA-Z0-9\s#+.\-]')),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          InkWell(
            onTap: () {
              if (searchedJob.isEmpty) {
                if (mounted) {
                  IconSnackBar.show(
                    context,
                    label: 'Please enter a valid job or skill to search.',
                    snackBarType: SnackBarType.alert,
                    backgroundColor: const Color(0xffBA1A1A),
                    iconColor: Colors.white,
                  );
                }
              } else {
                saveStringToPreferences("search", searchedJob);
                Navigator.pop(context);
              }
            },
            child: Container(
              width: MediaQuery.of(context).size.width - 40,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xff004C99),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: Text('Search Jobs',
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        fontSize: 14,
                        fontFamily: 'Lato')),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
