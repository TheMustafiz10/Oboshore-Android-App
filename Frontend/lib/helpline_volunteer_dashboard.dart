

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

class HelplineVolunteerDashboard extends StatefulWidget {
  const HelplineVolunteerDashboard({super.key});

  @override
  State<HelplineVolunteerDashboard> createState() => _HelplineVolunteerDashboardState();
}

class _HelplineVolunteerDashboardState extends State<HelplineVolunteerDashboard>
    with SingleTickerProviderStateMixin {
  
  final User? currentUser = FirebaseAuth.instance.currentUser;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  
  String volunteerName = "Loading...";
  bool isOnline = true;
  String currentStatus = "Available";
  String? activeCallId;
  Timer? _statusTimer;
  StreamSubscription<DocumentSnapshot>? _profileSubscription;

  int totalCallsToday = 0;
  int acceptedCalls = 0;
  int rejectedCalls = 0;
  int missedCalls = 0;
  Duration totalCallDuration = Duration.zero;
  
  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadVolunteerData();
    _startStatusTimer();
    _listenToProfileUpdates();
  }
  
  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _pulseController.repeat(reverse: true);
  }
  
  void _startStatusTimer() {
    _statusTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _updateOnlineStatus();
    });
  }
  
  void _listenToProfileUpdates() {
    if (currentUser != null) {
      _profileSubscription = FirebaseFirestore.instance
          .collection('volunteers')
          .doc(currentUser!.uid)
          .snapshots()
          .listen((doc) {
        if (doc.exists && mounted) {
          setState(() {
            volunteerName = doc.get('fullName') ?? 'Unknown'; 
          });
        }
      });
    }
  }
  
  Future<void> _loadVolunteerData() async {
    if (currentUser != null) {
      try {
        DocumentSnapshot doc = await FirebaseFirestore.instance
            .collection('volunteers')
            .doc(currentUser!.uid)
            .get();
        
        if (doc.exists && mounted) {
          setState(() {
            volunteerName = doc.get('fullName') ?? 'Unknown'; 
          });
        }
        _loadTodayStatistics();
      } catch (e) {
        print("Error loading volunteer data: $e");
      }
    }
  }
  
  Future<void> _loadTodayStatistics() async {
    if (currentUser == null) return;
    
    DateTime today = DateTime.now();
    DateTime startOfDay = DateTime(today.year, today.month, today.day);
    
    try {
      QuerySnapshot callsSnapshot = await FirebaseFirestore.instance
          .collection('helpline_calls')
          .where('volunteerId', isEqualTo: currentUser!.uid)
          .where('timestamp', isGreaterThan: Timestamp.fromDate(startOfDay))
          .get();
      
      if (mounted) {
        setState(() {
          totalCallsToday = callsSnapshot.docs.length;
          acceptedCalls = callsSnapshot.docs.where((doc) => 
              (doc.data() as Map<String, dynamic>)['status'] == 'accepted').length; 
          rejectedCalls = callsSnapshot.docs.where((doc) => 
              (doc.data() as Map<String, dynamic>)['status'] == 'rejected').length; 
          missedCalls = callsSnapshot.docs.where((doc) => 
              (doc.data() as Map<String, dynamic>)['status'] == 'missed').length; 
        });
      }
    } catch (e) {
      print("Error loading statistics: $e");
    }
  }
  
  Future<void> _updateOnlineStatus() async {
    if (currentUser != null) {
      try {
        await FirebaseFirestore.instance
            .collection('volunteer_status')
            .doc(currentUser!.uid)
            .set({
          'isOnline': isOnline,
          'lastSeen': FieldValue.serverTimestamp(),
          'status': currentStatus,
          'volunteerName': volunteerName, 
        }, SetOptions(merge: true));
      } catch (e) {
        print("Error updating status: $e");
      }
    }
  }
  
  Future<void> _acceptCall(String callId, Map<String, dynamic> callData) async {
    try {
      await FirebaseFirestore.instance
          .collection('helpline_calls')
          .doc(callId)
          .update({
        'status': 'accepted',
        'volunteerId': currentUser!.uid,
        'volunteerName': volunteerName,
        'acceptedAt': FieldValue.serverTimestamp(),
      });
      
      if (mounted) {
        setState(() {
          activeCallId = callId;
          currentStatus = "In Call";
          acceptedCalls++;
        });
      }
      
      _updateOnlineStatus();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Call accepted from ${callData['callerName'] ?? 'Unknown'}"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error accepting call: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }
  
  Future<void> _rejectCall(String callId, Map<String, dynamic> callData) async {
    try {
      await FirebaseFirestore.instance
          .collection('helpline_calls')
          .doc(callId)
          .update({
        'status': 'rejected',
        'rejectedBy': currentUser!.uid,
        'rejectedAt': FieldValue.serverTimestamp(),
      });
      
      if (mounted) {
        setState(() {
          rejectedCalls++;
        });
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Call rejected from ${callData['callerName'] ?? 'Unknown'}"),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error rejecting call: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }
  
  Future<void> _endCall() async {
    if (activeCallId != null) {
      try {
        await FirebaseFirestore.instance
            .collection('helpline_calls')
            .doc(activeCallId!)
            .update({
          'status': 'completed',
          'endedAt': FieldValue.serverTimestamp(),
          'endedBy': 'volunteer',
        });
        
        if (mounted) {
          setState(() {
            activeCallId = null;
            currentStatus = "Available";
          });
        }
        
        _updateOnlineStatus();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Call ended successfully"),
              backgroundColor: Colors.blue,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error ending call: $e"), backgroundColor: Colors.red),
          );
        }
      }
    }
  }
  
  Future<void> _toggleAvailability() async {
    if (mounted) {
      setState(() {
        isOnline = !isOnline;
        currentStatus = isOnline ? "Available" : "Offline";
      });
    }
    await _updateOnlineStatus();
  }
  
  Future<void> _logout() async {
    try {
      if (currentUser != null) {
        await FirebaseFirestore.instance
            .collection('volunteer_status')
            .doc(currentUser!.uid)
            .update({
          'isOnline': false,
          'status': 'Offline',
          'lastSeen': FieldValue.serverTimestamp(),
        });
      }
      
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error logging out: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }
  
  Future<void> _deleteProfile() async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Profile"),
        content: const Text("Are you sure you want to permanently delete your profile? This action cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false), 
            child: const Text("Cancel")
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Delete"),
          ),
        ],
      ),
    );
    
    if (confirm == true && currentUser != null) {
      try {
        await FirebaseFirestore.instance
            .collection('volunteers')
            .doc(currentUser!.uid)
            .delete();
        
        await FirebaseFirestore.instance
            .collection('volunteer_status')
            .doc(currentUser!.uid)
            .delete();
        
        await currentUser!.delete();
        
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/login');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error deleting profile: $e"), backgroundColor: Colors.red),
          );
        }
      }
    }
  }
  
  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.8), color],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  Widget _buildCallRequestCard(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    DateTime timestamp = (data['timestamp'] as Timestamp).toDate();
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.red.withOpacity(0.1), Colors.red.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(Icons.phone, color: Colors.white, size: 16),
                    ),
                  );
                },
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data['callerName'] ?? 'Anonymous Caller',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      "Incoming call - ${_formatTimeAgo(timestamp)}",
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (data['urgencyLevel'] != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getUrgencyColor(data['urgencyLevel']),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "Urgency: ${data['urgencyLevel']}",
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: activeCallId == null ? () => _acceptCall(doc.id, data) : null,
                  icon: const Icon(Icons.call, size: 18),
                  label: const Text("Accept"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _rejectCall(doc.id, data),
                  icon: const Icon(Icons.call_end, size: 18),
                  label: const Text("Reject"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Color _getUrgencyColor(String urgency) {
    switch (urgency.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.blue;
    }
  }
  
  String _formatTimeAgo(DateTime timestamp) {
    Duration diff = DateTime.now().difference(timestamp);
    if (diff.inMinutes < 1) return "Just now";
    if (diff.inMinutes < 60) return "${diff.inMinutes}m ago";
    if (diff.inHours < 24) return "${diff.inHours}h ago";
    return "${diff.inDays}d ago";
  }
  
  @override
  void dispose() {
    _pulseController.dispose();
    _statusTimer?.cancel();
    _profileSubscription?.cancel();
    if (currentUser != null) {
      FirebaseFirestore.instance
          .collection('volunteer_status')
          .doc(currentUser!.uid)
          .update({
        'isOnline': false,
        'status': 'Offline',
        'lastSeen': FieldValue.serverTimestamp(),
      });
    }
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade50, Colors.indigo.shade100],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade600, Colors.indigo.shade700],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Welcome back,",
                              style: TextStyle(color: Colors.white70, fontSize: 14),
                            ),
                            Text(
                              volunteerName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        PopupMenuButton(
                          icon: const Icon(Icons.more_vert, color: Colors.white),
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              child: ListTile(
                                leading: const Icon(Icons.edit),
                                title: const Text("Update Profile"),
                                onTap: () {
                                  Navigator.pop(context);
                                },
                              ),
                            ),
                            PopupMenuItem(
                              child: ListTile(
                                leading: const Icon(Icons.logout),
                                title: const Text("Logout"),
                                onTap: () {
                                  Navigator.pop(context);
                                  _logout();
                                },
                              ),
                            ),
                            PopupMenuItem(
                              child: ListTile(
                                leading: const Icon(Icons.delete, color: Colors.red),
                                title: const Text("Delete Profile", style: TextStyle(color: Colors.red)),
                                onTap: () {
                                  Navigator.pop(context);
                                  _deleteProfile();
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: isOnline ? Colors.green : Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              currentStatus,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                        Switch(
                          value: isOnline,
                          onChanged: activeCallId == null 
                            ? (value) => _toggleAvailability() 
                            : null, 
                          activeColor: Colors.green,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              if (activeCallId != null)
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.green.shade400, Colors.green.shade600],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          AnimatedBuilder(
                            animation: _pulseAnimation,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: _pulseAnimation.value,
                                child: const Icon(Icons.phone_in_talk, color: Colors.white, size: 24),
                              );
                            },
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Call in Progress",
                                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  "You are currently helping someone",
                                  style: TextStyle(color: Colors.white70, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _endCall,
                          icon: const Icon(Icons.call_end),
                          label: const Text("End Call"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GridView.count(
                        crossAxisCount: 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 1.3,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          _buildStatCard("Today's Calls", "$totalCallsToday", Icons.phone, Colors.blue),
                          _buildStatCard("Accepted", "$acceptedCalls", Icons.call_received, Colors.green),
                          _buildStatCard("Rejected", "$rejectedCalls", Icons.call_end, Colors.orange),
                          _buildStatCard("Missed", "$missedCalls", Icons.phone_missed, Colors.red),
                        ],
                      ),
                      
                      const SizedBox(height: 24),

                      Row(
                        children: [
                          const Icon(Icons.phone_callback, color: Colors.blue),
                          const SizedBox(width: 8),
                          const Text(
                            "Incoming Calls",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              "Real-time",
                              style: TextStyle(color: Colors.blue, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),

                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('helpline_calls')
                            .where('status', isEqualTo: 'pending')
                            .orderBy('timestamp', descending: true)
                            .limit(10)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text("Error loading calls: ${snapshot.error}"),
                            );
                          }
                          
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          
                          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                            return Container(
                              padding: const EdgeInsets.all(32),
                              decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Column(
                                children: [
                                  Icon(Icons.phone_disabled, size: 48, color: Colors.grey),
                                  SizedBox(height: 16),
                                  Text(
                                    "No incoming calls",
                                    style: TextStyle(fontSize: 16, color: Colors.grey),
                                  ),
                                  Text(
                                    "You'll see new calls here in real-time",
                                    style: TextStyle(fontSize: 12, color: Colors.grey),
                                  ),
                                ],
                              ),
                            );
                          }
                          
                          return Column(
                            children: snapshot.data!.docs
                                .map((doc) => _buildCallRequestCard(doc))
                                .toList(),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}














// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'dart:async';

// class HelplineVolunteerDashboard extends StatefulWidget {
//   const HelplineVolunteerDashboard({super.key});

//   @override
//   State<HelplineVolunteerDashboard> createState() => _HelplineVolunteerDashboardState();
// }

// class _HelplineVolunteerDashboardState extends State<HelplineVolunteerDashboard>
//     with SingleTickerProviderStateMixin {
  
//   final User? currentUser = FirebaseAuth.instance.currentUser;
//   late AnimationController _pulseController;
//   late Animation<double> _pulseAnimation;
  
//   String volunteerName = "Loading...";
//   bool isOnline = true;
//   String currentStatus = "Available";
//   String? activeCallId;
//   Timer? _statusTimer;
//   StreamSubscription<DocumentSnapshot>? _profileSubscription;
//   StreamSubscription<QuerySnapshot>? _callsSubscription;
//   StreamSubscription<QuerySnapshot>? _announcementsSubscription;
  
//   List<Map<String, dynamic>> announcements = [];
//   int totalCallsToday = 0;
//   int acceptedCalls = 0;
//   int rejectedCalls = 0;
//   int missedCalls = 0;
//   Duration totalCallDuration = Duration.zero;
  
//   @override
//   void initState() {
//     super.initState();
//     _initializeAnimations();
//     _loadVolunteerData();
//     _startStatusTimer();
//     _listenToProfileUpdates();
//     _listenToCallsUpdates();
//     _listenToAnnouncements();
//   }
  
//   void _initializeAnimations() {
//     _pulseController = AnimationController(
//       duration: const Duration(seconds: 2),
//       vsync: this,
//     );
//     _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
//       CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
//     );
//     _pulseController.repeat(reverse: true);
//   }
  
//   void _startStatusTimer() {
//     _statusTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
//       _updateOnlineStatus();
//     });
//   }
  
//   void _listenToProfileUpdates() {
//     if (currentUser != null) {
//       _profileSubscription = FirebaseFirestore.instance
//           .collection('volunteers')
//           .doc(currentUser!.uid)
//           .snapshots()
//           .listen((doc) {
//         if (doc.exists && mounted) {
//           setState(() {
//             volunteerName = doc.get('fullName') ?? 'Unknown'; 
//           });
//         }
//       });
//     }
//   }
  
//   void _listenToCallsUpdates() {
//     if (currentUser == null) return;
    
//     DateTime today = DateTime.now();
//     DateTime startOfDay = DateTime(today.year, today.month, today.day);
    
//     _callsSubscription = FirebaseFirestore.instance
//         .collection('helpline_calls')
//         .where('volunteerId', isEqualTo: currentUser!.uid)
//         .where('timestamp', isGreaterThan: Timestamp.fromDate(startOfDay))
//         .snapshots()
//         .listen((snapshot) {
//       if (mounted) {
//         setState(() {
//           totalCallsToday = snapshot.docs.length;
//           acceptedCalls = snapshot.docs.where((doc) => 
//               (doc.data() as Map<String, dynamic>)['status'] == 'accepted').length; 
//           rejectedCalls = snapshot.docs.where((doc) => 
//               (doc.data() as Map<String, dynamic>)['status'] == 'rejected').length; 
//           missedCalls = snapshot.docs.where((doc) => 
//               (doc.data() as Map<String, dynamic>)['status'] == 'missed').length; 
//         });
//       }
//     });
//   }
  
//   void _listenToAnnouncements() {
//     _announcementsSubscription = FirebaseFirestore.instance
//         .collection('announcements')
//         .where('isActive', isEqualTo: true)
//         .orderBy('createdAt', descending: true)
//         .limit(5)
//         .snapshots()
//         .listen((snapshot) {
//       if (mounted) {
//         setState(() {
//           announcements = snapshot.docs.map((doc) {
//             final data = doc.data() as Map<String, dynamic>;
//             data['id'] = doc.id;
//             return data;
//           }).toList();
//         });
//       }
//     });
//   }
  
//   Future<void> _loadVolunteerData() async {
//     if (currentUser != null) {
//       try {
//         DocumentSnapshot doc = await FirebaseFirestore.instance
//             .collection('volunteers')
//             .doc(currentUser!.uid)
//             .get();
        
//         if (doc.exists && mounted) {
//           setState(() {
//             volunteerName = doc.get('fullName') ?? 'Unknown'; 
//           });
//         }
//       } catch (e) {
//         print("Error loading volunteer data: $e");
//       }
//     }
//   }
  
//   Future<void> _updateOnlineStatus() async {
//     if (currentUser != null) {
//       try {
//         await FirebaseFirestore.instance
//             .collection('volunteer_status')
//             .doc(currentUser!.uid)
//             .set({
//           'isOnline': isOnline,
//           'lastSeen': FieldValue.serverTimestamp(),
//           'status': currentStatus,
//           'volunteerName': volunteerName, 
//         }, SetOptions(merge: true));
//       } catch (e) {
//         print("Error updating status: $e");
//       }
//     }
//   }
  
//   Future<void> _acceptCall(String callId, Map<String, dynamic> callData) async {
//     try {
//       await FirebaseFirestore.instance
//           .collection('helpline_calls')
//           .doc(callId)
//           .update({
//         'status': 'accepted',
//         'volunteerId': currentUser!.uid,
//         'volunteerName': volunteerName,
//         'acceptedAt': FieldValue.serverTimestamp(),
//       });
      
//       if (mounted) {
//         setState(() {
//           activeCallId = callId;
//           currentStatus = "In Call";
//         });
//       }
      
//       _updateOnlineStatus();
      
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text("Call accepted from ${callData['callerName'] ?? 'Unknown'}"),
//             backgroundColor: Colors.green,
//           ),
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text("Error accepting call: $e"), backgroundColor: Colors.red),
//         );
//       }
//     }
//   }
  
//   Future<void> _rejectCall(String callId, Map<String, dynamic> callData) async {
//     try {
//       await FirebaseFirestore.instance
//           .collection('helpline_calls')
//           .doc(callId)
//           .update({
//         'status': 'rejected',
//         'rejectedBy': currentUser!.uid,
//         'rejectedAt': FieldValue.serverTimestamp(),
//       });
      
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text("Call rejected from ${callData['callerName'] ?? 'Unknown'}"),
//             backgroundColor: Colors.orange,
//           ),
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text("Error rejecting call: $e"), backgroundColor: Colors.red),
//         );
//       }
//     }
//   }
  
//   Future<void> _endCall() async {
//     if (activeCallId != null) {
//       try {
//         await FirebaseFirestore.instance
//             .collection('helpline_calls')
//             .doc(activeCallId!)
//             .update({
//           'status': 'completed',
//           'endedAt': FieldValue.serverTimestamp(),
//           'endedBy': 'volunteer',
//         });
        
//         if (mounted) {
//           setState(() {
//             activeCallId = null;
//             currentStatus = "Available";
//           });
//         }
        
//         _updateOnlineStatus();
        
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text("Call ended successfully"),
//               backgroundColor: Colors.blue,
//             ),
//           );
//         }
//       } catch (e) {
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text("Error ending call: $e"), backgroundColor: Colors.red),
//           );
//         }
//       }
//     }
//   }
  
//   Future<void> _toggleAvailability() async {
//     if (mounted) {
//       setState(() {
//         isOnline = !isOnline;
//         currentStatus = isOnline ? "Available" : "Offline";
//       });
//     }
//     await _updateOnlineStatus();
//   }
  
//   Future<void> _updateProfile() async {
//     final TextEditingController nameController = TextEditingController(text: volunteerName);
    
//     bool? result = await showDialog<bool>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text("Update Profile"),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             TextField(
//               controller: nameController,
//               decoration: const InputDecoration(
//                 labelText: "Full Name",
//                 border: OutlineInputBorder(),
//               ),
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(false),
//             child: const Text("Cancel"),
//           ),
//           ElevatedButton(
//             onPressed: () => Navigator.of(context).pop(true),
//             child: const Text("Update"),
//           ),
//         ],
//       ),
//     );
    
//     if (result == true && currentUser != null) {
//       try {
//         await FirebaseFirestore.instance
//             .collection('volunteers')
//             .doc(currentUser!.uid)
//             .update({
//           'fullName': nameController.text.trim(),
//           'updatedAt': FieldValue.serverTimestamp(),
//         });
        
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text("Profile updated successfully"),
//               backgroundColor: Colors.green,
//             ),
//           );
//         }
//       } catch (e) {
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text("Error updating profile: $e"), backgroundColor: Colors.red),
//           );
//         }
//       }
//     }
//   }
  
//   Future<void> _logout() async {
//     bool? confirm = await showDialog<bool>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text("Logout"),
//         content: const Text("Are you sure you want to logout?"),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(false),
//             child: const Text("Cancel"),
//           ),
//           ElevatedButton(
//             onPressed: () => Navigator.of(context).pop(true),
//             style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
//             child: const Text("Logout"),
//           ),
//         ],
//       ),
//     );
    
//     if (confirm == true) {
//       try {
//         if (currentUser != null) {
//           await FirebaseFirestore.instance
//               .collection('volunteer_status')
//               .doc(currentUser!.uid)
//               .update({
//             'isOnline': false,
//             'status': 'Offline',
//             'lastSeen': FieldValue.serverTimestamp(),
//           });
//         }
        
//         await FirebaseAuth.instance.signOut();
//         if (mounted) {
//           Navigator.of(context).pushReplacementNamed('/login');
//         }
//       } catch (e) {
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text("Error logging out: $e"), backgroundColor: Colors.red),
//           );
//         }
//       }
//     }
//   }
  
