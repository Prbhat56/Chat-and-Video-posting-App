class UserModel {
  String? uid;
  String? email;
  String? fullname;
  String? profilepic;
  String? city;
  String? phone;
  UserModel({this.email, this.fullname, this.profilepic, this.uid,this.city,this.phone});

  UserModel.fromMap(Map<String, dynamic> map) {
    uid = map["uid"];
    fullname = map["fullname"];
    email = map["email"];
    profilepic = map["profilepic"];
    city=map['city'];
    phone=map['phone'];
  }
  Map<String, dynamic> toMap() {
    return {
      "uid": uid,
      "fullname": fullname,
      "email": email,
      "profilepic": profilepic,
      "city":city,
      'phone':phone
    };
  }
}
