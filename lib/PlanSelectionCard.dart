import 'package:flutter/material.dart';

class SubscriptionCard extends StatelessWidget {
  final String planName;
  final String price;
  final String description;
  final String billingDetails;
  final Function(BuildContext) onSelect;

  SubscriptionCard({
    required this.planName,
    required this.price,
    required this.description,
    required this.billingDetails,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onSelect(context),
      child: Container(
        width: 200,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.greenAccent, width: 3.0),
        ),
        child: Column(
          children: [
            Text(
              planName,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 10),
            Text(
              description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            Text(
              billingDetails,
              style: TextStyle(
                fontSize: 18,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}