//   Future<void> _deleteProfile() async {
//     bool? confirm = await showDialog<bool>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text("Delete Profile"),
//         content: const Text("Are you sure you want to permanently delete your profile? This action cannot be undone."),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(false), 
//             child: const Text("Cancel")
//           ),
//           ElevatedButton(
//             onPressed: () => Navigator.of(context).pop(true),
//             style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//             child: const Text("Delete", style: TextStyle(color: Colors.white)),
//           ),
//         ],
//       ),
//     );
    
//     if (confirm == true && currentUser != null) {
//       try {
//         // Delete from volunteers collection
//         await FirebaseFirestore.instance
//             .collection('volunteers')
//             .doc(currentUser!.uid)
//             .delete();
        
//         // Delete from volunteer_status collection
//         await FirebaseFirestore.instance
//             .collection('volunteer_status')
//             .doc(currentUser!.uid)
//             .delete();
        
//         // Delete user account
//         await currentUser!.delete();
        
//         if (mounted) {
//           Navigator.of(context).pushReplacementNamed('/login');
//         }
//       } catch (e) {
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text("Error deleting profile: $e"), backgroundColor: Colors.red),
//           );
//         }
//       }
//     }
//   }
  
//   Widget _buildAnnouncementCard(Map<String, dynamic> announcement) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 8),
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [Colors.amber.withOpacity(0.1), Colors.amber.withOpacity(0.05)],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(color: Colors.amber.withOpacity(0.3)),
//       ),
//       child: Row(
//         children: [
//           const Icon(Icons.announcement, color: Colors.amber, size: 20),
//           const SizedBox(width: 8),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   announcement['title'] ?? 'Announcement',
//                   style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
//                 ),
//                 if (announcement['message'] != null)
//                   Text(
//                     announcement['message'],
//                     style: const TextStyle(fontSize: 12, color: Colors.grey),
//                   ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
  
