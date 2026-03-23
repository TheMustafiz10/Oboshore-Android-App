
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/gestures.dart';



class WhyOboshore extends StatefulWidget {
  const WhyOboshore({Key? key}) : super(key: key);

  @override
  _WhyOboshoreState createState() => _WhyOboshoreState();
}



class _WhyOboshoreState extends State<WhyOboshore> {
  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
       throw 'Could not launch $url';
    }
  }



  int _currentIndex = 0;
  final List<Map<String, String>> quotes = [
    {
      "quote": "Every call answered is a life touched and a burden lightened.",
      "image": "assets/images/quotes-7.jpeg"
    },
    {
      "quote": "Compassionate listening can make the darkest days a little brighter.",
      "image": "assets/images/quotes-9.jpeg"
    },
    {
      "quote": "Oboshore empowers individuals through understanding, not judgment.",
      "image": "assets/images/quotes-222.jpeg"
    },
    {
      "quote": "Together, we provide hope in moments of despair.",
      "image": "assets/images/quotes-25.jpeg"
    },
  ];



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Why Oboshore"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              'assets/images/why-oboshore.jpeg',
              width: double.infinity,
              fit: BoxFit.fitWidth, 
            ),
            const SizedBox(height: 16),


            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "Why Oboshore is Necessary",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                "Crisis helplines are a proven method of suicide prevention globally. "
                "Oboshore provides timely access to support for individuals in distress, "
                "reducing isolation and offering compassionate listening when other resources may be unavailable.",
                style: TextStyle(fontSize: 16, height: 1.5),
              ),
            ),
            const SizedBox(height: 20),


            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "Befriending Model",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),


            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                "It was 1935 when Chad Varah attended the funeral of a local fourteen year old girl who had taken her own life as she had experienced her first menstrual cycle. "
                "Confused by this phenomenon, ashamed of her own body, and lacking someone to discuss this problem with, she committed suicide. Moved by this tragedy, Varah came to realize the need for open communication and the lack of it in society at that time.\n\n"

                "As a priest with psycho-therapeutic training, he initially opened up his parish office to those who might need counselling. "
                "However, soon enough, he found that the church people who were there to keep company those who were waiting to speak with Varah were able to help them more. "
                "As they waited, they were served tea and listened to compassionately and respectfully as they talked about their issues. "
                "This immediate and caring response was usually all they needed, as a result of which, many would no longer require Varah’s personal services.\n\n"

                "Varah took note of this and understood that even the average person without any professional training was able to be of significant help to others, simply by being an empathetic listener. "
                "And this idea of communicating with someone in a crisis and empathizing with them without any personal judgment, was the foundation on which the befriending model was built.\n\n"

                "Years later in 1953, Chad Varah founded the Samaritans, a non-religious and philanthropic organization that aimed to help others through their volunteer-run programs, built on the befriending model. "
                "Initially, it was targeted specifically towards those with suicidal inclinations but it also generally been applied to overall emotional support. "
                "The befriending scheme remains their most important creation and has since expanded to almost 40 countries all over the world, including our very own Oboshore, which is the first of its kind here in Bangladesh.\n\n"

                "Oboshore is part of Befrienders Worldwide and has been in place since the 22th of August in 2025. "
                "As an emotional support and suicide prevention helpline, Oboshore uses the befriending model when engaging with callers to provide them a safe space where they can share their burdens with trained volunteers. "
                "Contrary to popular belief, we do not provide any psychotherapy. "
                "Instead, our main work is active listening with an open mind, counselling, trying to understand the caller from an empathetic and nonjudgmental perspective. "
                "Anyone, regardless of professional background, can practice this. Befriending is not an alternative to professional mental health services, but immediate emotional support for those in crisis.\n\n"

                "The befriending model emphasizes empathetic listening without judgment. "
                "Oboshore volunteers provide a safe space to share burdens, helping individuals feel understood and supported. "
                "This model allows anyone, regardless of professional background, to make a meaningful difference.\n\n"
              ),
            ),
            const SizedBox(height: 20),



            Padding(
              padding: const EdgeInsets.all(16.0),
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                  children: [
                    const TextSpan(text: "Source: "),
                    TextSpan(
                      text: "History of Samaritans",
                      style: const TextStyle(
                        color: Colors.blue,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          _launchURL("http://www.samaritansusa.org/history.php");
                        },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),


            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "Why Oboshore!!",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),


            featureTile(
              "Immediate Support",
              "Oboshore is available when other resources are not. Every call ensures that an individual in distress receives compassionate attention and guidance right when they need it most.",
            ),
            featureTile(
              "Safe Space",
              "We provide a confidential and non-judgmental environment where individuals can openly share their struggles, allowing them to release emotional burdens safely and freely.",
            ),
            featureTile(
              "Empathy and Understanding",
              "Our trained volunteers actively listen with care, patience, and understanding, ensuring that each caller feels seen, heard, and validated in their experience.",
            ),
            featureTile(
              "Accessibility",
              "Oboshore is open to anyone with a phone, breaking down barriers to mental health support and ensuring that emotional care is reachable for all who seek it.",
            ),
            featureTile(
              "Promotes Emotional Health",
              "Through consistent support and compassionate listening, we foster mental wellness, encourage openness about struggles, and work to reduce stigma around seeking help.",
            ),
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
                                    fit: BoxFit.contain,
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ListTile(
        leading: const Icon(Icons.star, color: Colors.teal, size: 28),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(desc, style: const TextStyle(height: 1.5)),
      ),
    );
  }
}
