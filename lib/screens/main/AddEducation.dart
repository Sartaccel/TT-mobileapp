import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:talent_turbo_new/AppColors.dart';
import 'package:talent_turbo_new/AppConstants.dart';
import 'package:talent_turbo_new/Utils.dart';
import 'package:talent_turbo_new/models/candidate_profile_model.dart';
import 'package:talent_turbo_new/models/referral_profile_model.dart';
import 'package:talent_turbo_new/models/user_data_model.dart';
import 'package:http/http.dart' as http;
import 'package:talent_turbo_new/screens/main/personal_details.dart';

class Addeducation extends StatefulWidget {
  final educationDetail;
  const Addeducation({super.key, required this.educationDetail});

  @override
  State<Addeducation> createState() => _AddeducationState();
}

class _AddeducationState extends State<Addeducation> {


  bool isEdit = false;

  DateTime startDatems = DateTime.now();

  ReferralData? referralData;
  UserData? retrievedUserData;

  String? _selectedOption = 'No';
  String startYear = '', endYear = '';

  String selectedEducationType = '';
  bool isEducationTypeValid = true;

  bool isStartDateValid = true;
  bool _startDateSelected = false;
  String? startDateErrorMsg = 'Start date cannot be empty';
  final TextEditingController _startDateController = TextEditingController();

  bool isEndDateValid = true;
  String? endDateErrorMsg = 'End date cannot be empty';
  final TextEditingController _endDateController = TextEditingController();

  bool isQualificationValid = true;
  String? qualificationErrorMsg = 'Qualification cannot be empty';
  final TextEditingController txtQualificationController = TextEditingController();

  bool isSpecializationValid = true;
  String? specializationErrorMsg = 'Specialization cannot be empty';
  final TextEditingController txtSpecializationController = TextEditingController();

  bool isInstituteValid = true;
  String? instituteErrorMsg = 'Institute cannot be empty';
  final TextEditingController txtInstituteController = TextEditingController();

  bool isLoading = false;

  DateTime parseDate(String dateString) {
    // Split the date string into its components
    List<String> parts = dateString.split('-');

    // Check if the format is valid
    if (parts.length != 3) {
      throw FormatException('Invalid date format. Use YY-MM-DD.');
    }

    // Parse the year, month, and day
    int year = int.parse(parts[0]);
    int month = int.parse(parts[1]);
    int day = int.parse(parts[2]);

    // If the year is in 2 digits, adjust it to a 4-digit year
    if (year < 100) {
      year += (year < 70) ? 2000 : 1900; // Assuming 00-69 is 21st century and 70-99 is 20th century
    }

    // Return the DateTime object
    return DateTime(year, month, day);
  }

