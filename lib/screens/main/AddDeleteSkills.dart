import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:talent_turbo_new/AppColors.dart';
import 'package:talent_turbo_new/AppConstants.dart';
import 'package:talent_turbo_new/Utils.dart';
import 'package:talent_turbo_new/models/login_data_model.dart';
import 'package:talent_turbo_new/models/user_data_model.dart';
import 'package:talent_turbo_new/screens/main/personal_details.dart';

class Adddeleteskills extends StatefulWidget {
  const Adddeleteskills({super.key});

  @override
  State<Adddeleteskills> createState() => _AdddeleteskillsState();
}

class _AdddeleteskillsState extends State<Adddeleteskills> {
  UserData? retrievedUserData;
  final databaseRef =
      FirebaseDatabase.instance.ref().child(AppConstants.APP_NAME);

  String customSkills = '';

  TextEditingController _controller = TextEditingController();

  final List<String> skills = [
    'Java',
    'Python',
    'Flutter',
    'React',
    'Android Development',
    'iOS Development',
    'Embedded Systems',
    'Firmware Development',
    'Spring Boot',
    'Node.js',
    'Firebase',
    'SQL',
    'MongoDB',
    'AWS',
    'Azure',
    'Docker',
    'Kubernetes',
    'Git',
    'Communication',
    'Teamwork',
    'Leadership',
    'Problem-Solving',
    'UI/UX Design',
    'Adobe Photoshop',
    'Figma',
    'Digital Marketing',
    'SEO',
    'Project Management',
    'HTML',
    'JavaScript',
    'C++',
    'Ruby',
    'English',
    'Spanish',
    'German',
    'Japanese',
    'Public Speaking',
    'Time Management'
  ];

  List<String> userSkills = [];
  Map<String, String> skillKeys = {};

  String email = '';

  bool isLoading = true;

  Future<void> addSkillToFirebase(String skill) async {
    final String sanitizedEmail = email.replaceAll('.', ',');
    final DatabaseReference skillRef =
        databaseRef.child('$sanitizedEmail/mySkills');

    // Convert existing skills to lowercase for comparison
    List<String> lowerCaseSkills =
        userSkills.map((s) => s.toLowerCase()).toList();

    // Also convert the new skill to lowercase
    if (lowerCaseSkills.contains(skill.toLowerCase())) {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text('Skill "${skill.trim()}" already exists.')),
      // );
      return;
    }

