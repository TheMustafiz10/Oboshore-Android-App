
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';



class ContactPage extends StatefulWidget {
  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final List<Map<String, dynamic>> contacts = [
    {
      'icon': Icons.phone,
      'color': Colors.blue,
      'title': '999-123-456-789',
      'bgColor': [Colors.blue.shade100, Colors.blue.shade300]
    },
    {
      'icon': Icons.phone_android,
      'color': Colors.green,
      'title': '+880123456789',
      'bgColor': [Colors.green.shade100, Colors.green.shade300]
    },
    {
      'icon': Icons.email,
      'color': Colors.red,
      'title': 'info@oboshore.com',
      'bgColor': [Colors.red.shade100, Colors.red.shade300]
    },
    {
      'icon': FontAwesomeIcons.facebook,
      'color': Colors.blue,
      'title': 'fb.com/oboshore',
      'bgColor': [Colors.blue.shade50, Colors.blue.shade200]
    },
    {
      'icon': FontAwesomeIcons.instagram,
      'color': Colors.purple,
      'title': '@oboshore',
      'bgColor': [Colors.purple.shade100, Colors.purple.shade300]
    },
    {
      'icon': FontAwesomeIcons.linkedin,
      'color': Colors.blueAccent,
      'title': 'linkedin.com/company/oboshore',
      'bgColor': [Colors.blue.shade100, Colors.blue.shade300]
    },
    {
      'icon': FontAwesomeIcons.whatsapp,
      'color': Colors.green,
      'title': '+880123456789',
      'bgColor': [Colors.green.shade100, Colors.green.shade300]
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contact Us'),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 185, 184, 184),
      ),



      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ListView.builder(
          itemCount: contacts.length,
          itemBuilder: (context, index) {
            final contact = contacts[index];
            return InkWell(
              onTap: () {}, 
              borderRadius: BorderRadius.circular(16),
              splashColor: contact['color'].withOpacity(0.3),
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 8),
                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: contact['bgColor'],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      offset: Offset(0, 4),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    contact['icon'] is IconData
                        ? Icon(contact['icon'], color: contact['color'], size: 30)
                        : FaIcon(contact['icon'], color: contact['color'], size: 30),
                    SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        contact['title'],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}








// // with URL Link
// import 'package:flutter/material.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:url_launcher/url_launcher.dart';

// class ContactPage extends StatefulWidget {
//   @override
//   _ContactPageState createState() => _ContactPageState();
// }

// class _ContactPageState extends State<ContactPage> {
//   // Function to launch a URL
//   void _launchURL(String url) async {
//     final Uri uri = Uri.parse(url);
//     if (await canLaunchUrl(uri)) {
//       await launchUrl(uri);
//     } else {
//       throw 'Could not launch $url';
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return ListView(
//       padding: EdgeInsets.all(16),
//       children: [
//         ListTile(
//           leading: Icon(Icons.phone, color: Colors.blue),
//           title: Text("999-123-456-789"),
//           onTap: () => _launchURL("tel:999123456789"),
//         ),
//         ListTile(
//           leading: Icon(Icons.phone_android, color: Colors.green),
//           title: Text("+880123456789"),
//           onTap: () => _launchURL("tel:+880123456789"),
//         ),
//         ListTile(
//           leading: Icon(Icons.email, color: Colors.red),
//           title: Text("info@oboshore.com"),
//           onTap: () => _launchURL("mailto:info@oboshore.com"),
//         ),
//         ListTile(
//           leading: FaIcon(FontAwesomeIcons.facebook, color: Colors.blue),
//           title: Text("fb.com/oboshore"),
//           onTap: () => _launchURL("https://fb.com/oboshore"),
//         ),
//         ListTile(
//           leading: FaIcon(FontAwesomeIcons.instagram, color: Colors.purple),
//           title: Text("@oboshore"),
//           onTap: () => _launchURL("https://instagram.com/oboshore"),
//         ),
//         ListTile(
//           leading: FaIcon(FontAwesomeIcons.linkedin, color: Colors.blueAccent),
//           title: Text("linkedin.com/company/oboshore"),
//           onTap: () => _launchURL("https://linkedin.com/company/oboshore"),
//         ),
//         ListTile(
//           leading: FaIcon(FontAwesomeIcons.whatsapp, color: Colors.green),
//           title: Text("+880123456789"),
//           onTap: () => _launchURL("https://wa.me/880123456789"),
//         ),
//       ],
//     );
//   }
// }

