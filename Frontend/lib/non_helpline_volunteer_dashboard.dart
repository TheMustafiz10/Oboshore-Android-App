

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

class NonHelplineVolunteerDashboard extends StatefulWidget {
  const NonHelplineVolunteerDashboard({super.key});

  @override
  State<NonHelplineVolunteerDashboard> createState() => _NonHelplineVolunteerDashboardState();
}

class _NonHelplineVolunteerDashboardState extends State<NonHelplineVolunteerDashboard>
    with SingleTickerProviderStateMixin {
  
  final User? currentUser = FirebaseAuth.instance.currentUser;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  String volunteerName = "Loading...";
  List<String> volunteerRoles = [];
  Timer? _statusTimer;
  
 
  int completedTasks = 0;
  int pendingTasks = 0;
  int activeAnnouncements = 0;
  int totalContributions = 0;
  
  int _currentIndex = 0; 
  
  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadVolunteerData();
    _loadStatistics();
    _startStatusTimer();
    _updateOnlineStatus(); 
  }
  
  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }
  
  void _startStatusTimer() {
    _statusTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _updateOnlineStatus();
    });
  }
  
  Future<void> _loadVolunteerData() async {
    if (currentUser != null) {
      try {
        DocumentSnapshot doc = await FirebaseFirestore.instance
            .collection('volunteers')
            .doc(currentUser!.uid)
            .get();
        
        if (doc.exists && mounted) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          setState(() {
            volunteerName = data['fullName'] ?? 'Unknown';
            volunteerRoles = List<String>.from(data['roles'] ?? []);
          });
        }
      } catch (e) {
        print("Error loading volunteer data: $e");
      }
    }
  }
  
  Future<void> _loadStatistics() async {
    if (currentUser == null) return;
    
    try {
      QuerySnapshot completedTasksQuery = await FirebaseFirestore.instance
          .collection('volunteer_tasks')
          .where('volunteerId', isEqualTo: currentUser!.uid)
          .where('status', isEqualTo: 'completed')
          .get();
      

      QuerySnapshot pendingTasksQuery = await FirebaseFirestore.instance
          .collection('volunteer_tasks')
          .where('volunteerId', isEqualTo: currentUser!.uid)
          .where('status', isEqualTo: 'pending')
          .get();
      

      QuerySnapshot announcementsQuery = await FirebaseFirestore.instance
          .collection('announcements')
          .where('status', isEqualTo: 'active')
          .get();
      
      if (mounted) {
        setState(() {
          completedTasks = completedTasksQuery.docs.length;
          pendingTasks = pendingTasksQuery.docs.length;
          activeAnnouncements = announcementsQuery.docs.length;
          totalContributions = completedTasks + pendingTasks;
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
          'isOnline': true,
          'lastSeen': FieldValue.serverTimestamp(),
          'status': 'Available for tasks',
          'type': 'non-helpline',
        }, SetOptions(merge: true));
      } catch (e) {
        print("Error updating online status: $e");
      }
    }
  }
  
  Future<void> _acceptAnnouncement(String announcementId, Map<String, dynamic> announcementData) async {
    try {
      await FirebaseFirestore.instance
          .collection('announcement_responses')
          .add({
        'announcementId': announcementId,
        'volunteerId': currentUser!.uid,
        'volunteerName': volunteerName,
        'response': 'accepted',
        'message': 'I will be available for this task',
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'pending_admin_approval',
      });
      
      await FirebaseFirestore.instance
          .collection('announcements')
          .doc(announcementId)
          .update({
        'respondedVolunteers': FieldValue.arrayUnion([currentUser!.uid]),
        'responseCount': FieldValue.increment(1),
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Response sent for: ${announcementData['title']}"),
            backgroundColor: Colors.green,
          ),
        );
      }
      
      _loadStatistics(); 
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error accepting announcement: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }
  
  Future<void> _declineAnnouncement(String announcementId, Map<String, dynamic> announcementData) async {
    try {
      await FirebaseFirestore.instance
          .collection('announcement_responses')
          .add({
        'announcementId': announcementId,
        'volunteerId': currentUser!.uid,
        'volunteerName': volunteerName,
        'response': 'declined',
        'message': 'Not available for this task',
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'declined',
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Declined: ${announcementData['title']}"),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error declining announcement: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }
  
  Future<void> _showCustomResponseDialog(String announcementId, Map<String, dynamic> announcementData) async {
    TextEditingController responseController = TextEditingController();
    
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Respond to: ${announcementData['title']}"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              announcementData['description'] ?? '',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: responseController,
              decoration: const InputDecoration(
                labelText: "Your response",
                hintText: "I can do this task because...",
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (responseController.text.trim().isNotEmpty) {
                try {
                  await FirebaseFirestore.instance
                      .collection('announcement_responses')
                      .add({
                    'announcementId': announcementId,
                    'volunteerId': currentUser!.uid,
                    'volunteerName': volunteerName,
                    'response': 'custom',
                    'message': responseController.text.trim(),
                    'timestamp': FieldValue.serverTimestamp(),
                    'status': 'pending_admin_approval',
                  });
                  
                  await FirebaseFirestore.instance
                      .collection('announcements')
                      .doc(announcementId)
                      .update({
                    'respondedVolunteers': FieldValue.arrayUnion([currentUser!.uid]),
                    'responseCount': FieldValue.increment(1),
                  });
                  
                  Navigator.pop(context);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Custom response sent successfully!"),
                        backgroundColor: Colors.blue,
                      ),
                    );
                  }
                  
                  _loadStatistics();
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Error sending response: $e"), backgroundColor: Colors.red),
                    );
                  }
                }
              }
            },
            child: const Text("Send Response"),
          ),
        ],
      ),
    );
    
    responseController.dispose();
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
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Profile"),
        content: const Text("Are you sure you want to permanently delete your profile? This action cannot be undone."),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Delete"),
          ),
        ],
      ),
    ) ?? false;
    
    if (confirm && currentUser != null) {
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
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - _fadeAnimation.value)),
            child: Container(
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
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildAnnouncementCard(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    DateTime createdAt = (data['createdAt'] as Timestamp).toDate();
    bool hasResponded = data['respondedVolunteers'] != null && 
        (data['respondedVolunteers'] as List).contains(currentUser!.uid);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            hasResponded ? Colors.green.withOpacity(0.1) : Colors.purple.withOpacity(0.1),
            hasResponded ? Colors.green.withOpacity(0.05) : Colors.purple.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasResponded ? Colors.green.withOpacity(0.3) : Colors.purple.withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: (hasResponded ? Colors.green : Colors.purple).withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: hasResponded 
                  ? [Colors.green.withOpacity(0.8), Colors.green.withOpacity(0.6)]
                  : [Colors.purple.withOpacity(0.8), Colors.purple.withOpacity(0.6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  hasResponded ? Icons.check_circle : Icons.campaign,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['title'] ?? 'No Title',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _formatTimeAgo(createdAt),
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                if (hasResponded)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      "Responded",
                      style: TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['description'] ?? 'No description available',
                  style: TextStyle(color: Colors.grey[700], fontSize: 14),
                ),
                if (data['requirements'] != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Requirements:",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          data['requirements'],
                          style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
                if (data['deadline'] != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.schedule, size: 16, color: Colors.orange),
                      const SizedBox(width: 4),
                      Text(
                        "Deadline: ${_formatDate((data['deadline'] as Timestamp).toDate())}",
                        style: const TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 16),
                if (!hasResponded)
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _acceptAnnouncement(doc.id, data),
                          icon: const Icon(Icons.thumb_up, size: 16),
                          label: const Text("Available"),
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
                          onPressed: () => _showCustomResponseDialog(doc.id, data),
                          icon: const Icon(Icons.edit, size: 16),
                          label: const Text("Custom"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _declineAnnouncement(doc.id, data),
                          icon: const Icon(Icons.close, size: 16),
                          label: const Text("Pass"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                    ],
                  ),
                if (hasResponded)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.withOpacity(0.3)),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle, color: Colors.green, size: 16),
                        SizedBox(width: 8),
                        Text(
                          "You have responded to this announcement",
                          style: TextStyle(color: Colors.green, fontWeight: FontWeight.w500),
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
  
  Widget _buildTaskCard(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    DateTime assignedAt = (data['assignedAt'] as Timestamp).toDate();
    String status = data['status'] ?? 'pending';
    
    Color statusColor;
    IconData statusIcon;
    
    switch (status) {
      case 'completed':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'in_progress':
        statusColor = Colors.blue;
        statusIcon = Icons.timer;
        break;
      default:
        statusColor = Colors.orange;
        statusIcon = Icons.pending;
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [statusColor.withOpacity(0.1), statusColor.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(statusIcon, color: Colors.white, size: 16),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data['taskTitle'] ?? 'Task',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    Text(
                      "Assigned ${_formatTimeAgo(assignedAt)}",
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status.replaceAll('_', ' ').toUpperCase(),
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                ),
              ),
            ],
          ),
          if (data['description'] != null) ...[
            const SizedBox(height: 8),
            Text(
              data['description'],
              style: TextStyle(color: Colors.grey[700], fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }
  
  String _formatTimeAgo(DateTime timestamp) {
    Duration diff = DateTime.now().difference(timestamp);
    if (diff.inMinutes < 1) return "Just now";
    if (diff.inMinutes < 60) return "${diff.inMinutes}m ago";
    if (diff.inHours < 24) return "${diff.inHours}h ago";
    return "${diff.inDays}d ago";
  }
  
  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    _statusTimer?.cancel();
    super.dispose();
  }
  
 

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    

    switch (index) {
      case 0:
        break;
      case 1:
        Navigator.push(context, MaterialPageRoute(builder: (context) => TasksScreen()));
        break;
      case 2:
        Navigator.push(context, MaterialPageRoute(builder: (context) => AnnouncementsScreen()));
        break;
      case 3:
        Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileScreen()));
        break;
    }
  }
  




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple.shade50, Colors.pink.shade100],
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
                    colors: [Colors.purple.shade600, Colors.pink.shade700],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purple.withOpacity(0.3),
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
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Non-Helpline Volunteer",
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
                              if (volunteerRoles.isNotEmpty)
                                Text(
                                  volunteerRoles.take(2).join(", "),
                                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                                ),
                            ],
                          ),
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
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => UpdateProfileScreen()));
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
                          _buildStatCard("Completed Tasks", "$completedTasks", Icons.task_alt, Colors.green),
                          _buildStatCard("Pending Tasks", "$pendingTasks", Icons.pending_actions, Colors.orange),
                          _buildStatCard("Active Announcements", "$activeAnnouncements", Icons.campaign, Colors.purple),
                          _buildStatCard("Total Contributions", "$totalContributions", Icons.volunteer_activism, Colors.blue),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      


                      Row(
                        children: [
                          const Icon(Icons.assignment, color: Colors.blue),
                          const SizedBox(width: 8),
                          const Text(
                            "My Tasks",
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
                            .collection('volunteer_tasks')
                            .where('volunteerId', isEqualTo: currentUser?.uid)
                            .orderBy('assignedAt', descending: true)
                            .limit(5)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text("Error loading tasks: ${snapshot.error}"),
                            );
                          }
                          
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
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
                                  Icon(Icons.assignment_outlined, size: 48, color: Colors.grey),
                                  SizedBox(height: 16),
                                  Text(
                                    "No tasks assigned",
                                    style: TextStyle(fontSize: 16, color: Colors.grey),
                                  ),
                                  Text(
                                    "New tasks will appear here when assigned",
                                    style: TextStyle(fontSize: 12, color: Colors.grey),
                                  ),
                                ],
                              ),
                            );
                          }
                          
                          return Column(
                            children: snapshot.data!.docs
                                .map((doc) => _buildTaskCard(doc))
                                .toList(),
                          );
                        },
                      ),
                      
                      const SizedBox(height: 24),
                      
   
   

                      Row(
                        children: [
                          const Icon(Icons.campaign, color: Colors.purple),
                          const SizedBox(width: 8),
                          const Text(
                            "Latest Announcements",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.purple.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              "Live Updates",
                              style: TextStyle(color: Colors.purple, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      


                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('announcements')
                            .where('status', isEqualTo: 'active')
                            .orderBy('createdAt', descending: true)
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
                              child: Text("Error loading announcements: ${snapshot.error}"),
                            );
                          }
                          
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
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
                                    Icon(Icons.campaign_outlined, size: 48, color: Colors.grey),
                                    SizedBox(height: 16),
                                    Text(
                                      "No announcements",
                                      style: TextStyle(fontSize: 16, color: Colors.grey),
                                    ),
                                    Text(
                                      "New announcements from admin will appear here",
                                      style: TextStyle(fontSize: 12, color: Colors.grey),
                                    ),
                                ],
                              ),
                            );
                          }
                          
                          return Column(
                            children: snapshot.data!.docs
                                .map((doc) => _buildAnnouncementCard(doc))
                                .toList(),
                          );
                        },
                      ),

        
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.purple.withOpacity(0.1), Colors.pink.withOpacity(0.1)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.purple.withOpacity(0.2)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Volunteer Status",
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Online - Available for tasks",
                                  style: TextStyle(color: Colors.green.shade700, fontSize: 12),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.green),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.circle, color: Colors.green, size: 8),
                                  SizedBox(width: 4),
                                  Text("Active", style: TextStyle(color: Colors.green, fontSize: 12)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      
  
  
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple.shade600, Colors.pink.shade700],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.purple.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white70,
          type: BottomNavigationBarType.fixed,
          currentIndex: _currentIndex,
          onTap: _onItemTapped,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.task),
              label: 'Tasks',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.campaign),
              label: 'Announcements',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}




