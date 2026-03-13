



// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class HelplineVolunteersPage extends StatefulWidget {
//   const HelplineVolunteersPage({Key? key}) : super(key: key);

//   @override
//   State<HelplineVolunteersPage> createState() => _HelplineVolunteersPageState();
// }

// class _HelplineVolunteersPageState extends State<HelplineVolunteersPage> {
//   final FirebaseFirestore _db = FirebaseFirestore.instance;
  
//   // Filters
//   String? volunteerSlotFilter;
//   DateTime? acceptedDateFilter;
//   DateTime? rejectedDateFilter;

//   // Search per table
//   String volunteerSearch = "";
//   String acceptedSearch = "";
//   String rejectedSearch = "";

//   final List<String> allTimeSlots = [
//     "12:00 AM – 4:00 AM",
//     "4:00 AM – 8:00 AM", 
//     "8:00 AM – 12:00 PM",
//     "12:00 PM – 4:00 PM",
//     "4:00 PM – 8:00 PM",
//     "8:00 PM – 12:00 AM",
//     "Flexible / Available 24 Hours"
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Helpline Volunteers"),
//         backgroundColor: Colors.green,
//         foregroundColor: Colors.white,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Summary Statistics
//             _buildSummaryCards(),
//             const SizedBox(height: 20),
            
//             _buildVolunteerTable(),
//             const SizedBox(height: 30),
//             _buildAcceptedCallsTable(),
//             const SizedBox(height: 30),
//             _buildRejectedCallsTable(),
//           ],
//         ),
//       ),
//     );
//   }

//   // Summary Cards
//   Widget _buildSummaryCards() {
//     return StreamBuilder<QuerySnapshot>(
//       stream: _db.collection('volunteers')
//           .where('volunteerType', isEqualTo: 'helpline')
//           .where('status', isEqualTo: 'approved')
//           .snapshots(),
//       builder: (context, snapshot) {
//         if (!snapshot.hasData) {
//           return const Center(child: CircularProgressIndicator());
//         }

//         int totalVolunteers = snapshot.data!.docs.length;
        
//         return StreamBuilder<QuerySnapshot>(
//           stream: _db.collection('calls').snapshots(),
//           builder: (context, callSnapshot) {
//             if (!callSnapshot.hasData) {
//               return const Center(child: CircularProgressIndicator());
//             }

//             var callDocs = callSnapshot.data!.docs;
//             int answeredCalls = callDocs.where((d) => d.get('status') == 'answered').length;
//             int rejectedCalls = callDocs.where((d) => d.get('status') == 'rejected').length;
//             int pendingCalls = callDocs.where((d) => d.get('status') == 'pending').length;

