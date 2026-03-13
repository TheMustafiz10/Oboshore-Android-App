import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Announcement extends StatefulWidget {
  const Announcement({super.key});

  @override
  State<Announcement> createState() => _AnnouncementState();
}

class _AnnouncementState extends State<Announcement> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? _currentUser = FirebaseAuth.instance.currentUser;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  String _selectedAudience = 'non_helpline_volunteers'; // Default audience

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Announcements'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showCreateAnnouncementDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: const Text('Non-Helpline Volunteers'),
                    selected: _selectedAudience == 'non_helpline_volunteers',
                    onSelected: (selected) {
                      setState(() {
                        _selectedAudience = 'non_helpline_volunteers';
                      });
                    },
                    selectedColor: Colors.deepPurple,
                    labelStyle: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ChoiceChip(
                    label: const Text('Helpline Volunteers'),
                    selected: _selectedAudience == 'helpline_volunteers',
                    onSelected: (selected) {
                      setState(() {
                        _selectedAudience = 'helpline_volunteers';
                      });
                    },
                    selectedColor: Colors.deepPurple,
                    labelStyle: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('announcements')
                  .where('audience', isEqualTo: _selectedAudience)
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      'No announcements yet',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  );
                }
                
                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var announcement = snapshot.data!.docs[index];
                    return _buildAnnouncementCard(announcement);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnnouncementCard(DocumentSnapshot announcement) {
    Map<String, dynamic> data = announcement.data() as Map<String, dynamic>;
    Timestamp timestamp = data['timestamp'];
    DateTime date = timestamp.toDate();
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.deepPurple[100],
                  child: const Icon(Icons.announcement, color: Colors.deepPurple),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    data['title'],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              data['content'],
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Chip(
                  label: Text(
                    data['audience'] == 'helpline_volunteers' 
                      ? 'Helpline Volunteers' 
                      : 'Non-Helpline Volunteers',
                    style: const TextStyle(fontSize: 12, color: Colors.white),
                  ),
                  backgroundColor: data['audience'] == 'helpline_volunteers' 
                    ? Colors.blue 
                    : Colors.green,
                ),
                Text(
                  '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateAnnouncementDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Create New Announcement'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _contentController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Content',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedAudience,
                  items: const [
                    DropdownMenuItem(
                      value: 'non_helpline_volunteers',
                      child: Text('Non-Helpline Volunteers'),
                    ),
                    DropdownMenuItem(
                      value: 'helpline_volunteers',
                      child: Text('Helpline Volunteers'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedAudience = value!;
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: 'Audience',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                _createAnnouncement();
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
              ),
              child: const Text(
                'Publish',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _createAnnouncement() async {
    if (_titleController.text.isEmpty || _contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    try {
      await _firestore.collection('announcements').add({
        'title': _titleController.text,
        'content': _contentController.text,
        'audience': _selectedAudience,
        'author': _currentUser?.uid,
        'timestamp': Timestamp.now(),
      });


      _titleController.clear();
      _contentController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Announcement published successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }
}


class AnnouncementList extends StatelessWidget {
  final String audienceType;
  
  const AnnouncementList({super.key, required this.audienceType});

  @override
  Widget build(BuildContext context) {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('announcements')
          .where('audience', isEqualTo: audienceType)
          .orderBy('timestamp', descending: true)
          .limit(3)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('Something went wrong');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        if (snapshot.data!.docs.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('No announcements yet'),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                'Latest Announcements',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                var announcement = snapshot.data!.docs[index];
                Map<String, dynamic> data = announcement.data() as Map<String, dynamic>;
                
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    leading: const Icon(Icons.announcement, color: Colors.deepPurple),
                    title: Text(
                      data['title'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      data['content'],
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () {
                      
                    },
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}