    try {
      await skillRef.push().set(skill.trim());

      setState(() {
        userSkills.add(skill.trim());
      });

      fetchSkills(); // Optional: keeps things synced with Firebase
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add skill: $error')),
      );
    }
  }

  Future<void> deleteSkill(String skill) async {
    final String sanitizedEmail = email.replaceAll('.', ',');
    final String? skillKey = skillKeys[skill]; // Find the skill's key

    // IconSnackBar.show(
    //   context,
    //   label: 'Deleting Skill',
    //   snackBarType: SnackBarType.alert,
    //   backgroundColor: Color(0xff2D2D2D),
    //   iconColor: Colors.white,
    // );

    if (skillKey != null) {
      await databaseRef.child('$sanitizedEmail/mySkills/$skillKey').remove();
      fetchSkills(); // Refresh the skills list
    }
  }

  Future<void> fetchSkills() async {
    final String sanitizedEmail = email.replaceAll('.', ',');
    final DatabaseReference skillRef =
        databaseRef.child('$sanitizedEmail/mySkills');

    // Listen for value changes in Firebase
    try {
      if (kDebugMode) print('Fetching');
      skillRef.onValue.listen((event) {
        final Map<dynamic, dynamic>? data = event.snapshot.value as Map?;
        if (data != null) {
          if (kDebugMode) print('Fetched if');
          setState(() {
            userSkills = data.values.cast<String>().toList();
            skillKeys = data.map((key, value) => MapEntry(value, key));
            isLoading = false;
          });
        } else {
          if (kDebugMode) print('Fetched else');
          setState(() {
            userSkills = [];
            skillKeys = {};
            isLoading = false;
          });
        }
      }, onError: (error) {
        if (kDebugMode) print(error);
        setState(() {
          userSkills = [];
          skillKeys = {};
          isLoading = false;
        });
      });
    } catch (e) {
      if (kDebugMode) print(e);
      setState(() {
        userSkills = [];
        skillKeys = {};
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Change the status bar color
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
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
                //SizedBox(width: 80,)
                Text(
                  'Skills',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: InkWell(
                    onTap: () async {
                      // Trim spaces to avoid saving extra spaces as part of the skill
                      String skillToSave = customSkills.trim();

                      // Check that the skill is valid
                      if (skillToSave.isNotEmpty && skillToSave.length > 1) {
                        try {
                          // Add the skill to Firebase
                          await addSkillToFirebase(skillToSave);

                          // Clear the input field after saving
                          setState(() {
                            customSkills = ''; // Clear input after save
                            _controller
                                .clear(); // Clear the TextField controller
                          });

                          // Show success message
                          // ignore: use_build_context_synchronously
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: Color(0xff2D2D2D),
                              elevation: 10,
                              margin: EdgeInsets.only(
                                  bottom: 30, left: 15, right: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              content: Row(
                                children: [
                                  SvgPicture.asset('assets/icon/success.svg'),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Skills updated !',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => ScaffoldMessenger.of(context)
                                        .hideCurrentSnackBar(),
                                    child: Icon(Icons.close_rounded,
                                        color: Colors.white),
                                  )
                                ],
                              ),
                              duration: Duration(seconds: 3),
                            ),
                          );
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      PersonalDetails(),
                              transitionDuration: Duration.zero,
                              reverseTransitionDuration: Duration.zero,
                            ),
                          );
                        } catch (error) {
                          // Handle errors gracefully
                          // ignore: use_build_context_synchronously
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text('Failed to save skill: $error')),
                          );
                        }
                      } else {
                        // Show a message if the input is invalid
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Please enter a valid skill!')),
                        );
                      }
                    },
                    child: Text(
                      customSkills.trim().isEmpty
                          ? ''
                          : 'Save', // Hide text if input is empty
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            width: (MediaQuery.of(context).size.width) - 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add skill',
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Lato',
                      color: Color(0xff333333)),
                ),
                SizedBox(height: 7),
                /*Container(
                  width: (MediaQuery.of(context).size.width) - 20,
                  child: TextField(
                    style: TextStyle(fontSize: 14, fontFamily: 'Lato'),
                    decoration: InputDecoration(
                        hintText: 'Skills',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),

                        // Display error message if invalid
                        contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10)
                    ),
                    onChanged: (value) {
                      // Validate the email here and update _isEmailValid
                      setState(() {
                      });
                    },
                  ),
                ),*/

                Container(
                  width: MediaQuery.of(context).size.width - 20,
                  child: Autocomplete<String>(
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      // Return matching skills based on user input
                      if (textEditingValue.text.isEmpty) {
                        return const Iterable<String>.empty();
                      }
                      return skills.where((skill) => skill
                          .toLowerCase()
                          .contains(textEditingValue.text.toLowerCase()));
                    },
                    onSelected: (String selection) {
                      // Update customSkills with the selected skill
                      setState(() {
                        customSkills = selection;
                      });

                      // Add the selected skill to Firebase
                      addSkillToFirebase(selection);

                      // Clear the text field after selection
                      Future.delayed(Duration.zero, () {
                        _controller.clear(); // Clear the TextField's controller
                      });
                    },
                    fieldViewBuilder:
                        (context, controller, focusNode, onFieldSubmitted) {
                      // Store the controller to use it for clearing later
                      _controller = controller;

                      return TextField(
                        controller: controller,
                        focusNode: focusNode,
                        cursorColor: Color(0xff004C99),
                        onChanged: (val) {
                          setState(() {
                            customSkills = val;
                          });
                        },
                        style: const TextStyle(
                            fontSize: 14,
                            fontFamily: 'Lato',
                            color: Color(0xff333333)),
                        decoration: InputDecoration(
                          hintText: 'Skills',
                          hintStyle: TextStyle(color: Color(0xff545454)),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                                BorderSide(color: Color(0xffD9D9D9), width: 1),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                                BorderSide(color: Color(0xff004C99), width: 1),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 10,
                          ),
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[a-zA-Z0-9\s#+.\-]'),
                          ),
                        ],
                      );
                    },
                    optionsViewBuilder: (context, onSelected, options) {
                      return Align(
                        alignment: Alignment.topLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Material(
                            color: Colors.transparent,
                            child: Container(
                              width: MediaQuery.of(context).size.width - 45,
                              decoration: BoxDecoration(
                                color: Color(0xFFFCFCFC),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Color(0xffD9D9D9),
                                  width: 1,
                                ),
                              ),
                              child: ListView.builder(
                                padding: EdgeInsets.zero,
                                shrinkWrap: true,
                                itemCount: options.length,
                                itemBuilder: (BuildContext context, int index) {
                                  final String option =
                                      options.elementAt(index);
                                  return InkWell(
                                    onTap: () => onSelected(option),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12, horizontal: 16),
                                      child: Row(
                                        children: [
                                          SvgPicture.asset(
                                            'assets/icon/Search.svg',
                                            width: 22,
                                            height: 22,
                                          ),
                                          SizedBox(width: 10),
                                          Expanded(
                                            child: Text.rich(
                                              TextSpan(
                                                children: highlightMatchedText(
                                                    option, _controller.text),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                isLoading
                    ? Container(
                        width: MediaQuery.of(context).size.width,
                        child: Center(
                          child: Column(
                            children: [
                              const SizedBox(
                                height: 30,
                              ),
                              LoadingAnimationWidget.fourRotatingDots(
                                color: AppColors.primaryColor,
                                size: 40,
                              ),
                            ],
                          ),
                        ),
                      )
                    : Container(),
                SizedBox(
                  height: 20,
                ),
                Wrap(
                  alignment: WrapAlignment.start,
                  crossAxisAlignment: WrapCrossAlignment.start,
                  spacing: 12.0,
                  runSpacing: 12.0,
                  children: List.generate(userSkills.length, (i) {
                    return Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: AppColors.primaryColor),
                      child: InkWell(
                        onTap: () {
                          deleteSkill(userSkills[i]);
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SvgPicture.asset(
                              'assets/images/ic_close_vector.svg',
                              width: 8,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              userSkills[i],
                              style: TextStyle(
                                  fontFamily: 'Lato',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          )
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
    UserData? _retrievedUserData = await getUserData();
    UserCredentials? loadedCredentials =
        await UserCredentials.loadCredentials();

    setState(() {
      retrievedUserData = _retrievedUserData;
      if (loadedCredentials != null) {
        email = loadedCredentials.username;
        fetchSkills();
      } else if (retrievedUserData != null) {
        email = retrievedUserData!.email;
        fetchSkills();
      }
    });
  }

  List<TextSpan> highlightMatchedText(String fullText, String query) {
    final lowerFull = fullText.toLowerCase();
    final lowerQuery = query.toLowerCase();

    if (!lowerFull.contains(lowerQuery) || query.isEmpty) {
      return [
        TextSpan(
          text: fullText,
          style: TextStyle(
            fontSize: 14,
            fontFamily: 'Lato',
            color: Color(0xff333333),
          ),
        ),
      ];
    }

    final matchStart = lowerFull.indexOf(lowerQuery);
    final matchEnd = matchStart + query.length;

    return [
      TextSpan(
        text: fullText.substring(0, matchStart),
        style: TextStyle(
          fontSize: 14,
          fontFamily: 'Lato',
          color: Color(0xff333333),
        ),
      ),
      TextSpan(
        text: fullText.substring(matchStart, matchEnd),
        style: TextStyle(
          fontSize: 14,
          fontFamily: 'Lato',
          color: Color(0xFF7D7C7C),
        ),
      ),
      TextSpan(
        text: fullText.substring(matchEnd),
        style: TextStyle(
          fontSize: 14,
          fontFamily: 'Lato',
          color: Color(0xff333333),
        ),
      ),
    ];
  }
}
