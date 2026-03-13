
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:fl_chart/fl_chart.dart';
// import './services/firestore_service.dart';
// import './helpline_volunteers.dart';
// import './non_helpline_volunteers.dart';
// import './update_requests.dart';
// import './all_users.dart';
// import './calls_page.dart'; 
// import 'approval_requests.dart';


// class AdminDashboard extends StatefulWidget {
//   const AdminDashboard({Key? key}) : super(key: key);

//   @override
//   State<AdminDashboard> createState() => _AdminDashboardState();
// }

// class _AdminDashboardState extends State<AdminDashboard> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Admin Dashboard"),
//         backgroundColor: const Color.fromARGB(255, 108, 187, 187),
//       ),


//       drawer: Drawer(
//         child: ListView(
//           children: [
//             const DrawerHeader(
//               decoration: BoxDecoration(color: Colors.teal),
//               child: Text(
//                 "Admin Panel",
//                 style: TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white),
//               ),
//             ),
//             ListTile(
//               title: const Text("Dashboard Home"),
//               onTap: () {
//                 Navigator.pop(context); 
//               },
//             ),
//             ListTile(
//               title: const Text("All Users"),
//               onTap: () {
//                 Navigator.pop(context);
//                 Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                         builder: (_) => const AllUsersPage())); // your all_users.dart page
//               },
//             ),
//             ListTile(
//               title: const Text("Helpline Volunteers"),
//               onTap: () {
//                 Navigator.pop(context);
//                 Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                         builder: (_) => const HelplineVolunteersPage()));
//               },
//             ),
//             ListTile(
//               title: const Text("Non-Helpline Volunteers"),
//               onTap: () {
//                 Navigator.pop(context);
//                 Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                         builder: (_) => const NonHelplineVolunteersPage()));
//               },
//             ),
//             ListTile(
//               title: const Text("Calls"),
//               onTap: () {
//                 Navigator.pop(context);
//                 Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                         builder: (_) => const CallsPage())); // Optional page for calls
//               },
//             ),

//             ListTile(
//               title: const Text("Volunteer Approval Requests"),
//               onTap: () {
//                 Navigator.pop(context);
//                 Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                         builder: (_) => const ApprovalRequestsPage()));
//               },
//             ),

//             ListTile(
//               title: const Text("Update Requests"),
//               onTap: () {
//                 Navigator.pop(context);
//                 Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                         builder: (_) => const UpdateRequestsPage()));
//               },
//             ),
//           ],
//         ),
//       ),

//       body: _dashboardHome(),
//     );
//   }

//   Widget _dashboardHome() {
//     return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
//       stream: FS.db
//           .collection("calls")
//           .orderBy("timestamp", descending: true)
//           .limit(200)
//           .snapshots(),
//       builder: (context, snapshot) {
//         if (!snapshot.hasData)
//           return const Center(child: CircularProgressIndicator());

//         final docs = snapshot.data!.docs;

//         int accepted = 0;
//         int rejected = 0;
//         int slot1 = 0; // 12AM–3AM
//         int slot2 = 0; // 3AM–6AM

//         final today = DateTime.now();
//         Map<String, int> deEscalatedPerDay = {};

//         for (var doc in docs) {
//           final data = doc.data();
//           final status = data['status'] ?? '';
//           final timeSlot = data['timeSlot'] ?? '';
//           final ts = (data['timestamp'] as Timestamp?)?.toDate();
//           final dayStr = ts != null ? "${ts.year}-${ts.month}-${ts.day}" : "";

//           if (status == "answered") accepted++;
//           if (status == "rejected") rejected++;
//           if (timeSlot == "12AM-3AM") slot1++;
//           if (timeSlot == "3AM-6AM") slot2++;

//           if (dayStr.isNotEmpty && status == "de-escalated") {
//             deEscalatedPerDay[dayStr] = (deEscalatedPerDay[dayStr] ?? 0) + 1;
//           }
//         }

//         final spots = <FlSpot>[];
//         for (int i = 6; i >= 0; i--) {
//           final day = today.subtract(Duration(days: i));
//           final key = "${day.year}-${day.month}-${day.day}";
//           final count = deEscalatedPerDay[key] ?? 0;
//           spots.add(FlSpot((6 - i).toDouble(), count.toDouble()));
//         }

