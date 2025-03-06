import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:talent_turbo_new/screens/main/change_password.dart';
import 'package:talent_turbo_new/screens/main/notification_settings.dart';

class Accountsettings extends StatefulWidget {
  const Accountsettings({super.key});

  @override
  State<Accountsettings> createState() => _AccountsettingsState();
}

class _AccountsettingsState extends State<Accountsettings> {
  @override
  Widget build(BuildContext context) {
    // Change the status bar color
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Color(0xff001B3E),
      statusBarIconBrightness: Brightness.light,
    ));
    return Scaffold(
      backgroundColor: Color(0xffFCFCFC),
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
                  'Account Settings',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    '       ',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
              child: SingleChildScrollView(
                  child: Container(
            padding: EdgeInsets.all(10),
            child: Column(
              children: [
                ListTile(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) =>
                                ChangePassword()));
                  },
                  title: Text('Change Password'),
                  trailing: SvgPicture.asset(
                    'assets/icon/ArrowRight.svg',
                    width: 24,
                    height: 24,
                  ),
                ),
                Divider(
                  color: Color(0xffD9D9D9),
                  indent: 15,
                  endIndent: 15,
                ),
                ListTile(
                  title: Text('Notification Settings'),
                  trailing: SvgPicture.asset(
                    'assets/icon/ArrowRight.svg',
                    width: 24,
                    height: 24,
                  ),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) =>
                                NotificationSettings()));
                  },
                ),
                Divider(
                  color: Color(0xffD9D9D9),
                  indent: 15,
                  endIndent: 15,
                ),
              ],
            ),
          )))
        ],
      ),
    );
  }
}
