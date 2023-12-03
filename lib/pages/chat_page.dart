// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intern_assignment_app/model/chatroom_model.dart';
import 'package:intern_assignment_app/model/firebase_helper.dart';

import 'package:intern_assignment_app/model/user_model.dart';
import 'package:intern_assignment_app/pages/chat_room_page.dart';

import 'package:intern_assignment_app/pages/search_page.dart';

class ChatPage extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;
  const ChatPage({
    Key? key,
    required this.userModel,
    required this.firebaseUser,
  }) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chats", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blueAccent, // Enhanced AppBar color
      ),
      body: SafeArea(
          child: Container(
        child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection("chatrooms")
              .where("participants.${widget.userModel.uid}", isEqualTo: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.active) {
              if (snapshot.hasData) {
                QuerySnapshot chatRoomSnapshot = snapshot.data as QuerySnapshot;
                return ListView.builder(
                  itemCount: chatRoomSnapshot.docs.length,
                  itemBuilder: (context, index) {
                    ChatRoomModel chatRoomModel = ChatRoomModel.fromMap(
                        chatRoomSnapshot.docs[index].data()
                            as Map<String, dynamic>);
                    Map<String, dynamic> participants =
                        chatRoomModel.participants!;
                    List<String> participantKeys = participants.keys.toList();
                    participantKeys.remove(widget.userModel.uid);
                    return FutureBuilder(
                      future:
                          FirebaseHelper.getUserModelById(participantKeys[0]),
                      builder: (context, userData) {
                        if (userData.connectionState == ConnectionState.done) {
                          if (userData.data != null) {
                            UserModel targetUser = userData.data as UserModel;
                            return ListTile(
                              onTap: () {
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context) {
                                  return ChatRoomPage(
                                      targetUser: targetUser,
                                      chatroom: chatRoomModel,
                                      userModel: widget.userModel,
                                      firebaseUser: widget.firebaseUser);
                                }));
                              },
                              leading: CircleAvatar(
                                radius: 25, // Adjusted avatar size
                                backgroundColor:
                                    Colors.blueGrey, // Avatar background color
                                backgroundImage: NetworkImage(
                                    targetUser.profilepic.toString()),
                              ),
                              title: Text(
                                targetUser.fullname.toString(),
                                style: TextStyle(
                                    fontWeight:
                                        FontWeight.bold), // Bold text for names
                              ),
                              subtitle: Text(
                                chatRoomModel.lastMessage.toString(),
                                style: TextStyle(
                                    color: Colors.grey[
                                        600]), // Subtle color for subtitles
                              ),
                            );
                          } else {
                            return Container();
                          }
                        } else {
                          return Container();
                        }
                      },
                    );
                  },
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text(snapshot.error.toString()),
                );
              } else {
                return Center(
                  child: Text("No Chats"),
                );
              }
            } else {
              return Center(
                child: Text(""),
              );
            }
          },
        ),
      )),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return SearchPage(
                userModel: widget.userModel, firebaseUser: widget.firebaseUser);
          }));
        },
        child: Icon(Icons.search, size: 30), // Adjusted icon size
        backgroundColor: Colors.green, // Changed color
      ),
    );
  }
}