//         return SingleChildScrollView(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text(
//                 "Welcome to Admin Dashboard",
//                 style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 20),

//               Wrap(
//                 spacing: 16,
//                 runSpacing: 16,
//                 alignment: WrapAlignment.center,
//                 children: [
//                   _countCard(
//                       title: "Active Helpline Volunteers",
//                       stream: FS.volunteers(type: "helpline")),
//                   _countCard(
//                       title: "Non-Helpline Volunteers",
//                       stream: FS.volunteers(type: "non-helpline")),
//                   _countCard(
//                       title: "Calls Answered (All)",
//                       stream: FS.db
//                           .collection("calls")
//                           .where("status", isEqualTo: "answered")
//                           .snapshots()),
//                   StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
//                     stream: FS.db
//                         .collection("calls")
//                         .where("status", isEqualTo: "answered")
//                         .where("timeSlot", whereIn: ["12AM-3AM", "3AM-6AM"])
//                         .snapshots(),
//                     builder: (context, snapshot) {
//                       int count = 0;
//                       if (snapshot.hasData) count = snapshot.data!.docs.length;
//                       return _statCard(
//                           "Calls Answered After Midnight", "$count", Colors.teal);
//                     },
//                   ),
//                   _countCard(
//                       title: "Calls Rejected",
//                       stream: FS.db
//                           .collection("calls")
//                           .where("status", isEqualTo: "rejected")
//                           .snapshots()),
//                   _percentageCard(
//                       title: "De-escalation Success Rate",
//                       stream: FS.db.collection("calls").snapshots()),
//                 ],
//               ),
//               const SizedBox(height: 30),

//               const Text("Call Status Distribution",
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//               const SizedBox(height: 10),
//               Card(
//                 child: Container(
//                   height: 250,
//                   padding: const EdgeInsets.all(16),
//                   child: PieChart(
//                     PieChartData(
//                       sections: [
//                         PieChartSectionData(
//                             color: Colors.green,
//                             value: accepted.toDouble(),
//                             title: "Accepted"),
//                         PieChartSectionData(
//                             color: Colors.red,
//                             value: rejected.toDouble(),
//                             title: "Rejected"),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 30),

//               const Text("Calls by Time Slot",
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//               const SizedBox(height: 10),
//               Card(
//                 child: Container(
//                   height: 250,
//                   padding: const EdgeInsets.all(16),
//                   child: BarChart(
//                     BarChartData(
//                       minY: 0,
//                       titlesData: FlTitlesData(
//                         leftTitles:
//                             AxisTitles(sideTitles: SideTitles(showTitles: true)),
//                         bottomTitles: AxisTitles(
//                           sideTitles: SideTitles(
//                             showTitles: true,
//                             getTitlesWidget: (value, meta) {
//                               return value.toInt() == 0
//                                   ? const Text("12–3 AM")
//                                   : const Text("3–6 AM");
//                             },
//                           ),
//                         ),
//                       ),
//                       barGroups: [
//                         BarChartGroupData(
//                             x: 0,
//                             barRods: [
//                               BarChartRodData(toY: slot1.toDouble(), color: Colors.blue)
//                             ]),
//                         BarChartGroupData(
//                             x: 1,
//                             barRods: [
//                               BarChartRodData(toY: slot2.toDouble(), color: Colors.purple)
//                             ]),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 30),

//               const Text("De-escalation Trend (Last 7 Days)",
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//               const SizedBox(height: 10),
//               Card(
//                 child: Container(
//                   height: 250,
//                   padding: const EdgeInsets.all(16),
//                   child: LineChart(LineChartData(
//                     minY: 0,
//                     maxY: (deEscalatedPerDay.values.isNotEmpty
//                             ? deEscalatedPerDay.values.reduce((a, b) => a > b ? a : b) + 5
//                             : 10)
//                         .toDouble(),
//                     titlesData: FlTitlesData(
//                       bottomTitles: AxisTitles(
//                         sideTitles: SideTitles(
//                           showTitles: true,
//                           getTitlesWidget: (value, meta) {
//                             final day = today.subtract(Duration(days: 6 - value.toInt()));
//                             return Text("${day.month}/${day.day}");
//                           },
//                         ),
//                       ),
//                       leftTitles:
//                           AxisTitles(sideTitles: SideTitles(showTitles: true)),
//                     ),
//                     lineBarsData: [
//                       LineChartBarData(
//                         spots: spots,
//                         isCurved: true,
//                         color: Colors.orange,
//                         barWidth: 3,
//                         dotData: FlDotData(show: true),
//                       ),
//                     ],
//                   )),
//                 ),
//               ),
//               const SizedBox(height: 30),

