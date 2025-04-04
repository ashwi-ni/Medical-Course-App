import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo/profileScreen/ContactusScreen.dart';
import 'package:demo/profileScreen/EditProfileScreen.dart';
import 'package:demo/profileScreen/HelpCenterScreen.dart';
import 'package:demo/profileScreen/PaymentMethodsScreen.dart';
import 'package:demo/profileScreen/PrivacyPolicyScreen.dart';
import 'package:demo/profileScreen/TermsConditionsScreen.dart';
import 'package:demo/quiz_list.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:badges/badges.dart' as badges;
import 'CourseDetailScreen.dart';
import 'CoursesScreen.dart';
import 'LearningSoundSettingsScreen.dart';
import 'localization/app_localizations.dart';
import 'notificationscreen.dart';

import 'Autentication/signIn.dart';

class HomeScreen extends StatefulWidget {
  final void Function(Locale locale)? onLocaleChange;
  //final Locale locale;
  const HomeScreen({Key? key, this.onLocaleChange, }) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  int _notificationCount = 0;
  late List<Widget> _screens = [];
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final Map<String, Locale> _languageMap = {
    'English': Locale('en'),
    'Spanish': Locale('es'),
    'Hindi': Locale('hi'),
    'Marathi': Locale('mr'),
  };

  late String _selectedLanguage;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    Locale currentLocale = Localizations.localeOf(context);
    _selectedLanguage = _languageMap.entries.firstWhere(
          (entry) => entry.value == currentLocale,
      orElse: () => MapEntry('English', Locale('en')),
    ).key;

    _screens = [
      HomeContentScreen(onLocaleChange: widget.onLocaleChange ?? (locale) {}),
      CoursesScreen(),
      QuizListScreen(),
      ProfileScreen(),
    ];
  }
  @override
  void initState() {
    super.initState();
    _selectedLanguage = 'English'; // Default language
    _loadNotificationCount();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _incrementNotificationCount();
    });

    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        _incrementNotificationCount();
      }
    });
  }

  void _incrementNotificationCount() async {
    setState(() {
      _notificationCount++;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('notificationCount', _notificationCount);
  }

  void _resetNotificationCount() async {
    setState(() {
      _notificationCount = 0;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('notificationCount', 0);
  }

  Future<void> _loadNotificationCount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationCount = prefs.getInt('notificationCount') ?? 0;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onLanguageChanged(String? newLanguage) {
    if (newLanguage != null && _languageMap.containsKey(newLanguage)) {
      final newLocale = _languageMap[newLanguage]!;

      widget.onLocaleChange?.call(newLocale); // Update locale

      setState(() {
        _selectedLanguage = newLanguage;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context) ?? AppLocalizations(Locale('en'));


    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: const Color(0xFF3d675f),
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        title: DropdownButton<String>(
          value: _selectedLanguage,
          dropdownColor: const Color(0xFF3d675f),
          style: const TextStyle(color: Colors.white),
          iconEnabledColor: Colors.white,
          underline: const SizedBox(),
          items: _languageMap.keys.map((String language) {
            return DropdownMenuItem<String>(
              value: language,
              child: Text(language, style: const TextStyle(color: Colors.white)),
            );
          }).toList(),
          onChanged: _onLanguageChanged,
        ),
        actions: [
          IconButton(
            icon: Padding(
              padding: const EdgeInsets.only(right: 15),
              child: badges.Badge(
                badgeContent: Text(
                  _notificationCount > 0 ? '$_notificationCount' : '',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
                badgeStyle: const badges.BadgeStyle(badgeColor: Colors.red),
                showBadge: _notificationCount > 0,
                child: const Icon(Icons.notifications_active_outlined, color: Colors.white),
              ),
            ),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Notificationscreen()),
              );
              _resetNotificationCount();
            },
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        backgroundColor: const Color(0xFF3d675f),
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(icon: const Icon(Icons.home), label: localization.translate('home')),
          BottomNavigationBarItem(icon: const Icon(Icons.book), label: localization.translate('courses')),
          BottomNavigationBarItem(icon: const Icon(Icons.quiz), label: localization.translate('quiz')),
          BottomNavigationBarItem(icon: const Icon(Icons.account_circle), label: localization.translate('profile')),
        ],
        onTap: _onItemTapped,
      ),
      drawer: _buildDrawer(localization),
    );
  }

  Widget _buildDrawer(AppLocalizations? localization) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFF3d675f)),
            child: Text(
              localization!.translate('menu'),
              style: const TextStyle(color: Colors.white, fontSize: 30),
            ),
          ),
          _buildDrawerItem(Icons.home, localization.translate('home'), 0),
          _buildDrawerItem(Icons.info, localization.translate('aboutUs'), 1),
          _buildDrawerItem(Icons.description, localization.translate('termsOfService'), 2),
          _buildDrawerItem(Icons.security, localization.translate('privacyPolicy'), 3),
          _buildDrawerItem(Icons.star, localization.translate('rateUs'), 4),
          _buildDrawerItem(Icons.share, localization.translate('share'), 5),
          _buildDrawerItem(Icons.exit_to_app, localization.translate('logout'), 6),
          _buildDrawerItem(Icons.info_outline, '${localization.translate('appVersion')} 1.0.0', 7),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, int index) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        Navigator.pop(context);

        switch (index) {
          case 0:
            setState(() {
              _selectedIndex = 0;
            });
            break;
          case 2:
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => TermsConditionsScreen()),
            );
            break;
          case 3:
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PrivacyPolicyScreen()),
            );
            break;
          case 6:
            _logout();
            break;
        }
      },
    );
  }

  void _logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => SignInScreen()),
    );
  }
}


