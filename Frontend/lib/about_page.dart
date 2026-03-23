// import 'package:flutter/material.dart';

// class AboutPage extends StatefulWidget {
//   @override
//   _AboutPageState createState() => _AboutPageState();
// }

// class _AboutPageState extends State<AboutPage> {
//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Text(
//           "About Us\n\nWe provide counseling and emotional support for people in need.",
//           style: TextStyle(fontSize: 18),
//           textAlign: TextAlign.center,
//         ),
//       ),
//     );
//   }
// }





import 'package:flutter/material.dart';
// import 'who_we_are_page.dart';
// import 'mission_vision_page.dart';
// import 'reports_page.dart';




class AboutPage extends StatefulWidget {
  @override
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('About Oboshore'),
        backgroundColor: Color(0xFFF5F5F5),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            color: Colors.teal.shade50,
            child: TabBar(
              controller: _tabController,
              indicatorColor: Colors.teal,
              labelColor: Colors.teal.shade800,
              unselectedLabelColor: Colors.grey,
              tabs: [
                Tab(text: 'Who We Are'),
                Tab(text: 'Mission & Vision'),
                Tab(text: 'Reports'),
              ],
            ),
          ),


          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [

                // Who We Are Tab
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ListView(
                    children: [
                      Text(
                        "Who We Are",
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ),
                      SizedBox(height: 12),
                      Text(
                        "Oboshore is Bangladesh’s first and only emotional support and suicide prevention helpline for mobile app, staffed by trained volunteers. We provide immediate support to those in mental distress, emotional turmoil, or loneliness.",
                        style: TextStyle(fontSize: 16, height: 1.5),
                      ),
                      SizedBox(height: 12),
                      Text(
                        "Our helpline helps alleviate despair, isolation, and emotional pain through compassionate, open-minded listening. We aim to provide a safe space where anyone can share their feelings without judgment or stigma.",
                        style: TextStyle(fontSize: 16, height: 1.5),
                      ),
                      SizedBox(height: 12),
                      Text(
                        "Features of Oboshore:\n• Empathetic Listening\n• Volunteer-staffed Support\n• 100% Confidentiality\n• Safe & Non-Judgmental Space",
                        style: TextStyle(fontSize: 16, height: 1.5),
                      ),
                      SizedBox(height: 16),
                      Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        color: Colors.teal.shade50,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Text(
                                "“You are not alone. Someone is always here to listen.”",
                                style: TextStyle(
                                    fontSize: 16,
                                    fontStyle: FontStyle.italic,
                                    color: Colors.teal.shade900),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 12),
                              Text(
                                "“Even the darkest night will end and the sun will rise.”",
                                style: TextStyle(
                                    fontSize: 16,
                                    fontStyle: FontStyle.italic,
                                    color: Colors.teal.shade900),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),





                // Mission & Vision Tab
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ListView(
                    children: [
                      Text(
                        "Mission & Vision",
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ),
                      SizedBox(height: 12),
                      Text(
                        "Mission:\n"
                        "The mission of Oboshore is to alleviate feelings of despair, isolation, distress, and suicidal thoughts, provide an effective and reliable service for those experiencing emotional crises, and promote general mental health. "
                        "This is accomplished through confidential, compassionate, and open-minded listening on the helpline and through ongoing workshops, events, research, and collaborations with organizations.",
                        style: TextStyle(fontSize: 16, height: 1.5),
                      ),
                      SizedBox(height: 16),
                      Text(
                        "Vision:\n"
                        "We envision that all members of society will know and trust Oboshore as a place to go when in need.",
                        style: TextStyle(fontSize: 16, height: 1.5),
                      ),
                      SizedBox(height: 16),
                      Text(
                        "Values:\n"
                        "Oboshore operates through values of being open-minded, compassionate, non-judgmental, and respecting diversity and inclusivity.\n\n"
                        "“We believe in giving a person the opportunity to explore feelings which can cause distress, the importance of being listened to, in confidence, anonymously, and without prejudice. "
                        "We value that a person has the fundamental decision about their own life.”",
                        style: TextStyle(fontSize: 16, height: 1.5),
                      ),
                      SizedBox(height: 16),
                      Text(
                        "Objectives:\n"
                        "• Promote awareness that suicide is a preventable public health problem\n"
                        "• Develop broad-based support for suicide prevention\n"
                        "• Reduce stigma associated with mental health, substance abuse, and suicide prevention services\n"
                        "• Implement community-based suicide prevention programs\n"
                        "• Reduce access to lethal means and methods of self-harm\n"
                        "• Increase access and community linkages with mental health and substance abuse services\n"
                        "• Improve reporting and portrayal of suicidal behavior, mental illness, and substance abuse in media\n"
                        "• Promote and support research on suicide and prevention\n"
                        "• Select and train volunteer citizen groups\n"
                        "• Promote mental resilience through optimism and connectedness\n"
                        "• Provide outreach and education about suicide, risk factors, warning signs, and availability of help",
                        style: TextStyle(fontSize: 16, height: 1.5),
                      ),
                    ],
                  ),
                ),







                // Reports Tab
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ListView(
                    children: [
                      Text(
                        "Reports",
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ),
                      SizedBox(height: 12),
                      Text(
                        "Here you can find our annual reports, impact assessments, and statistics about the helpline's performance and volunteer engagement. These reports reflect our dedication to suicide prevention, emotional support, and mental health advocacy in Bangladesh.",
                        style: TextStyle(fontSize: 16, height: 1.5),
                      ),
                      SizedBox(height: 12),
                      Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          title: Text('Annual Report 2024'),
                          trailing: Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () {},
                        ),
                      ),
                      Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          title: Text('Impact Report 2023'),
                          trailing: Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () {},
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
