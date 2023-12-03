import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intern_assignment_app/model/user_model.dart';
import 'package:intern_assignment_app/pages/my_video_page.dart';
import 'package:intern_assignment_app/pages/video_player_page.dart';
import 'package:intern_assignment_app/pages/video_posting_page.dart';
import '../model/video_model.dart';

class VideoPage extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;

  const VideoPage({
    Key? key,
    required this.userModel,
    required this.firebaseUser,
  }) : super(key: key);

  @override
  _VideoPageState createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text("All Videos", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: Icon(Icons.video_collection),
            onPressed: () {
              // Navigate to MyVideosPage
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MyVideosPage(
                      userModel: widget.userModel,
                      firebaseUser: widget.firebaseUser),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.my_library_books),
            onPressed: () {
              // Navigate to MyVideosPage
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MyVideosPage(
                      userModel: widget.userModel,
                      firebaseUser: widget.firebaseUser),
                ),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("videos")
            .orderBy("uploadedOn", descending: true)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text("Error loading videos"));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No videos found"));
          }

          QuerySnapshot data = snapshot.data!;
          return ListView.builder(
            itemCount: data.docs.length,
            itemBuilder: (context, index) {
              VideoModel video = VideoModel.fromMap(
                  data.docs[index].data() as Map<String, dynamic>);
              return Card(
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  VideoPlayerScreen(videoUrl: video.videoUrl)),
                        );
                      },
                      child: Image.network(
                        video.thumbnailUrl,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    ListTile(
                      title: Text(
                        video.title,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18), // Bold and larger text
                      ),
                      subtitle: Text(
                        video.description,
                        maxLines: 2, // Limit to two lines
                        overflow: TextOverflow.ellipsis, // Add ellipsis
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.play_circle_fill),
                        color: Colors.red,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => VideoPlayerScreen(
                                    videoUrl: video.videoUrl)),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => UploadVideoPage(
                    userModel: widget.userModel,
                    firebaseUser: widget.firebaseUser)),
          );
        },
        child: const Icon(Icons.add, size: 30), // Larger icon
        backgroundColor: Colors.green,
      ),
    );
  }
}