  Future<void> updateEducation() async {
    final url = Uri.parse(AppConstants.BASE_URL + AppConstants.ADD_UPDATE_EDUCATION + retrievedUserData!.profileId.toString() + '/education');

    final bodyParams =
    isEdit ? {
      "candidateEducation": [
        {
          "id" : widget.educationDetail['id'],
          "schoolName": txtInstituteController.text,
          "degree": txtQualificationController.text,
          "city": selectedEducationType,
          "stateName": "TN",
          "year": endYear,
          "countryId": "IN",
          "percentage": 78,
          "specialization": txtSpecializationController.text,
          "graduatedFrom" : _startDateController.text,
          "graduatedTo" : _selectedOption == 'No' ?  _endDateController.text : '1970-01-01'
        }
      ]
    } :
    {
      "candidateEducation": [
        {
          //"id" : 2064,
          "schoolName": txtInstituteController.text,
          "degree": txtQualificationController.text,
          "city": selectedEducationType,
          "stateName": "TN",
          "year": endYear,
          "countryId": "IN",
          "percentage": 78,
          "specialization": txtSpecializationController.text,
          "graduatedFrom" : _startDateController.text,
          "graduatedTo" :_selectedOption == 'No' ?  _endDateController.text : '1970-01-01'
        }
      ]
    };

    try{
 var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      Fluttertoast.showToast(
        msg: "No internet connection",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Color(0xff2D2D2D),
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return;  // Exit the function if no internet
    }
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
        print('Response code ${response.statusCode} :: Response => ${response
            .body}');
      }

      if(response.statusCode == 200 || response.statusCode == 202){
        fetchCandidateProfileData(retrievedUserData!.profileId, retrievedUserData!.token);
      }

      /*setState(() {
        isLoading = false;
      });*/
    }  catch(e){
      setState(() {
        if (kDebugMode) {
          print(e);
        }
        isLoading = false;
      });
    }


  }

  Future<void> fetchCandidateProfileData(int profileId, String token) async {
    //final url = Uri.parse(AppConstants.BASE_URL + AppConstants.REFERRAL_PROFILE + profileId.toString());
    final url = Uri.parse(AppConstants.BASE_URL + AppConstants.CANDIDATE_PROFILE + profileId.toString());



    try {
      setState(() {
        isLoading = true;
      });

      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json', 'Authorization': token},
      );

      if(kDebugMode) {
        print('Response code ${response.statusCode} :: Response => ${response
            .body}');
      }

      if(response.statusCode == 200) {
        var resOBJ = jsonDecode(response.body);

        String statusMessage = resOBJ['message'];

        if(statusMessage.toLowerCase().contains('success')){

          final Map<String, dynamic> data = resOBJ['data'];
          //ReferralData referralData = ReferralData.fromJson(data);
          CandidateProfileModel candidateData = CandidateProfileModel.fromJson(data);

          await saveCandidateProfileData(candidateData);



          /*Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => PersonalDetails()),
                (Route<dynamic> route) => route.isFirst, // This will keep Screen 1
          );*/

          Navigator.pop(context);
          setState(() {
            isLoading = false;
          });
        }

      } else{
        print(response);
        setState(() {
          isLoading = false;
        });
      }


    }
    catch(e){
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: 40,
            decoration: BoxDecoration(color: Color(0xff001B3E)),),
          Container(
            width: MediaQuery.of(context).size.width,
            height: 60,
            decoration: BoxDecoration(color: Color(0xff001B3E)),
            child:
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row( children: [ IconButton(icon:  Icon(Icons.arrow_back_ios_new, color: Colors.white,), onPressed: (){Navigator.pop(context);},), InkWell(onTap: (){Navigator.pop(context);},child: Container(height: 50, child: Center(child: Text('Back', style: TextStyle(fontFamily: 'Lato', fontSize: 16, color: Colors.white),)))) ],),
                //SizedBox(width: 80,)
                Text('Education', style: TextStyle(color: Colors.white, fontSize: 16),),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text('       ', style: TextStyle(color: Colors.white, fontSize: 16),),
                ),
              ],
            ),


          ),

          Expanded(child: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 25,),

                  Text('Qualification', style: TextStyle(fontSize: 14, fontFamily: 'Lato', fontWeight: FontWeight.w500, color: Color(0xff333333)),),
                  SizedBox(height: 10,),
                  Container(
                    width: (MediaQuery.of(context).size.width) - 20,
                    child: TextField(
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')), // Allow only letters and spaces
                      ],
                      controller: txtQualificationController,
                      style: TextStyle(fontSize: 14, fontFamily: 'Lato'),
                      decoration: InputDecoration(
                          hintText: 'Qualification',
                          border: OutlineInputBorder(),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: isQualificationValid ? Colors.grey : Colors.red, // Default border color
                                width: 1
                            ),
                          ),

                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: isQualificationValid ? Colors.blue : Colors.red, // Border color when focused
                                width: 1
                            ),
                          ),

                          errorText: isQualificationValid ? null : qualificationErrorMsg, // Display error message if invalid
                          contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10)
                      ),
                      onChanged: (value) {
                        // Validate the email here and update _isEmailValid
                        setState(() {

                          isQualificationValid = true;

                        });
                      },
                    ),
                  ),


                  SizedBox(height: 25,),
                  Text('Specialization', style: TextStyle(fontSize: 14, fontFamily: 'Lato'),),
                  SizedBox(height: 10,),
                  Container(
                    width: (MediaQuery.of(context).size.width) - 20,
                    child: TextField(
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')), // Allow only letters and spaces
                      ],
                      controller: txtSpecializationController,
                      style: TextStyle(fontSize: 14, fontFamily: 'Lato'),
                      decoration: InputDecoration(
                          hintText: 'Specialization',
                          border: OutlineInputBorder(),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: isSpecializationValid ? Colors.grey : Colors.red, // Default border color
                                width: 1
                            ),
                          ),

                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: isSpecializationValid ? Colors.blue : Colors.red, // Border color when focused
                                width: 1
                            ),
                          ),

                          errorText: isSpecializationValid ? null : specializationErrorMsg, // Display error message if invalid
                          contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10)
                      ),
                      onChanged: (value) {
                        // Validate the email here and update _isEmailValid
                        setState(() {
                          isSpecializationValid = true;
                        });
                      },
                    ),
                  ),

                  SizedBox(height: 25,),
                  Text('Institute name', style: TextStyle(fontSize: 14, fontFamily: 'Lato'),),
                  SizedBox(height: 10,),
                  Container(
                    width: (MediaQuery.of(context).size.width) - 20,
                    child: TextField(
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')), // Allow only letters and spaces
                      ],
                      controller: txtInstituteController,
                      style: TextStyle(fontSize: 14, fontFamily: 'Lato'),
                      decoration: InputDecoration(
                          hintText: 'Institute',
                          border: OutlineInputBorder(),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: isInstituteValid ? Colors.grey : Colors.red, // Default border color
                                width: 1
                            ),
                          ),

                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: isInstituteValid ? Colors.blue : Colors.red, // Border color when focused
                                width: 1
                            ),
                          ),

                          errorText: isInstituteValid ? null : instituteErrorMsg, // Display error message if invalid
                          contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10)
                      ),
                      onChanged: (value) {
                        // Validate the email here and update _isEmailValid
                        setState(() {
                          isInstituteValid = true;
                        });
                      },
                    ),
                  ),

                 SizedBox(height: 20,),
