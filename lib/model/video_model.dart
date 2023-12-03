import 'package:cloud_firestore/cloud_firestore.dart';

class VideoModel {
  String videoId;
  String uploaderId;
  DateTime uploadedOn;
  String videoUrl;
  String title;
  String description;
  String thumbnailUrl; 

  VideoModel({
    required this.videoId,
    required this.uploaderId,
    required this.uploadedOn,
    required this.videoUrl,
    required this.title,
    required this.description,
    required this.thumbnailUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'videoId': videoId,
      'uploaderId': uploaderId,
      'uploadedOn': uploadedOn,
      'videoUrl': videoUrl,
      'title': title,
      'description': description,
      'thumbnailUrl': thumbnailUrl,
    };
  }

  static VideoModel fromMap(Map<String, dynamic> map) {
    return VideoModel(
      videoId: map['videoId'] ?? 'default_video_id', // Provide default value
      uploaderId: map['uploaderId'] ?? 'default_uploader_id', // Provide default value
      uploadedOn: map['uploadedOn'] != null 
          ? (map['uploadedOn'] as Timestamp).toDate()
          : DateTime.now(), // Provide current time as default
      videoUrl: map['videoUrl'] ?? '', // Provide empty string as default
      title: map['title'] ?? 'Untitled', // Provide default title
      description: map['description'] ?? '', // Provide empty string as default
      thumbnailUrl: map['thumbnailUrl'] ?? '', // Provide empty string as default
    );
  }
}
