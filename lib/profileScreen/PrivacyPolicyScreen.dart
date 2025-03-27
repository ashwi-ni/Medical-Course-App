import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Privacy Policy',
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
              'Privacy Policies are required by law to be posted on your website. You may be required to include specific clauses in your Privacy Policy, depending on the applicable laws within your area or where you are conducting business.',
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'In fact, privacy laws are in place in many countries around the globe, including the following:',
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 16),
            const Text(
              '• Canada\'s Personal Information Protection and Electronic Documents Act (PIPEDA)\n'
                  '• The California Online Privacy Protection Act (CalOPPA)\n'
                  '• The California Consumer Privacy Act (CCPA)\n'
                  '• Europe\'s General Data Protection Regulation (GDPR)\n'
                  '• Australia\'s Privacy Act\n'
                  '• The UK\'s Data Protection Act\n'
                  'Loading...',
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'Third Party Services Require a Privacy Policy',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Many third-party services that you use to improve your website\'s user experience, monitor analytics, or display ads require you to post a Privacy Policy.',
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'You should provide clauses detailing how you use third-party services, APIs, and SDKs.',
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'Just some of the most popular third-party services, which require you to post a Privacy Policy are:',
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 8),
            const Text(
              '• Google Analytics\n'
                  '• Google AdSense\n'
                  '• Google AdWords\n'
                  '• Amazon Associates\n'
                  '• ClickBank\n'
                  '• Twitter Lead Generation\n'
                  '• Facebook Pages, Stores, and Apps\n'
                  '• Google Play Store\n'
                  '• Apple\'s App Store',
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'A few of the reasons these third-party services require you to post a Privacy Policy and disclose your usage of their cookies and data collection methods are:',
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
