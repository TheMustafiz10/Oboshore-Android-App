



import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  final User? user = FirebaseAuth.instance.currentUser;
  DocumentSnapshot? userData;
  List<Activity> _activities = [];

  @override
  void initState() {
    super.initState();
    if (user != null) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .collection('activities')
          .orderBy('time', descending: true)
          .limit(10)
          .snapshots()
          .listen((snapshot) {
        if (mounted) {
          setState(() {
            _activities = snapshot.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return Activity(
                data['title'] as String? ?? 'No Title',
                data['description'] as String? ?? 'No Description',
                _formatTimestamp(data['time'] as Timestamp? ?? Timestamp.now()),
                _mapIconNameToIcon(data['icon'] as String? ?? 'info'),
              );
            }).toList();
          });
        }
      });
    }
  }
  

  String _formatTimestamp(Timestamp timestamp) {
    final now = DateTime.now();
    final date = timestamp.toDate();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} mins ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else {
      return DateFormat('MMM d, yyyy').format(date);
    }
  }

  IconData _mapIconNameToIcon(String iconName) {
    switch (iconName) {
      case 'task':
        return Icons.task;
      case 'calendar_today':
        return Icons.calendar_today;
      case 'assignment':
        return Icons.assignment;
      case 'system_update':
        return Icons.system_update;
      case 'message':
        return Icons.message;
      default:
        return Icons.info;
    }
  }

  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushNamedAndRemoveUntil(
        context, 
        '/', 
        (route) => false
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error signing out: ${e.toString()}')),
      );
    }
  }

  Future<void> _deleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
            'Are you sure you want to delete your account? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .delete();


      await user!.delete();
      await FirebaseAuth.instance.signOut();
      Navigator.pushNamedAndRemoveUntil(
        context, 
        '/', 
        (route) => false
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting account: ${e.toString()}')),
      );
    }
  }

  void _showAccountMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Logout'),
                onTap: () {
                  Navigator.pop(context);
                  _logout();
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Delete Account', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _deleteAccount();
                },
              ),
            ],
          ),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Please log in to view your dashboard')),
      );
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(user!.uid).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return const Scaffold(
            body: Center(child: Text('Error loading user data')),
          );
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Scaffold(
            body: Center(child: Text('User data not found')),
          );
        }

        userData = snapshot.data!;
        final data = userData!.data() as Map<String, dynamic>? ?? {};
        final name = data['name'] as String? ?? 'User';
        final email = data['email'] as String? ?? 'No email';
        final createdAt = data['createdAt'] as Timestamp?;
        final memberSince = createdAt != null
            ? 'Member since ${DateFormat('MMM yyyy').format(createdAt.toDate())}'
            : 'Member since unknown';
        final userLevel = data['userLevel'] as String? ?? 'Member';
        final points = data['points'] as int? ?? 0;
        final completedTasks = data['completedTasks'] as int? ?? 0;
        final ongoingProjects = data['ongoingProjects'] as int? ?? 0;
        final notifications = data['notifications'] as int? ?? 0;
        final weeklyCalls = (data['weeklyCalls'] as num?)?.toDouble() ?? 0.0;

        return Scaffold(
          backgroundColor: const Color.fromARGB(255, 162, 159, 159),
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 220.0,
                floating: false,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(name,
                      style: const TextStyle(color: Colors.white, fontSize: 16.0)),
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 70.0, left: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(userLevel,
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 14.0)),
                          const SizedBox(height: 4.0),
                          Text(memberSince,
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 12.0)),
                        ],
                      ),
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.account_circle, color: Colors.white),
                    onPressed: _showAccountMenu,
                  ),
                  Stack(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.notifications, color: Colors.white),
                        onPressed: () {
                          
                        },
                      ),
                      if (notifications > 0)
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 14,
                              minHeight: 14,
                            ),
                            child: Text(
                              notifications > 9 ? '9+' : '$notifications',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                    ],
                  ),
                ],
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildWelcomeCard(name, email),

                      const SizedBox(height: 20),
                      GridView(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 1.2,
                        ),
                        children: [
                          _buildStatCard("Points", points.toString(), Icons.star,
                              const Color(0xFFFF9F43)),
                          _buildStatCard("Tasks Completed", completedTasks.toString(),
                              Icons.check_circle, const Color(0xFF2ECC71)),
                          _buildStatCard("Calls", ongoingProjects.toString(),
                              Icons.folder_open, const Color(0xFF3498DB)),
                          _buildStatCard("Achievements", "0", Icons.emoji_events,
                              const Color(0xFF9B59B6)),
                        ],
                      ),

                      const SizedBox(height: 30),
                      _buildProgressCard(weeklyCalls),

                      const SizedBox(height: 30),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text("Recent Calls",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 16),
                      _activities.isEmpty
                          ? const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Text("No recent activities"),
                            )
                          : ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _activities.length,
                              separatorBuilder: (context, index) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final activity = _activities[index];
                                return _buildActivityCard(activity);
                              },
                            ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.task),
                label: 'Tasks',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.bar_chart),
                label: 'Stats',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings),
                label: 'Settings',
              ),
            ],
            onTap: (index) {
            },
          ),
        );
      },
    );
  }

  Widget _buildWelcomeCard(String name, String email) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.person, color: Colors.white, size: 30),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Welcome back, $name!",
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(email,
                      style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color),
            ),
            const Spacer(),
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              title,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard(double progress) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Weekly Calls",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text("${(progress * 100).toStringAsFixed(0)}% completed",
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
            const SizedBox(height: 16),
            Stack(
              children: [
                Container(
                  height: 12.0,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                Container(
                  height: 12.0,
                  width: MediaQuery.of(context).size.width * progress,
                  decoration: BoxDecoration(
                    color: const Color(0xFF6A11CB),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Mon",
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                Text("Wed",
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                Text("Fri",
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                Text("Sun",
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityCard(Activity activity) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            shape: BoxShape.circle,
          ),
          child: Icon(activity.icon, color: Colors.blue.shade700),
        ),
        title: Text(activity.title,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(activity.description,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
        trailing: Text(activity.time,
            style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
      ),
    );
  }
}

class Activity {
  final String title;
  final String description;
  final String time;
  final IconData icon;

  Activity(this.title, this.description, this.time, this.icon);
}