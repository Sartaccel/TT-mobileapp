import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  Widget build(BuildContext context) {
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
            color: Color(0xff001B3E),
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            height: 60,
            color: Color(0xff001B3E),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  left: 0,
                  child: Row(
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
                          alignment: Alignment.center,
                          child: Text(
                            'Back',
                            style: TextStyle(
                              fontFamily: 'Lato',
                              fontSize: 14,
                              color: Colors.white,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Center(
                  child: Text(
                    'Notification',
                    style: TextStyle(
                      fontFamily: 'Lato',
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/images/ic_notification_big_1.png',
                    height: 100,
                    width: 100,
                    opacity: AlwaysStoppedAnimation(0.7),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'No Notification',
                    style: TextStyle(
                      color: Color(0xff333333),
                      fontWeight: FontWeight.w700,
                      fontFamily: 'lato',
                      fontSize: 16,
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
