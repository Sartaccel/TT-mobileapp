import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:talent_turbo_new/screens/main/home_container.dart';

class Companydetails extends StatefulWidget {
  const Companydetails({super.key});

  @override
  State<Companydetails> createState() => _CompanydetailsState();
}

class _CompanydetailsState extends State<Companydetails> {
  @override
  Widget build(BuildContext context) {
    // Change the status bar color
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Color(0xff001B3E),
      statusBarIconBrightness: Brightness.light,
    ));
    return Scaffold(
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
                Text(
                  'Company Details',
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(color: Colors.white),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Image.asset(
                            'assets/images/bmw_logo.png',
                            height: 41,
                            width: 41,
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Bayerische Motoren Werke AG',
                                style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontFamily: 'Lato',
                                    fontSize: 20,
                                    color: Color(0xff333333)),
                              ),
                              SizedBox(
                                height: 3,
                              ),
                              Text(
                                'Motor Vehicle Manufacturing',
                                style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontFamily: 'Lato',
                                    fontSize: 14,
                                    color: Color(0xff545454)),
                              ),
                              SizedBox(
                                height: 3,
                              ),
                              Row(
                                children: [
                                  Icon(
                                    Icons.insert_link,
                                    color: Color(0xff2979FF),
                                    size: 18,
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    'www.bmw.com',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontFamily: 'Lato',
                                        fontSize: 13,
                                        color: Color(0xff2979FF)),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(color: Colors.white),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'About Company:',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xff333333),
                            fontSize: 16),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        'With its four brands BMW, MINI, Rolls-Royce and BMW Motor rad, the BMW Group is the world’s leading premium manufacturer of automobiles and motorcycles and also provides premium financial and mobility services. The BMW Group production network comprises over 30 production sites worldwide; the company has a global sales network in more than 140 countries.',
                        style: TextStyle(
                            fontSize: 16,
                            color: Color(0xff333333),
                            height: 1.5),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                    ],
                  ),
                ),
                Container(
                    margin: EdgeInsets.symmetric(horizontal: 15),
                    child: InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      HomeContainer()));
                        },
                        child: Text(
                          'Similar jobs',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: Color(0xff333333)),
                        ))),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 5),
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                      border: Border.all(width: 0.2, color: Colors.grey),
                      color: Colors.white),
                  width: MediaQuery.of(context).size.width,
                  height: 160,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset(
                        'assets/images/ic_comp_logo.png',
                        height: 32,
                        width: 32,
                      ),
                      SizedBox(
                        width: 15,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'UI UX Designer',
                            style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Lato',
                                fontSize: 16,
                                color: Color(0xff333333)),
                          ),
                          Text(
                            'PUMA',
                            style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontFamily: 'Lato',
                                fontSize: 13,
                                color: Color(0xff545454)),
                          ),
                          Row(
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
                              Text(
                                'Skills : Interaction Design · User Research +5',
                                style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 14,
                                    color: Color(0xff545454)),
                              ),
                            ],
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
                                    'Full time',
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
                              Row(
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
                                  Text(
                                    'Milpitas, CA  (On-Site)',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 14,
                                        color: Color(0xff545454)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Text(
                            '17 days ago',
                            style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 14,
                                color: Color(0xff545454)),
                          )
                        ],
                      ),
                      Icon(
                        Icons.bookmark_border_rounded,
                        size: 25,
                      )
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 5),
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                      border: Border.all(width: 0.2, color: Colors.grey),
                      color: Colors.white),
                  width: MediaQuery.of(context).size.width,
                  height: 160,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset(
                        'assets/images/ic_comp_logo.png',
                        height: 32,
                        width: 32,
                      ),
                      SizedBox(
                        width: 15,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'UI UX Designer',
                            style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Lato',
                                fontSize: 16,
                                color: Color(0xff333333)),
                          ),
                          Text(
                            'PUMA',
                            style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontFamily: 'Lato',
                                fontSize: 13,
                                color: Color(0xff545454)),
                          ),
                          Row(
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
                              Text(
                                'Skills : Interaction Design · User Research +5',
                                style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 14,
                                    color: Color(0xff545454)),
                              ),
                            ],
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
                                    'Full time',
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
                              Row(
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
                                  Text(
                                    'Milpitas, CA  (On-Site)',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 14,
                                        color: Color(0xff545454)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Text(
                            '17 days ago',
                            style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 14,
                                color: Color(0xff545454)),
                          )
                        ],
                      ),
                      Icon(
                        Icons.bookmark_border_rounded,
                        size: 25,
                      )
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 5),
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                      border: Border.all(width: 0.2, color: Colors.grey),
                      color: Colors.white),
                  width: MediaQuery.of(context).size.width,
                  height: 160,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset(
                        'assets/images/ic_comp_logo.png',
                        height: 32,
                        width: 32,
                      ),
                      SizedBox(
                        width: 15,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'UI UX Designer',
                            style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Lato',
                                fontSize: 16,
                                color: Color(0xff333333)),
                          ),
                          Text(
                            'PUMA',
                            style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontFamily: 'Lato',
                                fontSize: 13,
                                color: Color(0xff545454)),
                          ),
                          Row(
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
                              Text(
                                'Skills : Interaction Design · User Research +5',
                                style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 14,
                                    color: Color(0xff545454)),
                              ),
                            ],
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
                                    'Full time',
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
                              Row(
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
                                  Text(
                                    'Milpitas, CA  (On-Site)',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 14,
                                        color: Color(0xff545454)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Text(
                            '17 days ago',
                            style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 14,
                                color: Color(0xff545454)),
                          )
                        ],
                      ),
                      Icon(
                        Icons.bookmark_border_rounded,
                        size: 25,
                      )
                    ],
                  ),
                ),
              ],
            ),
          ))
        ],
      ),
    );
  }
}
