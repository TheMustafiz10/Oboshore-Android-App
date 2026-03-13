

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NonHelplineVolunteersPage extends StatefulWidget {
  const NonHelplineVolunteersPage({super.key});

  @override
  State<NonHelplineVolunteersPage> createState() => _NonHelplineVolunteersPageState();
}

class _NonHelplineVolunteersPageState extends State<NonHelplineVolunteersPage> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String volunteerSearch = "";
  String selectedRoleFilter = "";
  


  Set<String> availableRoles = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Non-Helpline Volunteers"),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
    
    
            _buildSummaryCard(),
            const SizedBox(height: 20),


            _buildFiltersSection(),
            const SizedBox(height: 16),
            
     
     
            Expanded(child: _buildVolunteersList()),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return StreamBuilder<QuerySnapshot>(
      stream: _db
          .collection("volunteers")
          .where("volunteerType", isEqualTo: "non-helpline")
          .where("status", isEqualTo: "approved")
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        int totalVolunteers = snapshot.data!.docs.length;


        int recentVolunteers = 0;
        DateTime thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
        
        for (var doc in snapshot.data!.docs) {
          var createdAt = doc.get('createdAt');
          if (createdAt is Timestamp) {
            if (createdAt.toDate().isAfter(thirtyDaysAgo)) {
              recentVolunteers++;
            }
          }
        }

        return Row(
          children: [
            Expanded(
              child: Card(
                elevation: 4,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    gradient: LinearGradient(
                      colors: [Colors.orange.withOpacity(0.1), Colors.orange.withOpacity(0.05)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.volunteer_activism, size: 32, color: Colors.orange),
                      const SizedBox(height: 8),
                      Text(
                        "$totalVolunteers",
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                      const Text("Total Volunteers", style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Card(
                elevation: 4,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    gradient: LinearGradient(
                      colors: [Colors.green.withOpacity(0.1), Colors.green.withOpacity(0.05)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.new_releases, size: 32, color: Colors.green),
                      const SizedBox(height: 8),
                      Text(
                        "$recentVolunteers",
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const Text("New (30 days)", style: TextStyle(fontSize: 12)),
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

  Widget _buildFiltersSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.filter_list, color: Colors.orange),
                SizedBox(width: 8),
                Text("Search & Filter", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
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
                      labelText: "Filter by Role",
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    value: selectedRoleFilter.isEmpty ? null : selectedRoleFilter,
                    items: [
                      const DropdownMenuItem(value: "", child: Text("All Roles")),
                      ...availableRoles.map((role) => 
                        DropdownMenuItem(value: role, child: Text(role, style: const TextStyle(fontSize: 12))))
                    ],
                    onChanged: (val) => setState(() => selectedRoleFilter = val ?? ""),
                  ),
                ),

                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => setState(() {
                    volunteerSearch = "";
                    selectedRoleFilter = "";
                  }),
                  icon: const Icon(Icons.clear),
                  tooltip: "Clear All Filters",
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVolunteersList() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _db
          .collection("volunteers")
          .where("volunteerType", isEqualTo: "non-helpline")
          .where("status", isEqualTo: "approved")
          .orderBy("createdAt", descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (snapshot.hasError) {
          return Center(child: Text("Error loading volunteers: ${snapshot.error}"));
        }
        
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.volunteer_activism, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text("No approved non-helpline volunteers found", 
                    style: TextStyle(fontSize: 16, color: Colors.grey)),
              ],
            ),
          );
        }

        var docs = snapshot.data!.docs;

   
   
        Set<String> roles = {};
        for (var doc in docs) {
          List<dynamic> docRoles = doc.data()['roles'] ?? [];
          for (var role in docRoles) {
            roles.add(role.toString());
          }
        }
        availableRoles = roles;

   
        if (volunteerSearch.isNotEmpty) {
          docs = docs.where((d) {
            final data = d.data();
            final name = (data['fullName'] ?? "").toString().toLowerCase();
            final email = (data['email'] ?? "").toString().toLowerCase();
            return name.contains(volunteerSearch) || email.contains(volunteerSearch);
          }).toList();
        }

        if (selectedRoleFilter.isNotEmpty) {
          docs = docs.where((d) {
            final roles = List<String>.from(d.data()['roles'] ?? []);
            return roles.contains(selectedRoleFilter);
          }).toList();
        }

        if (docs.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(Icons.search_off, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text("No volunteers match your criteria", 
                      style: TextStyle(fontSize: 16, color: Colors.grey)),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index];
            final data = doc.data();
            final roles = List<String>.from(data['roles'] ?? []);
            final availabilityDays = List<String>.from(data['availabilityDays'] ?? []);
            final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
            
            bool isNew = false;
            if (createdAt != null) {
              final diff = DateTime.now().difference(createdAt);
              isNew = diff.inDays <= 7; 
            }
            
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6),
              elevation: 2,
              color: isNew ? Colors.yellow[50] : Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
               
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.orange[100],
                          radius: 24,
                          child: Text(
                            (data['fullName'] ?? "?").substring(0, 1).toUpperCase(),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold, 
                              color: Colors.orange,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    data['fullName'] ?? "Unnamed",
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                  if (isNew) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.green,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Text(
                                        "NEW",
                                        style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              Text(
                                data['email'] ?? "",
                                style: TextStyle(color: Colors.grey[600], fontSize: 14),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.phone, size: 14, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Text(
                                    data['phone'] ?? "N/A", 
                                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 12),
                  
                    const Text(
                      "Roles:",
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      children: roles.map((role) {
                        return Container(
                          margin: const EdgeInsets.only(right: 6, bottom: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.orange[200],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            role,
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                          ),
                        );
                      }).toList(),
                    ),
                    
                    const SizedBox(height: 12),
              
                    if (availabilityDays.isNotEmpty) ...[
                      const Text(
                        "Available Days:",
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        children: availabilityDays.take(7).map((day) {
                          return Container(
                            margin: const EdgeInsets.only(right: 4, bottom: 4),
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.blue[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              day,
                              style: const TextStyle(fontSize: 11),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 12),
                    ],
                    
     
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton.icon(
                          onPressed: () => _showVolunteerInfoModal(data, doc.id),
                          icon: const Icon(Icons.info_outline, size: 16),
                          label: const Text("Details"),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.orange,
                            side: const BorderSide(color: Colors.orange),
                          ),
                        ),                     
                        const SizedBox(width: 8),



                        ElevatedButton.icon(
                          onPressed: () => _showContactVolunteerDialog(data),
                          icon: const Icon(Icons.email, size: 16),
                          label: const Text("Contact"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }


  void _showVolunteerInfoModal(Map<String, dynamic> data, String docId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(data['fullName'] ?? "Volunteer Details"),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow("Email", data['email'] ?? "N/A"),
              _buildDetailRow("Phone", data['phone'] ?? "N/A"),
              _buildDetailRow("Address", _formatAddress(data['address'])),
              const SizedBox(height: 16),
              const Text("Roles:", style: TextStyle(fontWeight: FontWeight.bold)),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: (data['roles'] as List<dynamic>?)
                        ?.map((role) => Chip(label: Text(role.toString()), backgroundColor: Colors.orange[100]))
                        .toList() ??
                    [const Text("No roles specified")],
              ),
              const SizedBox(height: 16),
              const Text("Availability Days:", style: TextStyle(fontWeight: FontWeight.bold)),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: (data['availabilityDays'] as List<dynamic>?)
                        ?.map((day) => Chip(label: Text(day.toString()), backgroundColor: Colors.blue[100]))
                        .toList() ??
                    [const Text("No availability days specified")],
              ),
            ],
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 100, child: Text("$label:", style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _formatAddress(dynamic address) {
    if (address == null || address is! Map) return "Not provided";
    List<String> parts = [];
    if ((address['street'] ?? "").toString().isNotEmpty) parts.add(address['street']);
    if ((address['city'] ?? "").toString().isNotEmpty) parts.add(address['city']);
    if ((address['state'] ?? "").toString().isNotEmpty) parts.add(address['state']);
    if ((address['postalCode'] ?? "").toString().isNotEmpty) parts.add(address['postalCode']);
    return parts.isNotEmpty ? parts.join(", ") : "Not provided";
  }



  void _showContactVolunteerDialog(Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Contact Volunteer"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Name: ${data['fullName']}"),
            Text("Email: ${data['email']}"),
            Text("Phone: ${data['phone'] ?? 'N/A'}"),
            const SizedBox(height: 16),
            const Text("Choose contact method:"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Send Email"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Make Call"),
          ),
        ],
      ),
    );
  }
}
