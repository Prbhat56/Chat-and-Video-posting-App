// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:intern_assignment_app/authentication/login_page.dart';

import 'package:intern_assignment_app/model/user_model.dart';
import 'package:intern_assignment_app/pages/chat_page.dart';
import 'package:intern_assignment_app/pages/edit_profile_page.dart';
import 'package:intern_assignment_app/pages/profile_page.dart';
import 'package:intern_assignment_app/pages/video_loading_page.dart';

import 'home_page.dart';

class Home extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;
  const Home({
    Key? key,
    required this.userModel,
    required this.firebaseUser,
  }) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _currentIndex = 0;
  late List<Widget> tabs;

  @override
  void initState() {
    super.initState();
    // Initialize 'tabs' here
    tabs = [
       VideoPage(userModel: widget.userModel, firebaseUser: widget.firebaseUser),
      ChatPage(userModel: widget.userModel, firebaseUser: widget.firebaseUser),
       ProfilePage(userModel: widget.userModel, firebaseUser: widget.firebaseUser), 
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Video Chat App"),
        actions: [
          IconButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.popUntil(context, (route) => route.isFirst);
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) {
                  return const MyLogin();
                }));
              },
              icon: Icon(Icons.exit_to_app))
        ],
      ),
      body: tabs[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        items: [
          const BottomNavigationBarItem(
              icon: Icon(Icons.video_camera_back_sharp),
              label: "Video",
              backgroundColor: Colors.white),
          const BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble),
              label: "Chat",
              backgroundColor: Colors.white),
          const BottomNavigationBarItem(
              icon: Icon(Icons.person_2_outlined),
              label: "Profile",
              backgroundColor: Colors.white),
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
