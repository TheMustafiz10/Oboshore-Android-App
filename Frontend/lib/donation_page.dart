import 'package:flutter/material.dart';

class DonationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Donate to Oboshore'),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.asset(
                'assets/images/Donations.jpg',
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 16),

            Text(
              "Thank you for your interest in donating to Oboshore.\n\n"
              "Oboshore is Bangladesh’s first and only emotional support and suicide prevention helpline for mobile app. "
              "The mission of the helpline is to alleviate feelings of despair, isolation, distress, and suicidal intent among members of our community. "
              "Oboshore accomplishes this through confidential, compassionate, and open-minded listening.\n\n"
              "Depending on what is most convenient for you, there are numerous ways to donate to Oboshore:",
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            SizedBox(height: 16),
            Text(
              "1. Directly depositing into Oboshore’s bank account:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              "Account Name: Oboshore\n"
              "Account Number: 123012301230\n"
              "Bank Name: Dutch Bangla Bank Ltd.\n"
              "Branch Name: Dhanmondi Branch\n"
              "Routing No: 098765432",
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            SizedBox(height: 16),

            Text(
              "2. Writing an account payee cheque in the name of 'Oboshore.' "
              "You can mail the cheque, drop it off at our office, or we can pick it up from you at a convenient time. "
              "Please confirm the amount deposited via email; we will then issue you a donation receipt.",
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            SizedBox(height: 16),

 

            Text(
              "If neither of the options above are convenient, it is also possible to donate cash. "
              "Please let us know what you think, or if you have any additional questions.",
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            SizedBox(height: 16),


            Text(
              "If you have questions, need more information, or need support in the process of making a donation, please call us at +880123456789 or email us at info@oboshore.org.",
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            SizedBox(height: 16),

            Text(
              "Thank you again for donating!",
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal),
            ),
          ],
        ),
      ),
    );
  }
}