class UpdateProfileScreen extends StatefulWidget {
  const UpdateProfileScreen({super.key});

  @override
  State<UpdateProfileScreen> createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  final _formKey = GlobalKey<FormState>();
  

  String _fullName = '';
  String _email = '';
  String _phone = '';
  String _address = '';
  List<String> _selectedRoles = [];
  String _availability = '';
  String _skills = '';
  
  final List<String> _availableRoles = [
    'Event Organizer',
    'Fundraiser',
    'Community Outreach',
    'Social Media Manager',
    'Content Creator',
    'Translator',
    'Driver',
    'Other'
  ];
  
  @override
  void initState() {
    super.initState();
    _loadCurrentProfile();
  }
  
  
  

  Future<void> _loadCurrentProfile() async {
    if (currentUser != null) {
      try {
        DocumentSnapshot doc = await FirebaseFirestore.instance
            .collection('volunteers')
            .doc(currentUser!.uid)
            .get();
        
        if (doc.exists && mounted) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          setState(() {
            _fullName = data['fullName'] ?? '';
            _email = data['email'] ?? '';
            _phone = data['phone'] ?? '';
            _address = data['address'] ?? '';
            _selectedRoles = List<String>.from(data['roles'] ?? []);
            _availability = data['availability'] ?? '';
            _skills = data['skills'] ?? '';
          });
        }
      } catch (e) {
        print("Error loading profile data: $e");
      }
    }
  }

  Future<void> _submitUpdate() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      
      try {
        await FirebaseFirestore.instance
            .collection('profile_update_requests')
            .add({
          'volunteerId': currentUser!.uid,
          'fullName': _fullName,
          'email': _email,
          'phone': _phone,
          'address': _address,
          'roles': _selectedRoles,
          'availability': _availability,
          'skills': _skills,
          'status': 'pending',
          'requestedAt': FieldValue.serverTimestamp(),
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Profile update request submitted for admin approval"),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error submitting update: $e"), backgroundColor: Colors.red),
          );
        }
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Update Profile"),
        backgroundColor: Colors.purple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: _fullName,
                decoration: const InputDecoration(labelText: "Full Name"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
                onSaved: (value) => _fullName = value!,
              ),
              TextFormField(
                initialValue: _email,
                decoration: const InputDecoration(labelText: "Email"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
                onSaved: (value) => _email = value!,
              ),
              TextFormField(
                initialValue: _phone,
                decoration: const InputDecoration(labelText: "Phone"),
                onSaved: (value) => _phone = value!,
              ),
              TextFormField(
                initialValue: _address,
                decoration: const InputDecoration(labelText: "Address"),
                onSaved: (value) => _address = value!,
              ),
              const SizedBox(height: 16),
              const Text("Select Roles:"),
              Wrap(
                spacing: 8.0,
                children: _availableRoles.map((role) {
                  return FilterChip(
                    label: Text(role),
                    selected: _selectedRoles.contains(role),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedRoles.add(role);
                        } else {
                          _selectedRoles.remove(role);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _availability,
                decoration: const InputDecoration(labelText: "Availability (e.g., Weekends, Evenings)"),
                onSaved: (value) => _availability = value!,
              ),
              TextFormField(
                initialValue: _skills,
                decoration: const InputDecoration(labelText: "Skills"),
                maxLines: 3,
                onSaved: (value) => _skills = value!,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitUpdate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text("Submit Update Request", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final User? currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Tasks"),
        backgroundColor: Colors.purple,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('volunteer_tasks')
            .where('volunteerId', isEqualTo: currentUser?.uid)
            .orderBy('assignedAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.assignment_outlined, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    "No tasks assigned yet",
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Tasks from admin will appear here",
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                ],
              ),
            );
          }

          final tasks = snapshot.data!.docs;
          final pendingTasks = tasks.where((doc) => (doc.data() as Map<String, dynamic>)['status'] == 'pending').toList();
          final completedTasks = tasks.where((doc) => (doc.data() as Map<String, dynamic>)['status'] == 'completed').toList();

          return DefaultTabController(
            length: 2,
            child: Column(
              children: [
                const TabBar(
                  tabs: [
                    Tab(text: "Pending"),
                    Tab(text: "Completed"),
                  ],
                  indicatorColor: Colors.purple,
                  labelColor: Colors.purple,
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      ListView.builder(
                        itemCount: pendingTasks.length,
                        itemBuilder: (context, index) {
                          final doc = pendingTasks[index];
                          final data = doc.data() as Map<String, dynamic>;
                          final assignedAt = (data['assignedAt'] as Timestamp).toDate();
                          
                          return Container(
                            margin: const EdgeInsets.all(8),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.orange.withOpacity(0.3)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.pending_actions, color: Colors.orange),
                                    const SizedBox(width: 8),
                                    Text(
                                      data['taskTitle'] ?? 'Task',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                if (data['description'] != null) 
                                  Text(data['description']),
                                const SizedBox(height: 8),
                                Text(
                                  "Assigned: ${_formatDate(assignedAt)}",
                                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                ),
                                const SizedBox(height: 12),
                                ElevatedButton(
                                  onPressed: () {
                                    FirebaseFirestore.instance
                                        .collection('volunteer_tasks')
                                        .doc(doc.id)
                                        .update({'status': 'completed'});
                                  },
                                  child: const Text("Mark as Completed"),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      
  
  
                      ListView.builder(
                        itemCount: completedTasks.length,
                        itemBuilder: (context, index) {
                          final doc = completedTasks[index];
                          final data = doc.data() as Map<String, dynamic>;
                          final assignedAt = (data['assignedAt'] as Timestamp).toDate();
                          
                          return Container(
                            margin: const EdgeInsets.all(8),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.green.withOpacity(0.3)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.task_alt, color: Colors.green),
                                    const SizedBox(width: 8),
                                    Text(
                                      data['taskTitle'] ?? 'Task',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                if (data['description'] != null) 
                                  Text(data['description']),
                                const SizedBox(height: 8),
                                Text(
                                  "Assigned: ${_formatDate(assignedAt)}",
                                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Status: Completed",
                                  style: TextStyle(color: Colors.green[700], fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }
}

class AnnouncementsScreen extends StatelessWidget {
  const AnnouncementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Announcements"),
        backgroundColor: Colors.purple,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('announcements')
            .where('status', isEqualTo: 'active')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.campaign_outlined, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    "No announcements",
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Check back later for new announcements",
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final createdAt = (data['createdAt'] as Timestamp).toDate();
              
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.purple.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.campaign, color: Colors.purple),
                        const SizedBox(width: 8),
                        Text(
                          data['title'] ?? 'Announcement',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      data['description'] ?? 'No description available',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 8),
                    if (data['requirements'] != null) 
                      Text(
                        "Requirements: ${data['requirements']}",
                        style: TextStyle(color: Colors.grey[600], fontStyle: FontStyle.italic),
                      ),
                    const SizedBox(height: 8),
                    if (data['deadline'] != null) 
                      Text(
                        "Deadline: ${_formatDate((data['deadline'] as Timestamp).toDate())}",
                        style: TextStyle(color: Colors.orange[700], fontWeight: FontWeight.w500),
                      ),
                    const SizedBox(height: 8),
                    Text(
                      "Posted: ${_formatTimeAgo(createdAt)}",
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _formatTimeAgo(DateTime timestamp) {
    Duration diff = DateTime.now().difference(timestamp);
    if (diff.inMinutes < 1) return "Just now";
    if (diff.inMinutes < 60) return "${diff.inMinutes}m ago";
    if (diff.inHours < 24) return "${diff.inHours}h ago";
    return "${diff.inDays}d ago";
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  Map<String, dynamic> profileData = {};

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    if (currentUser != null) {
      try {
        DocumentSnapshot doc = await FirebaseFirestore.instance
            .collection('volunteers')
            .doc(currentUser!.uid)
            .get();
        
        if (doc.exists && mounted) {
          setState(() {
            profileData = doc.data() as Map<String, dynamic>;
          });
        }
      } catch (e) {
        print("Error loading profile data: $e");
      }
    }
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
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Profile"),
        content: const Text("Are you sure you want to permanently delete your profile? This action cannot be undone."),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Delete"),
          ),
        ],
      ),
    ) ?? false;
    
    if (confirm && currentUser != null) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Profile"),
        backgroundColor: Colors.purple,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const UpdateProfileScreen()));
            },
          ),
        ],
      ),
      body: profileData.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Personal Information",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        _buildProfileItem("Full Name", profileData['fullName'] ?? 'Not provided'),
                        _buildProfileItem("Email", profileData['email'] ?? 'Not provided'),
                        _buildProfileItem("Phone", profileData['phone'] ?? 'Not provided'),
                        _buildProfileItem("Address", profileData['address'] ?? 'Not provided'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Volunteer Information",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        _buildProfileItem(
                          "Roles", 
                          (profileData['roles'] != null && (profileData['roles'] as List).isNotEmpty)
                            ? (profileData['roles'] as List).join(', ')
                            : 'Not specified'
                        ),
                        _buildProfileItem("Availability", profileData['availability'] ?? 'Not specified'),
                        _buildProfileItem("Skills", profileData['skills'] ?? 'Not specified'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: _logout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text("Logout"),
                    ),
                    ElevatedButton(
                      onPressed: _deleteProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text("Delete Profile"),
                    ),
                  ],
                ),
              ],
            ),
    );
  }

  Widget _buildProfileItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: 4),
          Text(value),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}