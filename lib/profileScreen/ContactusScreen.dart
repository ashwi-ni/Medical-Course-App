import"package:flutter/material.dart";

class ContactusScreen extends StatelessWidget {
  const ContactusScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Contact Us')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Heading
            Text(
              'Get in Touch',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            SizedBox(height: 20),

            // Phone Number
            Row(
              children: [
                Icon(Icons.phone, color: Colors.teal),
                SizedBox(width: 10),
                Text(
                  'Phone: +1 234 567 890',
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
            SizedBox(height: 15),

            // Email
            Row(
              children: [
                Icon(Icons.email, color: Colors.teal),
                SizedBox(width: 10),
                Text(
                  'Email: contact@company.com',
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
            SizedBox(height: 15),

            // Address
            // Row(
            //   children: [
            //     Icon(Icons.location_on, color: Colors.blue),
            //     SizedBox(width: 10),
            //     Text(
            //       'Address: 1234 Street, City, Country',
            //       style: TextStyle(fontSize: 18),
            //     ),
            //   ],
            // ),
          //  SizedBox(height: 30),

            // Social Media (Optional)
            Text(
              'Follow us on:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.facebook, color: Colors.teal),
                SizedBox(width: 10),
                Text('Facebook: @company'),
                SizedBox(width: 20),

              ],
            ),
          ],
        ),
      ),
    );
  }
}
