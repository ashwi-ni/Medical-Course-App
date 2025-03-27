import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class Notificationscreen extends StatefulWidget {
  const Notificationscreen({super.key});

  @override
  _NotificationscreenState createState() => _NotificationscreenState();
}

class _NotificationscreenState extends State<Notificationscreen> with WidgetsBindingObserver {
  List<Map<String, dynamic>> _notifications = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadNotifications();
  }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadNotifications(); // Load notifications when returning to the screen
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadNotifications();
    }
  }

  Future<void> _loadNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? storedNotifications = prefs.getStringList('notifications');

    if (storedNotifications != null) {
      setState(() {
        _notifications = storedNotifications
            .map((json) => jsonDecode(json) as Map<String, dynamic>)
            .toList();
      });
    }
  }


  void _deleteNotification(int index) async {
    setState(() {
      _notifications.removeAt(index);
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'notifications',
      _notifications.map((e) => jsonEncode(e)).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Notifications")),
      body: _notifications.isEmpty
          ? const Center(child: Text('No notifications yet'))
          : ListView.builder(
        itemCount: _notifications.length,
        itemBuilder: (context, index) {
          final notification = _notifications[index];
          return Dismissible(
            key: ValueKey(notification["title"] + notification["time"]),
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            direction: DismissDirection.endToStart,
            onDismissed: (direction) => _deleteNotification(index),
            child: ListTile(
              leading: notification["imageUrl"] != ""
                  ? CircleAvatar(
                backgroundImage: NetworkImage(notification["imageUrl"]),
              )
                  : const CircleAvatar(child: Icon(Icons.notifications)),
              title: Text(notification["title"]),
              subtitle: Text(notification["body"]),
              trailing: Text(
                DateFormat('hh:mm a').format(DateTime.parse(notification["time"])),
                style: const TextStyle(color: Colors.grey),
              ),
            ),
          );
        },
      ),
    );
  }
}