//   Widget _buildStatCard(String title, String value, IconData icon, Color color) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [color.withOpacity(0.8), color],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: color.withOpacity(0.3),
//             blurRadius: 8,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(icon, color: Colors.white, size: 32),
//           const SizedBox(height: 8),
//           Text(
//             value,
//             style: const TextStyle(
//               color: Colors.white,
//               fontSize: 24,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           Text(
//             title,
//             style: const TextStyle(
//               color: Colors.white70,
//               fontSize: 12,
//             ),
//             textAlign: TextAlign.center,
//           ),
//         ],
//       ),
//     );
//   }
  
//   Widget _buildCallRequestCard(DocumentSnapshot doc) {
//     Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
//     DateTime timestamp = (data['timestamp'] as Timestamp).toDate();
    
//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [Colors.red.withOpacity(0.1), Colors.red.withOpacity(0.05)],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.red.withOpacity(0.3)),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.red.withOpacity(0.1),
//             blurRadius: 4,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               AnimatedBuilder(
//                 animation: _pulseAnimation,
//                 builder: (context, child) {
//                   return Transform.scale(
//                     scale: _pulseAnimation.value,
//                     child: Container(
//                       padding: const EdgeInsets.all(8),
//                       decoration: BoxDecoration(
//                         color: Colors.red,
//                         borderRadius: BorderRadius.circular(20),
//                       ),
//                       child: const Icon(Icons.phone, color: Colors.white, size: 16),
//                     ),
//                   );
//                 },
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       data['callerName'] ?? 'Anonymous Caller',
//                       style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//                     ),
//                     Text(
//                       "Incoming call - ${_formatTimeAgo(timestamp)}",
//                       style: TextStyle(color: Colors.grey[600], fontSize: 12),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//           if (data['urgencyLevel'] != null) ...[
//             const SizedBox(height: 8),
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//               decoration: BoxDecoration(
//                 color: _getUrgencyColor(data['urgencyLevel']),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Text(
//                 "Urgency: ${data['urgencyLevel']}",
//                 style: const TextStyle(color: Colors.white, fontSize: 12),
//               ),
//             ),
//           ],
//           const SizedBox(height: 12),
//           Row(
//             children: [
//               Expanded(
//                 child: ElevatedButton.icon(
//                   onPressed: activeCallId == null ? () => _acceptCall(doc.id, data) : null,
//                   icon: const Icon(Icons.call, size: 18),
//                   label: const Text("Accept"),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.green,
//                     foregroundColor: Colors.white,
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 8),
//               Expanded(
//                 child: ElevatedButton.icon(
//                   onPressed: () => _rejectCall(doc.id, data),
//                   icon: const Icon(Icons.call_end, size: 18),
//                   label: const Text("Reject"),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.red,
//                     foregroundColor: Colors.white,
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
  
