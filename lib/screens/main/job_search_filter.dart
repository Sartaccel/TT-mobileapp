import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  String? selectedEmpType = 'Full time';

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
      });

      _isFullTimeSelected = false;
      _isContractSelected = false;
      _isInternshipSelected = false;
      selectedExpType = '';
      selectedEmpType = '';

      await saveStringToPreferences("searchEmpType", "");
      await saveStringToPreferences("searchExp", '0');

      setState(() {
        _isLoading = false;
      });
    }

    return Scaffold(
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
                //SizedBox(width: 80,)
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
            padding: EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 10,
                ),
                Text(
                  'Employment Type:',
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Color(0xff333333),
                      fontFamily: 'Lato',
                      fontSize: 18),
                ),
                SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.all(0.0),
                  child: Row(
                    children: [
                      Radio(
                          value: 'Full time',
                          activeColor: AppColors.primaryColor,
                          groupValue: selectedEmpType,
                          onChanged: (val) {
                            setState(() {
                              selectedEmpType = val;
                              saveStringToPreferences(
                                  "searchEmpType", selectedEmpType!);
                            });
                          }),
                      const Text(
                        'Full time',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 0,
                ),
                Row(
                  children: [
                    Radio(
                        value: 'Contract',
                        activeColor: AppColors.primaryColor,
                        groupValue: selectedEmpType,
                        onChanged: (val) {
                          setState(() {
                            selectedEmpType = val;
                            saveStringToPreferences(
                                "searchEmpType", selectedEmpType!);
                          });
                        }),
                    const Text(
                      'Contract',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                SizedBox(
                  height: 0,
                ),
                Padding(
                  padding: const EdgeInsets.all(0.0),
                  child: Row(
                    children: [
                      Radio(
                          value: 'Internship',
                          activeColor: AppColors.primaryColor,
                          groupValue: selectedEmpType,
                          onChanged: (val) {
                            setState(() {
                              selectedEmpType = val;
                              saveStringToPreferences(
                                  "searchEmpType", selectedEmpType!);
                            });
                          }),
                      const Text(
                        'Internship',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
                Divider(),
                SizedBox(
                  height: 10,
                ),
                Text(
                  'Experience:',
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Color(0xff333333),
                      fontFamily: 'Lato',
                      fontSize: 18),
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                  height: 50,
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                      border: Border.all(width: 1, color: Color(0xffD9D9D9)),
                      borderRadius: BorderRadius.circular(10)),
                  width: (MediaQuery.of(context).size.width) - 20,
                  child: InkWell(
                    onTap: () {
                      showMaterialModalBottomSheet(
                        isDismissible: true,
                        context: context,
                        builder: (context) => Container(
                          padding: EdgeInsets.symmetric(
                              vertical: 30, horizontal: 10),
                          width: MediaQuery.of(context).size.width,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                //leading: Icon(Icons.visibility_outlined),
                                title: Text('Fresher'),
                                onTap: () {
                                  setState(() {
                                    selectedExpType = 'Fresher';
                                    saveStringToPreferences("searchExp", '0');
                                  });
                                  Navigator.pop(context);
                                },
                              ),
                              ListTile(
                                //leading: Icon(Icons.visibility_outlined),
                                title: Text('1 Year'),
                                onTap: () {
                                  setState(() {
                                    selectedExpType = '1 Year';
                                    saveStringToPreferences("searchExp", '1');
                                  });
                                  Navigator.pop(context);
                                },
                              ),
                              ListTile(
                                //leading: Icon(Icons.visibility_outlined),
                                title: Text('2 Years'),
                                onTap: () {
                                  setState(() {
                                    selectedExpType = '2 Years';
                                    saveStringToPreferences("searchExp", '2');
                                  });
                                  Navigator.pop(context);
                                },
                              ),
                              ListTile(
                                //leading: Icon(Icons.visibility_outlined),
                                title: Text('3 Years'),
                                onTap: () {
                                  setState(() {
                                    selectedExpType = '3 Years';
                                    saveStringToPreferences("searchExp", '3');
                                  });
                                  Navigator.pop(context);
                                },
                              ),
                              ListTile(
                                //leading: Icon(Icons.visibility_outlined),
                                title: Text('4 Years'),
                                onTap: () {
                                  setState(() {
                                    selectedExpType = '4 Years';
                                    saveStringToPreferences("searchExp", '4');
                                  });
                                  Navigator.pop(context);
                                },
                              ),
                              ListTile(
                                //leading: Icon(Icons.visibility_outlined),
                                title: Text('5 Years'),
                                onTap: () {
                                  setState(() {
                                    selectedExpType = '5 Years';
                                    saveStringToPreferences("searchExp", '5');
                                  });
                                  Navigator.pop(context);
                                },
                              ),
                              /*ListTile(
                                    //leading: Icon(Icons.visibility_outlined),
                                    title: Text('6 Years'),
                                    onTap: (){
                                      setState(() {
                                        selectedExpType  = '6 Years';
                                      });
                                      Navigator.pop(context);
                                    },
                                  ),
                                  ListTile(
                                    //leading: Icon(Icons.visibility_outlined),
                                    title: Text('7 Years'),
                                    onTap: (){
                                      setState(() {
                                        selectedExpType  = '7 Years';
                                      });
                                      Navigator.pop(context);
                                    },
                                  ),
                                  ListTile(
                                    //leading: Icon(Icons.visibility_outlined),
                                    title: Text('8 Years'),
                                    onTap: (){
                                      setState(() {
                                        selectedExpType  = '8 Years';
                                      });
                                      Navigator.pop(context);
                                    },
                                  ),
                                  ListTile(
                                    //leading: Icon(Icons.visibility_outlined),
                                    title: Text('9 Years'),
                                    onTap: (){
                                      setState(() {
                                        selectedExpType  = '9 Years';
                                      });
                                      Navigator.pop(context);
                                    },
                                  ),
                                  ListTile(
                                    //leading: Icon(Icons.visibility_outlined),
                                    title: Text('10 Years'),
                                    onTap: (){
                                      setState(() {
                                        selectedExpType  = '10 Years';
                                      });
                                      Navigator.pop(context);
                                    },
                                  ),*/
                            ],
                          ),
                        ),
                      );
                    },
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        selectedExpType.isEmpty
                            ? 'Choose Experience'
                            : selectedExpType == "0"
                                ? "Fresher"
                                : '${selectedExpType}',
                        style: TextStyle(color: Color(0xff7D7C7C)),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                _isLoading
                    ? Center(
                        child: LoadingAnimationWidget.fourRotatingDots(
                          color: AppColors.primaryColor,
                          size: 40,
                        ),
                      )
                    : Container(),
                SizedBox(
                  height: 30,
                ),
                InkWell(
                  onTap: () {
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
                      child: Text(
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchProfileFromPref();
  }

  Future<void> fetchProfileFromPref() async {
    String? pref_emp_filt = await getStringFromPreferences("searchEmpType");
    selectedEmpType = pref_emp_filt ?? '';

    String? pref_filt = await getStringFromPreferences("searchExp");
    selectedExpType = pref_filt ?? '';

    if (selectedExpType == "0") {
      selectedExpType = "Fresher";
    } else if (selectedExpType == '1') {
      selectedExpType = selectedExpType + ' year';
    } else {
      selectedExpType = selectedExpType + ' years';
    }

    setState(() {});
  }
}
