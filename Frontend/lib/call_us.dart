import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CallUsPage extends StatelessWidget {
  final List<Map<String, dynamic>> contacts = [
    {
      "title": "Telephone",
      "value": "021234567",
      "icon": Icons.phone,
      "color": Colors.teal,
      "type": "call"
    },
    {
      "title": "Mobile",
      "value": "+8801712345678",
      "icon": Icons.smartphone,
      "color": Colors.blue,
      "type": "call"
    },
    {
      "title": "WhatsApp",
      "value": "+8801812345678",
      "icon": FontAwesomeIcons.whatsapp,
      "color": Colors.green,
      "type": "whatsapp"
    },
  ];

  void _makeCall(String number) async {
    final Uri url = Uri(scheme: 'tel', path: number);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  void _openWhatsApp(String number) async {
    final Uri url = Uri.parse("https://wa.me/$number");
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Call Us")),
      body: ListView.builder(
        padding: const EdgeInsets.all(20.0),
        itemCount: contacts.length,
        itemBuilder: (context, index) {
          final contact = contacts[index];
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              leading: Icon(contact["icon"], color: contact["color"], size: 28),
              title: Text(
                "${contact['title']}: ${contact['value']}",
                style: const TextStyle(fontSize: 16),
              ),
              onTap: () {
                if (contact["type"] == "call") {
                  _makeCall(contact["value"]);
                } else if (contact["type"] == "whatsapp") {
                  _openWhatsApp(contact["value"]);
                }
              },
            ),
          );
        },
      ),
    );
  }
}
