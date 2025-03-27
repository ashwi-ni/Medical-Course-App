import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';

class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  bool isEditing = false;
  bool isLoading = false;

  String profilePicUrl = '';
  String userName = '';
  String email = '';
  double profileCompletion = 0.0;

  TextEditingController emailController = TextEditingController();
  TextEditingController userNameController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  File? _profileImage;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    _toggleLoading(true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

        if (userDoc.exists) {
          final data = userDoc.data()!;
          setState(() {
            userName = data['userName'] ?? 'User Name';
            email = user.email ?? '';
            profilePicUrl = data['profilePicUrl'] ?? 'https://via.placeholder.com/150';

            emailController.text = email;
            userNameController.text = userName;

            profileCompletion = _calculateProfileCompletion();
          });
        }
      }
    } catch (e) {
      print('Error fetching user data: $e');
    } finally {
      _toggleLoading(false);
    }
  }

  Future<String?> _uploadProfileImage(File imageFile) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final storageRef = FirebaseStorage.instance.ref().child('profilePictures/${user.uid}');
        await storageRef.putFile(imageFile);
        return await storageRef.getDownloadURL();
      }
    } catch (e) {
      print('Error uploading profile image: $e');
    }
    return null;
  }

  Future<void> _updateUserData() async {
    if (userNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("User name cannot be empty!")),
      );
      return;
    }

    _toggleLoading(true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'userName': userNameController.text,
          'profilePicUrl': profilePicUrl,
        });
        setState(() {
          userName = userNameController.text;
          profileCompletion = _calculateProfileCompletion();
        });
      }
    } catch (e) {
      print('Error updating user data: $e');
    } finally {
      _toggleLoading(false);
    }
  }

  double _calculateProfileCompletion() {
    int filledFields = 0;
    if (userName.isNotEmpty) filledFields++;
    if (profilePicUrl.isNotEmpty) filledFields++;
    return filledFields / 2;
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _imagePicker.pickImage(source: source);
    if (pickedFile != null) {
      final File imageFile = File(pickedFile.path);
      final uploadedImageUrl = await _uploadProfileImage(imageFile);
      if (uploadedImageUrl != null) {
        setState(() {
          _profileImage = imageFile;
          profilePicUrl = uploadedImageUrl;
        });
        await _updateProfilePicUrl(uploadedImageUrl);
      }
    }
  }

  Future<void> _updateProfilePicUrl(String imageUrl) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'profilePicUrl': imageUrl,
        });
      } catch (e) {
        print('Error updating profile picture URL: $e');
      }
    }
  }

  void _toggleLoading(bool value) {
    setState(() {
      isLoading = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: GestureDetector(
                  onTap: () {
                    if (profilePicUrl.isNotEmpty) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => Scaffold(
                            appBar: AppBar(title: Text('Profile Picture')),
                            body: Center(
                              child: Image.network(profilePicUrl),
                            ),
                          ),
                        ),
                      );
                    }
                  },
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundImage: _profileImage != null
                            ? FileImage(_profileImage!)
                            : CachedNetworkImageProvider(profilePicUrl),
                        child: profilePicUrl.isEmpty
                            ? Icon(Icons.person, size: 40, color: Colors.grey.shade700)
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: InkWell(
                          onTap: () => _showImageSourceOptions(context),
                          child: CircleAvatar(
                            radius: 15,
                            backgroundColor: Colors.teal,
                            child: Icon(Icons.edit, size: 15, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 10),
              Center(
                child: Text(
                  userName,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 20),
              LinearProgressIndicator(
                value: profileCompletion,
                backgroundColor: Colors.grey.shade300,
                color: Colors.green,
              ),
              SizedBox(height: 10),
              Center(
                child: Text(
                  '${(profileCompletion * 100).toStringAsFixed(0)}% complete your profile',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade300,
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Profile Information',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: Icon(isEditing ? Icons.check : Icons.edit),
                          onPressed: () {
                            if (isEditing) _updateUserData();
                            setState(() {
                              isEditing = !isEditing;
                            });
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    _buildUserInfoRow('Email Address', emailController, isEditing),
                    _buildUserInfoRow('User Name', userNameController, isEditing),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserInfoRow(String label, TextEditingController controller, bool isEditable) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 2,
            child: Text(label, style: TextStyle(fontSize: 16)),
          ),
          Expanded(
            flex: 3,
            child: isEditable
                ? TextField(
              controller: controller,
              decoration: InputDecoration(border: OutlineInputBorder()),
            )
                : Text(
              controller.text,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  void _showImageSourceOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Gallery'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Camera'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