//   Color _getUrgencyColor(String urgency) {
//     switch (urgency.toLowerCase()) {
//       case 'high':
//         return Colors.red;
//       case 'medium':
//         return Colors.orange;
//       case 'low':
//         return Colors.green;
//       default:
//         return Colors.blue;
//     }
//   }
  
//   String _formatTimeAgo(DateTime timestamp) {
//     Duration diff = DateTime.now().difference(timestamp);
//     if (diff.inMinutes < 1) return "Just now";
//     if (diff.inMinutes < 60) return "${diff.inMinutes}m ago";
//     if (diff.inHours < 24) return "${diff.inHours}h ago";
//     return "${diff.inDays}d ago";
//   }
  
//   @override
//   void dispose() {
//     _pulseController.dispose();
//     _statusTimer?.cancel();
//     _profileSubscription?.cancel();
//     _callsSubscription?.cancel();
//     _announcementsSubscription?.cancel();
    
//     if (currentUser != null) {
//       FirebaseFirestore.instance
//           .collection('volunteer_status')
//           .doc(currentUser!.uid)
//           .update({
//         'isOnline': false,
//         'status': 'Offline',
//         'lastSeen': FieldValue.serverTimestamp(),
//       });
//     }
//     super.dispose();
//   }
  
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             colors: [Colors.blue.shade50, Colors.indigo.shade100],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//         ),
//         child: SafeArea(
//           child: Column(
//             children: [
//               // Header Section
//               Container(
//                 padding: const EdgeInsets.all(20),
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: [Colors.blue.shade600, Colors.indigo.shade700],
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                   ),
//                   borderRadius: const BorderRadius.only(
//                     bottomLeft: Radius.circular(30),
//                     bottomRight: Radius.circular(30),
//                   ),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.blue.withOpacity(0.3),
//                       blurRadius: 10,
//                       offset: const Offset(0, 4),
//                     ),
//                   ],
//                 ),
//                 child: Column(
//                   children: [
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               "Welcome back,",
//                               style: TextStyle(color: Colors.white70, fontSize: 14),
//                             ),
//                             Text(
//                               volunteerName,
//                               style: const TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 20,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ],
//                         ),
//                         Row(
//                           children: [
//                             // Logout button
//                             IconButton(
//                               onPressed: _logout,
//                               icon: const Icon(Icons.logout, color: Colors.white),
//                               tooltip: "Logout",
//                             ),
//                             // Menu button
//                             PopupMenuButton(
//                               icon: const Icon(Icons.more_vert, color: Colors.white),
//                               itemBuilder: (context) => [
//                                 PopupMenuItem(
//                                   child: ListTile(
//                                     leading: const Icon(Icons.edit),
//                                     title: const Text("Update Profile"),
//                                     onTap: () {
//                                       Navigator.pop(context);
//                                       _updateProfile();
//                                     },
//                                   ),
//                                 ),
//                                 PopupMenuItem(
//                                   child: ListTile(
//                                     leading: const Icon(Icons.logout),
//                                     title: const Text("Logout"),
//                                     onTap: () {
//                                       Navigator.pop(context);
//                                       _logout();
//                                     },
//                                   ),
//                                 ),
//                                 PopupMenuItem(
//                                   child: ListTile(
//                                     leading: const Icon(Icons.delete, color: Colors.red),
//                                     title: const Text("Delete Profile", style: TextStyle(color: Colors.red)),
//                                     onTap: () {
//                                       Navigator.pop(context);
//                                       _deleteProfile();
//                                     },
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 16),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Row(
//                           children: [
//                             Container(
//                               width: 12,
//                               height: 12,
//                               decoration: BoxDecoration(
//                                 color: isOnline ? Colors.green : Colors.red,
//                                 shape: BoxShape.circle,
//                               ),
//                             ),
//                             const SizedBox(width: 8),
//                             Text(
//                               currentStatus,
//                               style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
//                             ),
//                           ],
//                         ),
//                         Switch(
//                           value: isOnline,
//                           onChanged: activeCallId == null 
//                             ? (value) => _toggleAvailability() 
//                             : null, 
//                           activeColor: Colors.green,
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),

