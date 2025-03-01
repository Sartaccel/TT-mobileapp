import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MyReferralsFragment extends StatefulWidget {
  const MyReferralsFragment({super.key});

  @override
  State<MyReferralsFragment> createState() => _MyReferralsFragmentState();
}

class _MyReferralsFragmentState extends State<MyReferralsFragment> {
  @override
  Widget build(BuildContext context) {
    // Change the status bar color
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Color(0xff001B3E),
      statusBarIconBrightness: Brightness.light,
    ));
    return Column(
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
                    icon: Container(),
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
                            '',
                            style: TextStyle(
                                fontFamily: 'Lato',
                                fontSize: 16,
                                color: Colors.white),
                          ))))
                ],
              ),
              Text(
                'My Referrals',
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
          child: Center(
            child: Text('No data to show here'),
          ),
        )
        /* Column(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset('assets/images/user_.webp', height: 40, width: 40,),

                    SizedBox(width: 20,),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Kabilan', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),),
                        SizedBox(height: 5,),
                        Text('UI UX Designer | Microsoft', style: TextStyle(fontWeight: FontWeight.w400, fontSize: 14),),
                        SizedBox(height: 5,),
                        Text('Referred date:  01-10-2024', style: TextStyle(fontWeight: FontWeight.w400, fontSize: 14),),
                      ],
                    )
                  ],
                ),

                Icon(Icons.chevron_right, size: 36,)




              ],
            ),),
            Divider()
          ],
        ),*/
      ],
    );
  }
}
