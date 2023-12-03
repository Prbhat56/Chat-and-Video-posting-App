// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intern_assignment_app/main.dart';
import 'package:intern_assignment_app/model/video_model.dart';
import 'package:video_player/video_player.dart';

import '../model/user_model.dart';

class UploadVideoPage extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;
  const UploadVideoPage({
    Key? key,
    required this.userModel,
    required this.firebaseUser,
  }) : super(key: key);
  @override
  _UploadVideoPageState createState() => _UploadVideoPageState();
}

class _UploadVideoPageState extends State<UploadVideoPage> {
  File? videoFile;
  File? thumbnailFile;
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
// Get current user's UID

  VideoPlayerController? _videoController;

  void selectVideo(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickVideo(source: source);
    if (pickedFile != null) {
      _videoController?.dispose(); // Dispose the old controller if exists
      _videoController = VideoPlayerController.file(File(pickedFile.path))
        ..initialize().then((_) {
          setState(() {});
        });

      setState(() {
        videoFile = File(pickedFile.path);
      });
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  void selectThumbnail(ImageSource source) async {
    XFile? pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        thumbnailFile = File(pickedFile.path);
      });
    }
  }

  void uploadVideo() async {
    
    String des = descriptionController.text.trim();
    String title = titleController.text.trim();
   
    descriptionController.clear();
    titleController.clear();
      UploadTask videouploadTask = FirebaseStorage.instance
        .ref("videos")
        .child(widget.userModel.uid.toString())
        .putFile(videoFile!);
    TaskSnapshot snapshot = await videouploadTask;
    String? videoUrl = await snapshot.ref.getDownloadURL();
        UploadTask thumbnailuploadTask = FirebaseStorage.instance
        .ref("thumbnail")
        .child(widget.userModel.uid.toString())
        .putFile(thumbnailFile!);
    TaskSnapshot newsnapshot = await thumbnailuploadTask;
    String? thumbnailUrl = await newsnapshot.ref.getDownloadURL();

    if (des != ""||title!=""||videoFile!=null||thumbnailFile!=null) {
      VideoModel newVideo = VideoModel(
        videoId: uuid.v1(),
        uploaderId: widget.userModel.uid.toString(),
        uploadedOn: DateTime.now(),
        videoUrl: videoUrl,
        title: title,
        description: des,
        thumbnailUrl: thumbnailUrl,
       
      );
      FirebaseFirestore.instance
          .collection("videos")
          .doc(newVideo.videoId)
          .collection("users")
          .doc(widget.userModel.uid)
          .set(newVideo.toMap());
     
      FirebaseFirestore.instance
          .collection("videos")
          .doc(newVideo.videoId)
          .set(newVideo.toMap());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload Video'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            GestureDetector(
              onTap: () => selectVideo(ImageSource.gallery),
              child: Container(
                height: 200,
                color: Colors.grey[300],
                child: Center(
                  child: videoFile == null
                      ? Icon(Icons.video_camera_back, size: 100)
                      : _videoController != null &&
                              _videoController!.value.isInitialized
                          ? AspectRatio(
                              aspectRatio: _videoController!.value.aspectRatio,
                              child: VideoPlayer(_videoController!),
                            )
                          : CircularProgressIndicator(), // Show loading indicator while video is initializing
                ),
              ),
            ),
            // Thumbnail preview placeholder
            GestureDetector(
              onTap: () => selectThumbnail(ImageSource.gallery),
              child: Container(
                height: 150,
                color: Colors.grey[200],
                child: Center(
                  child: thumbnailFile == null
                      ? Text('Select a thumbnail')
                      : Image.file(thumbnailFile!, fit: BoxFit.cover),
                ),
              ),
            ),
            // Title input field
            Padding(
              padding: EdgeInsets.all(8.0),
              child: TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: 'Title'),
              ),
            ),
            // Description input field
            Padding(
              padding: EdgeInsets.all(8.0),
              child: TextField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
              ),
            ),
            // Upload button
            ElevatedButton(
              onPressed: uploadVideo,
              child: Text('Upload Video'),
            ),
          ],
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () => selectVideo(ImageSource.gallery),
            child: Icon(Icons.videocam),
            heroTag: null, // Important for multiple FABs
          ),
          SizedBox(width: 10),
          FloatingActionButton(
            onPressed: () => selectThumbnail(ImageSource.gallery),
            child: Icon(Icons.photo),
            heroTag: null, // Important for multiple FABs
          ),
        ],
      ),
    );
  }
}
