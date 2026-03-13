

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ApprovalRequestsPage extends StatefulWidget {
  const ApprovalRequestsPage({super.key});

  @override
  State<ApprovalRequestsPage> createState() => _ApprovalRequestsPageState();
}

class _ApprovalRequestsPageState extends State<ApprovalRequestsPage> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String helplineSearch = "";
  String nonHelplineSearch = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Volunteer Approval Requests"),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
   
            _buildSummaryCards(),
            const SizedBox(height: 20),

          
            Container(
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green[200]!),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("🟢 Helpline Volunteer Requests",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  TextField(
                    decoration: const InputDecoration(
                      labelText: "Search by Name or Email",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    onChanged: (val) => setState(() => helplineSearch = val.toLowerCase()),
                  ),
                  const SizedBox(height: 12),
                  _buildVolunteerCards("helpline", helplineSearch),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Container(
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange[200]!),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("🟡 Non-Helpline Volunteer Requests",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  TextField(
                    decoration: const InputDecoration(
                      labelText: "Search by Name or Email",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    onChanged: (val) => setState(() => nonHelplineSearch = val.toLowerCase()),
                  ),
                  const SizedBox(height: 12),
                  _buildVolunteerCards("non-helpline", nonHelplineSearch),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildSummaryCards() {
    return StreamBuilder<QuerySnapshot>(
      stream: _db.collection('volunteers').where('status', isEqualTo: 'pending').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        var docs = snapshot.data!.docs;
        int helplineCount = docs.where((d) => d.get('volunteerType') == 'helpline').length;
        int nonHelplineCount = docs.where((d) => d.get('volunteerType') == 'non-helpline').length;
        int totalCount = docs.length;

        return Row(
          children: [
            Expanded(
              child: Card(
                color: Colors.blue[100],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Icon(Icons.pending_actions, size: 40, color: Colors.blue),
                      const SizedBox(height: 8),
                      Text('$totalCount', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      const Text('Total Pending'),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Card(
                color: Colors.green[100],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Icon(Icons.phone, size: 40, color: Colors.green),
                      const SizedBox(height: 8),
                      Text('$helplineCount', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      const Text('Helpline'),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Card(
                color: Colors.orange[100],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Icon(Icons.volunteer_activism, size: 40, color: Colors.orange),
                      const SizedBox(height: 8),
                      Text('$nonHelplineCount', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      const Text('Non-Helpline'),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildVolunteerCards(String role, String search) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _db
          .collection('volunteers')
          .where('volunteerType', isEqualTo: role)
          .where('status', isEqualTo: 'pending')
          .orderBy('createdAt', descending: true)
          .snapshots(), 
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (snapshot.hasError) {
          return Center(
            child: Text("Error loading data: ${snapshot.error}"),
          );
        }
        
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(20),
            child: const Center(
              child: Text(
                "No pending requests found.",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
          );
        }

        var docs = snapshot.data!.docs;
        if (search.isNotEmpty) {
          docs = docs.where((d) {
            final data = d.data();
            final email = (data['email'] ?? "").toString().toLowerCase();
            final name = (data['fullName'] ?? "").toString().toLowerCase();
            return email.contains(search) || name.contains(search);
          }).toList();
        }

        if (docs.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(20),
            child: const Center(
              child: Text(
                "No matching results found.",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
          );
        }

        return Column(
          children: docs.map((doc) {
            final data = doc.data();
            bool isNew = false;
            if (data['createdAt'] != null && data['createdAt'] is Timestamp) {
              final createdAt = (data['createdAt'] as Timestamp).toDate();
              final diff = DateTime.now().difference(createdAt);
              isNew = diff.inMinutes <= 60;
            }

            return Card(
              color: isNew ? Colors.yellow[100] : Colors.white,
              elevation: 3,
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data['fullName'] ?? "N/A",
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                data['email'] ?? "N/A",
                                style: TextStyle(
                                    fontSize: 14, color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                        if (isNew)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              "NEW",
                              style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ),
                      ],
                    ),
                    
                    const SizedBox(height: 12),
                    
  
                    Row(
                      children: [
                        Icon(Icons.phone, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(data['phone'] ?? "N/A", style: TextStyle(color: Colors.grey[600])),
                        const SizedBox(width: 16),
                        Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(data['dob'] ?? "N/A", style: TextStyle(color: Colors.grey[600])),
                      ],
                    ),
                    
                    const SizedBox(height: 8),
                    
          
                    if (data['roles'] != null && data['roles'] is List && (data['roles'] as List).isNotEmpty)
                      Wrap(
                        children: (data['roles'] as List).take(3).map<Widget>((role) {
                          return Container(
                            margin: const EdgeInsets.only(right: 6, bottom: 4),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: role == 'helpline' ? Colors.green[200] : Colors.blue[200],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              role.toString(),
                              style: const TextStyle(fontSize: 12),
                            ),
                          );
                        }).toList(),
                      ),
                    
                    const SizedBox(height: 12),
                    
    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton.icon(
                          onPressed: () => _showVolunteerInfoModal(data, doc.id),
                          icon: const Icon(Icons.info_outline, size: 16),
                          label: const Text("View Details"),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: () => _updateVolunteerStatus(doc.id, "approved", data['fullName'] ?? 'Volunteer'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                          icon: const Icon(Icons.check, size: 16),
                          label: const Text("Approve"),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: () => _showRejectDialog(doc.id, data['fullName'] ?? 'Volunteer'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                          icon: const Icon(Icons.close, size: 16),
                          label: const Text("Reject"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }


  void _updateVolunteerStatus(String docId, String status, String volunteerName) async {
    try {
      await _db.collection('volunteers').doc(docId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
        'reviewedBy': 'Admin', 
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("$volunteerName has been $status successfully"),
          backgroundColor: status == 'approved' ? Colors.green : Colors.red,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error updating status: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showRejectDialog(String docId, String volunteerName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Reject Volunteer"),
        content: Text("Are you sure you want to reject $volunteerName's application?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _updateVolunteerStatus(docId, "rejected", volunteerName);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Reject", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }


  void _showVolunteerInfoModal(Map<String, dynamic> info, String docId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.person, color: Colors.blue),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                "Volunteer Details",
                style: const TextStyle(fontSize: 18),
              ),
            ),
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
                
                _buildInfoSection("Volunteer Details", {
                  'Type': info['volunteerType'],
                  'Status': info['status'],
                }),
                
                if (info['roles'] != null && info['roles'] is List)
                  _buildListSection("Roles", info['roles'] as List),
                
                if (info['availabilityDays'] != null && info['availabilityDays'] is List)
                  _buildListSection("Available Days", info['availabilityDays'] as List),
                
                if (info['availabilityTimes'] != null && info['availabilityTimes'] is List)
                  _buildListSection("Available Times", info['availabilityTimes'] as List),
                
                if (info['additionalInfo'] != null)
                  _buildInfoSection("Additional Information", info['additionalInfo'] as Map<String, dynamic>),
                
                if (info['consent'] != null)
                  _buildConsentSection(info['consent'] as Map<String, dynamic>),
                
                _buildInfoSection("System Info", {
                  'Created': info['createdAt'] != null && info['createdAt'] is Timestamp 
                    ? (info['createdAt'] as Timestamp).toDate().toString()
                    : 'N/A',
                  'Document ID': docId,
                }),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _updateVolunteerStatus(docId, "approved", info['fullName'] ?? 'Volunteer');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            icon: const Icon(Icons.check, color: Colors.white),
            label: const Text("Approve", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, Map<String, dynamic> data) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: data.entries.map((e) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
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
        ],
      ),
    );
  }

  Widget _buildListSection(String title, List data) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Wrap(
              children: data.map<Widget>((item) {
                return Container(
                  margin: const EdgeInsets.only(right: 8, bottom: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    item.toString(),
                    style: const TextStyle(fontSize: 12),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConsentSection(Map<String, dynamic> consent) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Consent & Agreements",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: consent.entries.map((e) {
                bool isChecked = e.value == true;
                return Row(
                  children: [
                    Icon(
                      isChecked ? Icons.check_box : Icons.check_box_outline_blank,
                      color: isChecked ? Colors.green : Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(e.key)),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}