// Show App Version function
//     void _showAppVersion() async {
//       PackageInfo packageInfo = await PackageInfo.fromPlatform();
//       String version = packageInfo.version;
//       String buildNumber = packageInfo.buildNumber;
//
//       showDialog(
//         context: context,
//         builder: (context) {
//           return AlertDialog(
//             title: Text('App Version'),
//             content: Text('Version: $version\nBuild Number: $buildNumber'),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.pop(context),
//                 child: Text('Close'),
//               ),
//             ],
//           );
//         },
//       );
//     }



class HomeContentScreen extends StatefulWidget {
  final void Function(Locale) onLocaleChange;

  const HomeContentScreen({super.key, required this.onLocaleChange});
  @override
  _HomeContentScreenState createState() => _HomeContentScreenState();
}

class _HomeContentScreenState extends State<HomeContentScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _filteredCourses = [];
  String _searchQuery = '';
  String _selectedCategoryKey  = 'All Courses'; // Default category is All Courses

  final List<String> _categoryKeys = [
    'All Courses',
    //'UI/UX Designer',
    'Cell Biology',
    'Hematology',
    'Immunology',
    'Cardiovascular Physiology'
  ];
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categoryKeys.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _filterCourses(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
    });
  }

  Widget _buildTab(String key) {
    //List<String> translatedCategoryKeys = _categoryKeys.map((key) => key.translate(context)).toList();
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.teal,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.teal),
      ),
      child: Text(
        key.translate(context),
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),

    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // First container for AppBar, Title, Search Bar, and TabBar
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color(0xFF3d675f),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                AppLocalizations.of(context)!.translate('What would you like to learn today? Search below'),
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _searchController,
                  onChanged: _filterCourses,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search courses...'.translate(context),
                    hintStyle: TextStyle(color: Colors.white),
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(
                      Icons.search,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: 16),
                TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  indicatorColor: Colors.transparent,
                  labelColor: Colors.teal,
                  unselectedLabelColor: Colors.white,
                  dividerColor: Colors.transparent,
                  onTap: (index) {
                    setState(() {
                      _selectedCategoryKey = _categoryKeys[index];
                    });
                  },
                  tabs: _categoryKeys.map((key) => _buildTab(key)).toList(),
                ),
              ],
            ),
    ),




          SizedBox(height: 16),

          // Ongoing Courses Section with Firestore Data
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ongoing Courses'.translate(context),
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('courses').snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Center(child: Text('No courses available.'));
                    }

                    final courses = snapshot.data!.docs.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      return {
                        'id': data.containsKey('id') ? data['id'] : 'Unknown id',  // Fixed key name
                        'imageUrl': data.containsKey('imageUrl') && data['imageUrl'] != null && Uri.tryParse(data['imageUrl'])?.isAbsolute == true
                            ? data['imageUrl']
                            : 'assets/images/placeholder.png',
                        'title': data.containsKey('title') ? data['title'] : 'Unknown Title',
                        'progress': data.containsKey('progress') ? data['progress'].toDouble() : 0.0,
                        'cost': data.containsKey('cost') ? data['cost'] : 0,
                        'author': data.containsKey('author') ? data['author'] : 'Unknown Author',
                        'lessons': data.containsKey('lessons') ? data['lessons'] : 0,
                        'rating': data.containsKey('rating') ? data['rating'].toDouble() : 0.0,
                        'description': data.containsKey('description') ? data['description'] : 'Unknown description',
                        'category': data.containsKey('category') ? data['category'] : 'Other',  // Assuming category is saved in the Firestore document
                      };
                    }).toList();

                    // Filter courses by selected category
                    _filteredCourses = _searchQuery.isEmpty
                        ? courses.where((course) {
                      return  _selectedCategoryKey == 'All Courses' || course['category'] == _selectedCategoryKey;
                    }).toList()
                        : courses.where((course) {
                      return (course['title'].toLowerCase().contains(_searchQuery)) &&
                          (_selectedCategoryKey  == 'All Courses' || course['category'] == _selectedCategoryKey);
                    }).toList();

                    return Column(
                      children: [
                        // Ongoing courses (horizontal scroll)
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: _filteredCourses.map((courses) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 16),
                                child: OngoingCourseCard(
                                  courseTitle: courses['title'],
                                  progress: courses['progress'],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        SizedBox(height: 16),
                        // Additional courses (vertical layout)
                        GridView.builder(
                          physics: NeverScrollableScrollPhysics(), // Prevents the grid from scrolling if nested
                          shrinkWrap: true, // Ensures the grid takes only the required space
                          itemCount: _filteredCourses.length,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2, // Number of columns in the grid
                            mainAxisSpacing: 16.0, // Spacing between rows
                            crossAxisSpacing: 16.0, // Spacing between columns
                            childAspectRatio: 0.75, // Adjust this based on the aspect ratio of your items
                          ),
                          itemBuilder: (context, index) {
                            final courses = _filteredCourses[index];
                            return InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CourseDetailScreen(
                                      course: courses, // Passing the course data to the CourseDetailScreen
                                    ),
                                  ),
                                );
                              },
                              child: CourseContainer(
                                id: courses['id']?.toString() ?? 'unknown_id', // Ensure it is a string
                                imageUrl: courses['imageUrl'] ?? '',
                                title: courses['title'] ?? 'Untitled',
                                cost: courses['cost'] ?? 0,
                                author: courses['author'] ?? 'Unknown',
                                lessons: courses['lessons'] ?? 0,
                                rating: courses['rating'] ?? 0.0,
                                description: courses['description'] ?? 'No description available',
                              ),
                            );
                          },
                        ),
                      ],
                    );
                  },
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
extension LocalizationExtension on String {
  String translate(BuildContext context) {
    return AppLocalizations.of(context)?.translate(this) ?? this;
  }
}