//               const Text("Midnight Calls vs Regular Hours Call",
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//               const SizedBox(height: 10),
//               Card(
//                 child: Container(
//                   height: 250,
//                   padding: const EdgeInsets.all(16),
//                   child: PieChart(
//                     PieChartData(
//                       sections: [
//                         PieChartSectionData(
//                             color: Colors.teal,
//                             value: (slot1 + slot2).toDouble(),
//                             title: "12AM–6AM"),
//                         PieChartSectionData(
//                             color: Colors.orange,
//                             value: (accepted - (slot1 + slot2)).toDouble(),
//                             title: "Other Times"),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   Widget _countCard(
//           {required String title,
//           required Stream<QuerySnapshot<Map<String, dynamic>>> stream}) =>
//       StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
//         stream: stream,
//         builder: (context, snapshot) {
//           int count = 0;
//           if (snapshot.hasData) count = snapshot.data!.docs.length;
//           return _statCard(title, "$count", Colors.blue);
//         },
//       );

//   Widget _percentageCard(
//           {required String title,
//           required Stream<QuerySnapshot<Map<String, dynamic>>> stream}) =>
//       StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
//         stream: stream,
//         builder: (context, snapshot) {
//           double percent = 0;
//           if (snapshot.hasData) {
//             final docs = snapshot.data!.docs;
//             final answered = docs.where((d) => d['status'] == "answered").length;
//             final deEscalated =
//                 docs.where((d) => d['status'] == "de-escalated").length;
//             if (answered > 0) percent = (deEscalated / answered) * 100;
//           }
//           return _statCard(title, "${percent.toStringAsFixed(1)}%", Colors.purple);
//         },
//       );

//   Widget _statCard(String title, String value, Color color) {
//     return Card(
//       elevation: 4,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Container(
//         width: 180,
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//             color: color.withOpacity(0.1),
//             borderRadius: BorderRadius.circular(12)),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Text(title,
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                     fontSize: 16, fontWeight: FontWeight.bold, color: color)),
//             const SizedBox(height: 10),
//             Text(value,
//                 style: const TextStyle(
//                     fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black)),
//           ],
//         ),
//       ),
//     );
//   }
// }












