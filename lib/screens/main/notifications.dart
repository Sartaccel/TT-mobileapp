import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  Widget build(BuildContext context) {
    // Change the status bar color
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Color(0xff001B3E),
      statusBarIconBrightness: Brightness.light,
    ));
    return Scaffold(
        body: Column(children: [
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
                        )))),
              ],
            ),
            Text(
              'Notification',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                '                ',
                style: TextStyle(color: Colors.white, fontSize: 16),
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
            //SvgPicture.asset('assets/images/ic_notification_big.svg', height: 100, width: 100),
            SizedBox(
              height: 10,
            ),
            Text(
              'No notification',
              style: TextStyle(
                  color: Color(0xff333333),
                  fontWeight: FontWeight.w700,
                  fontSize: 16),
            )
          ],
        ),
      ))
    ]));
  }
}
