import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';
import 'package:talent_turbo_new/AppColors.dart';
import 'package:talent_turbo_new/Utils.dart';

class Searchandfilter extends StatefulWidget {
  const Searchandfilter({super.key});

  @override
  State<Searchandfilter> createState() => _SearchandfilterState();
}

class _SearchandfilterState extends State<Searchandfilter> {
  final List<String> jobSuggestions = [
    " Automation Engineer",
    ".Net Core Developer",
    "123346",
    "28 july job",
    "8 december",
    "activity job",
    "Admin ",
    "AEM Developer",
    "Ajace Pubic Job",
    "analyst",
    "Andriod Developer",
    "Android developer",
    "Android Game Developer",
    "angular",
    "Angular 4",
    "Angular Developer",
    "Apache Spark",
    "App Developer",
    "Application Developer",
    "Asp Dot Net Developer",
    "ASP NET Developer",
    "Assistance Manager Post",
    "assistant",
    "Associate Software Engineer",
    "Automation Manager",
    "Automation Technical Manager",
    "AWS engineer",
    "Aws load engineer",
    "Back End Java Developer/Architect/Lead",
    "Backup And Storage",
    "balu private job",
    "balu public job",
    "Banking Manager",
    "Big data Analyst",
    "Big Data Developer",
    "Bigdata analyst",
    "BPO Job",
    "Busineess Analyst",
    "Business Analyst",
    "Business architect",
    "Business Consultant",
    "Business Consulting-Technology Risk",
    "Business Consulting-Technology Risk-Staff ",
    "C# Senior Developer",
    "Chief information officer",
    "Chief Legal Officer",
    "Clerk",
    "cli testing job",
    "Client Technology- QA Engineer1",
    "Cloud Architect",
    "Cloud Architect - AWS",
    "Cloud Automation Engineer ",
    "Cloud Migration Engineer",
    "Computer and information systems managers",
    "Core Java with Angular JS Developer",
    "customer support associate",
    "Customer Support Associate - [JOB_001_1680]",
    "D",
    "Data Analysis and Design",
    "Data Analyst",
    "Data Engineer",
    "Data Entry",
    "Data Project Manager",
    "Data Scientist",
    "Data Tester Interns",
    "Database analyst",
    "Delphi Lead",
    "designer",
    "Developer",
    "Developer Android And IOS",
    "Development head",
    "Development Manager",
    "Devops",
    "Devops Programmer",
    "dfdfdfdf",
    "Director",
    "Doctor",
    "DOT Developer",
    "Dot Net Angular Job",
    "Dot Net MVC",
    "Dot Net Senior Developer",
    "Embedded Software Developer",
    "Embedded Software Engineer",
    "Embedded SW",
    "Enterprise Cloud Engineer/DataArchitect",
    "ETL Developer",
    "ETL Tester",
    "fddgasd",
    "Flutter developer",
    "FrontEnd Developer",
    "Full Stack Developer",
    "Full Stack Engineer",
    "General Manager post",
    "Graphic Designer",
    "Graphics Designer",
    "Harry C. Dobson Jr.",
    "hhhhhhhhhhhhh",
    "HTML Developer",
    "IOS Developer",
    "IT Manager",
    "IT Marketing",
    "IT Project Manager",
    "IT Solution Architect",
    "Java Architect",
    "Java Cloud Developer",
    "Java Dev",
    "JAVA developer",
    "Java developer Level I",
    "Java Full Stack Developer",
    "Java Test Developer",
    "Job -kader",
    "Job1 -kader",
    "Job2 -kader",
    "Job3 -kader",
    "Job4 -kader",
    "junior analyst",
    "Junior Architect",
    "Junior Developer",
    "Junior Software Engineer",
    "Junior Technical Assistant",
    "Junior Technical Assistant -IV",
    "JUnit Test Engineer",
    "Kala Test ",
    "karthihayan dev job",
    "karthihayantestjob",
    "kkkkkkkkkkkkkkkkkkkh",
    "Lead I Software Testing",
    "Lead Java Developer ",
    "Lead OpenShift Engineer",
    "Lead Production unit",
    "Lead QA",
    "lead Tech",
    "Manager",
    "Marketing Executive",
    "MJ Javaid",
    "Mobile App Developers",
    "monday20dec",
    "my job checking",
    "my new job",
    "my new job4",
    "Network architect",
    "Network Engineer",
    "New Job",
    "new job 1",
    "new job 4555",
    "new job pvt",
    "new job test",
    "New Job23",
    "new job3",
    "new job40",
    "new job54",
    "new jobzz",
    "New Test Job",
    "New Test Job23",
    "newjob",
    "NewJob320",
    "NewJobss",
    "Next.js Developer",
    "Nodejs developer",
    "Performance Tester ",
    "private karthi job",
    "Program Manager",
    "Project Lead",
    "Project Manager",
    "Project Manager/Program Manager",
    "Public Job - Dot NEt",
    "public jon",
    "Python Developer",
    "Python fullstack ",
    "python2 Developer",
    "QA Analyst",
    "QA Automation Engineer",
    "QA Engineer",
    "QA Engineer- Manual",
    "QA Job",
    "QA Manager",
    "QA Manual  Tester",
    "QA Manual Tester",
    "QA Senior analyst",
    "QA Test Job",
    "QA Tester",
    "QA Testing",
    "QA&QC",
    "QA-Tester ",
    "Quality analyst",
    "Quality Control ",
    "quality control manager",
    "Quality Engineer",
    "React ",
    "React Developer",
    "react js",
    "React Native",
    "react native developer",
    "Referral job test",
    "Report Job",
    "Research analyst",
    "Research Analystt",
    "restrict new",
    "Robotics Engineer1",
    "Search Engine Specialist",
    "senior",
    "Senior .NET Developer",
    "Senior analyst",
    "Senior Architect",
    "SENIOR DEVELOPER",
    "senior engineer",
    "Senior Java Developer",
    "Senior Manager, Software Engineering (Salesforce)",
    "Senior Manager, SW Engineering",
    "Senior Python Developer",
    "Senior QA analyst",
    "Senior QA manager",
    "Senior SAP specialist and Developer",
    "Senior Software Engineer",
    "Senior SQL SSIS Developer",
    "Senior System Analyst",
    "Senior System Architect-[Information systems]",
    "Senior System Engineer",
    "Senior Technical Analyst",
    "Senior Technical assistant",
    "Senior Test Engineer",
    "Senior Tester",
    "Senior web developer",
    "SHARE",
    "share job",
    "Shift Supervisor ",
    "software",
    "Software  Developer",
    "Software Analyst",
    "Software Data Analyst",
    "Software Developer",
    "Software Developer IT",
    "Software Developer Java",
    "Software Developer,OHIO, USA",
    "Software Developer- SeniorEngineer python",
    "Software Developer-java",
    "Software Engineer",
    "Software Engineer - Java/AWS",
    "Software Engineer Associate",
    "Software Engineer T",
    "Software Engineer, Associate",
    "Software Engineer2",
    "Software Project Manager",
    "Software Python Developer",
    "Software Technical Programmer",
    "Software Technical Recruiter",
    "Software Test analyst",
    "Software Test Engineer",
    "Software TEST Engineer- SDET",
    "Software Tester",
    "Software Testing",
    "Software Validation engineer",
    "Software/Application Developer",
    "Splunk Specialist",
    "Sr .Net Developer",
    "Sr.Selenium Automation Tester",
    "SW Implementation Project Manager",
    "System admin Recruitment ",
    "System Analyst",
    "System Architect",
    "System Engineer",
    "Team Lead",
    "Team Leader",
    "Team Leader Recruitment",
    "Tech Assistance Job",
    "Technical",
    "Technical Architect",
    "Technical Lead",
    "Technical Specialist",
    "Technical Support Engineer",
    "Technology Architect",
    "Telecom VAS",
    "Test Analyst",
    "Test Analyst1",
    "Test Analyst2",
    "Test Architect",
    "test data",
    "Test Developer",
    "Test Developer-2",
    "Test Engineer",
    "Test Jan12 job",
    "Test Job",
    "test Job 1",
    "Test Job EKS",
    "Test Job-Developer",
    "Test Job-QA",
    "test job1",
    "Test Job123",
    "test job1234",
    "test job2",
    "test job33",
    "Test Lead",
    "Test manager",
    "TEST PRogram",
    "test Public",
    "Test QA Job",
    "Test1",
    "testanalyst",
    "TestDev-2",
    "TestDev-Jan04",
    "TestDev-Jan05",
    "TestDev-Jan06",
    "TestDev-Jan07",
    "TestDev-Jan08",
    "TestDev-Jan080",
    "TestDev1-Jan04",
    "Testegf",
    "Tester",
    "Tester11",
    "Testing",
    "testing job",
    "Testjan12-2job",
    "testJob",
    "TestJob-Jan072021",
    "testjob1",
    "TestNg Developer",
    "tests",
    "TestSolution Architect",
    "TestSolution Architect3",
    "TestSolution Architect4",
    "TT db job",
    "TT Java",
    "TT React Job",
    "TT Vue Developer",
    "ui developer",
    "UI/UX Designer",
    "Vendor manager",
    "vue js developer",
    "Wanted Angular Developer",
    "web designer",
    "Web Developer",
    "wwaaa",
    "Zero Interest"
  ];

  String selectedJob = '', searchedJob = '';

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
                //SizedBox(width: 80,)
                Text(
                  'Job Search',
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
          Container(
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(color: Color(0xff001B3E)),
            padding: EdgeInsets.all(20),
            child: Container(
              width: MediaQuery.of(context).size.width - 50,
              height: 40,
              padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color: Colors.white,
              ),
              child: Center(
                child: Autocomplete<String>(
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    if (textEditingValue.text.isEmpty) {
                      return const Iterable<String>.empty();
                    }
                    return jobSuggestions.where((String option) {
                      return option
                          .toLowerCase()
                          .contains(textEditingValue.text.toLowerCase());
                    });
                  },
                  onSelected: (String selection) {
                    // Update the text field and save to preferences but don't navigate

                    setState(() {
                      selectedJob = selection;
                      searchedJob = selection;
                    });
                    saveStringToPreferences("search", selection);
                  },
                  fieldViewBuilder: (context, textEditingController, focusNode,
                      onFieldSubmitted) {
                    return TextField(
                      textAlign: TextAlign.start,
                      controller: textEditingController,
                      focusNode: focusNode,
                      onChanged: (s) {
                        setState(() {
                          searchedJob = s;
                        });
                      },
                      decoration: InputDecoration(
                        prefixIcon: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: SvgPicture.asset(
                            'assets/icon/Search.svg',
                            width: 22,
                            height: 22,
                          ),
                        ),
                        hintText: 'Search for job or skills',
                        hintStyle: TextStyle(
                          color: Color(0xFF818385),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 5),
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'[a-zA-Z0-9\s#+.\-]'),
                        ),
                      ],
                      onSubmitted: (value) {},
                    );
                  },
                ),
              ),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          InkWell(
            onTap: () {
              if (searchedJob.isEmpty) {
                // Show an error popup
                // ScaffoldMessenger.of(context).showSnackBar(
                //   SnackBar(
                //     content: Text('Please enter a job or skill to search.'),
                //     backgroundColor: Colors.red,
                //   ),
                IconSnackBar.show(
                  context,
                  label: 'Please enter a job or skill to search.',
                  snackBarType: SnackBarType.alert,
                  backgroundColor: Color(0xffBA1A1A),
                  iconColor: Colors.white,
                );
              } else {
                saveStringToPreferences("search", searchedJob);
                Navigator.pop(context);
              }
            },
            child: Container(
              width: MediaQuery.of(context).size.width - 40,
              decoration: BoxDecoration(
                color: Color(0xff004C99),
                borderRadius: BorderRadius.circular(10),
              ),
              height: 50,
              child: Center(
                child: Text(
                  'Search Jobs',
                  style: TextStyle(
                      fontWeight: FontWeight.w600, color: Colors.white),
                ),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.all(10),
              ),
            ),
          )
        ],
      ),
    );
  }
}
