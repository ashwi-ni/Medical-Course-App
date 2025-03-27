import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'Autentication/signIn.dart';


class OnboardingScreen extends StatefulWidget {
  final void Function(Locale locale)? onLocaleChange; // ✅ Added this

  const OnboardingScreen({super.key, this.onLocaleChange});
  @override _OnboardingScreenState createState() => _OnboardingScreenState();
}
class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();late String docId;
  int currentPageIndex = 0;
  @override
  void initState() {
    super.initState();
    docId = FirebaseFirestore.instance.collection('students_session').doc().id;
    FirebaseFirestore.instance.collection('students_session').doc(docId).set({
      'studentId': docId,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      currentPageIndex = index;
                    });
                  },
                  children: [
                    OnboardingPage1(),
                    OnboardingPage2(docId: docId,pageController: _pageController),
                    OnboardingPage3(docId: docId, pageController: _pageController),
                    OnboardingPage4(docId: docId, pageController: _pageController),
                    OnboardingPage5(docId: docId),
                    OnboardingPage6(docId: docId),
                  ],
                ),
              ),
              _buildPersistentButtons(context),
            ],
          ),
        ],
      ),
    );}
  Widget _buildPersistentButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton(onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => SignInScreen(
                onLocaleChange: widget.onLocaleChange,
              )),);
          },
            child: const Text('Skip'),
            style: ElevatedButton.styleFrom(foregroundColor: const Color(0xFF76d9c7),
              backgroundColor: const Color(0xFFd8f7f2),
              shape: const CircleBorder(), padding: const EdgeInsets.all(30),
              elevation: 5,
              textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),),
          ),
          ElevatedButton(
            onPressed: () {
              if (currentPageIndex == 5) {
                Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => SignInScreen(
                    onLocaleChange: widget.onLocaleChange,
                  )),
                );
              } else {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              }
            },
            child: const Text('Continue'),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: const Color(0xFF00463a),
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(45),
              elevation: 5,
              textStyle: const TextStyle(fontSize: 15),
            ),
          ),
        ],),
    );
  }
}
class OnboardingPage1 extends StatelessWidget {
  final void Function(Locale locale)? onLocaleChange; // ✅ Added this

  const OnboardingPage1({super.key, this.onLocaleChange});
  @override
Widget build(BuildContext context) {   return Center(
  child: Column(
    mainAxisAlignment: MainAxisAlignment.center, children: [
    // Image for OnboardingPage1 (use your actual image path)
    Padding(
      padding: const EdgeInsets.all(8.0),
      child: Image.asset('assets/images/onboard1.jpg', height: 300),), // Image
    const SizedBox(height: 20),
    const Text(
      'You learn \nWhile Sitting \n at Home',
      style: TextStyle(
        fontSize: 50,
        fontWeight: FontWeight.bold,
      ),
      // textAlign: TextAlign.center,  // Correct placement for textAlign
    ),
  ],
  ),
);}
}
class OnboardingPage2 extends StatelessWidget {
  final void Function(Locale locale)? onLocaleChange; // ✅ Added this
  final PageController pageController;
  final String docId; // Added this if you plan to use it later

