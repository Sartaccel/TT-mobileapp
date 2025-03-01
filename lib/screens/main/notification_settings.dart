import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:talent_turbo_new/AppColors.dart';
import 'package:talent_turbo_new/AppConstants.dart';
import 'package:talent_turbo_new/models/login_data_model.dart';

class NotificationSettings extends StatefulWidget {
  const NotificationSettings({super.key});

  @override
  State<NotificationSettings> createState() => _NotificationSettingsState();
}

class _NotificationSettingsState extends State<NotificationSettings> {
  bool isLoading = true;

  final databaseRef =
      FirebaseDatabase.instance.ref().child(AppConstants.APP_NAME);

  bool pushNotification = false;
  bool emailNotification = false;

  String email = '';

  Future<void> getUserSettings(String email) async {
    final sanitizedEmail = email.replaceAll('.', ',');
    final snapshot =
        await databaseRef.child('$sanitizedEmail/notificationSettings').get();

    setState(() {
      isLoading = true;
    });

    if (snapshot.exists) {
      print('Settings: ${snapshot.value}');

      var snapData = snapshot.value as Map<dynamic, dynamic>;

      setState(() {
        pushNotification = snapData['pushNotification'];
        emailNotification = snapData['emailNotification'];

        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      print('No data found for the user.');
    }
  }

  void updatePushNotificationDb() {
    final sanitizedEmail = email.replaceAll('.', ',');

    databaseRef.child('${sanitizedEmail}/notificationSettings').set({
      'pushNotification': pushNotification,
      'emailNotification': emailNotification
    });
  }

  @override
  Widget build(BuildContext context) {
    // Change the status bar color
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Color(0xff001B3E),
      statusBarIconBrightness: Brightness.light,
    ));
    return Scaffold(
      backgroundColor: Color(0xFFFCFCFC),
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
                SizedBox(
                  width: 80,
                )
              ],
            ),
          ),
          SizedBox(
            height: 20,
          ),
          ListTile(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Push Notifications',
                      style: TextStyle(
                          fontFamily: 'NunitoSans',
                          fontSize: 14,
                          fontWeight: FontWeight.w600),
                    ),
                    Text(
                      'Job alerts, referral updates, messages',
                      style: TextStyle(
                          fontFamily: 'NunitoSans',
                          fontSize: 12,
                          fontWeight: FontWeight.w300),
                    ),
                  ],
                ),
                Switch(
                    value: pushNotification,
                    activeTrackColor: Color(0xFF2563EB),
                    inactiveTrackColor: Color(0xFFD2D5DA),
                    activeColor: Colors.white,
                    inactiveThumbColor: Colors.white,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    trackOutlineColor:
                        WidgetStateProperty.all(Colors.transparent),
                    onChanged: (value) {
                      setState(() {
                        pushNotification = value;

                        updatePushNotificationDb();
                      });
                    })
              ],
            ),
          ),
          Divider(
            color: Color(0xffD9D9D9),
            indent: 15,
            endIndent: 15,
          ),
          ListTile(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Email Notifications',
                      style: TextStyle(
                          fontFamily: 'NunitoSans',
                          fontSize: 14,
                          fontWeight: FontWeight.w600),
                    ),
                    Text(
                      'Job alerts, referral updates, messages',
                      style: TextStyle(
                          fontFamily: 'NunitoSans',
                          fontSize: 12,
                          fontWeight: FontWeight.w300),
                    ),
                  ],
                ),
                Switch(
                    value: emailNotification,
                    activeTrackColor: Color(0xFF2563EB),
                    inactiveTrackColor: Color(0xFFD2D5DA),
                    activeColor: Colors.white,
                    inactiveThumbColor: Colors.white,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    trackOutlineColor:
                        WidgetStateProperty.all(Colors.transparent),
                    onChanged: (value) {
                      setState(() {
                        emailNotification = value;
                        updatePushNotificationDb();
                      });
                    })
              ],
            ),
          ),
          Divider(
            color: Color(0xffD9D9D9),
            indent: 15,
            endIndent: 15,
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            child: Center(
              child: Visibility(
                visible: isLoading,
                child: Column(
                  children: [
                    SizedBox(
                      height: 30,
                    ),
                    LoadingAnimationWidget.fourRotatingDots(
                      color: AppColors.primaryColor,
                      size: 40,
                    ),
                  ],
                ),
              ),
            ),
          ),
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
    UserCredentials? loadedCredentials =
        await UserCredentials.loadCredentials();
    if (loadedCredentials != null) {
      setState(() {
        email = loadedCredentials.username;

        getUserSettings(email);
      });
    }
  }
}
