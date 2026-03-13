import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UpdateRequestsPage extends StatefulWidget {
  const UpdateRequestsPage({super.key});

  @override
  State<UpdateRequestsPage> createState() => _UpdateRequestsPageState();
}

class _UpdateRequestsPageState extends State<UpdateRequestsPage> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String helplineSearch = "";
  String nonHelplineSearch = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile Update Requests"),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryCards(),
            const SizedBox(height: 20),

            // HELPLINE VOLUNTEERS
            Container(
              decoration: BoxDecoration(
                color: Colors.indigo[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.indigo[200]!),
                boxShadow: [
                  BoxShadow(
                    color: Colors.indigo.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.indigo[100],
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.phone, color: Colors.indigo),
                      ),
                      const SizedBox(width: 12),
                      const Text("Helpline Volunteer Updates",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    decoration: InputDecoration(
                      labelText: "Search by Name or Email",
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    ),
                    onChanged: (val) => setState(() => helplineSearch = val.toLowerCase()),
                  ),
                  const SizedBox(height: 12),
                  _buildUpdateCards("helpline", helplineSearch),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // NON-HELPLINE VOLUNTEERS
            Container(
              decoration: BoxDecoration(
                color: Colors.amber[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber[200]!),
                boxShadow: [
                  BoxShadow(
                    color: Colors.amber.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.amber[100],
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.people, color: Colors.amber),
                      ),
                      const SizedBox(width: 12),
                      const Text("Non-Helpline Volunteer Updates",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    decoration: InputDecoration(
                      labelText: "Search by Name or Email",
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    ),
                    onChanged: (val) => setState(() => nonHelplineSearch = val.toLowerCase()),
                  ),
                  const SizedBox(height: 12),
                  _buildUpdateCards("non-helpline", nonHelplineSearch),
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
      stream: _db.collection('updateRequests').where('status', isEqualTo: 'pending').snapshots(),
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
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.deepPurple[100],
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.update, size: 24, color: Colors.deepPurple),
                      ),
                      const SizedBox(height: 8),
                      Text('$totalCount', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      const Text('Total Updates', textAlign: TextAlign.center),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.indigo[100],
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.phone, size: 24, color: Colors.indigo),
                      ),
                      const SizedBox(height: 8),
                      Text('$helplineCount', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      const Text('Helpline', textAlign: TextAlign.center),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.amber[100],
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.people, size: 24, color: Colors.amber),
                      ),
                      const SizedBox(height: 8),
                      Text('$nonHelplineCount', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      const Text('Non-Helpline', textAlign: TextAlign.center),
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






  Widget _buildUpdateCards(String volunteerType, String search) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _db
          .collection('updateRequests')
          .where('volunteerType', isEqualTo: volunteerType)
          .where('status', isEqualTo: 'pending')
          .orderBy('requestedAt', descending: true)
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
            child: Center(
              child: Text(
                "No update requests found for ${volunteerType == 'helpline' ? 'helpline' : 'non-helpline'} volunteers.",
                style: const TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
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

         

            if (data['requestedAt'] != null && data['requestedAt'] is Timestamp) {
              final requestedAt = (data['requestedAt'] as Timestamp).toDate();
              final diff = DateTime.now().difference(requestedAt);
              isNew = diff.inMinutes <= 60;
            }

            return Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              color: isNew ? Colors.deepPurple[50] : Colors.white,
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
                              color: Colors.deepPurple,
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
                    
     



                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Update Summary:",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          _buildUpdateSummary(data['updates']),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 12),
          
          

                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton.icon(
                          onPressed: () => _showUpdateDetailsModal(data, doc.id),
                          icon: const Icon(Icons.compare_arrows, size: 16),
                          label: const Text("Review Changes"),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.deepPurple,
                            side: const BorderSide(color: Colors.deepPurple),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: () => _approveUpdate(doc.id, data),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                          icon: const Icon(Icons.check, size: 16),
                          label: const Text("Approve"),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: () => _rejectUpdate(doc.id, data['fullName'] ?? 'Volunteer'),
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





  Widget _buildUpdateSummary(dynamic updates) {
    if (updates == null || updates is! Map) {
      return const Text("No update details available");
    }
    
    final updateMap = Map<String, dynamic>.from(updates);
    if (updateMap.isEmpty) {
      return const Text("No update details available");
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: updateMap.entries.map((entry) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Text(
            "• ${entry.key}: ${entry.value.toString()}",
            style: const TextStyle(fontSize: 14),
          ),
        );
      }).toList(),
    );
  }




  void _approveUpdate(String requestId, Map<String, dynamic> requestData) async {
    try {
      final volunteerId = requestData['volunteerId'];
      final updates = requestData['updates'];
      
      if (volunteerId == null || updates == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Invalid update request data"),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      


      await _db.collection('volunteers').doc(volunteerId).update(
        Map<String, dynamic>.from(updates)
      );
      


      await _db.collection('updateRequests').doc(requestId).update({
        'status': 'approved',
        'processedAt': FieldValue.serverTimestamp(),
        'processedBy': 'Admin', 
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("${requestData['fullName']}'s profile has been updated successfully"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error approving update: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }







  void _rejectUpdate(String requestId, String volunteerName) async {
    try {
      await _db.collection('updateRequests').doc(requestId).update({
        'status': 'rejected',
        'processedAt': FieldValue.serverTimestamp(),
        'processedBy': 'Admin',
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("$volunteerName's update request has been rejected"),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error rejecting update: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }



 
  void _showUpdateDetailsModal(Map<String, dynamic> requestData, String requestId) {
    final volunteerId = requestData['volunteerId'];
    
    showDialog(
      context: context,
      builder: (_) => Dialog(
        insetPadding: const EdgeInsets.all(16),
        child: StreamBuilder<DocumentSnapshot>(
          stream: _db.collection('volunteers').doc(volunteerId).snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            
            final currentData = snapshot.data!.data() as Map<String, dynamic>? ?? {};
            final updates = requestData['updates'] as Map<String, dynamic>? ?? {};
            
            return Container(
              padding: const EdgeInsets.all(24),
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.compare_arrows, color: Colors.deepPurple, size: 24),
                      const SizedBox(width: 8),
                      const Text(
                        "Review Profile Changes",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  Text(
                    "Update request from ${requestData['fullName']}",
                    style: const TextStyle(fontSize: 16),
                  ),
                  
                  const SizedBox(height: 16),
                  
             
                  Expanded(
                    child: ListView(
                      shrinkWrap: true,
                      children: updates.entries.map((entry) {
                        final field = entry.key;
                        final newValue = entry.value.toString();
                        final currentValue = currentData[field]?.toString() ?? 'Not set';
                        
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                field.toUpperCase(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepPurple,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "Current Value:",
                                          style: TextStyle(fontSize: 12, color: Colors.grey),
                                        ),
                                        Text(currentValue),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.arrow_forward, color: Colors.deepPurple),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "New Value:",
                                          style: TextStyle(fontSize: 12, color: Colors.grey),
                                        ),
                                        Text(
                                          newValue,
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
            
            
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Cancel"),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _rejectUpdate(requestId, requestData['fullName'] ?? 'Volunteer');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text("Reject"),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _approveUpdate(requestId, requestData);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text("Approve Changes"),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}