//               // Announcements Section
//               if (announcements.isNotEmpty)
//                 Container(
//                   margin: const EdgeInsets.all(16),
//                   padding: const EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(12),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.grey.withOpacity(0.1),
//                         blurRadius: 4,
//                         offset: const Offset(0, 2),
//                       ),
//                     ],
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Row(
//                         children: [
//                           Icon(Icons.campaign, color: Colors.amber),
//                           SizedBox(width: 8),
//                           Text(
//                             "Admin Announcements",
//                             style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 12),
//                       ...announcements.map((announcement) => _buildAnnouncementCard(announcement)).toList(),
//                     ],
//                   ),
//                 ),

//               // Active Call Section
//               if (activeCallId != null)
//                 Container(
//                   margin: const EdgeInsets.symmetric(horizontal: 16),
//                   padding: const EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       colors: [Colors.green.shade400, Colors.green.shade600],
//                       begin: Alignment.topLeft,
//                       end: Alignment.bottomRight,
//                     ),
//                     borderRadius: BorderRadius.circular(16),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.green.withOpacity(0.3),
//                         blurRadius: 8,
//                         offset: const Offset(0, 4),
//                       ),
//                     ],
//                   ),
//                   child: Column(
//                     children: [
//                       Row(
//                         children: [
//                           AnimatedBuilder(
//                             animation: _pulseAnimation,
//                             builder: (context, child) {
//                               return Transform.scale(
//                                 scale: _pulseAnimation.value,
//                                 child: const Icon(Icons.phone_in_talk, color: Colors.white, size: 24),
//                               );
//                             },
//                           ),
//                           const SizedBox(width: 12),
//                           const Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   "Call in Progress",
//                                   style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
//                                 ),
//                                 Text(
//                                   "You are currently helping someone",
//                                   style: TextStyle(color: Colors.white70, fontSize: 12),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 12),
//                       SizedBox(
//                         width: double.infinity,
//                         child: ElevatedButton.icon(
//                           onPressed: _endCall,
//                           icon: const Icon(Icons.call_end),
//                           label: const Text("End Call"),
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.red,
//                             foregroundColor: Colors.white,
//                             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
              
//               // Main Content
//               Expanded(
//                 child: SingleChildScrollView(
//                   padding: const EdgeInsets.all(16),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // Statistics Grid
//                       GridView.count(
//                         crossAxisCount: 2,
//                         mainAxisSpacing: 16,
//                         crossAxisSpacing: 16,
//                         childAspectRatio: 1.3,
//                         shrinkWrap: true,
//                         physics: const NeverScrollableScrollPhysics(),
//                         children: [
//                           _buildStatCard("Today's Calls", "$totalCallsToday", Icons.phone, Colors.blue),
//                           _buildStatCard("Accepted", "$acceptedCalls", Icons.call_received, Colors.green),
//                           _buildStatCard("Rejected", "$rejectedCalls", Icons.call_end, Colors.orange),
//                           _buildStatCard("Missed", "$missedCalls", Icons.phone_missed, Colors.red),
//                         ],
//                       ),
                      
//                       const SizedBox(height: 24),

//                       // Incoming Calls Section
//                       Row(
//                         children: [
//                           const Icon(Icons.phone_callback, color: Colors.blue),
//                           const SizedBox(width: 8),
//                           const Text(
//                             "Incoming Calls",
//                             style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                           ),
//                           const Spacer(),
//                           Container(
//                             padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                             decoration: BoxDecoration(
//                               color: Colors.blue.withOpacity(0.1),
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             child: const Text(
//                               "Real-time",
//                               style: TextStyle(color: Colors.blue, fontSize: 12),
//                             ),
//                           ),
//                         ],
//                       ),
                      
//                       const SizedBox(height: 16),

//                       // Real-time Calls Stream
//                       StreamBuilder<QuerySnapshot>(
//                         stream: FirebaseFirestore.instance
//                             .collection('helpline_calls')
//                             .where('status', isEqualTo: 'pending')
//                             .orderBy('timestamp', descending: true)
//                             .limit(10)
//                             .snapshots(),
//                         builder: (context, snapshot) {
//                           if (snapshot.hasError) {
//                             return Container(
//                               padding: const EdgeInsets.all(16),
//                               decoration: BoxDecoration(
//                                 color: Colors.red.withOpacity(0.1),
//                                 borderRadius: BorderRadius.circular(8),
//                               ),
//                               child: Text("Error loading calls: ${snapshot.error}"),
//                             );
//                           }
                          
//                           if (snapshot.connectionState == ConnectionState.waiting) {
//                             return const Center(
//                               child: CircularProgressIndicator(),
//                             );
//                           }
                          
//                           if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//                             return Container(
//                               padding: const EdgeInsets.all(32),
//                               decoration: BoxDecoration(
//                                 color: Colors.grey.withOpacity(0.1),
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                               child: const Column(
//                                 children: [
//                                   Icon(Icons.phone_disabled, size: 48, color: Colors.grey),
//                                   SizedBox(height: 16),
//                                   Text(
//                                     "No incoming calls",
//                                     style: TextStyle(fontSize: 16, color: Colors.grey),
//                                   ),
//                                   Text(
//                                     "You'll see new calls here in real-time",
//                                     style: TextStyle(fontSize: 12, color: Colors.grey),
//                                   ),
//                                 ],
//                               ),
//                             );
//                           }
                          
//                           return Column(
//                             children: snapshot.data!.docs
//                                 .map((doc) => _buildCallRequestCard(doc))
//                                 .toList(),
//                           );
//                         },
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }