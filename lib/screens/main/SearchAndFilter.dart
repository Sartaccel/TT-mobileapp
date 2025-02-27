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
  // Software Development
  "Software Developer",
  "Software Engineer",
  "Senior Software Engineer",
  "Full Stack Developer",
  "Front-End Developer",
  "Back-End Developer",
  "Web Developer",
  "Mobile App Developer",
  "iOS Developer",
  "Android Developer",
  "Flutter Developer",
  "React Native Developer",
  "Node.js Developer",
  "Vue.js Developer",
  "Angular Developer",
  "React Developer",
  "Java Developer",
  "Java Full Stack Developer",
  "Python Developer",
  "Ruby on Rails Developer",
  "PHP Developer",
  "C++ Developer",
  "C# Developer",
  ".NET Developer",
  "Golang Developer",
  "Rust Developer",
  "Swift Developer",
  "Kotlin Developer",
  "TypeScript Developer",

  // Data Science & AI
  "Data Scientist",
  "Data Analyst",
  "Data Engineer",
  "Big Data Developer",
  "Machine Learning Engineer",
  "AI Engineer",
  "Deep Learning Engineer",
  "NLP Engineer",
  "Business Intelligence Developer",
  "Business Intelligence Analyst",
  "Data Visualization Specialist",
  "ETL Developer",

  // Cloud & DevOps
  "Cloud Engineer",
  "Cloud Architect",
  "AWS Engineer",
  "Azure Engineer",
  "Google Cloud Engineer",
  "DevOps Engineer",
  "Site Reliability Engineer (SRE)",
  "Kubernetes Engineer",
  "Cloud Security Engineer",
  "Infrastructure Engineer",

  // Cybersecurity
  "Cybersecurity Analyst",
  "Cybersecurity Engineer",
  "Ethical Hacker",
  "Security Engineer",
  "Penetration Tester",
  "SOC Analyst",
  "Network Security Engineer",
  "Application Security Engineer",
  "Cloud Security Architect",

  // Quality Assurance & Testing
  "QA Engineer",
  "QA Analyst",
  "QA Automation Engineer",
  "Software Tester",
  "Test Engineer",
  "Performance Tester",
  "Security Tester",
  "Manual Tester",
  "SDET (Software Development Engineer in Test)",

  // IT Management & Support
  "IT Manager",
  "IT Project Manager",
  "IT Support Engineer",
  "System Administrator",
  "Network Administrator",
  "Help Desk Technician",
  "Technical Support Engineer",
  "Cloud Support Engineer",

  // Blockchain & Web3
  "Blockchain Developer",
  "Solidity Developer",
  "Smart Contract Developer",
  "Web3 Developer",
  "Crypto Analyst",

  // Embedded Systems & IoT
  "Embedded Software Engineer",
  "Firmware Engineer",
  "IoT Engineer",
  "Embedded Systems Developer",
  "Hardware Engineer",

  // UI/UX & Product Design
  "UI/UX Designer",
  "Product Designer",
  "UX Researcher",
  "Graphic Designer",
  "Motion Graphics Designer",
  "Game UI Designer",

  // Game Development
  "Game Developer",
  "Unity Developer",
  "Unreal Engine Developer",
  "Game Designer",
  "Game Tester",

  // Business & Marketing
  "Product Manager",
  "Project Manager",
  "Marketing Manager",
  "SEO Specialist",
  "Digital Marketing Specialist",
  "Growth Hacker",
  "Social Media Manager",
  "Content Writer",
  "Technical Writer",

  // Finance & Management
  "Financial Analyst",
  "Investment Analyst",
  "Risk Analyst",
  "Accountant",
  "Banking Manager",
  "Chief Technology Officer (CTO)",
  "Chief Information Officer (CIO)",
  "Chief Product Officer (CPO)",

  // Other Technical Roles
  "Solutions Architect",
  "System Architect",
  "Enterprise Architect",
  "Robotics Engineer",
  "Mechatronics Engineer",
  "Electronics Engineer",
  "Network Engineer",
  "Hardware Engineer",
  "Telecommunications Engineer",
  "Technical Recruiter"

  // Healthcare & Medical
  "Doctor",
  "Nurse",
  "Pharmacist",
  "Medical Lab Technician",
  "Radiologist",
  "Physical Therapist",
  "Occupational Therapist",
  "Dietitian",
  "Psychologist",
  "Veterinarian",
  "Dental Hygienist",
  "Paramedic",
  "Medical Receptionist",
  "Surgeon",
  "Optometrist",

  // Education & Research
  "Teacher",
  "Professor",
  "Librarian",
  "Academic Researcher",
  "Education Consultant",
  "School Principal",
  "Private Tutor",
  "Special Education Teacher",

  // Business & Finance
  "Accountant",
  "Financial Analyst",
  "Bank Teller",
  "Loan Officer",
  "Investment Banker",
  "Auditor",
  "Stockbroker",
  "Actuary",
  "Insurance Agent",
  "Tax Consultant",
  "Risk Manager",
  "Economist",

  // Marketing & Sales
  "Marketing Manager",
  "Sales Representative",
  "Real Estate Agent",
  "Advertising Executive",
  "Public Relations Specialist",
  "Customer Service Representative",
  "Brand Manager",
  "Market Research Analyst",
  "Event Planner",
  "Retail Store Manager",

  // Legal & Government
  "Lawyer",
  "Judge",
  "Police Officer",
  "Detective",
  "Paralegal",
  "Court Reporter",
  "Corrections Officer",
  "Firefighter",
  "Customs Officer",
  "Politician",
  "Diplomat",
  "Social Worker",

  // Engineering & Construction
  "Civil Engineer",
  "Mechanical Engineer",
  "Electrical Engineer",
  "Architect",
  "Structural Engineer",
  "Surveyor",
  "Construction Worker",
  "Plumber",
  "Electrician",
  "Carpenter",
  "Welder",
  "HVAC Technician",
  "Interior Designer",

  // Aviation & Transportation
  "Pilot",
  "Flight Attendant",
  "Air Traffic Controller",
  "Ship Captain",
  "Train Conductor",
  "Truck Driver",
  "Taxi Driver",
  "Delivery Driver",
  "Logistics Coordinator",

  // Media & Entertainment
  "Journalist",
  "News Anchor",
  "Actor",
  "Musician",
  "Singer",
  "Dancer",
  "Radio Host",
  "Photographer",
  "Film Director",
  "Video Editor",
  "Graphic Designer",
  "Fashion Designer",

  // Hospitality & Tourism
  "Hotel Manager",
  "Chef",
  "Bartender",
  "Waiter/Waitress",
  "Tour Guide",
  "Travel Agent",
  "Cruise Ship Staff",
  "Casino Dealer",
  "Resort Manager",

  // Agriculture & Environment
  "Farmer",
  "Agricultural Scientist",
  "Zoologist",
  "Wildlife Conservationist",
  "Forester",
  "Environmental Scientist",
  "Horticulturist",
  "Fisherman",

  // Manufacturing & Production
  "Factory Worker",
  "Production Manager",
  "Assembly Line Worker",
  "Quality Control Inspector",
  "Machinist",
  "Forklift Operator",

  // Skilled Trades & Services
  "Auto Mechanic",
  "Barber",
  "Hair Stylist",
  "Makeup Artist",
  "Tattoo Artist",
  "Personal Trainer",
  "Yoga Instructor",
  "Security Guard",
  "Housekeeper",
  "Florist",
  "Funeral Director"
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
  child: SizedBox(
    width: MediaQuery.of(context).size.width - 50,
    height: 40,
    child: Autocomplete<String>(
      optionsViewBuilder: (context, onSelected, options) {
        return Padding( 
          padding: EdgeInsets.only(top: 10), // ✅ Creates gap outside the box
          child: Align(
            alignment: Alignment.topLeft,
            child: Material(
              elevation: 5,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: MediaQuery.of(context).size.width - 50,
                constraints: BoxConstraints(maxHeight: 200),
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: options.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    final String option = options.elementAt(index);
                    return ListTile(
                      leading: SvgPicture.asset( 
                        'assets/icon/Search.svg',
                        width: 18,
                        height: 18,
                        color: Color(0xFF818385),
                      ),
                      title: Text(option),
                      onTap: () {
                        onSelected(option);
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return const Iterable<String>.empty();
        }
        List<String> filteredList = jobSuggestions
            .where((String option) =>
                option.toLowerCase().contains(textEditingValue.text.toLowerCase()))
            .toList();

        filteredList.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

        return filteredList;
      },
      onSelected: (String selection) {
        setState(() {
          selectedJob = selection;
          searchedJob = selection;
        });
        saveStringToPreferences("search", selection);
      },
      fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
        return Container(
          width: MediaQuery.of(context).size.width - 50,
          height: 40,
          padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            color: Colors.white,
          ),
          child: TextField(
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
          ),
        );
      },
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