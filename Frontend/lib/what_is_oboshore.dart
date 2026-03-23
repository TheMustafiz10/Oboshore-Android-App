
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';



class WhatIsOboshore extends StatefulWidget {
  const WhatIsOboshore({Key? key}) : super(key: key);

  @override
  _WhatIsOboshoreState createState() => _WhatIsOboshoreState();
}

class _WhatIsOboshoreState extends State<WhatIsOboshore> {
  int _currentIndex = 0;

  final List<Map<String, String>> quotes = [
    {
      "quote": "Listening is often the only thing needed to help someone.",
      "image": "assets/images/quotes-7.jpeg"
    },
    {
      "quote": "Hope is stronger when shared with another soul.",
      "image": "assets/images/quotes-9.jpeg"
    },
    {
      "quote": "Oboshore believes in compassion, not judgment.",
      "image": "assets/images/quotes-222.jpeg"
    },
    {
      "quote": "Together, we build a brighter future.",
      "image": "assets/images/quotes-25.jpeg"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("What is Oboshore"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset("assets/images/quotes-2.jpg", fit: BoxFit.cover),

            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "What is Oboshore?",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                "Oboshore is Bangladesh’s first and only emotional support, loneliness and suicide prevention mobile friendly helpline, staffed by trained volunteers. Our mission is to offer a safe space through open-hearted listening, helping people feel less alone in their moments of despair. Since its beginning, Oboshore has supported countless individuals, offering comfort and hope when life feels unbearable.\n\n"
                "Like the calm of an 'Oboshore' (harbor), we provide a place of rest for minds in distress.\n\n"
                "Supported by dedicated volunteers, Oboshore remains accessible, confidential, and compassionate. We are committed to reducing stigma, encouraging openness, and creating a culture where asking for help is seen as a sign of strength.",
                style: TextStyle(fontSize: 16, height: 1.5),
              ),
            ),

            const SizedBox(height: 20),

            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "Features of Oboshore",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),

            featureTile("Befriending",
                "Compassionate, non-judgmental listening for those feeling isolated or distressed."),
            featureTile("Volunteer-staffed",
                "Staffed by trained volunteers, ensuring genuine empathy and dedication."),
            featureTile("Accessibility",
                "Anyone with a phone can reach us, removing barriers to seeking help."),
            featureTile("Anonymity",
                "Callers are not required to share their identity."),
            featureTile("Confidentiality",
                "All conversations remain private and protected."),
            featureTile("A Culture of Care",
                "Oboshore builds awareness about mental health, nurturing a more compassionate society."),

            const SizedBox(height: 30),

            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "Inspirational Quotes",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),

   

            CarouselSlider(
              options: CarouselOptions(
                height: 220,
                autoPlay: true,
                autoPlayInterval: const Duration(seconds: 3),
                enlargeCenterPage: true,
                viewportFraction: 0.8,
                onPageChanged: (index, reason) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
              ),


              items: quotes.map((item) {
                return Builder(
                  builder: (BuildContext context) {
                    return Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      elevation: 5,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (item["image"] != null)
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.asset(
                                    item["image"]!,
                                    fit: BoxFit.contain, // ✅ full image shown
                                    width: double.infinity,
                                  ),
                                ),
                              ),
                            const SizedBox(height: 10),
                            Text(
                              item["quote"]!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 16,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 10),

  
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: quotes.asMap().entries.map((entry) {
                return GestureDetector(
                  onTap: () => setState(() => _currentIndex = entry.key),
                  child: Container(
                    width: _currentIndex == entry.key ? 12 : 8,
                    height: _currentIndex == entry.key ? 12 : 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentIndex == entry.key
                          ? Colors.teal
                          : Colors.grey,
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget featureTile(String title, String desc) {
    return ListTile(
      leading: const Icon(Icons.star, color: Colors.teal),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(desc),
    );
  }
}
