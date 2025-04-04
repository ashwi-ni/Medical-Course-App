import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo/payment/ReviewSummaryScreen.dart';
import 'package:demo/services/stripe_service.dart';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:video_player/video_player.dart';

class CourseDetailScreen extends StatefulWidget {
  final Map<String, dynamic> course;
  const CourseDetailScreen({required this.course});


  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  bool isSaved = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkIfSaved(); // Ensure saved state is checked after the widget is built
    });
  }

  Future<void> checkIfSaved() async {
    try {
      final docRef = FirebaseFirestore.instance
          .collection('savedCourses')
          .doc(widget.course['id']);

      final docSnapshot = await docRef.get();

      setState(() {
        isSaved = docSnapshot.exists; // Update state based on Firestore data
      });
    } catch (e) {
      print("Error checking saved course: $e");
    }
  }

  Future<void> toggleSaveCourse() async {
    final docRef = FirebaseFirestore.instance
        .collection('savedCourses')
        .doc(widget.course['id']);

    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final docSnapshot = await transaction.get(docRef);

        if (docSnapshot.exists) {
          // If the course is already saved, remove it
          transaction.delete(docRef);
          setState(() {
            isSaved = false; // Update state to reflect removal
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Course removed from Saved!')),
          );
        } else {
          // If the course is not saved, save it
          transaction.set(docRef, {
            "id": widget.course['id'],
            "title": widget.course['title'],
            "imageUrl": widget.course['imageUrl'],
            "description": widget.course['description'],
            "cost": widget.course['cost'],
            "lessons": widget.course['lessons'],
            "rating": widget.course['rating'],
            "reviews": widget.course['reviews'],
            "author": widget.course['author'],
            "bestSeller": widget.course['bestSeller'],
            "savedAt": Timestamp.now(),
          });

          setState(() {
            isSaved = true; // Update state to reflect saving
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Course saved!')),
          );
        }
      });
    } catch (e) {
      print("Error toggling saved course: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating saved course. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    print(widget.course);
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(
              isSaved ? Icons.bookmark : Icons.bookmark_border,
              color: isSaved ? Colors.grey : null,
            ),
            onPressed: toggleSaveCourse,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section with Image
            Stack(
              children: [
                Image.network(
                  widget.course['imageUrl'] ?? 'https://via.placeholder.com/600x300',
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  bottom: 10,
                  left: 10,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black.withOpacity(0.6),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      // Add course preview functionality
                    },
                    icon: Icon(Icons.play_arrow),
                    label: Text('Course Preview'),
                  ),
                ),
              ],
            ),

            // Course Details
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.yellow.shade700,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          widget.course['bestSeller'] ?? 'Best Seller',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Spacer(),
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 20),
                          SizedBox(width: 4),
                          Text('${widget.course['rating'] ?? 'N/A'} (${widget.course['reviews'] ?? '0'} reviews)'),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    widget.course['title'] ?? 'No Title',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Text(widget.course['author'] ?? 'Unknown Author'),
                      SizedBox(width: 16),
                      Text('${widget.course['lessons'] ?? 0} Lessons'),
                      SizedBox(width: 16),
                      Text('Certificate'),
                    ],
                  ),
                ],
              ),
            ),

            // Tab Bar Section
            TabBarSection(course: widget.course),

            // Enroll Section
            // Enroll Section
            Container(
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  Text(
                    '\$${widget.course['cost'] ?? 0}',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.orange),
                  ),
                  Spacer(),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ReviewSummaryScreen(courseData: widget.course),
                        ),
                      );
                    },
                    child: const Text('Enroll Now'),
                  ),

                ],

              ),


            ),
          ],
        ),
      ),
    );
  }
}


class TabBarSection extends StatefulWidget {
  final Map<String, dynamic> course;
  TabBarSection({required this.course});

  @override
  State<TabBarSection> createState() => _TabBarSectionState();
}

