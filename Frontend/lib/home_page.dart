
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:oboshore/call_us.dart';
import 'package:oboshore/volunteer_registration.dart';
import 'what_is_oboshore.dart';
import 'why_oboshore.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentImage = 0;
  int currentInfo = 0;

  final List<Map<String, dynamic>> slides = [
    {
      "image": "assets/images/loneliness-weather.jpg",
      "title": "Are you Lonely?\nDistressed?\nSuicidal?",
      "subtitle": "You are not alone. Oboshore wants to hear from you!",
      "buttonText": "Call Us",
      "isCall": true
    },
    {
      "image": "assets/images/helping-hand.jpg",
      "title": "Ready to make a\nDifference?",
      "subtitle": "Join our Volunteer Team",
      "buttonText": "Apply Now",
      "isCall": false
    },
  ];

  final List<Map<String, String>> infoSlides = [
    {
      "title": "Who We Are",
      "description":
          "Oboshore is dedicated to supporting those in distress, loneliness, and crisis with love and care.",
    },
    {
      "title": "Mission & Vision",
      "description":
          "Our mission is to provide mental health support and crisis counseling. Our vision is a world without silent suffering, "
          "where everyone feels supported and understood, and volunteers actively participate in helping others.",
    },
    {
      "title": "Reports",
      "description":
          "We ensure full transparency by sharing regular reports of our activities, donations, and volunteer efforts.",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            CarouselSlider.builder(
              itemCount: slides.length,
              itemBuilder: (context, index, realIndex) {
                final slide = slides[index];
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(slide["image"], fit: BoxFit.cover),
                    Container(color: Colors.black.withOpacity(0.4)),
                    Positioned(
                      left: 20,
                      right: 20,
                      bottom: 50,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            slide["title"],
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            slide["subtitle"],
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 30, vertical: 15),
                              backgroundColor: Colors.teal,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () {
                              if (slide["isCall"]) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => CallUsPage()),
                                );
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          VolunteerRegistrationPage()),
                                );
                              }
                            },


                            child: Text(
                              slide["buttonText"],
                              style: const TextStyle(
                                  fontSize: 18, color: Colors.white),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                );
              },


              options: CarouselOptions(
                height: MediaQuery.of(context).size.height * 0.55,
                autoPlay: true,
                autoPlayInterval: const Duration(seconds: 3),
                enlargeCenterPage: true,
                viewportFraction: 1,
                enableInfiniteScroll: true,
                scrollPhysics: const BouncingScrollPhysics(),
                onPageChanged: (index, reason) {
                  setState(() => currentImage = index);
                },
              ),
            ),
            const SizedBox(height: 16),




            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "What is Oboshore?",
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal),
                ),
              ),
            ),
            const SizedBox(height: 8),


            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                elevation: 4,
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(15)),
                      child: Image.asset(
                        'assets/images/quotes-2.jpg',
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(
                        "Oboshore is Bangladesh’s first emotional support and suicide prevention helpline, "
                        "offering compassionate listening for those in distress.",
                        style: const TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => WhatIsOboshore()),
                        );
                      },
                      child: const Text("Read More"),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),




 
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Why Oboshore is Necessary!!",
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal),
                ),
              ),
            ),
            const SizedBox(height: 8),


            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                elevation: 4,
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(15)),
                      child: Image.asset(
                        'assets/images/why-oboshore.jpeg',
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(
                        "Crisis helplines are a proven method of suicide prevention globally. "
                        "Oboshore provides timely access to support for individuals in distress, "
                        "reducing isolation and offering compassionate listening when other resources may be unavailable.",
                        style: const TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => WhyOboshore()),
                        );
                      },
                      child: const Text("Read More"),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),






            CarouselSlider.builder(
              itemCount: infoSlides.length,
              itemBuilder: (context, index, realIndex) {
                final info = infoSlides[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 4,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            info["title"]!,
                            style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.teal),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            info["description"]!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
              
              options: CarouselOptions(
                height: 220,
                autoPlay: true,
                autoPlayInterval: const Duration(seconds: 3),
                enlargeCenterPage: true,
                viewportFraction: 0.8,
                enableInfiniteScroll: true,
                scrollPhysics: const BouncingScrollPhysics(),
                onPageChanged: (index, reason) {
                  setState(() => currentInfo = index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
