import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intern_assignment_app/home/home_page.dart';

import 'package:intern_assignment_app/model/user_model.dart';

class EditProfilePage extends StatefulWidget {
  final UserModel? userModel;
  final User? firebaseUser;
  const EditProfilePage({
    Key? key,
    this.userModel,
    this.firebaseUser,
  }) : super(key: key);

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  File? imageFile;
  TextEditingController cityController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  void selectImage(ImageSource source) async {
    XFile? pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        imageFile = File(pickedFile.path);
      });
    }
  }

  void showPhotoOption() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Upload Profile Pic"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  onTap: () {
                    Navigator.pop(context);
                    selectImage(ImageSource.gallery);
                  },
                  leading: Icon(Icons.photo_album),
                  title: Text("Select from Gallery"),
                ),
                ListTile(
                  onTap: () {
                    Navigator.pop(context);
                    selectImage(ImageSource.camera);
                  },
                  leading: Icon(Icons.camera_alt),
                  title: Text("Take a Photo"),
                )
              ],
            ),
          );
        });
  }

  void checkValues() {
    String city = cityController.text.trim();
    String phoneNumber = phoneController.text.trim();
    String name = nameController.text.trim();
    String email = emailController.text.trim();

    if (city == "" ||
        phoneNumber == "" ||
        name == "" ||
        email == "" ||
        imageFile == null) {
      print("please fill all fields");
    } else {
      uploadData();
    }
  }

  void uploadData() async {
    UploadTask uploadTask = FirebaseStorage.instance
        .ref("profilepictures")
        .child(widget.userModel!.uid.toString())
        .putFile(imageFile!);
    TaskSnapshot snapshot = await uploadTask;
    String? imageUrl = await snapshot.ref.getDownloadURL();

    String? city = cityController.text.trim();
    String? phone = phoneController.text.trim();
    String? name = nameController.text.trim();
    String? email = emailController.text.trim();

    widget.userModel!.city = city;
    widget.userModel!.phone = phone;
    widget.userModel!.fullname = name;
    widget.userModel!.email = email;
    widget.userModel!.profilepic = imageUrl;

    await FirebaseFirestore.instance
        .collection("users")
        .doc(widget.userModel!.uid)
        .set(widget.userModel!.toMap())
        .then((value) {
      print("data uploaded");

      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
        return Home(
            userModel: widget.userModel!, firebaseUser: widget.firebaseUser!);
      }));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(top: 40),
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.purple, Colors.purple.shade200],
              ),
            ),
            child: Column(
              children: <Widget>[
                CupertinoButton(
                  onPressed: () {
                    showPhotoOption();
                  },
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: 45,
                      backgroundImage:
                          (imageFile != null) ? FileImage(imageFile!) : null,
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  widget.userModel!.fullname.toString(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                _buildTextField(
                    context, Icons.person, 'fullname', nameController),
                    SizedBox(height: 10,),
                _buildTextField(context, Icons.email, 'email', emailController),
                 SizedBox(height: 10,),
                _buildTextField(context, Icons.phone, 'phone', phoneController),
                SizedBox(height: 10,),
                _buildTextField(
                    context, Icons.location_city, 'city', cityController),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.purple,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.all(15),
                    ),
                    onPressed: () {
                      checkValues();
                    },
                    child: const Center(
                      child: Text(
                        'Save Profile',
                        style: TextStyle(fontSize: 18,color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(BuildContext context, IconData icon, String labelText,
      TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(icon, color: Colors.purple),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
    );
  }
}