//             return Row(
//               children: [
//                 Expanded(
//                   child: _buildStatCard(
//                     title: "Active Volunteers",
//                     value: "$totalVolunteers",
//                     icon: Icons.people,
//                     color: Colors.green,
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: _buildStatCard(
//                     title: "Calls Answered",
//                     value: "$answeredCalls",
//                     icon: Icons.call_received,
//                     color: Colors.blue,
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: _buildStatCard(
//                     title: "Calls Rejected",
//                     value: "$rejectedCalls",
//                     icon: Icons.call_end,
//                     color: Colors.red,
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: _buildStatCard(
//                     title: "Pending Calls",
//                     value: "$pendingCalls",
//                     icon: Icons.pending,
//                     color: Colors.orange,
//                   ),
//                 ),
//               ],
//             );
//           },
//         );
//       },
//     );
//   }

//   Widget _buildStatCard({
//     required String title,
//     required String value,
//     required IconData icon,
//     required Color color,
//   }) {
//     return Card(
//       elevation: 4,
//       child: Container(
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(8),
//           gradient: LinearGradient(
//             colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//         ),
//         child: Column(
//           children: [
//             Icon(icon, size: 32, color: color),
//             const SizedBox(height: 8),
//             Text(
//               value,
//               style: TextStyle(
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//                 color: color,
//               ),
//             ),
//             const SizedBox(height: 4),
//             Text(
//               title,
//               textAlign: TextAlign.center,
//               style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildVolunteerTable() {
//     return Card(
//       elevation: 3,
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 const Icon(Icons.people, color: Colors.green),
//                 const SizedBox(width: 8),
//                 const Text("Approved Helpline Volunteers",
//                     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//               ],
//             ),
//             const SizedBox(height: 16),
            
//             // Filters Row
//             Row(
//               children: [
//                 Expanded(
//                   flex: 2,
//                   child: TextField(
//                     decoration: const InputDecoration(
//                       labelText: "Search by Name/Email",
//                       border: OutlineInputBorder(),
//                       prefixIcon: Icon(Icons.search),
//                       isDense: true,
//                     ),
//                     onChanged: (val) => setState(() => volunteerSearch = val.toLowerCase()),
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   flex: 2,
//                   child: DropdownButtonFormField<String>(
//                     decoration: const InputDecoration(
//                       labelText: "Filter by Time Slot",
//                       border: OutlineInputBorder(),
//                       isDense: true,
//                     ),
//                     value: volunteerSlotFilter,
//                     items: allTimeSlots
//                         .map((slot) => DropdownMenuItem(value: slot, child: Text(slot, style: const TextStyle(fontSize: 12))))
//                         .toList(),
//                     onChanged: (val) => setState(() => volunteerSlotFilter = val),
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 IconButton(
//                   onPressed: () => setState(() {
//                     volunteerSlotFilter = null;
//                     volunteerSearch = "";
//                   }),
//                   icon: const Icon(Icons.clear),
//                   tooltip: "Clear Filters",
//                 )
//               ],
//             ),
//             const SizedBox(height: 16),
            
//             StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
//               stream: _db
//                   .collection('volunteers')
//                   .where('volunteerType', isEqualTo: 'helpline')
//                   .where('status', isEqualTo: 'approved')
//                   .orderBy('createdAt', descending: true)
//                   .snapshots(),
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return const Center(child: CircularProgressIndicator());
//                 }
                
//                 if (snapshot.hasError) {
//                   return Center(child: Text("Error: ${snapshot.error}"));
//                 }
                
//                 if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//                   return const Center(
//                     child: Padding(
//                       padding: EdgeInsets.all(32),
//                       child: Column(
//                         children: [
//                           Icon(Icons.people_outline, size: 64, color: Colors.grey),
//                           SizedBox(height: 16),
//                           Text("No approved helpline volunteers found", 
//                               style: TextStyle(fontSize: 16, color: Colors.grey)),
//                         ],
//                       ),
//                     ),
//                   );
//                 }

//                 var docs = snapshot.data!.docs;

//                 // Apply filters
//                 if (volunteerSlotFilter != null) {
//                   docs = docs.where((d) {
//                     final times = List<String>.from(d.data()['availabilityTimes'] ?? []);
//                     return times.contains(volunteerSlotFilter);
//                   }).toList();
//                 }
                
//                 if (volunteerSearch.isNotEmpty) {
//                   docs = docs.where((d) {
//                     final data = d.data();
//                     final name = (data['fullName'] ?? "").toString().toLowerCase();
//                     final email = (data['email'] ?? "").toString().toLowerCase();
//                     return name.contains(volunteerSearch) || email.contains(volunteerSearch);
//                   }).toList();
//                 }

//                 if (docs.isEmpty) {
//                   return const Center(
//                     child: Padding(
//                       padding: EdgeInsets.all(32),
//                       child: Text("No volunteers match your search criteria", 
//                           style: TextStyle(fontSize: 16, color: Colors.grey)),
//                     ),
//                   );
//                 }

//                 return Column(
//                   children: docs.map((doc) {
//                     final data = doc.data();
//                     return Card(
//                       margin: const EdgeInsets.symmetric(vertical: 6),
//                       elevation: 2,
//                       child: ListTile(
//                         leading: CircleAvatar(
//                           backgroundColor: Colors.green[100],
//                           child: Text(
//                             (data['fullName'] ?? "?").substring(0, 1).toUpperCase(),
//                             style: const TextStyle(fontWeight: FontWeight.bold),
//                           ),
//                         ),
//                         title: Text(
//                           data['fullName'] ?? "Unnamed",
//                           style: const TextStyle(fontWeight: FontWeight.w600),
//                         ),
//                         subtitle: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(data['email'] ?? ""),
//                             const SizedBox(height: 4),
//                             Row(
//                               children: [
//                                 const Icon(Icons.phone, size: 14, color: Colors.grey),
//                                 const SizedBox(width: 4),
//                                 Text(data['phone'] ?? "N/A", style: const TextStyle(fontSize: 12)),
//                               ],
//                             ),
//                           ],
//                         ),
//                         trailing: Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             if ((data['availabilityTimes'] as List?)?.isNotEmpty == true)
//                               Container(
//                                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                                 decoration: BoxDecoration(
//                                   color: Colors.blue[100],
//                                   borderRadius: BorderRadius.circular(12),
//                                 ),
//                                 child: Text(
//                                   "${(data['availabilityTimes'] as List).length} slots",
//                                   style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
//                                 ),
//                               ),
//                             const SizedBox(width: 8),
//                             ElevatedButton.icon(
//                               onPressed: () => _showVolunteerInfoModal(data, doc.id),
//                               icon: const Icon(Icons.info_outline, size: 16),
//                               label: const Text("Details"),
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: Colors.green,
//                                 foregroundColor: Colors.white,
//                                 padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     );
//                   }).toList(),
//                 );
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildAcceptedCallsTable() {
//     return Card(
//       elevation: 3,
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 const Icon(Icons.call_received, color: Colors.blue),
//                 const SizedBox(width: 8),
//                 const Text("Accepted Calls", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//               ],
//             ),
//             const SizedBox(height: 16),
            
//             Row(
//               children: [
//                 Expanded(
//                   flex: 2,
//                   child: TextField(
//                     decoration: const InputDecoration(
//                       labelText: "Search by Volunteer/User Name",
//                       border: OutlineInputBorder(),
//                       prefixIcon: Icon(Icons.search),
//                       isDense: true,
//                     ),
//                     onChanged: (val) => setState(() => acceptedSearch = val.toLowerCase()),
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: ElevatedButton.icon(
//                     onPressed: () async {
//                       final date = await showDatePicker(
//                         context: context,
//                         initialDate: acceptedDateFilter ?? DateTime.now(),
//                         firstDate: DateTime(2020),
//                         lastDate: DateTime.now(),
//                       );
//                       if (date != null) setState(() => acceptedDateFilter = date);
//                     },
//                     icon: const Icon(Icons.calendar_today, size: 16),
//                     label: Text(
//                       acceptedDateFilter == null
//                           ? "Filter by Date"
//                           : "${acceptedDateFilter!.day}/${acceptedDateFilter!.month}/${acceptedDateFilter!.year}",
//                       style: const TextStyle(fontSize: 12),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 IconButton(
//                   onPressed: () => setState(() {
//                     acceptedDateFilter = null;
//                     acceptedSearch = "";
//                   }),
//                   icon: const Icon(Icons.clear),
//                   tooltip: "Clear Filters",
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
            
//             StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
//               stream: _db
//                   .collection("calls")
//                   .where("status", isEqualTo: "answered")
//                   .orderBy("timestamp", descending: true)
//                   .limit(50)
//                   .snapshots(),
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return const Center(child: CircularProgressIndicator());
//                 }
                
//                 if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//                   return const Center(
//                     child: Padding(
//                       padding: EdgeInsets.all(32),
//                       child: Column(
//                         children: [
//                           Icon(Icons.call_received, size: 64, color: Colors.grey),
//                           SizedBox(height: 16),
//                           Text("No accepted calls found", 
//                               style: TextStyle(fontSize: 16, color: Colors.grey)),
//                         ],
//                       ),
//                     ),
//                   );
//                 }
                
//                 var docs = snapshot.data!.docs;

//                 // Apply filters
//                 if (acceptedDateFilter != null) {
//                   docs = docs.where((d) {
//                     final ts = (d.data()['timestamp'] as Timestamp?)?.toDate();
//                     if (ts == null) return false;
//                     return ts.year == acceptedDateFilter!.year &&
//                         ts.month == acceptedDateFilter!.month &&
//                         ts.day == acceptedDateFilter!.day;
//                   }).toList();
//                 }

//                 if (acceptedSearch.isNotEmpty) {
//                   docs = docs.where((d) {
//                     final data = d.data();
//                     final volunteerName = (data['volunteerName'] ?? "").toString().toLowerCase();
//                     final userName = (data['userInfo']?['name'] ?? "").toString().toLowerCase();
//                     return volunteerName.contains(acceptedSearch) || userName.contains(acceptedSearch);
//                   }).toList();
//                 }

//                 if (docs.isEmpty) {
//                   return const Center(
//                     child: Padding(
//                       padding: EdgeInsets.all(32),
//                       child: Text("No calls match your search criteria", 
//                           style: TextStyle(fontSize: 16, color: Colors.grey)),
//                     ),
//                   );
//                 }

//                 return Column(
//                   children: docs.map((doc) {
//                     final data = doc.data();
//                     final timestamp = (data['timestamp'] as Timestamp?)?.toDate();
                    
//                     return Card(
//                       margin: const EdgeInsets.symmetric(vertical: 4),
//                       elevation: 1,
//                       child: ListTile(
//                         leading: const CircleAvatar(
//                           backgroundColor: Colors.blue,
//                           child: Icon(Icons.call, color: Colors.white, size: 20),
//                         ),
//                         title: Text(
//                           data['volunteerName'] ?? "Unknown Volunteer",
//                           style: const TextStyle(fontWeight: FontWeight.w600),
//                         ),
//                         subtitle: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text("Time Slot: ${data['timeSlot'] ?? 'N/A'}"),
//                             if (timestamp != null)
//                               Text("Date: ${timestamp.day}/${timestamp.month}/${timestamp.year} ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}"),
//                           ],
//                         ),
//                         trailing: Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             ElevatedButton(
//                               onPressed: () => _showUserInfoModal(data['userInfo']),
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: Colors.blue[100],
//                                 foregroundColor: Colors.blue[800],
//                                 padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                               ),
//                               child: const Text("User Info", style: TextStyle(fontSize: 12)),
//                             ),
//                             const SizedBox(width: 6),
//                             ElevatedButton(
//                               onPressed: () => _showCallVolunteerInfoModal(data['volunteerInfo']),
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: Colors.green[100],
//                                 foregroundColor: Colors.green[800],
//                                 padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                               ),
//                               child: const Text("Volunteer Info", style: TextStyle(fontSize: 12)),
//                             ),
//                           ],
//                         ),
//                       ),
//                     );
//                   }).toList(),
//                 );
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildRejectedCallsTable() {
//     return Card(
//       elevation: 3,
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 const Icon(Icons.call_end, color: Colors.red),
//                 const SizedBox(width: 8),
//                 const Text("Rejected Calls", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//               ],
//             ),
//             const SizedBox(height: 16),
            
//             Row(
//               children: [
//                 Expanded(
//                   flex: 2,
//                   child: TextField(
//                     decoration: const InputDecoration(
//                       labelText: "Search by Volunteer/User Name",
//                       border: OutlineInputBorder(),
//                       prefixIcon: Icon(Icons.search),
//                       isDense: true,
//                     ),
//                     onChanged: (val) => setState(() => rejectedSearch = val.toLowerCase()),
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: ElevatedButton.icon(
//                     onPressed: () async {
//                       final date = await showDatePicker(
//                         context: context,
//                         initialDate: rejectedDateFilter ?? DateTime.now(),
//                         firstDate: DateTime(2020),
//                         lastDate: DateTime.now(),
//                       );
//                       if (date != null) setState(() => rejectedDateFilter = date);
//                     },
//                     icon: const Icon(Icons.calendar_today, size: 16),
//                     label: Text(
//                       rejectedDateFilter == null
//                           ? "Filter by Date"
//                           : "${rejectedDateFilter!.day}/${rejectedDateFilter!.month}/${rejectedDateFilter!.year}",
//                       style: const TextStyle(fontSize: 12),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 IconButton(
//                   onPressed: () => setState(() {
//                     rejectedDateFilter = null;
//                     rejectedSearch = "";
//                   }),
//                   icon: const Icon(Icons.clear),
//                   tooltip: "Clear Filters",
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
            
//             StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
//               stream: _db
//                   .collection("calls")
//                   .where("status", isEqualTo: "rejected")
//                   .orderBy("timestamp", descending: true)
//                   .limit(50)
//                   .snapshots(),
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return const Center(child: CircularProgressIndicator());
//                 }
                
//                 if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//                   return const Center(
//                     child: Padding(
//                       padding: EdgeInsets.all(32),
//                       child: Column(
//                         children: [
//                           Icon(Icons.call_end, size: 64, color: Colors.grey),
//                           SizedBox(height: 16),
//                           Text("No rejected calls found", 
//                               style: TextStyle(fontSize: 16, color: Colors.grey)),
//                         ],
//                       ),
//                     ),
//                   );
//                 }
                
//                 var docs = snapshot.data!.docs;

//                 // Apply filters
//                 if (rejectedDateFilter != null) {
//                   docs = docs.where((d) {
//                     final ts = (d.data()['timestamp'] as Timestamp?)?.toDate();
//                     if (ts == null) return false;
//                     return ts.year == rejectedDateFilter!.year &&
//                         ts.month == rejectedDateFilter!.month &&
//                         ts.day == rejectedDateFilter!.day;
//                   }).toList();
//                 }

//                 if (rejectedSearch.isNotEmpty) {
//                   docs = docs.where((d) {
//                     final data = d.data();
//                     final volunteerName = (data['volunteerName'] ?? "").toString().toLowerCase();
//                     final userName = (data['userInfo']?['name'] ?? "").toString().toLowerCase();
//                     return volunteerName.contains(rejectedSearch) || userName.contains(rejectedSearch);
//                   }).toList();
//                 }

//                 if (docs.isEmpty) {
//                   return const Center(
//                     child: Padding(
//                       padding: EdgeInsets.all(32),
//                       child: Text("No calls match your search criteria", 
//                           style: TextStyle(fontSize: 16, color: Colors.grey)),
//                     ),
//                   );
//                 }

//                 return Column(
//                   children: docs.map((doc) {
//                     final data = doc.data();
//                     final timestamp = (data['timestamp'] as Timestamp?)?.toDate();
                    
//                     return Card(
//                       margin: const EdgeInsets.symmetric(vertical: 4),
//                       elevation: 1,
//                       child: ListTile(
//                         leading: const CircleAvatar(
//                           backgroundColor: Colors.red,
//                           child: Icon(Icons.call_end, color: Colors.white, size: 20),
//                         ),
//                         title: Text(
//                           data['volunteerName'] ?? "Unknown Volunteer",
//                           style: const TextStyle(fontWeight: FontWeight.w600),
//                         ),
//                         subtitle: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text("Time Slot: ${data['timeSlot'] ?? 'N/A'}"),
//                             if (timestamp != null)
//                               Text("Date: ${timestamp.day}/${timestamp.month}/${timestamp.year} ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}"),
//                           ],
//                         ),
//                         trailing: Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             ElevatedButton(
//                               onPressed: () => _showUserInfoModal(data['userInfo']),
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: Colors.blue[100],
//                                 foregroundColor: Colors.blue[800],
//                                 padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                               ),
//                               child: const Text("User Info", style: TextStyle(fontSize: 12)),
//                             ),
//                             const SizedBox(width: 6),
//                             ElevatedButton(
//                               onPressed: () => _showCallVolunteerInfoModal(data['volunteerInfo']),
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: Colors.green[100],
//                                 foregroundColor: Colors.green[800],
//                                 padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                               ),
//                               child: const Text("Volunteer Info", style: TextStyle(fontSize: 12)),
//                             ),
//                           ],
//                         ),
//                       ),
//                     );
//                   }).toList(),
//                 );
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // Show detailed volunteer info modal (from registration)
//   void _showVolunteerInfoModal(Map<String, dynamic> info, String docId) {
//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: Row(
//           children: [
//             const Icon(Icons.person, color: Colors.green),
//             const SizedBox(width: 8),
//             const Text("Volunteer Details"),
//           ],
//         ),
//         content: SizedBox(
//           width: double.maxFinite,
//           height: 500,
//           child: SingleChildScrollView(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 _buildInfoSection("Personal Information", {
//                   'Full Name': info['fullName'],
//                   'Email': info['email'],
//                   'Phone': info['phone'],
//                   'Date of Birth': info['dob'],
//                 }),
                
//                 if (info['address'] != null) 
//                   _buildInfoSection("Address", info['address'] as Map<String, dynamic>),
                
//                 if (info['roles'] != null && info['roles'] is List)
//                   _buildListSection("Roles", info['roles'] as List),
                
//                 if (info['availabilityDays'] != null && info['availabilityDays'] is List)
//                   _buildListSection("Available Days", info['availabilityDays'] as List),
                
//                 if (info['availabilityTimes'] != null && info['availabilityTimes'] is List)
//                   _buildListSection("Available Times", info['availabilityTimes'] as List),
                
//                 if (info['additionalInfo'] != null)
//                   _buildInfoSection("Additional Information", info['additionalInfo'] as Map<String, dynamic>),
//               ],
//             ),
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text("Close"),
//           ),
//         ],
//       ),
//     );
//   }

//   // Show volunteer info from call data
//   void _showCallVolunteerInfoModal(Map<String, dynamic>? info) {
//     if (info == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("No volunteer information available")),
//       );
//       return;
//     }
    
//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: Row(
//           children: [
//             const Icon(Icons.person, color: Colors.green),
//             const SizedBox(width: 8),
//             const Text("Call Volunteer Info"),
//           ],
//         ),
//         content: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: info.entries.map((e) {
//               return Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 4),
//                 child: Row(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     SizedBox(
//                       width: 100,
//                       child: Text(
//                         "${e.key}:",
//                         style: const TextStyle(fontWeight: FontWeight.w500),
//                       ),
//                     ),
//                     Expanded(child: Text(e.value?.toString() ?? "N/A")),
//                   ],
//                 ),
//               );
//             }).toList(),
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text("Close"),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showUserInfoModal(Map<String, dynamic>? info) {
//     if (info == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("No user information available")),
//       );
//       return;
//     }
    
//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: Row(
//           children: [
//             const Icon(Icons.person_outline, color: Colors.blue),
//             const SizedBox(width: 8),
//             const Text("User Info"),
//           ],
//         ),
//         content: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: info.entries.map((e) {
//               return Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 4),
//                 child: Row(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     SizedBox(
//                       width: 100,
//                       child: Text(
//                         "${e.key}:",

















import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HelplineVolunteersPage extends StatefulWidget {
  const HelplineVolunteersPage({Key? key}) : super(key: key);

  @override
  State<HelplineVolunteersPage> createState() => _HelplineVolunteersPageState();
}

class _HelplineVolunteersPageState extends State<HelplineVolunteersPage> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  
  // Filters
  String? volunteerSlotFilter;
  DateTime? acceptedDateFilter;
  DateTime? rejectedDateFilter;

  // Search per table
  String volunteerSearch = "";
  String acceptedSearch = "";
  String rejectedSearch = "";

  final List<String> allTimeSlots = [
    "12:00 AM – 4:00 AM",
    "4:00 AM – 8:00 AM", 
    "8:00 AM – 12:00 PM",
    "12:00 PM – 4:00 PM",
    "4:00 PM – 8:00 PM",
    "8:00 PM – 12:00 AM",
    "Flexible / Available 24 Hours"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Helpline Volunteers"),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Statistics
            _buildSummaryCards(),
            const SizedBox(height: 20),
            
            _buildVolunteerTable(),
            const SizedBox(height: 30),
            _buildAcceptedCallsTable(),
            const SizedBox(height: 30),
            _buildRejectedCallsTable(),
          ],
        ),
      ),
    );
  }

  // Summary Cards
  Widget _buildSummaryCards() {
    return StreamBuilder<QuerySnapshot>(
      stream: _db.collection('volunteers')
          .where('volunteerType', isEqualTo: 'helpline')
          .where('status', isEqualTo: 'approved')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        int totalVolunteers = snapshot.data!.docs.length;
        
        return StreamBuilder<QuerySnapshot>(
          stream: _db.collection('calls').snapshots(),
          builder: (context, callSnapshot) {
            if (!callSnapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            var callDocs = callSnapshot.data!.docs;
            int answeredCalls = callDocs.where((d) => d.get('status') == 'answered').length;
            int rejectedCalls = callDocs.where((d) => d.get('status') == 'rejected').length;
            int pendingCalls = callDocs.where((d) => d.get('status') == 'pending').length;

            return Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    title: "Active Volunteers",
                    value: "$totalVolunteers",
                    icon: Icons.people,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    title: "Calls Answered",
                    value: "$answeredCalls",
                    icon: Icons.call_received,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    title: "Calls Rejected",
                    value: "$rejectedCalls",
                    icon: Icons.call_end,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    title: "Pending Calls",
                    value: "$pendingCalls",
                    icon: Icons.pending,
                    color: Colors.orange,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          gradient: LinearGradient(
            colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVolunteerTable() {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.people, color: Colors.green),
                const SizedBox(width: 8),
                const Text("Approved Helpline Volunteers",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            
            // Filters Row
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: "Search by Name/Email",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.search),
                      isDense: true,
                    ),
                    onChanged: (val) => setState(() => volunteerSearch = val.toLowerCase()),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<String>(
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: "Filter by Time Slot",
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    value: volunteerSlotFilter,
                    items: allTimeSlots
                        .map((slot) => DropdownMenuItem(value: slot, child: Text(slot, style: const TextStyle(fontSize: 12))))
                        .toList(),
                    onChanged: (val) => setState(() => volunteerSlotFilter = val),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => setState(() {
                    volunteerSlotFilter = null;
                    volunteerSearch = "";
                  }),
                  icon: const Icon(Icons.clear),
                  tooltip: "Clear Filters",
                )
              ],
            ),
            const SizedBox(height: 16),
            
            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _db
                  .collection('volunteers')
                  .where('volunteerType', isEqualTo: 'helpline')
                  .where('status', isEqualTo: 'approved')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }
                
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(Icons.people_outline, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text("No approved helpline volunteers found", 
                              style: TextStyle(fontSize: 16, color: Colors.grey)),
                        ],
                      ),
                    ),
                  );
                }

                var docs = snapshot.data!.docs;

                // Apply filters
                if (volunteerSlotFilter != null) {
                  docs = docs.where((d) {
                    final times = List<String>.from(d.data()['availabilityTimes'] ?? []);
                    return times.contains(volunteerSlotFilter);
                  }).toList();
                }
                
                if (volunteerSearch.isNotEmpty) {
                  docs = docs.where((d) {
                    final data = d.data();
                    final name = (data['fullName'] ?? "").toString().toLowerCase();
                    final email = (data['email'] ?? "").toString().toLowerCase();
                    return name.contains(volunteerSearch) || email.contains(volunteerSearch);
                  }).toList();
                }

                if (docs.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Text("No volunteers match your search criteria", 
                          style: TextStyle(fontSize: 16, color: Colors.grey)),
                    ),
                  );
                }

                return Column(
                  children: docs.map((doc) {
                    final data = doc.data();
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      elevation: 2,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.green[100],
                          child: Text(
                            (data['fullName'] ?? "?").substring(0, 1).toUpperCase(),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        title: Text(
                          data['fullName'] ?? "Unnamed",
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(data['email'] ?? ""),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.phone, size: 14, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text(data['phone'] ?? "N/A", style: const TextStyle(fontSize: 12)),
                              ],
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if ((data['availabilityTimes'] as List?)?.isNotEmpty == true)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.blue[100],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  "${(data['availabilityTimes'] as List).length} slots",
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                                ),
                              ),
                            const SizedBox(width: 8),
                            ElevatedButton.icon(
                              onPressed: () => _showVolunteerInfoModal(data, doc.id),
                              icon: const Icon(Icons.info_outline, size: 16),
                              label: const Text("Details"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAcceptedCallsTable() {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.call_received, color: Colors.blue),
                const SizedBox(width: 8),
                const Text("Accepted Calls", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: "Search by Volunteer/User Name",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.search),
                      isDense: true,
                    ),
                    onChanged: (val) => setState(() => acceptedSearch = val.toLowerCase()),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: acceptedDateFilter ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) setState(() => acceptedDateFilter = date);
                    },
                    icon: const Icon(Icons.calendar_today, size: 16),
                    label: Text(
                      acceptedDateFilter == null
                          ? "Filter by Date"
                          : "${acceptedDateFilter!.day}/${acceptedDateFilter!.month}/${acceptedDateFilter!.year}",
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => setState(() {
                    acceptedDateFilter = null;
                    acceptedSearch = "";
                  }),
                  icon: const Icon(Icons.clear),
                  tooltip: "Clear Filters",
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _db
                  .collection("calls")
                  .where("status", isEqualTo: "answered")
                  .orderBy("timestamp", descending: true)
                  .limit(50)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(Icons.call_received, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text("No accepted calls found", 
                              style: TextStyle(fontSize: 16, color: Colors.grey)),
                        ],
                      ),
                    ),
                  );
                }
                
                var docs = snapshot.data!.docs;

                // Apply filters
                if (acceptedDateFilter != null) {
                  docs = docs.where((d) {
                    final ts = (d.data()['timestamp'] as Timestamp?)?.toDate();
                    if (ts == null) return false;
                    return ts.year == acceptedDateFilter!.year &&
                        ts.month == acceptedDateFilter!.month &&
                        ts.day == acceptedDateFilter!.day;
                  }).toList();
                }

                if (acceptedSearch.isNotEmpty) {
                  docs = docs.where((d) {
                    final data = d.data();
                    final volunteerName = (data['volunteerName'] ?? "").toString().toLowerCase();
                    final userName = (data['userInfo']?['name'] ?? "").toString().toLowerCase();
                    return volunteerName.contains(acceptedSearch) || userName.contains(acceptedSearch);
                  }).toList();
                }

                if (docs.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Text("No calls match your search criteria", 
                          style: TextStyle(fontSize: 16, color: Colors.grey)),
                    ),
                  );
                }

                return Column(
                  children: docs.map((doc) {
                    final data = doc.data();
                    final timestamp = (data['timestamp'] as Timestamp?)?.toDate();
                    
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      elevation: 1,
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Colors.blue,
                          child: Icon(Icons.call, color: Colors.white, size: 20),
                        ),
                        title: Text(
                          data['volunteerName'] ?? "Unknown Volunteer",
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Time Slot: ${data['timeSlot'] ?? 'N/A'}"),
                            if (timestamp != null)
                              Text("Date: ${timestamp.day}/${timestamp.month}/${timestamp.year} ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}"),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ElevatedButton(
                              onPressed: () => _showUserInfoModal(data['userInfo']),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue[100],
                                foregroundColor: Colors.blue[800],
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              ),
                              child: const Text("User Info", style: TextStyle(fontSize: 12)),
                            ),
                            const SizedBox(width: 6),
                            ElevatedButton(
                              onPressed: () => _showCallVolunteerInfoModal(data['volunteerInfo']),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green[100],
                                foregroundColor: Colors.green[800],
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              ),
                              child: const Text("Volunteer Info", style: TextStyle(fontSize: 12)),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRejectedCallsTable() {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.call_end, color: Colors.red),
                const SizedBox(width: 8),
                const Text("Rejected Calls", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: "Search by Volunteer/User Name",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.search),
                      isDense: true,
                    ),
                    onChanged: (val) => setState(() => rejectedSearch = val.toLowerCase()),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: rejectedDateFilter ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) setState(() => rejectedDateFilter = date);
                    },
                    icon: const Icon(Icons.calendar_today, size: 16),
                    label: Text(
                      rejectedDateFilter == null
                          ? "Filter by Date"
                          : "${rejectedDateFilter!.day}/${rejectedDateFilter!.month}/${rejectedDateFilter!.year}",
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => setState(() {
                    rejectedDateFilter = null;
                    rejectedSearch = "";
                  }),
                  icon: const Icon(Icons.clear),
                  tooltip: "Clear Filters",
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _db
                  .collection("calls")
                  .where("status", isEqualTo: "rejected")
                  .orderBy("timestamp", descending: true)
                  .limit(50)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(Icons.call_end, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text("No rejected calls found", 
                              style: TextStyle(fontSize: 16, color: Colors.grey)),
                        ],
                      ),
                    ),
                  );
                }
                
                var docs = snapshot.data!.docs;

                // Apply filters
                if (rejectedDateFilter != null) {
                  docs = docs.where((d) {
                    final ts = (d.data()['timestamp'] as Timestamp?)?.toDate();
                    if (ts == null) return false;
                    return ts.year == rejectedDateFilter!.year &&
                        ts.month == rejectedDateFilter!.month &&
                        ts.day == rejectedDateFilter!.day;
                  }).toList();
                }

                if (rejectedSearch.isNotEmpty) {
                  docs = docs.where((d) {
                    final data = d.data();
                    final volunteerName = (data['volunteerName'] ?? "").toString().toLowerCase();
                    final userName = (data['userInfo']?['name'] ?? "").toString().toLowerCase();
                    return volunteerName.contains(rejectedSearch) || userName.contains(rejectedSearch);
                  }).toList();
                }

                if (docs.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Text("No calls match your search criteria", 
                          style: TextStyle(fontSize: 16, color: Colors.grey)),
                    ),
                  );
                }

                return Column(
                  children: docs.map((doc) {
                    final data = doc.data();
                    final timestamp = (data['timestamp'] as Timestamp?)?.toDate();
                    
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      elevation: 1,
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Colors.red,
                          child: Icon(Icons.call_end, color: Colors.white, size: 20),
                        ),
                        title: Text(
                          data['volunteerName'] ?? "Unknown Volunteer",
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Time Slot: ${data['timeSlot'] ?? 'N/A'}"),
                            if (timestamp != null)
                              Text("Date: ${timestamp.day}/${timestamp.month}/${timestamp.year} ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}"),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ElevatedButton(
                              onPressed: () => _showUserInfoModal(data['userInfo']),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue[100],
                                foregroundColor: Colors.blue[800],
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              ),
                              child: const Text("User Info", style: TextStyle(fontSize: 12)),
                            ),
                            const SizedBox(width: 6),
                            ElevatedButton(
                              onPressed: () => _showCallVolunteerInfoModal(data['volunteerInfo']),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green[100],
                                foregroundColor: Colors.green[800],
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              ),
                              child: const Text("Volunteer Info", style: TextStyle(fontSize: 12)),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Show detailed volunteer info modal (from registration)
  void _showVolunteerInfoModal(Map<String, dynamic> info, String docId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.person, color: Colors.green),
            const SizedBox(width: 8),
            const Text("Volunteer Details"),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 500,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoSection("Personal Information", {
                  'Full Name': info['fullName'],
                  'Email': info['email'],
                  'Phone': info['phone'],
                  'Date of Birth': info['dob'],
                }),
                
                if (info['address'] != null) 
                  _buildInfoSection("Address", info['address'] as Map<String, dynamic>),
                
                if (info['roles'] != null && info['roles'] is List)
                  _buildListSection("Roles", info['roles'] as List),
                
                if (info['availabilityDays'] != null && info['availabilityDays'] is List)
                  _buildListSection("Available Days", info['availabilityDays'] as List),
                
                if (info['availabilityTimes'] != null && info['availabilityTimes'] is List)
                  _buildListSection("Available Times", info['availabilityTimes'] as List),
                
                if (info['additionalInfo'] != null)
                  _buildInfoSection("Additional Information", info['additionalInfo'] as Map<String, dynamic>),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  // Show volunteer info from call data
  void _showCallVolunteerInfoModal(Map<String, dynamic>? info) {
    if (info == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No volunteer information available")),
      );
      return;
    }
    
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.person, color: Colors.green),
            const SizedBox(width: 8),
            const Text("Call Volunteer Info"),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: info.entries.map((e) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 100,
                      child: Text(
                        "${e.key}:",
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    Expanded(child: Text(e.value?.toString() ?? "N/A")),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  void _showUserInfoModal(Map<String, dynamic>? info) {
    if (info == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No user information available")),
      );
      return;
    }
    
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.person_outline, color: Colors.blue),
            const SizedBox(width: 8),
            const Text("User Info"),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: info.entries.map((e) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 100,
                      child: Text(
                        "${e.key}:",
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    Expanded(child: Text(e.value?.toString() ?? "N/A")),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, Map<String, dynamic> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green),
        ),
        const SizedBox(height: 8),
        ...data.entries.map((e) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 120,
                  child: Text(
                    "${e.key}:",
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                Expanded(child: Text(e.value?.toString() ?? "N/A")),
              ],
            ),
          );
        }),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildListSection(String title, List<dynamic> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: items.map((item) {
            return Chip(
              label: Text(item.toString()),
              backgroundColor: Colors.green[100],
              labelStyle: const TextStyle(fontSize: 12),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}