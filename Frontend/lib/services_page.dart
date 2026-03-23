
import 'package:flutter/material.dart';
import 'service_detail_page.dart';

class ServicesPage extends StatefulWidget {
  @override
  _ServicesPageState createState() => _ServicesPageState();
}

class _ServicesPageState extends State<ServicesPage> {
  final List<Map<String, String>> services = [
    {
      'title': 'Counseling Services',
      'description':
          'One-on-one counseling to support individuals in emotional distress.',
      'image': 'assets/images/counseling.png',
    },
    {
      'title': 'Suicide Prevention Support',
      'description':
          'Immediate support for those at risk of suicidal thoughts or behavior.',
      'image': 'assets/images/YOU-ARE-NOT-ALONE.png',
    },
    {
      'title': 'Emotional Guidance',
      'description':
          'Guidance for managing stress, anxiety, and emotional challenges.',
      'image': 'assets/images/emotional-guidance-support.jpg',
    },
    {
      'title': 'Volunteer Support',
      'description':
          'Training and support for volunteers to assist in helpline services.',
      'image': 'assets/images/Tomorrow-needs-you.webp',
    },
    {
      'title': 'Helpline Service',
      'description':
          'Call our helpline for confidential, compassionate support anytime.',
      'image': 'assets/images/helpline.png',
    },
    {
      'title': 'Trainings & Workshops',
      'description':
          'Workshops to educate about mental health and volunteer training.',
      'image': 'assets/images/presentation.png',
    },
    {
      'title': 'Corporate Wellness Program',
      'description':
          'Programs designed to support mental health and well-being in workplaces.',
      'image': 'assets/images/corporate-wellness-program.jpeg',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Our Services'),
        backgroundColor: Colors.teal,
      ),


      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: services.length,
        itemBuilder: (context, index) {
          final service = services[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ServiceDetailPage(
                    title: service['title']!,
                    description: service['description']!,
                    imagePath: service['image']!,
                  ),
                ),
              );
            },


            child: Card(
              elevation: 4,
              margin: EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                    child: AspectRatio(
                      aspectRatio: 16 / 12, 
                      child: Image.asset(
                        service['image']!,
                        width: double.infinity,
                        fit: BoxFit.contain, 
                      ),
                    ),
                  ),


                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          service['title']!,
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 6),
                        Text(
                          service['description']!,
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 6),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Icon(Icons.arrow_forward_ios, size: 16),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}






// import 'package:flutter/material.dart';
// import 'service_detail_page.dart';




// class ServicesPage extends StatefulWidget {
//   @override
//   _ServicesPageState createState() => _ServicesPageState();
// }

// class _ServicesPageState extends State<ServicesPage> {
//   final List<Map<String, String>> services = [
//     {
//       'title': 'Counseling Services',
//       'description':
//           'One-on-one counseling to support individuals in emotional distress.',
//       'image': 'assets/images/counseling.png',
//     },
//     {
//       'title': 'Suicide Prevention Support',
//       'description':
//           'Immediate support for those at risk of suicidal thoughts or behavior.',
//       'image': 'assets/images/YOU-ARE-NOT-ALONE.png',
//     },
//     {
//       'title': 'Emotional Guidance',
//       'description':
//           'Guidance for managing stress, anxiety, and emotional challenges.',
//       'image': 'assets/images/emotional-guidance-support.jpg',
//     },
//     {
//       'title': 'Volunteer Support',
//       'description':
//           'Training and support for volunteers to assist in helpline services.',
//       'image': 'assets/images/Tomorrow-needs-you.webp',
//     },
//     {
//       'title': 'Helpline Service',
//       'description':
//           'Call our helpline for confidential, compassionate support anytime.',
//       'image': 'assets/images/helpline.png',
//     },
//     {
//       'title': 'Trainings & Workshops', 
//       'description':
//           'Workshops to educate about mental health and volunteer training.',
//       'image': 'assets/images/presentation.png',
//     },
//     {
//       'title': 'Corporate Wellness Program',
//       'description':
//           'Programs designed to support mental health and well-being in workplaces.',
//       'image': 'assets/images/corporate-wellness-program.jpeg',
//     },
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Our Services'),
//         backgroundColor: Colors.teal,
//       ),
//       body: ListView.builder(
//         padding: EdgeInsets.all(16),
//         itemCount: services.length,
//         itemBuilder: (context, index) {
//           final service = services[index];
//           return GestureDetector(
//             onTap: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => ServiceDetailPage(
//                     title: service['title']!,
//                     description: service['description']!,
//                     imagePath: service['image']!,
//                   ),
//                 ),
//               );
//             },



//             child: Card(
//               elevation: 3,
//               margin: EdgeInsets.symmetric(vertical: 8),
//               shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12)),
//               child: ListTile(
//                 leading: service['image'] != null
//                     ? Image.asset(
//                         service['image']!,
//                         width: 60,
//                         height: 60,
//                         fit: BoxFit.cover,
//                       )
//                     : null,
//                 title: Text(
//                   service['title']!,
//                   style: TextStyle(
//                       fontSize: 18, fontWeight: FontWeight.bold),
//                 ),
//                 subtitle: Text(service['description']!),
//                 trailing: Icon(Icons.arrow_forward_ios, size: 16),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
