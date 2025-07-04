import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:talent_turbo_new/AppColors.dart';
import 'package:talent_turbo_new/Utils.dart';

class JobSearchFilter extends StatefulWidget {
  const JobSearchFilter({super.key});

  @override
  State<JobSearchFilter> createState() => _JobSearchFilterState();
}

class _JobSearchFilterState extends State<JobSearchFilter> {
  bool _isFullTimeSelected = false;
  bool _isContractSelected = false;
  bool _isInternshipSelected = false;

  bool _isLoading = false;

  String selectedExpType = '';
  String? selectedEmpType = '';

  @override
  Widget build(BuildContext context) {
    // Change the status bar color
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Color(0xff001B3E),
      statusBarIconBrightness: Brightness.light,
    ));

    Future<void> clearFilter() async {
      setState(() {
        _isLoading = true;
        _isFullTimeSelected = false;
        _isContractSelected = false;
        _isInternshipSelected = false;
        selectedExpType = '';
        selectedEmpType = '';
      });

      await saveStringToPreferences("searchEmpType", "");
      await saveStringToPreferences("searchExp", "");
      await saveEmploymentTypeToPrefs(false, false, false);

      setState(() {
        _isLoading = false;
      });
    }

    void resetExperience() {
      setState(() {
        selectedExpType = '';
      });
      saveStringToPreferences("searchExp", "");
    }

    return Scaffold(
      backgroundColor: Color(0xffFCFCFC),
      body: Column(
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
                  'Filter',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                InkWell(
                    onTap: () {
                      clearFilter();
                    },
                    child: Text(
                      'Reset        ',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ))
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10),
                Text(
                  'Employment Type:',
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Color(0xff333333),
                      fontFamily: 'Lato',
                      fontSize: 18),
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Transform.scale(
                      scale: 1.5,
                      child: Checkbox(
                          value: _isFullTimeSelected,
                          activeColor: AppColors.primaryColor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5)),
                          side: BorderSide(width: 1, color: Color(0xffD1D1D6)),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          onChanged: (bool? value) {
                            setState(() {
                              _isFullTimeSelected = value!;
                              saveEmploymentTypeToPrefs(_isFullTimeSelected,
                                  _isContractSelected, _isInternshipSelected);
                            });
                          }),
                    ),
                    const SizedBox(width: 7),
                    const Text(
                      'Full time',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                SizedBox(height: 0),
                Row(
                  children: [
                    Transform.scale(
                      scale: 1.5,
                      child: Checkbox(
                          value: _isContractSelected,
                          activeColor: AppColors.primaryColor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5)),
                          side: BorderSide(width: 1, color: Color(0xffD1D1D6)),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          onChanged: (bool? value) {
                            setState(() {
                              _isContractSelected = value!;
                              saveEmploymentTypeToPrefs(_isFullTimeSelected,
                                  _isContractSelected, _isInternshipSelected);
                            });
                          }),
                    ),
                    const SizedBox(width: 7),
                    const Text(
                      'Contract',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                SizedBox(height: 0),
                Row(
                  children: [
                    Transform.scale(
                      scale: 1.5,
                      child: Checkbox(
                          value: _isInternshipSelected,
                          activeColor: AppColors.primaryColor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5)),
                          side: BorderSide(width: 1, color: Color(0xffD1D1D6)),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          onChanged: (bool? value) {
                            setState(() {
                              _isInternshipSelected = value!;
                              saveEmploymentTypeToPrefs(_isFullTimeSelected,
                                  _isContractSelected, _isInternshipSelected);
                            });
                          }),
                    ),
                    const SizedBox(width: 7),
                    const Text(
                      'Internship',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                Divider(),
                SizedBox(height: 10),
                Text(
                  'Experience:',
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Color(0xff333333),
                      fontFamily: 'Lato',
                      fontSize: 18),
                ),
                SizedBox(height: 20),
                Container(
                  height: 50,
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    border: Border.all(width: 1, color: Color(0xffD9D9D9)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  width: MediaQuery.of(context).size.width - 20,
                  child: InkWell(
                    onTap: () {
                      showMaterialModalBottomSheet(
                        backgroundColor: Colors.transparent,
                        isDismissible: true,
                        context: context,
                        builder: (context) {
                          ScrollController scrollController =
                              ScrollController();
                          return Container(
                            height: MediaQuery.of(context).size.height * 0.365,
                            padding:
                                EdgeInsets.only(top: 30, left: 10, right: 10),
                            decoration: BoxDecoration(
                              color: Color(0xffFCFCFC),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(25),
                                topRight: Radius.circular(25),
                              ),
                            ),
                            width: MediaQuery.of(context).size.width,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.25,
                                  height: 5,
                                  decoration: BoxDecoration(
                                    color: Color(0xff333333),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                SizedBox(height: 10),
                                Expanded(
                                  child: Padding(
                                    padding:
                                        EdgeInsets.only(bottom: 20, right: 10),
                                    child: Scrollbar(
                                      controller: scrollController,
                                      thumbVisibility: true,
                                      trackVisibility: true,
                                      thickness: 5,
                                      radius: Radius.circular(10),
                                      child: Theme(
                                        data: Theme.of(context).copyWith(
                                          scrollbarTheme: ScrollbarThemeData(
                                            thumbColor: WidgetStateProperty.all(
                                                Color(0xff545454)),
                                            trackColor: WidgetStateProperty.all(
                                                Color(0xffD9D9D9)),
                                          ),
                                        ),
                                        child: SingleChildScrollView(
                                          controller: scrollController,
                                          child: Column(
                                            children:
                                                List.generate(11, (index) {
                                              String label = index == 0
                                                  ? "Fresher"
                                                  : index == 10
                                                      ? "10+ Years"
                                                      : "$index ${index > 1 ? 'Years' : 'Year'}";
                                              return ListTile(
                                                title: Text(label),
                                                onTap: () {
                                                  setState(() {
                                                    selectedExpType =
                                                        index.toString();
                                                    saveStringToPreferences(
                                                        "searchExp",
                                                        index.toString());
                                                  });
                                                  Navigator.pop(context);
                                                },
                                              );
                                            }),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          selectedExpType.isEmpty
                              ? 'Choose Experience'
                              : selectedExpType == "0"
                                  ? "Fresher"
                                  : selectedExpType == "10"
                                      ? "10+ Years"
                                      : '${selectedExpType} ${int.parse(selectedExpType) > 1 ? 'Years' : 'Year'}',
                          style: TextStyle(color: Color(0xff545454)),
                        ),
                        if (selectedExpType.isNotEmpty)
                          GestureDetector(
                            onTap: resetExperience,
                            child: Container(
                              padding: EdgeInsets.all(4),
                              child: SvgPicture.asset(
                                'assets/images/ic_close_vector.svg',
                                height: 16,
                                width: 16,
                                color: Color(0xff545454),
                                placeholderBuilder: (BuildContext context) =>
                                    Icon(
                                  Icons.close,
                                  size: 16,
                                  color: Color(0xff545454),
                                ),
                              ),
                            ),
                          )
                        else
                          SvgPicture.asset('assets/icon/ArrowDown.svg',
                              height: 10, width: 10),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 30),
                InkWell(
                  onTap: () async {
                    setState(() {
                      _isLoading = true;
                    });

                    await saveStringToPreferences(
                        "searchEmpType", getSelectedEmploymentTypes());
                    if (selectedExpType.isNotEmpty) {
                      await saveStringToPreferences(
                          "searchExp", selectedExpType);
                    } else {
                      await saveStringToPreferences("searchExp", "");
                    }

                    setState(() {
                      _isLoading = false;
                    });

                    Navigator.pop(context);
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: 44,
                    margin: EdgeInsets.symmetric(horizontal: 0),
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                        color: AppColors.primaryColor,
                        borderRadius: BorderRadius.circular(10)),
                    child: Center(
                      child: _isLoading
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
                                      backgroundColor: const Color.fromARGB(
                                          142, 234, 232, 232),
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                    ),
                                  );
                                },
                                onEnd: () => {},
                              ),
                            )
                          : Text(
                              'Filter',
                              style: TextStyle(color: Colors.white),
                            ),
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Future<void> saveEmploymentTypeToPrefs(
      bool fullTime, bool contract, bool internship) async {
    await saveStringToPreferences("isFullTimeSelected", fullTime.toString());
    await saveStringToPreferences("isContractSelected", contract.toString());
    await saveStringToPreferences(
        "isInternshipSelected", internship.toString());
  }

  Future<void> loadEmploymentTypeFromPrefs() async {
    String? fullTime = await getStringFromPreferences("isFullTimeSelected");
    String? contract = await getStringFromPreferences("isContractSelected");
    String? internship = await getStringFromPreferences("isInternshipSelected");

    setState(() {
      _isFullTimeSelected = fullTime == "true";
      _isContractSelected = contract == "true";
      _isInternshipSelected = internship == "true";
    });
  }

  String getSelectedEmploymentTypes() {
    List<String> types = [];
    if (_isFullTimeSelected) types.add("Full time");
    if (_isContractSelected) types.add("Contract");
    if (_isInternshipSelected) types.add("Internship");
    return types.join(", ");
  }

  @override
  void initState() {
    super.initState();
    fetchProfileFromPref();
    loadEmploymentTypeFromPrefs();
  }

  Future<void> fetchProfileFromPref() async {
    String? pref_emp_filt = await getStringFromPreferences("searchEmpType");
    selectedEmpType = pref_emp_filt ?? '';

    String? pref_filt = await getStringFromPreferences("searchExp");
    selectedExpType = pref_filt ?? '';

    setState(() {});
  }
}