import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import './services/firestore_service.dart';
import './helpline_volunteers.dart';
import './non_helpline_volunteers.dart';
import './update_requests.dart';
import './all_users.dart';
import './calls_page.dart'; 
import 'approval_requests.dart';
import 'admin_announcement.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final Stream<QuerySnapshot<Map<String, dynamic>>> _callsStream = 
      FirebaseFirestore.instance
          .collection("calls")
          .orderBy("timestamp", descending: true)
          .limit(200)
          .snapshots();

  final Stream<QuerySnapshot<Map<String, dynamic>>> _helplineVolunteersStream = 
      FirebaseFirestore.instance
          .collection("volunteers")
          .where("volunteerType", isEqualTo: "helpline")
          .where("status", isEqualTo: "approved")
          .snapshots();

  final Stream<QuerySnapshot<Map<String, dynamic>>> _nonHelplineVolunteersStream = 
      FirebaseFirestore.instance
          .collection("volunteers")
          .where("volunteerType", isEqualTo: "non-helpline")
          .where("status", isEqualTo: "approved")
          .snapshots();

  final Stream<QuerySnapshot<Map<String, dynamic>>> _answeredCallsStream = 
      FirebaseFirestore.instance
          .collection("calls")
          .where("status", isEqualTo: "answered")
          .snapshots();

  final Stream<QuerySnapshot<Map<String, dynamic>>> _rejectedCallsStream = 
      FirebaseFirestore.instance
          .collection("calls")
          .where("status", isEqualTo: "rejected")
          .snapshots();

  final Stream<QuerySnapshot<Map<String, dynamic>>> _midnightCallsStream = 
      FirebaseFirestore.instance
          .collection("calls")
          .where("status", isEqualTo: "answered")
          .where("timeSlot", whereIn: ["12AM-3AM", "3AM-6AM"])
          .snapshots();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        backgroundColor: const Color.fromARGB(255, 108, 187, 187),
      ),
      drawer: _buildDrawer(),
      body: _dashboardHome(),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.teal),
            child: Text(
              "Admin Panel",
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ),
          ListTile(
            title: const Text("Dashboard Home"),
            onTap: () {
              Navigator.pop(context); 
            },
          ),
          ListTile(
            title: const Text("All Users"),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const AllUsersPage()));
            },
          ),
          ListTile(
            title: const Text("Admin Announcements"),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const Announcement()));
            },
          ),

          ListTile(
            title: const Text("Helpline Volunteers"),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const HelplineVolunteersPage()));
            },
          ),
          ListTile(
            title: const Text("Non-Helpline Volunteers"),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const NonHelplineVolunteersPage()));
            },
          ),
          ListTile(
            title: const Text("Calls"),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const CallsPage()));
            },
          ),
          ListTile(
            title: const Text("Volunteer Approval Requests"),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const ApprovalRequestsPage()));
            },
          ),
          ListTile(
            title: const Text("Update Requests"),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const UpdateRequestsPage()));
            },
          ),
        ],
      ),
    );
  }

  Widget _dashboardHome() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Welcome to Admin Dashboard",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          Wrap(
            spacing: 16,
            runSpacing: 16,
            alignment: WrapAlignment.center,
            children: [
              _countCard(
                title: "Active Helpline Volunteers",
                stream: _helplineVolunteersStream,
                color: Colors.blue,
              ),
              _countCard(
                title: "Non-Helpline Volunteers",
                stream: _nonHelplineVolunteersStream,
                color: Colors.green,
              ),
              _countCard(
                title: "Calls Answered (All)",
                stream: _answeredCallsStream,
                color: Colors.teal,
              ),
              _countCard(
                title: "Midnight Calls (12AM-6AM)",
                stream: _midnightCallsStream,
                color: Colors.purple,
              ),
              _countCard(
                title: "Calls Rejected",
                stream: _rejectedCallsStream,
                color: Colors.red,
              ),
              _percentageCard(),
            ],
          ),
          const SizedBox(height: 30),

          const Text("Call Status Distribution",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: _callsStream,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Card(
                  child: SizedBox(
                    height: 250,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                );
              }

              final docs = snapshot.data!.docs;
              final answered = docs.where((doc) => doc['status'] == 'answered').length;
              final rejected = docs.where((doc) => doc['status'] == 'rejected').length;
              final total = answered + rejected;

              return Card(
                child: Container(
                  height: 250,
                  padding: const EdgeInsets.all(16),
                  child: PieChart(
                    PieChartData(
                      sections: [
                        PieChartSectionData(
                          color: Colors.green,
                          value: answered.toDouble(),
                          title: "${total > 0 ? ((answered / total) * 100).toStringAsFixed(1) : '0'}%",
                          radius: 60,
                          titleStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        PieChartSectionData(
                          color: Colors.red,
                          value: rejected.toDouble(),
                          title: "${total > 0 ? ((rejected / total) * 100).toStringAsFixed(1) : '0'}%",
                          radius: 60,
                          titleStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 30),

          const Text("Calls by Time Slot",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: _callsStream,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Card(
                  child: SizedBox(
                    height: 250,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                );
              }

              final docs = snapshot.data!.docs;
              final slot1 = docs.where((doc) => doc['timeSlot'] == '12AM-3AM').length;
              final slot2 = docs.where((doc) => doc['timeSlot'] == '3AM-6AM').length;
              final slot3 = docs.where((doc) => doc['timeSlot'] == '6AM-9AM').length;
              final slot4 = docs.where((doc) => doc['timeSlot'] == '9AM-12PM').length;

              final maxY = [slot1, slot2, slot3, slot4].reduce((a, b) => a > b ? a : b).toDouble();

              return Card(
                child: Container(
                  height: 250,
                  padding: const EdgeInsets.all(16),
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: maxY + 5,
                      barTouchData: BarTouchData(enabled: false),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final titles = ['12-3AM', '3-6AM', '6-9AM', '9-12PM'];
                              return value.toInt() < titles.length
                                  ? Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text(titles[value.toInt()], style: const TextStyle(fontSize: 10)),
                                    )
                                  : const Text('');
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                          ),
                        ),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      gridData: const FlGridData(show: true),
                      borderData: FlBorderData(show: false),
                      barGroups: [
                        BarChartGroupData(
                          x: 0,
                          barRods: [BarChartRodData(toY: slot1.toDouble(), color: Colors.blue, width: 20)],
                        ),
                        BarChartGroupData(
                          x: 1,
                          barRods: [BarChartRodData(toY: slot2.toDouble(), color: Colors.purple, width: 20)],
                        ),
                        BarChartGroupData(
                          x: 2,
                          barRods: [BarChartRodData(toY: slot3.toDouble(), color: Colors.orange, width: 20)],
                        ),
                        BarChartGroupData(
                          x: 3,
                          barRods: [BarChartRodData(toY: slot4.toDouble(), color: Colors.green, width: 20)],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 30),

          const Text("De-escalation Trend (Last 7 Days)",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: _callsStream,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Card(
                  child: SizedBox(
                    height: 250,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                );
              }

              final docs = snapshot.data!.docs;
              final today = DateTime.now();
              final Map<String, int> deEscalatedPerDay = {};

              for (var doc in docs) {
                final data = doc.data();
                if (data['status'] == 'de-escalated') {
                  final ts = (data['timestamp'] as Timestamp?)?.toDate();
                  if (ts != null) {
                    final dayStr = "${ts.year}-${ts.month}-${ts.day}";
                    deEscalatedPerDay[dayStr] = (deEscalatedPerDay[dayStr] ?? 0) + 1;
                  }
                }
              }

              final spots = <FlSpot>[];
              for (int i = 6; i >= 0; i--) {
                final day = today.subtract(Duration(days: i));
                final key = "${day.year}-${day.month}-${day.day}";
                final count = deEscalatedPerDay[key] ?? 0;
                spots.add(FlSpot((6 - i).toDouble(), count.toDouble()));
              }

              final maxY = spots.isNotEmpty 
                  ? spots.map((spot) => spot.y).reduce((a, b) => a > b ? a : b) + 2
                  : 10.0;

              return Card(
                child: Container(
                  height: 250,
                  padding: const EdgeInsets.all(16),
                  child: LineChart(
                    LineChartData(
                      minY: 0,
                      maxY: maxY,
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final day = today.subtract(Duration(days: 6 - value.toInt()));
                              return Text("${day.day}/${day.month}", style: const TextStyle(fontSize: 10));
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                          ),
                        ),
                      ),
                      gridData: const FlGridData(show: true),
                      borderData: FlBorderData(show: true),
                      lineBarsData: [
                        LineChartBarData(
                          spots: spots,
                          isCurved: true,
                          color: Colors.orange,
                          barWidth: 3,
                          dotData: FlDotData(show: true),
                          belowBarData: BarAreaData(show: true, color: Colors.orange.withOpacity(0.3)),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _countCard({
    required String title,
    required Stream<QuerySnapshot<Map<String, dynamic>>> stream,
    required Color color,
  }) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: stream,
      builder: (context, snapshot) {
        int count = 0;
        if (snapshot.hasData) {
          count = snapshot.data!.docs.length;
        }
        return _statCard(title, count.toString(), color);
      },
    );
  }

  Widget _percentageCard() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _callsStream,
      builder: (context, snapshot) {
        double percent = 0;
        if (snapshot.hasData) {
          final docs = snapshot.data!.docs;
          final answered = docs.where((doc) => doc['status'] == "answered").length;
          final deEscalated = docs.where((doc) => doc['status'] == "de-escalated").length;
          if (answered > 0) {
            percent = (deEscalated / answered) * 100;
          }
        }
        return _statCard(
          "De-escalation Success Rate",
          "${percent.toStringAsFixed(1)}%",
          Colors.purple,
        );
      },
    );
  }

  Widget _statCard(String title, String value, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 180,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}