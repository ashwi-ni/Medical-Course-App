import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'QuizGameScreen.dart';

class QuizListScreen extends StatefulWidget {
  @override
  _QuizListScreenState createState() => _QuizListScreenState();
}

class _QuizListScreenState extends State<QuizListScreen> {
  List<String> _courses = [];

  @override
  void initState() {
    super.initState();
    _fetchCourses();
  }

  // Fetch courses from Firestore
  void _fetchCourses() async {
    final snapshot = await FirebaseFirestore.instance.collection('courses').get();
    setState(() {
      _courses = snapshot.docs.map((doc) => doc['title'] as String).toList();
    });
  }

  // Navigate to QuizGameScreen
  void _startQuiz(String title) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizGameScreen(title: title),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Select a Course to start the Quiz!!",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: _courses.isEmpty
          ? Center(child: CircularProgressIndicator()) // Loading indicator
          : ListView.builder(
        itemCount: _courses.length + 1, // Add 1 for the image at the end
        itemBuilder: (context, index) {
          if (index < _courses.length) {
            // Display courses
            return Card(
              color: Colors.teal,
              margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: ListTile(
                title: Center(
                  child: Text(
                    _courses[index],
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                onTap: () => _startQuiz(_courses[index]),
              ),
            );
          } else {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Image.asset(
                'assets/images/quizman2.png', // Ensure the image is in the correct path
                height: 350.0,
                fit: BoxFit.contain, // Ensures the full image is shown
              ),
            );

          }
        },
      ),
    );
  }
}