class _TabBarSectionState extends State<TabBarSection> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<String> lessonTitles = [];
  List<String> lessonVideos = [];
  int? selectedLessonIndex; // ✅ Track selected lesson index

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchCourseDetails();
  }

  Future<void> _fetchCourseDetails() async {
    try {
      var documentId = widget.course['id'] ?? "";

      print('Fetching course where id = $documentId');

      var querySnapshot = await FirebaseFirestore.instance
          .collection('courses')
          .where('id', isEqualTo: documentId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        var courseData = querySnapshot.docs.first.data();

        print('Fetched course data: $courseData');

        setState(() {
          lessonTitles = List<String>.from(courseData['lessonTitles'] ?? []);
          lessonVideos = List<String>.from(courseData['lessonVideos'] ?? []);
        });
      } else {
        print("Course with id $documentId does not exist.");
      }
    } catch (e) {
      print("Error fetching course details: $e");
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TabBar(
            controller: _tabController,
            tabs: [
              Tab(text: 'Course Details'),
              Tab(text: 'Lesson Content (${lessonTitles.length})'),
              Tab(text: '${widget.course['reviews'] ?? 0} Reviews'),
            ],
            indicatorColor: Colors.teal,
            labelColor: Colors.teal,
            unselectedLabelColor: Colors.black,
          ),
          Container(
            height: 550,
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildCourseDetails(),
                _buildLessonContent(),
                _buildReviews(),
              ],
            ),
          ),
               ],
      ),
    );
  }

  Widget _buildCourseDetails() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Text(
            widget.course['description'] ?? 'No description available',
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 20),
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundImage: NetworkImage(widget.course['instructorImage'] ?? 'https://via.placeholder.com/150'),
              ),
              SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.course['author'] ?? 'Instructor Name',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text('Instructor', style: TextStyle(color: Colors.grey)),
                  Text(
                    'Review: ${widget.course['rating'] ?? 'N/A'}',
                    style: TextStyle(color: Colors.green),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLessonContent() {
    return ListView.builder(
      itemCount: lessonTitles.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: Icon(Icons.check_circle, color: Colors.green),
          title: GestureDetector(
            onTap: () {
              setState(() {
                selectedLessonIndex = index; // Highlight the tapped lesson
              });

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
                    content: SizedBox                 (
                      width: MediaQuery.of(context).size.width * 0.9, // Set explicit width
                      height: 400, // Set explicit height
                      child: FlickVideoPlayer(flickManager: flickManager),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          flickManager.dispose(); // Dispose of the FlickManager
                          Navigator.of(context).pop(); // Close the dialog
                        },
                        child: Text('Close'),
                      ),
                    ],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10), // Rounded corners
                      side: BorderSide(
                        color: Colors.teal, // Border color
                        width: 2, // Border width
                      ),
                    ),
                  );
                },
              );

            },
            child: Text(
              'Lesson ${index + 1}: ${lessonTitles[index]}',
              style: TextStyle(
                fontWeight: selectedLessonIndex == index ? FontWeight.bold : FontWeight.normal, // Highlight selected lesson
                color: selectedLessonIndex == index ? Colors.teal : Colors.black, // Change color for selected lesson
              ),
            ),
          ),
        );
      },
    );
  }


  Widget _buildReviews() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.8,
        ),
        itemCount: 120,
        itemBuilder: (context, index) {
          return Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(color: Colors.grey.shade300, blurRadius: 6, offset: Offset(0, 2)),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (starIndex) {
                    return Icon(
                      starIndex < 4 ? Icons.star : Icons.star_border,
                      color: Colors.yellow,
                      size: 16,
                    );
                  }),
                ),
                SizedBox(height: 4),
                Text(
                  'Review ${index + 1}: Great course!',
                  style: TextStyle(color: Colors.black, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundImage: NetworkImage('https://via.placeholder.com/150'),
                    ),
                    SizedBox(width: 8),
                    Text('User Name', style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class LessonVideoPlayer extends StatefulWidget {
  final String? videoUrl;

  const LessonVideoPlayer({Key? key, this.videoUrl}) : super(key: key);

  @override
  _LessonVideoPlayerState createState() => _LessonVideoPlayerState();
}

class _LessonVideoPlayerState extends State<LessonVideoPlayer> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;

  @override
  void initState() {
    super.initState();
    if (widget.videoUrl != null && widget.videoUrl!.isNotEmpty) {
      _controller = VideoPlayerController.network(widget.videoUrl!);
      _initializeVideoPlayerFuture = _controller.initialize();
    }
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.videoUrl == null || widget.videoUrl!.isEmpty) {
      return Container(); // If no video URL is provided, return an empty container
    }

    return FutureBuilder<void>(
      future: _initializeVideoPlayerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Column(
            children: [
              AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(
                      _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                    ),
                    onPressed: () {
                      setState(() {
                        if (_controller.value.isPlaying) {
                          _controller.pause();
                        } else {
                          _controller.play();
                        }
                      });
                    },
                  ),
                ],
              ),
            ],
          );
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}

Widget _buildReviews() {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // This will create 2 columns
        crossAxisSpacing: 10, // Space between columns
        mainAxisSpacing: 10, // Space between rows
        childAspectRatio: 0.8, // Adjust the height/width ratio of each item
      ),
      itemCount: 120, // Adjust the item count based on actual data
      itemBuilder: (context, index) {
        return Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(color: Colors.grey.shade300, blurRadius: 6, offset: Offset(0, 2)),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (starIndex) {
                  return Icon(
                    starIndex < 4 ? Icons.star : Icons.star_border,
                    color: Colors.yellow,
                    size: 16,
                  );
                }),
              ),
              SizedBox(height: 4),
              Text(
                'Review ${index + 1}: Great course!',
                style: TextStyle(color: Colors.black, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 4),
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: NetworkImage(
                      'https://via.placeholder.com/150',
                    ),
                  ),
                  SizedBox(width: 8),
                  Text('User Name', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        );
      },
    ),
  );
}

