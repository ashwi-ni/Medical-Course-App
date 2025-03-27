import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../profileScreen/PaymentMethodsScreen.dart';
import 'PaymentSuccessScreen.dart';

class ReviewSummaryScreen extends StatelessWidget {
  final Map<String, dynamic> courseData;
  const ReviewSummaryScreen({required this.courseData});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Review Summary', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<QuerySnapshot>(
          future: FirebaseFirestore.instance.collection('courses').get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(child: Text('No courses available'));
            }

            // Get the first course document from the list
         //  var courseData = snapshot.data!.docs[0].data() as Map<String, dynamic>;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Course Card
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  //color: Colors.grey.shade100,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                courseData['imageUrl'], // Replace with Firestore image URL
                                height: 120,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: 8,
                              left: 8,
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.teal,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text('Best Seller', style: TextStyle(fontWeight: FontWeight.bold,color:Colors.white)),
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Icon(Icons.bookmark, color: Colors.teal),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          courseData['title'], // Course title from Firestore
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.person, size: 16),
                            SizedBox(width: 4),
                            Text(courseData['author']), // Instructor name
                          ],
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.star, size: 16, color: Colors.teal.shade700),
                            SizedBox(width: 4),
                            Text('${courseData['rating']} (${courseData['reviewsCount']} reviews)'),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text('\$${courseData['cost']}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16),
                // Course Details
                _buildDetailRow('Course', courseData['title']),
                _buildDetailRow('Lessons', '${courseData['lessons']}'),
                //_buildDetailRow('Level', courseData['level']),
                Divider(),
                _buildDetailRow('Amount', '\$${courseData['cost']}'),
                _buildDetailRow('Tax', '\$5.00'),
                Divider(),
                _buildDetailRow('Total', '\$${courseData['cost'] + 5}', isBold: true),
                SizedBox(height: 24),
                Divider(),
                // Payment Method
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.credit_card, color: Colors.teal.shade700),
                        SizedBox(width: 8),
                        Text('Apple Pay', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>   PaymentMethodsScreen(),
                          ),
                        );

                      },
                      child: Text('Change', style: TextStyle(color: Colors.teal.shade700)),
                    ),
                  ],
                ),
                Spacer(),
                // Done Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal.shade700,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: () async {
                      bool paymentSuccess = await _processPayment(); // Simulate or call payment logic

                      if (paymentSuccess) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PaymentSuccessScreen(),
                          ),
                        );
                      } else {
                        // Show an error dialog or message
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('Payment Failed'),
                            content: Text('There was an issue with your payment. Please try again.'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text('OK'),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                    child: Text('Done', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,color:Colors.white)),
                  ),

                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // Utility to build detail rows
  Widget _buildDetailRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 16)),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
Future<bool> _processPayment() async {
  // Simulate payment processing with a delay
  await Future.delayed(Duration(seconds: 2)); // Simulate a delay
  return true; // Change this based on payment status
}