Text('Are you currently studying here?', style: TextStyle(fontSize: 14, fontFamily: 'Lato'),),
SizedBox(height: 10,),
Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Radio<String>(
          value: 'Yes',
          groupValue: _selectedOption,
          onChanged: (value) {
            setState(() {
              _selectedOption = value;
              isEndDateValid = true;
              _endDateController.text = ''; // Reset the end date field
            });
          },
        ),
        Text('Yes', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, fontFamily: 'Lato'),),
      ],
    ),
    SizedBox(width: 20),
    Row(
      children: [
        Radio<String>(
          value: 'No',
          groupValue: _selectedOption,
          onChanged: (value) {
            setState(() {
              isEndDateValid = true;
              _selectedOption = value;
            });
          },
        ),
        Text('No', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, fontFamily: 'Lato'),),
      ],
    ),
    SizedBox(width: 80),
  ],
),

SizedBox(height: 25,),
Row(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Start Date', style: TextStyle(fontSize: 14, fontFamily: 'Lato'),),
          SizedBox(height: 10,),
          TextField(
            controller: _startDateController,
            decoration: InputDecoration(
               suffixIcon: Icon(Icons.calendar_today),
                hintText: 'From',
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: isStartDateValid ? Colors.grey : Colors.red, // Default border color
                      width: 1
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: isStartDateValid ? Colors.blue : Colors.red, // Border color when focused
                      width: 1
                  ),
                ),
                errorText: isStartDateValid ? null : startDateErrorMsg, // Display error message if invalid
                contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10)
            ),
            readOnly: true,
            onTap: () async {
              DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now().subtract(Duration(days: 1)),
                firstDate: DateTime(2000),
                lastDate: DateTime.now().subtract(Duration(days: 1)),
                initialDatePickerMode: DatePickerMode.year
              );
              if (pickedDate != null) {
                setState(() {
                  startDatems = pickedDate;
                   isStartDateValid = true;
                  _startDateSelected = true;
                  _startDateController.text = "${pickedDate.year}-${pickedDate.month}-${pickedDate.day}";
                  startYear = pickedDate.year.toString();
                });
              }
            },
          ),
        ],
      ),
    ),
    SizedBox(width: 10), // Space between the two fields
    Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('End Date', style: TextStyle(fontSize: 14, fontFamily: 'Lato'),),
          SizedBox(height: 10,),
          TextField(
            controller: _endDateController,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
              hintText: 'To', // Display 'To' for both Yes and No
              suffixIcon: Icon(Icons.calendar_today),
              border: OutlineInputBorder(),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: isEndDateValid ? Colors.grey : Colors.red, // Default border color
                    width: 1
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: isEndDateValid ? Colors.blue : Colors.red, // Border color when focused
                    width: 1
                ),
              ),
              errorText: isEndDateValid ? null : endDateErrorMsg,
            ),
            readOnly: false, // Allow manual input for both Yes and No
            onChanged: (text) {
              // Update validation based on input
              setState(() {
                isEndDateValid = text.isNotEmpty;
              });
            },
            onTap: _selectedOption == 'No' && _startDateSelected == true
                ? () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: startDatems,
                      firstDate: startDatems,
                      lastDate: DateTime.now(),
                      initialDatePickerMode: DatePickerMode.year
                    );
                    if (pickedDate != null) {
                      setState(() {
                        isEndDateValid = true;
                        _endDateController.text = "${pickedDate.year}-${pickedDate.month}-${pickedDate.day}";
                        endYear = pickedDate.year.toString();
                      });
                    }
                  }
                : null, // Allow manual input without picking a date when 'Yes' is selected
          ),
        ],
      ),
    ),
  ],
),


                  SizedBox(height: 25,),
                  Text('Education type', style: TextStyle(fontSize: 14, fontFamily: 'Lato'),),
                  SizedBox(height: 10,),
                  Container(
                    height: 50,
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(border: Border.all(width: 1, color: isEducationTypeValid? Color(0xffD9D9D9) : Colors.red),
                      borderRadius: BorderRadius.circular(10)
                    ),
                    width: (MediaQuery.of(context).size.width) - 20,
                    child: InkWell(
                      onTap: (){
                        showMaterialModalBottomSheet(
                          isDismissible: true,
                          context: context,
                          builder: (context) =>
                              Container(
                                padding: EdgeInsets.symmetric(vertical: 30, horizontal: 10),
                                width: MediaQuery.of(context).size.width,
                                child: Column(

                                  mainAxisSize: MainAxisSize.min,
                                  children: [

                                    ListTile(
                                      //leading: Icon(Icons.visibility_outlined),
                                      title: Text('Full time'),
                                      onTap: (){
                                        setState(() {
                                          selectedEducationType  = 'Full time';
                                          isEducationTypeValid = true;
                                        });
                                        Navigator.pop(context);
                                      },
                                    ),
                                    ListTile(
                                      //leading: Icon(Icons.refresh),
                                      title: Text('Part time'),
                                      onTap: (){
                                        setState(() {
                                          selectedEducationType  = 'Part time';
                                          isEducationTypeValid = true;
                                        });
                                        Navigator.pop(context);
                                      },
                                    ),
                                    ListTile(
                                      //leading: Icon(Icons.download),
                                      title: Text('Correspondence'),
                                      onTap: (){
                                        setState(() {
                                          selectedEducationType  = 'Correspondence';
                                          isEducationTypeValid = true;
                                        });
                                        Navigator.pop(context);
                                      },
                                    ),

                                  ],
                                ),
                              ),
                        );
                      },
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text( selectedEducationType.isEmpty? 'Select your education type' : selectedEducationType, style: TextStyle(color: Color(0xff7D7C7C)),),
                      ),
                    ),
                  ),

                  Visibility(
                      visible: !isEducationTypeValid,
                      child: Column(
                    children: [
                      SizedBox(height: 10,),
                      Text('        Education type cannot be empty', style: TextStyle(color: Colors.red, fontSize: 12),),
                    ],
                  )),

                  isLoading? Container(
                    width: MediaQuery.of(context).size.width,
                    child: Center(
                      child: Visibility(
                        visible: isLoading,
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
                  ) : Container(),

                  SizedBox(height: 25,),
                  InkWell(
                    onTap: (){

                      if( (_selectedOption=='No' && _endDateController.text.isEmpty) || txtQualificationController.text.isEmpty || txtSpecializationController.text.isEmpty || txtInstituteController.text.isEmpty || _startDateController.text.isEmpty){

                        if(txtQualificationController.text.isEmpty){
                          setState(() {
                            isQualificationValid = false;
                          });
                        }

                        if(txtSpecializationController.text.isEmpty){
                          setState(() {
                            isSpecializationValid = false;
                          });
                        }

                        if(txtInstituteController.text.isEmpty){
                          setState(() {
                            isInstituteValid = false;
                          });
                        }

                        if(_startDateController.text.isEmpty){
                          setState(() {
                            isStartDateValid = false;
                          });
                        }

                        if(_selectedOption=='No' && _endDateController.text.isEmpty){
                          setState(() {
                            isEndDateValid = false;
                          });
                        }

                        if(selectedEducationType.isEmpty){
                          setState(() {
                            isEducationTypeValid = false;
                          });
                        }

                      }
                      else{
                        if(kDebugMode){
                          print('Performing operation................');

                        }

                        if(isLoading == false) {
                          updateEducation();
                        }

                      }

                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: 44,
                      margin: EdgeInsets.symmetric(horizontal: 0),
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(color: AppColors.primaryColor ,borderRadius: BorderRadius.circular(10)),
                      child: Center(child: Text('Save', style: TextStyle(color: Colors.white),),),
                    ),
                  )
                ],
              ),
            ),
          ))

        ],
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchProfileFromPref();

    if(widget.educationDetail != null){

      setState(() {
        isEdit = true;
        txtQualificationController.text = widget.educationDetail['degree'];
        txtSpecializationController.text = widget.educationDetail['specialization'];
        txtInstituteController.text = widget.educationDetail['schoolName'];
        _startDateController.text = widget.educationDetail['graduatedFrom']?? '';
        _selectedOption = widget.educationDetail['graduatedTo'] == '1970-01-01' ? 'Yes' : 'No';
        _endDateController.text = widget.educationDetail['graduatedTo'] == '1970-01-01' ? '' : widget.educationDetail['graduatedTo'] ?? '';
        isStartDateValid = true;
        isEndDateValid = true;
        _startDateSelected = true;
        startDatems = parseDate(widget.educationDetail['graduatedFrom']?? '1970-01-01');
        selectedEducationType = widget.educationDetail['city'];

      });

    }

  }

  Future<void> fetchProfileFromPref() async {
    ReferralData? _referralData = await getReferralProfileData();
    UserData? _retrievedUserData = await getUserData();
    setState(() {
      referralData = _referralData;
      retrievedUserData = _retrievedUserData;
    });
  }

}
