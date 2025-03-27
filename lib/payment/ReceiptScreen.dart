import 'package:flutter/material.dart';

class ReceiptScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text('E-Receipt', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.share, color: Colors.black),
            onPressed: () {
              // Add share logic here
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.network(
                'https://via.placeholder.com/300x100.png?text=Barcode',
                height: 100,
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(height: 16),
            _buildReceiptDetail('Purchase Date', 'August 24, 2023 | 10:00 AM'),
            _buildReceiptDetail('Mentor', 'Robert Green'),
            _buildReceiptDetail('Language', 'English'),
            _buildReceiptDetail('Lessons', '32'),
            _buildReceiptDetail('Level', 'Beginner'),
            Divider(height: 32, thickness: 1, color: Colors.grey.shade300),
            _buildReceiptDetail('Amount', '\$180.00'),
            _buildReceiptDetail('Tax', '\$5.00'),
            _buildReceiptDetail('Total', '\$185.00'),
            Divider(height: 32, thickness: 1, color: Colors.grey.shade300),
            _buildReceiptDetail('Payment Method', 'Apple Pay'),
            _buildReceiptDetail('Payment Status', 'Paid'),
            _buildReceiptDetail('Transaction ID', '#RE2564HG23'),
            Spacer(),
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
                onPressed: () {
                  // Add download logic here
                },
                child: Text(
                  'Download E-Receipt',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
          Text(
            value,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}


