import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intern_assignment_app/model/user_model.dart';
import 'package:intern_assignment_app/pages/video_player_page.dart';
import 'package:intern_assignment_app/pages/video_posting_page.dart';
import '../model/video_model.dart';

class MyVideosPage extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;

  const MyVideosPage({
    Key? key,
    required this.userModel,
    required this.firebaseUser,
  }) : super(key: key);

  @override
  _MyVideosPageState createState() => _MyVideosPageState();
}

class _MyVideosPageState extends State<MyVideosPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Videos"),
        actions: [
          IconButton(
            icon: Icon(Icons.video_collection),
            onPressed: () {},
          ),
        ],
      ),
    body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("videos")
            .where("uploaderId", isEqualTo: widget.userModel.uid)
            .orderBy("uploadedOn", descending: true)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting ) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            print(snapshot.error);
            return const Center(child: Text("Error loading videos"));
          }

          if (snapshot.hasData || snapshot.data!.docs.isEmpty) {
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
                      title: Text(video.title),
                      subtitle: Text(video.description),
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
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        video.description,
                        style: TextStyle(color: Colors.black.withOpacity(0.6)),
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
        child: const Icon(Icons.add),
      ),
    );
  }
}
