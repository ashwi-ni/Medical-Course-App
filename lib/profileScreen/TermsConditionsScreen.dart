import 'package:flutter/material.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Terms of Service',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'As stated above, a Terms of Service agreement is a legal agreement where you disclose your rules and guidelines that your users or visitors must agree to in order to use your website or app.',
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'Some common rules and guidelines include the following:',
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 8),
            const Text(
              '• Not stealing your content and violating copyright laws\n'
                  '• Not spamming other users\n'
                  '• Not using your site for illegal activities\n'
                  'These agreements are commonly abbreviated as ToS and are also referred to as a Terms and Conditions, Terms of Use, Conditions of Use, or User Agreement.',
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'Regardless of what you call your Terms of Service, the aim of the agreement is the same:',
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 8),
            const Text(
              '• Disclose the rules and restrictions that your users must adhere to\n'
                  '• Maintain your right to terminate abusive accounts\n'
                  '• Make your copyright, trademark, and intellectual property rights known\n'
                  '• Limit your liability\n'
                  '• Disclaim warranties',
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'Depending on the nature of your business, your ToS may also need clauses that cover:',
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 8),
            const Text(
              '• Payment terms\n'
                  '• Subscription information\n'
                  '• Licensing rights\n'
                  '• Customer support\n'
                  '• User-generated content',
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
