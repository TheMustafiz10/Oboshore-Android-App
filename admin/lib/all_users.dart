

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AllUsersPage extends StatefulWidget {
  const AllUsersPage({super.key});

  @override
  State<AllUsersPage> createState() => _AllUsersPageState();
}

class _AllUsersPageState extends State<AllUsersPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _filterStatus = 'All';
  String _sortBy = 'recent';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'User Management',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo[900],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: TextField(
                          controller: _searchController,
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value;
                            });
                          },
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.search, size: 20),
                            hintText: 'Search users...',
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    MediaQuery.of(context).size.width > 600 
                      ? ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.add),
                          label: const Text('Add User'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        )
                      : IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.add),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.indigo,
                            foregroundColor: Colors.white,
                          ),
                        ),
                  ],
                ),
              ],
            ),
          ),
          

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      FilterChip(
                        label: const Text('All'),
                        selected: _filterStatus == 'All',
                        onSelected: (selected) {
                          setState(() {
                            _filterStatus = selected ? 'All' : _filterStatus;
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: const Text('Active'),
                        selected: _filterStatus == 'Active',
                        onSelected: (selected) {
                          setState(() {
                            _filterStatus = selected ? 'Active' : _filterStatus;
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: const Text('Inactive'),
                        selected: _filterStatus == 'Inactive',
                        onSelected: (selected) {
                          setState(() {
                            _filterStatus = selected ? 'Inactive' : _filterStatus;
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: const Text('Suspended'),
                        selected: _filterStatus == 'Suspended',
                        onSelected: (selected) {
                          setState(() {
                            _filterStatus = selected ? 'Suspended' : _filterStatus;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),


                DropdownButton<String>(
                  value: _sortBy,
                  items: const [
                    DropdownMenuItem(value: 'recent', child: Text('Recent')),
                    DropdownMenuItem(value: 'name', child: Text('Name')),
                    DropdownMenuItem(value: 'email', child: Text('Email')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _sortBy = value!;
                    });
                  },
                ),
              ],
            ),
          ),
          


          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('users').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.group_off, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No users found',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }
                List<QueryDocumentSnapshot> users = snapshot.data!.docs;


                if (_searchQuery.isNotEmpty) {
                  users = users.where((user) {
                    final name = _getUserField(user, 'name', 'Unknown').toLowerCase();
                    final email = _getUserField(user, 'email', 'No email').toLowerCase();
                    return name.contains(_searchQuery.toLowerCase()) || 
                           email.contains(_searchQuery.toLowerCase());
                  }).toList();
                }


                if (_filterStatus != 'All') {
                  users = users.where((user) {
                    return _getUserField(user, 'status', 'Active') == _filterStatus;
                  }).toList();
                }
                


                users.sort((a, b) {
                  if (_sortBy == 'name') {
                    return _getUserField(a, 'name', '').compareTo(_getUserField(b, 'name', ''));
                  } else if (_sortBy == 'email') {
                    return _getUserField(a, 'email', '').compareTo(_getUserField(b, 'email', ''));
                  } else {
                    final aTime = a['createdAt'] as Timestamp?;
                    final bTime = b['createdAt'] as Timestamp?;
                    return (bTime ?? Timestamp.now()).compareTo(aTime ?? Timestamp.now());
                  }
                });
                
                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: MediaQuery.of(context).size.width > 1200 ? 4 : 
                                  MediaQuery.of(context).size.width > 800 ? 3 : 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return _buildUserCard(user);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }



  String _getUserField(QueryDocumentSnapshot user, String field, String fallback) {
    try {
      return user.get(field) ?? fallback;
    } catch (e) {
      return fallback;
    }
  }

  Widget _buildUserCard(QueryDocumentSnapshot user) {
    final name = _getUserField(user, 'name', 'Unknown');
    final email = _getUserField(user, 'email', 'No email');
    final status = _getUserField(user, 'status', 'Active');
    final role = _getUserField(user, 'role', 'User');
    final createdAt = user['createdAt'] as Timestamp?;
    
    String formattedDate = 'Unknown';
    if (createdAt != null) {
      formattedDate = DateFormat('MMM dd, yyyy').format(createdAt.toDate());
    }
    

    String lastActive = 'Never';
    try {
      final lastLogin = user['lastLogin'] as Timestamp?;
      if (lastLogin != null) {
        final now = DateTime.now();
        final difference = now.difference(lastLogin.toDate());
        
        if (difference.inMinutes < 60) {
          lastActive = '${difference.inMinutes} min ago';
        } else if (difference.inHours < 24) {
          lastActive = '${difference.inHours} hours ago';
        } else {
          lastActive = '${difference.inDays} days ago';
        }
      }
    } catch (e) {
      lastActive = 'Unknown';
    }
    
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showUserDetails(user),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: _getUserColor(name),
                    radius: 24,
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : 'U',
                      style: const TextStyle(
                        fontSize: 18, 
                        fontWeight: FontWeight.bold,
                        color: Colors.white
                      ),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _getStatusColor(status),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        color: _getStatusColor(status),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
       
              Text(
                name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 4),
              
       
              Text(
                email,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 16),
              


              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getRoleColor(role).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  role,
                  style: TextStyle(
                    color: _getRoleColor(role),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              
              const Spacer(),
              


              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Joined: $formattedDate',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
    
              Row(
                children: [
                  const Icon(Icons.access_time, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Active: $lastActive',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_vert, size: 18),
                    onPressed: () {},
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Active':
        return Colors.green;
      case 'Inactive':
        return Colors.orange;
      case 'Suspended':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'Admin':
        return Colors.deepPurple;
      case 'Moderator':
        return Colors.blue;
      case 'Editor':
        return Colors.teal;
      default:
        return Colors.grey[700]!;
    }
  }
  
  Color _getUserColor(String name) {
    final colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.indigo,
      Colors.brown,
    ];
    
    final index = name.isNotEmpty ? name.codeUnitAt(0) % colors.length : 0;
    return colors[index];
  }

  void _showUserDetails(QueryDocumentSnapshot user) {
    final name = _getUserField(user, 'name', 'Unknown');
    final email = _getUserField(user, 'email', 'No email');
    final status = _getUserField(user, 'status', 'Active');
    final role = _getUserField(user, 'role', 'User');
    final createdAt = user['createdAt'] as Timestamp?;
    
    String formattedDate = 'Unknown';
    if (createdAt != null) {
      formattedDate = DateFormat('MMM dd, yyyy - HH:mm').format(createdAt.toDate());
    }
    


    String lastActive = 'Never';
    try {
      final lastLogin = user['lastLogin'] as Timestamp?;
      if (lastLogin != null) {
        lastActive = DateFormat('MMM dd, yyyy - HH:mm').format(lastLogin.toDate());
      }
    } catch (e) {
      lastActive = 'Unknown';
    }
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('User Details: $name'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: _getUserColor(name),
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : 'U',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(name),
                subtitle: Text(email),
              ),
              const SizedBox(height: 16),
              _buildDetailRow('User ID', user.id),
              _buildDetailRow('Role', role),
              _buildDetailRow('Status', status),
              _buildDetailRow('Registration Date', formattedDate),
              _buildDetailRow('Last Login', lastActive),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              
              Navigator.pop(context);
            },
            child: const Text('Edit'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}