  OnboardingPage2({
  super.key,
  required this.pageController,
  required this.docId,
  this.onLocaleChange
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.close, color: Colors.black),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => SignInScreen(
                      onLocaleChange: onLocaleChange,
                    )),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'What you will learn?',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Select your goal of learning',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 50),
          Expanded(child: _learningCircleLayout(context)),
        ],
      ),
    );
  }

  Widget _learningCircleLayout(BuildContext context) {
    List<String> courses = [
      'Marketing',
      'Programming',
      'UI/UX Design',
      'Development',
      'Graphics',
    ];

    List<Offset> positions = [
      Offset(-100, -80), // Top-left
      Offset(100, -80), // Top-right
      Offset(0, 0), // Center
      Offset(-100, 80), // Bottom-left
      Offset(100, 80), // Bottom-right
    ];

    return Stack(
      alignment: Alignment.center,
      children: List.generate(courses.length, (index) {
        bool isSelected = courses[index] == 'UI/UX Design';
        return Positioned(
          left: MediaQuery.of(context).size.width / 2 + positions[index].dx - 60,
          top: MediaQuery.of(context).size.height / 3 + positions[index].dy - 120,
          child: GestureDetector(
            onTap: () {
              _onCircleTapped(context, courses[index]);
            },
            child: CircleAvatar(
              radius: isSelected ? 50 : 40,
              backgroundColor:
              isSelected ? Colors.teal : Colors.grey.withOpacity(0.2),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  courses[index],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: isSelected ? 16 : 14,
                    fontWeight:
                    isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  void _onCircleTapped(BuildContext context, String course) async {
    try {
      DocumentReference docRef =
      FirebaseFirestore.instance.collection('students_session').doc();

      await docRef.set({
        'studentId': docRef.id,
        'selectedCourse': course,
        'timestamp': FieldValue.serverTimestamp(),
      });

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Course Selected'),
            content: Text('You have selected the $course course.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close the dialog first
                  pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      print('Error saving course: $e');
    }
  }
}
class OnboardingPage3 extends StatefulWidget {
  final void Function(Locale locale)? onLocaleChange;
  final String docId;
  final PageController pageController; // Added PageController to navigate
  OnboardingPage3({required this.docId, required this.pageController, this.onLocaleChange});
  @override _OnboardingPage3State createState() => _OnboardingPage3State();
}
class _OnboardingPage3State extends State<OnboardingPage3> {   String? _selectedLevel;
@override Widget build(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.all(20.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(Icons.close, color: Colors.black),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => SignInScreen(
                    onLocaleChange: widget.onLocaleChange,
                  )),
                );
              },
            ),
          ],
        ),
        SizedBox(height: 20),
        Text(
          'Choose Your Level',
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        Text(
          'Select your level',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
        SizedBox(height: 30),
        Flexible(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _levelCard('Beginner', '10-16 Age', 300, 110),
                SizedBox(width: 10),
                _levelCard('Medium', '16-24 Age', 400, 110),
                SizedBox(width: 10),
                _levelCard('Intermediate', '24-36 Age', 500, 110),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
Widget _levelCard(String level, String ageGroup, double height, double width) {   bool isSelected = _selectedLevel == level;
return GestureDetector(   onTap: () {
  setState(() {
    _selectedLevel = level;
  });
  _onLevelSelected(level, ageGroup);
},
  child: Align(
    alignment: Alignment.bottomCenter,
    child: Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: isSelected ? Color(0xe733ecbc) : Colors.grey,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Text(level, style: TextStyle(fontSize: 15)),
          SizedBox(height: 5),
          Text(ageGroup, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          Divider(),
          SizedBox(height: 20),
          Expanded(child: Image.asset('assets/images/age.jpg', fit: BoxFit.fill)),
        ],
      ),
    ),
  ),
); }
void _onLevelSelected(String level, String ageGroup) async {
  try {await FirebaseFirestore.instance.collection('students_session').doc(widget.docId).update({
    'selectedLevel': level,
    'ageGroup': ageGroup,
    'timestamp': FieldValue.serverTimestamp(),
  });
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Level Selected'),
      content: Text('You have selected the $level level for age group $ageGroup.'),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            widget.pageController.nextPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          },
          child: Text('OK'),
        ),
      ],
    ),
  );
  } catch (e) {
    print('Error saving level: $e');
  }
}
}
class OnboardingPage4 extends StatefulWidget {
  final String docId;
  final PageController pageController; // Added PageController to navigate

  OnboardingPage4({required this.docId, required this.pageController});

