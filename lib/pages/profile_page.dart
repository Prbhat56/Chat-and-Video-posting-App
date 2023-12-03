import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intern_assignment_app/model/user_model.dart';

import 'edit_profile_page.dart';

class ProfilePage extends StatelessWidget {
  final UserModel? userModel;
  final User? firebaseUser;

  ProfilePage({Key? key, this.userModel, this.firebaseUser}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
      ),
      body: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListView(
                children: <Widget>[
                  // Profile image and user info
                  _buildProfileSection(context),
                  // Other user data
                  _buildListTile(context, Icons.phone, userModel?.phone ?? 'No Phone'),
                  _buildListTile(context, Icons.email, firebaseUser?.email ?? 'No Email'),
                  _buildListTile(context, Icons.location_city, userModel?.city ?? 'No City'),
                ],
              ),
            ),
            ElevatedButton(
              child: Text("Edit Profile"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EditProfilePage(
                    userModel: userModel,
                    firebaseUser: firebaseUser,
                  )),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection(BuildContext context) {
    return Column(
      children: <Widget>[
        CircleAvatar(
          radius: 50,
          backgroundColor: Colors.white,
          child: CircleAvatar(
            radius: 45,
            backgroundImage: NetworkImage(userModel?.profilepic ?? 'https://via.placeholder.com/150'),
          ),
        ),
        SizedBox(height: 10),
        Text(
          userModel!.fullname.toString(),
          style: TextStyle(color: Colors.black, fontSize: 20),
        ),
        SizedBox(height: 20),
      ],
    );
  }

  ListTile _buildListTile(BuildContext context, IconData icon, String text) {
    return ListTile(
      leading: Icon(icon, color: Colors.purple),
      title: Text(text),
    );
  }
}