// Sample Chat Screen


// Sample Profile Screen
class ProfileScreen extends StatelessWidget {
  Future<Map<String, dynamic>?> _fetchUserProfile() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          return userDoc.data();
        }
      }
    } catch (e) {
      print('Error fetching user profile: $e');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _fetchUserProfile(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error fetching profile data'));
        } else if (!snapshot.hasData || snapshot.data == null) {
          return Center(child: Text('No profile data available'));
        }

        final userData = snapshot.data!;
        final profilePicUrl = userData['profilePicUrl'] ?? 'https://via.placeholder.com/150';
        final userName = userData['userName'] ?? 'User Name';

        return Scaffold(
          body: Column(
            children: [
              // Top profile section
              Container(
                color: Color(0xFF3d675f),
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 30),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage(profilePicUrl),
                    ),
                    SizedBox(height: 10),
                    Text(
                      userName,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              // Menu options
              Expanded(
                child: ListView(
                  children: [
                    _buildProfileMenuItem(
                      context,
                      icon: Icons.edit,
                      text: 'Edit Profile',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditProfileScreen(),
                          ),
                        );
                      },
                    ),
                    _buildProfileMenuItem(
                      context,
                      icon: Icons.credit_card,
                      text: 'Payment Methods',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PaymentMethodsScreen(),
                          ),
                        );
                      },
                    ),
                    _buildProfileMenuItem(
                      context,
                      icon: Icons.settings,
                      text: 'Settings',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SettingsScreen(),
                          ),
                        );
                      },
                    ),
                    _buildProfileMenuItem(
                      context,
                      icon: Icons.help_outline,
                      text: 'Help Center',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HelpCenterScreen(),
                          ),
                        );
                      },
                    ),
                    _buildProfileMenuItem(
                      context,
                      icon: Icons.description,
                      text: 'Terms & Conditions',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TermsConditionsScreen(),
                          ),
                        );
                      },
                    ),
                    _buildProfileMenuItem(
                      context,
                      icon: Icons.privacy_tip,
                      text: 'Privacy Policy',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PrivacyPolicyScreen(),
                          ),
                        );
                      },
                    ),
                    _buildProfileMenuItem(
                      context,
                      icon: Icons.privacy_tip,
                      text: 'Contact Us',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ContactusScreen(),
                          ),
                       );
                      },
                    ),
                    _buildProfileMenuItem(
                      context,
                      icon: Icons.logout,
                      text: 'Logout',
                      onTap: () {
                        _logout(context);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileMenuItem(BuildContext context,
      {required IconData icon, required String text, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.teal.shade700),
      title: Text(text),
      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: onTap,
    );
  }

  // Logout function
  void _logout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Logout'),
        content: Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              FirebaseAuth.instance.signOut(); // Sign out from Firebase
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/signIn'); // Navigate to login screen
            },
            child: Text('Logout'),
          ),
        ],
      ),
    );
  }

}

  class SettingsScreen extends StatefulWidget {
    @override
    _SettingsScreenState createState() => _SettingsScreenState();
  }

  class _SettingsScreenState extends State<SettingsScreen> {
    bool _isFacebookEnabled = false;
    bool _isDarkMode = false;

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: Text("Settings"),
        ),
        body: ListView(
          children: [
            // Facebook Connection
            SwitchListTile(
              //leading: Icon(Icons.facebook, color: Colors.blue), // Leading icon for Facebook
                title: Text("Connect to Facebook"),
                value: _isFacebookEnabled,
                onChanged: (value) {
                  setState(() {
                    _isFacebookEnabled = value;
                  });
                },
                secondary: Icon(Icons.facebook, color: Colors.blue)
            ),

            // Notifications Toggle


            ListTile(
              leading: Icon(Icons.notifications_active_outlined), // Leading icon for Help
              title: Text("Enable Notifications"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Notificationscreen()),
                );
              },
            ),

            ListTile(
              leading: Icon(Icons.surround_sound), // Leading icon for Help
              title: Text("Learning & sound setting"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LearningSoundSettingsScreen()),
                );
              },
            ),
            // Dark Mode Toggle
            SwitchListTile(
              // leading: Icon(Icons.dark_mode, color: Colors.deepPurple), // Leading icon for Dark Mode
                title: Text("Dark Mode"),
                value: _isDarkMode,
                onChanged: (value) {
                  setState(() {
                    _isDarkMode = value;
                  });
                },
                secondary: Icon(Icons.dark_mode, color: Colors.blue)
            ),
          ],
        ),
      );
    }
  }
  class OngoingCourseCard extends StatelessWidget {
    final String courseTitle;
    final double progress;

    OngoingCourseCard({required this.courseTitle, required this.progress});

    @override
    Widget build(BuildContext context) {
      return Container(
        width: 200,
        margin: EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: Colors.green,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 80,
              color: Colors.green,
              child: Center(
                child: Text(
                  courseTitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            LinearProgressIndicator(
              value:progress,
              color: Colors.green[900],
              backgroundColor: Colors.grey,
            ),
            SizedBox(height: 8),
            Text('${(progress * 100).toStringAsFixed(0)}% Complete', style: TextStyle(color: Colors.white)),
          ],
        ),
      );
    }
  }

  class CourseContainer extends StatelessWidget {
    final String title;
    final int cost;
    final int lessons;
    final double rating;
    final String author;
    final String imageUrl;
    final String description;
    final String id;
    CourseContainer({
      required this.title,
      required this.cost,
      required this.lessons,
      required this.rating,
      required this.author,
      required this.imageUrl,
      required this.description,
      required this.id,
    });

    @override
    Widget build(BuildContext context) {
      return Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.grey.shade200,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              imageUrl.startsWith('http')
                  ? Image.network(imageUrl, fit: BoxFit.cover)
                  : Image.asset(imageUrl, fit: BoxFit.cover),
              SizedBox(height: 1),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text(title, style: TextStyle(fontWeight: FontWeight.bold))),
                  Text('\$$cost', style: TextStyle(color: Colors.green)),
                ],
              ),
              SizedBox(height: 4),
             Text('Lessons: $lessons', style: TextStyle(color: Colors.grey)),
              Divider(),
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < rating ? Icons.star : Icons.star_border,
                    color: Colors.yellow,
                    size: 16,
                  );
                }),
              ),
            ],
          ),
        ),
      );
    }
  }