  @override
  _OnboardingPage4State createState() => _OnboardingPage4State();
}
class _OnboardingPage4State extends State<OnboardingPage4> {
  int _selectedDayIndex = 2;
  int _selectedTimeIndex = 2;
  String _selectedTime = '02 : 30 PM';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.close, color: Colors.black),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
          SizedBox(height: 20),
          Text(
            'Set up learning reminders',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Text(
            'Tell us when you want to learn and we will send push notifications to remind you.',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          SizedBox(height: 30),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(7, (index) {
                final isSelected = index == _selectedDayIndex;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedDayIndex = index;
                    });
                  },
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 5.0),
                    width: 60,
                    height: 80,
                    decoration: BoxDecoration(
                      color: isSelected ? Color(0xFF1DDE7D) : Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${23 + index}',
                          style: TextStyle(fontSize: 18, color: isSelected ? Colors.white : Colors.black),
                        ),
                        Text(
                          ['Thu', 'Fri', 'Sat', 'Sun', 'Mon', 'Tue', 'Wed'][index],
                          style: TextStyle(color: isSelected ? Colors.white : Colors.black),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
          SizedBox(height: 30),
          Center(
            child: Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Color(0xFFF0F8F5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: ListWheelScrollView.useDelegate(
                itemExtent: 50,
                perspective: 0.002,
                diameterRatio: 2.0,
                physics: FixedExtentScrollPhysics(),
                childDelegate: ListWheelChildBuilderDelegate(
                  builder: (context, index) {
                    final times = [
                      '02 : 00 PM',
                      '02 : 15 PM',
                      '02 : 30 PM',
                      '02 : 45 PM',
                      '03 : 00 PM',
                    ];

                    final isSelected = index == _selectedTimeIndex;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedTimeIndex = index;
                          _selectedTime = times[index % times.length];
                        });
                      },
                      child: Text(
                        times[index % times.length],
                        style: TextStyle(
                          fontSize: 18,
                          color: isSelected ? Color(0xFF1DDE7D) : Colors.black,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    );
                  },
                  childCount: 96,
                ),
              ),
            ),
          ),
          SizedBox(height: 30),
          Center(
            child: ElevatedButton(
              onPressed: _saveReminder,
              child: Text('Save Reminder'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                textStyle: TextStyle(fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _saveReminder() async {
    try {
      String selectedDayAndDate = '${['Thu', 'Fri', 'Sat', 'Sun', 'Mon', 'Tue', 'Wed'][_selectedDayIndex]}, ${23 + _selectedDayIndex}';

      await FirebaseFirestore.instance.collection('students_session').doc(widget.docId).update({
        'learningReminder': {
          'dayAndDate': selectedDayAndDate,
          'time': _selectedTime,
        },
        'timestamp': FieldValue.serverTimestamp(),
      });

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Reminder Saved'),
            content: Text('You have set up a reminder for $selectedDayAndDate at $_selectedTime.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  widget.pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      print('Error saving reminder: $e');
    }
  }
}
class OnboardingPage5 extends StatelessWidget {
  final String docId; // Pass docId to identify the current user
  OnboardingPage5({required this.docId});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(height: 50), // Spacing at the top
          Image.asset(
            'assets/images/discount.jpeg', // Your image path
            height: 200,
            width: 400,
          ),
          SizedBox(height: 10),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Pick a Plan to Try for free.\nYou can cancel anytime.',
                style: TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              const Text(
                'Choose a plan to start after your 1-week free trial.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    SubscriptionCard(
                      planName: "Annual Plan",
                      price: "\$9.99/month",
                      description:
                      "^ All answers, no ads\n^ Exclusive features\n^ 24/7 Support",
                      billingDetails:
                      "Only \$9.99/month\nBilled yearly at \$8.00/month",
                      onSelect: (context) {
                        saveSubscriptionPlanToFirebase(
                          context,
                          docId, // Pass the docId directly here
                          "Annual Plan",
                          "\$9.99/month",
                          "Billed yearly at \$8.00/month",
                        );
                      },
                    ),
                    SizedBox(width: 10), SubscriptionCard(
                      planName: "Monthly Plan",
                      price: "\$12.99/month",
                      description:
                      "^ All answers, no ads\n^ Cancel anytime\n^ Full features",
                      billingDetails:
                      "Only \$12.99/month\nPay as you go",
                      onSelect: (context) {
                        saveSubscriptionPlanToFirebase(
                          context,
                          docId, // Pass the docId directly here
                          "Monthly Plan",
                          "\$12.99/month",
                          "Pay as you go",
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          const Text('What is tutor?',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
  Future<void> saveSubscriptionPlanToFirebase(
      BuildContext context, String docId, // Accept docId as a parameter
      String planName,
      String price,
      String billingDetails,
      ) async {
    try {
      await FirebaseFirestore.instance.collection('students_session').doc(docId).update({
        'planName': planName,
        'price': price,
        'billingDetails': billingDetails,
        'timestamp': FieldValue.serverTimestamp(),
      });
      // Show snackbar when successfully saved
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('plan Saved'),
            content: Text('You have selected $planName.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OnboardingPage6(docId:docId), // Pass docId to OnboardingPage4
                    ),
                  );
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      // Show snackbar for error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving plan: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
class SubscriptionCard extends StatelessWidget {   final String planName;
final String price; final String description;
final String billingDetails; final Function(BuildContext) onSelect;
SubscriptionCard({   required this.planName,
  required this.price,
  required this.description,
  required this.billingDetails,
  required this.onSelect,
});
@override Widget build(BuildContext context) {
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
              fontSize: 16, fontWeight: FontWeight.bold,
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
            ), textAlign: TextAlign.center,
          ),
          SizedBox(height: 10),
        ],
      ),
    ),
  );
} }
class OnboardingPage6 extends StatefulWidget {
  final String docId; // Pass docId to identify the current user
  final void Function(Locale locale)? onLocaleChange;
  OnboardingPage6({super.key, required this.docId, this.onLocaleChange});

  @override
  _OnboardingPage6State createState() => _OnboardingPage6State();
}

class _OnboardingPage6State extends State<OnboardingPage6> {
  double _ratingValue = 5; // Default value
  String _smiley = '😊'; // Default smiley

  void _updateSmiley(double value) {
    setState(() {
      _ratingValue = value;
      if (value >= 8) {
        _smiley = '😊';
      } else if (value >= 5) {
        _smiley = '🙂';
      } else if (value >= 3) {
        _smiley = '😐';
      } else {
        _smiley = '😞';
      }
    });
  }
  Future<void> _saveFeedbackToFirebase() async {
    try {
      await FirebaseFirestore.instance
          .collection('students_session')
          .doc(widget.docId)
          .update({
        'sessionRating': _ratingValue,
        'sessionSmiley': _smiley,
        'feedbackTimestamp': FieldValue.serverTimestamp(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Thank you for your feedback!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving feedback: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.black),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => SignInScreen(
                  onLocaleChange: widget.onLocaleChange,
                )),
              );
            },
          ),
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'How was your session?',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              const Text(
                'Love it! What is your favorite part?',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  _smiley,
                  style: const TextStyle(
                    fontSize: 50,
                    color: Colors.green,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Please rate your experience:',
                style: TextStyle(fontSize: 18),
              ),
              Slider(
                value: _ratingValue,
                min: 1,
                max: 10,
                divisions: 9,
                label: _ratingValue.round().toString(),
                onChanged: (double value) {
                  _updateSmiley(value);
                },
              ),
              const SizedBox(height: 20),
              Text(
                'Your rating: ${_ratingValue.toStringAsFixed(1)}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _saveFeedbackToFirebase,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                  ),
                  child: const Text('Submit Feedback'),
                ),
              ),
            ],
          ),
        ));
  }
}
