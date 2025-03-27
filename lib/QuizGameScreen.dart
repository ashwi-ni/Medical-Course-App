import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class QuizGameScreen extends StatefulWidget {
  final String title; // Place this before the constructor

  QuizGameScreen({required this.title});

  @override
  _QuizGameScreenState createState() => _QuizGameScreenState();
}

class _QuizGameScreenState extends State<QuizGameScreen> {
  List<Map<String, dynamic>> _questions = [];
  int _currentQuestionIndex = 0;
  int _score = 0;
  bool _isAnswered = false;
  Timer? _timer;
  int _timeLeft = 15;
  String? _selectedAnswer;

  @override
  void initState() {
    super.initState();
    _fetchQuestions();
  }

  void _fetchQuestions() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('quiz_questions')
        .where('title', isEqualTo: widget.title) // Filter by course
        .get();
    setState(() {
      _questions = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'question': data['question'] ?? 'No question',
          'options': (data['options'] as List<dynamic>?)?.cast<String>() ?? [],
          'answer': data['answer'] ?? '',
        };
      }).toList();
      _startTimer();
    });
  }


  void _startTimer() {
    _timeLeft = 15;
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _timeLeft--;
      });
      if (_timeLeft <= 0) {
        timer.cancel();
        _nextQuestion();
      }
    });
  }

  void _checkAnswer(String selectedAnswer) {
    if (_isAnswered) return;
    setState(() {
      _isAnswered = true;
      _timer?.cancel();
      _selectedAnswer = selectedAnswer;
      if (selectedAnswer == _questions[_currentQuestionIndex]['answer']) {
        _score++;
      }
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _isAnswered = false;
        _startTimer();
      });
    } else {
      _showScoreDialog();
    }
  }

  void _showScoreDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Quiz Completed"),
          content: Text("Your score is $_score out of ${_questions.length}"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text("Quiz for ${widget.title}"), // Use widget.courseName
          backgroundColor: Colors.teal,
        ),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Quiz for ${widget.title}"), // Use widget.courseName
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Question ${_currentQuestionIndex + 1} of ${_questions.length}",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              "Time left: $_timeLeft seconds",
              style: TextStyle(fontSize: 16, color: Colors.red),
            ),
            SizedBox(height: 20),
            Text(
              _questions[_currentQuestionIndex]['question'],
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 20),
            ..._questions[_currentQuestionIndex]['options'].map<Widget>((option) {
              Color buttonColor;
              if (_isAnswered) {
                if (option == _questions[_currentQuestionIndex]['answer']) {
                  buttonColor = Colors.green;
                } else if (option == _selectedAnswer) {
                  buttonColor = Colors.red;
                } else {
                  buttonColor = Colors.grey;
                }
              } else {
                buttonColor = Colors.teal;
              }

              return ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor,
                ),
                onPressed: () => _checkAnswer(option),
                child: Text(option, style: TextStyle(color:Colors.white),),
              );
            }).toList(),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isAnswered ? _nextQuestion : null,
              child: Text("Next"),
            ),
          ],
        ),
      ),
    );
  }
}
