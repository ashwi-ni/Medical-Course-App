  import 'dart:async';
  import 'package:firebase_auth/firebase_auth.dart';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
  import 'package:cloud_firestore/cloud_firestore.dart';
  import 'package:table_calendar/table_calendar.dart';
import 'package:video_player/video_player.dart';

  import 'CourseDetailScreen.dart';

  class CoursesScreen extends StatefulWidget {
    @override
    _CoursesScreenState createState() => _CoursesScreenState();
  }

  class _CoursesScreenState extends State<CoursesScreen> with SingleTickerProviderStateMixin {
    Map<String, Map<String, String>> schedule = {};
    late TabController _tabController;
    late DateTime _selectedDay;

    // Timer variables
    Map<int, int> questionTimers = {}; // Keeps track of each question's time
    List<String> questions = [];

    Future<void> _fetchScheduleFromFirestore() async {
      try {
        var snapshot = await FirebaseFirestore.instance
            .collection('schedules')
            .doc('user_id') // Replace with actual user_id
            .get();

        if (snapshot.exists) {
          Map<String, Map<String, String>> fetchedSchedule = {};

          snapshot.data()!.forEach((date, activities) {
            Map<String, String> daySchedule = {};
            (activities as Map<String, dynamic>).forEach((timeSlot, activity) {
              daySchedule[timeSlot] = activity;
            });
            fetchedSchedule[date] = daySchedule;
          });

          setState(() {
            schedule = fetchedSchedule;
          });
        }
      } catch (e) {
        print("Error fetching data: $e");
      }
    }

    @override
    void dispose() {
      _tabController.dispose();
      super.dispose();
    }

    @override
    void initState() {
      super.initState();
      _tabController = TabController(length: 3, vsync: this);
      _selectedDay = DateTime.now();

      _tabController.addListener(() {
        setState(() {});
      });

      _fetchScheduleFromFirestore();
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
              'Courses & Schedule', style: TextStyle(color: Colors.white)),
          backgroundColor: Color(0xFF3d675f),
          bottom: TabBar(
            controller: _tabController,
            tabs: [
              Tab(child: Text(
                  'Class Schedule', style: TextStyle(color: Colors.white))),
              Tab(child: Text('Studying', style: TextStyle(color: Colors.white))),
              Tab(child: Text('Saved', style: TextStyle(color: Colors.white))),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildClassScheduleTab(), // Class Schedule Tab
            StudyingTab (), // Studying Tab
            _buildSavedTab(), // Saved Tab
          ],
        ),
        floatingActionButton: _tabController.index == 0
            ? FloatingActionButton(
          onPressed: () {
            _showAddNewDialog();
          },
          child: Icon(Icons.add),
          backgroundColor: Colors.teal,
        )
            : null, // No button for other tabs
      );
    }

      Widget _buildClassScheduleTab() {
      return Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2025, 12, 31),
            focusedDay: _selectedDay,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
              });
              _fetchScheduleForSelectedDay();
            },
          ),
          Expanded(
            child: _buildScheduleForSelectedDay(),
          ),
        ],
      );
    }
    Widget _buildSavedTab() {
      final String? userId = FirebaseAuth.instance.currentUser?.uid;

      if (userId == null) {
        return Center(child: Text("Please log in to view saved courses"));
      }

      return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('savedCourses')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No saved courses found.'));
          }

          final savedCourses = snapshot.data!.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();

          return ListView.builder(
            itemCount: savedCourses.length,
            itemBuilder: (context, index) {
              final savedCourse = savedCourses[index];
              final String courseId = savedCourse['id']; // Assuming each course has an 'id' field
              final String imageUrl = savedCourse['imageUrl'] ?? '';
              final String courseName = savedCourse['title'] ?? 'Unnamed Course';
              final int completedLessons = savedCourse['completedLessons'] ?? 0;
              final int totalLessons = savedCourse['totalLessons'] ?? 1;

              return Card(
                margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation: 5,
                child: ListTile(
                  contentPadding: EdgeInsets.all(10),
                  leading: imageUrl.isNotEmpty
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      imageUrl,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  )
                      : Icon(Icons.bookmark, color: Colors.teal),
                  title: Text(courseName, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  subtitle: Text('$completedLessons of $totalLessons lessons completed'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          await _removeCourseFromSaved(userId, courseId);
                        },
                      ),
                      Icon(Icons.arrow_forward_ios, color: Colors.teal),
                    ],
                  ),
                  onTap: () {
                    print("🚀 Selected Course Data: $savedCourse");
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CourseDetailScreen(course: savedCourse),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      );
    }

    Future<void> _removeCourseFromSaved(String? userId, String courseId) async {
      try {
        if (userId != null && courseId.isNotEmpty) {
          // Make sure you have the correct path to the saved courses collection
          // and you're deleting the specific course using courseId
          await FirebaseFirestore.instance
              .collection('savedCourses') // Path to saved courses
              .where('id', isEqualTo: courseId) // Find the document with this courseId
              .get()
              .then((querySnapshot) {
            for (var doc in querySnapshot.docs) {
              // Deleting the course document
              doc.reference.delete();
              print("Course removed successfully!");
            }
          });

        }
      } catch (e) {
        print("Error removing course: $e");
      }
    }




    void _fetchScheduleForSelectedDay() {
      // Implement logic to fetch or filter the schedule based on selected day
    }

    Widget _buildScheduleForSelectedDay() {
      String selectedDayKey = _getFormattedDateFromDate(_selectedDay);

      if (!schedule.containsKey(selectedDayKey)) {
        return Center(child: Text('No schedule available for this day.'));
      }

      return ListView.builder(
        itemCount: schedule[selectedDayKey]?.length ?? 0,
        itemBuilder: (context, index) {
          String timeSlot = schedule[selectedDayKey]!.keys.elementAt(index);
          String activity = schedule[selectedDayKey]![timeSlot]!;

          return ListTile(
            title: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: activity != null ? Colors.teal.shade100 : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: activity != null ? Colors.teal : Colors.transparent),
                ),
                child: Center(child: Text('$timeSlot: $activity', style: TextStyle(color: Colors.purple, fontWeight: FontWeight.bold, fontSize: 20)))),
                          );
                        },
                      );
                    }

    String _getFormattedDateFromDate(DateTime date) {
      return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    }

    Future<void> _addNewSchedule(String day, String timeSlot, String activity, DateTime selectedDate) async {
      try {
        String formattedDate = _getFormattedDateFromDate(selectedDate);

        await FirebaseFirestore.instance.collection('schedules').doc('user_id').set({
          formattedDate: {
            timeSlot: activity
          }
        }, SetOptions(merge: true));

        setState(() {
          if (schedule[formattedDate] == null) {
            schedule[formattedDate] = {};
          }
          schedule[formattedDate]![timeSlot] = activity;
        });
      } catch (e) {
        print("Error adding schedule: $e");
      }
    }

    void _showAddNewDialog() {
      final TextEditingController timeSlotController = TextEditingController();
      final TextEditingController activityController = TextEditingController();

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Add New Schedule'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: timeSlotController,
                  decoration: InputDecoration(labelText: 'Time Slot (e.g., 10:00 AM - 11:00 AM)'),
                ),
                TextField(
                  controller: activityController,
                  decoration: InputDecoration(labelText: 'Activity'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  if (timeSlotController.text.isNotEmpty &&
                      activityController.text.isNotEmpty) {
                    // Add the schedule to Firebase
                    await _addNewSchedule(
                      _getFormattedDateFromDate(_selectedDay),
                      timeSlotController.text,
                      activityController.text,
                      _selectedDay,
                    );
                    Navigator.pop(context);
                  } else {
                    // Show error if fields are empty
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Please fill in all fields.')),
                    );
                  }
                },
                child: Text('Add'),
              ),
            ],
          );
        },
      );
    }

  }


  class StudyingTab extends StatefulWidget {
    @override
    _StudyingTabState createState() => _StudyingTabState();
  }

  class _StudyingTabState extends State<StudyingTab> {
    List<Map<String, dynamic>> courses = []; // Store all courses
    List<String> lessonTitles = [];
    List<String> lessonVideos = [];
    List<bool> lessonCompleted = []; // Track if each lesson is completed
    int selectedCourseIndex = -1; // Track the selected course
    int selectedLessonIndex = -1;

    // Fetch all courses data from Firestore
    Future<void> _fetchCourseData() async {
      try {
        print("Fetching all courses");

        var courseSnapshot = await FirebaseFirestore.instance
            .collection('courses')
            .get();

        print('Course snapshot exists: ${courseSnapshot.docs.isNotEmpty}');

        if (courseSnapshot.docs.isNotEmpty) {
          setState(() {
            courses.clear();
            selectedCourseIndex = -1;
            lessonTitles.clear();
            lessonVideos.clear();
            lessonCompleted.clear();
          });

          for (var courseDoc in courseSnapshot.docs) {
            var courseData = courseDoc.data() as Map<String, dynamic>;
            courses.add(courseData);
          }

          // Auto-select "Flutter Basics" course on load
          int flutterBasicsIndex =
          courses.indexWhere((course) => course['title'] == 'Flutter Basics');

          if (flutterBasicsIndex != -1) {
            var flutterBasicsCourse = courses[flutterBasicsIndex];
            var titles = flutterBasicsCourse['lessonTitles'] as List<dynamic>;
            var videos = flutterBasicsCourse['lessonVideos'] as List<dynamic>;

            if (titles != null &&
                videos != null &&
                titles.isNotEmpty &&
                videos.isNotEmpty) {
              setState(() {
                selectedCourseIndex = flutterBasicsIndex;
                lessonTitles = List<String>.from(titles.cast<String>());
                lessonVideos = List<String>.from(videos.cast<String>());
                lessonCompleted = List<bool>.filled(lessonTitles.length, false);
              });
            } else {
              print('No lesson data found in Flutter Basics.');
            }
          } else {
            print('Flutter Basics course not found.');
          }
        } else {
          print('No courses found');
        }
      } catch (e) {
        print("Error fetching course data: $e");
      }
    }


    @override
    void initState() {
      super.initState();
      _fetchCourseData(); // Fetch all course data on init
    }

    // Helper function for course cards
    Widget _courseCard(String title, int lessons, double progress) {
      return GestureDetector(
        onTap: () {
          setState(() {
            selectedCourseIndex = courses.indexWhere((course) => course['title'] == title);
            lessonTitles = List<String>.from(courses[selectedCourseIndex]['lessonTitles'].cast<String>());
            lessonVideos = List<String>.from(courses[selectedCourseIndex]['lessonVideos'].cast<String>());
            lessonCompleted = List<bool>.filled(lessonTitles.length, false); // Reset completion status on course change
          });
        },
        child: Card(
          color: Colors.lightGreen,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.book, size: 40, color: Colors.red),
                SizedBox(height: 8),
                Text(
                  title,
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 5),
                Text(
                  "$lessons Lessons",
                  style: TextStyle(color: Colors.grey[900], fontSize: 12),
                ),
                SizedBox(height: 5),
                LinearProgressIndicator(
                  value: progress,
                  color: Colors.green[900],
                  backgroundColor: Colors.grey,
                ),
                SizedBox(height: 5),
                Text('${(progress * 100).toStringAsFixed(0)}% Complete', style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
        ),
      );
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        body: courses.isEmpty
            ? Center(child: CircularProgressIndicator()) // Show loading until courses are loaded
            : SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Display all courses dynamically using a horizontally scrollable Row
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal, // Enable horizontal scrolling
                  child: Row(
                    children: List.generate(courses.length, (index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: SizedBox(
                          width: 250, // Set a fixed width for the course cards
                          child: _courseCard(
                            courses[index]['title'] ?? 'Unknown Course',
                            courses[index]['lessonTitles']?.length ?? 0,
                            courses[index]['progress'] ?? 0.0,
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                SizedBox(height: 20),
                // Display the selected course and its lessons
                if (selectedCourseIndex != -1)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "All Lessons of ${courses[selectedCourseIndex]['title'] ?? 'Course'}",
                        style: TextStyle(color: Colors.black, fontSize: 18),
                      ),
                      SizedBox(height: 5),
                      Text(
                        "Here ${lessonTitles.length} lessons to complete",
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                      SizedBox(height: 20),
                      // Lesson List
                      lessonTitles.isEmpty
                          ? Center(child: CircularProgressIndicator())
                          : ListView.builder(
                        shrinkWrap: true,
                        itemCount: lessonTitles.length,
                        itemBuilder: (context, index) {
                          bool isLessonComplete = lessonCompleted[index];

                          return SingleChildScrollView(
                            child: Row(
                              children: [
                                Column(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        // Create FlickManager for video playback
                                        FlickManager flickManager = FlickManager(
                                          videoPlayerController: VideoPlayerController.network(lessonVideos[index]),
                                        );

                                        // Show video player dialog with FlickVideoPlayer
                                        showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              backgroundColor: Colors.white,
                                              title: Text(lessonTitles[index]),
                                              content: SizedBox(
                                                width: MediaQuery.of(context).size.width * 0.9,
                                                height: 400,
                                                child: FlickVideoPlayer(flickManager: flickManager),
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    flickManager.dispose(); // Dispose of the FlickManager
                                                    Navigator.of(context).pop(); // Close the dialog
                                                    // Mark lesson as complete when video ends
                                                    setState(() {
                                                      lessonCompleted[index] = true;
                                                    });
                                                  },
                                                  child: Text('Close'),
                                                ),
                                              ],
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(10),
                                                side: BorderSide(
                                                  color: Colors.teal, // Border color
                                                  width: 2, // Border width
                                                ),
                                              ),
                                            );
                                          },
                                        );
                                      },
                                      child: Container(
                                        padding: EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: isLessonComplete
                                              ? Colors.green
                                              : Colors.orange,
                                        ),
                                        child: Icon(
                                          isLessonComplete
                                              ? Icons.check_circle
                                              : Icons.play_circle_fill,
                                          color: Colors.white,
                                          size: 15,
                                        ),
                                      ),
                                    ),
                                    if (index != lessonTitles.length - 1)
                                      Container(
                                        width: 2,
                                        height: 40,
                                        color: Colors.black, // Line connecting the icons
                                      ),
                                  ],
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        selectedLessonIndex = index;
                                      });
                                    },
                                    child: Text(
                                      'Lesson ${index + 1}: ${lessonTitles[index]}',
                                      style: TextStyle(
                                        fontWeight: selectedLessonIndex == index
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        color: selectedLessonIndex == index
                                            ? Colors.teal
                                            : Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      );
    }
  }




