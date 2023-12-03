class MessageModel {
  String? messageid;
  String? sender;
  String? text;
  bool? seen;
  DateTime? createdon;

  MessageModel(
      {this.sender, this.text, this.createdon, this.seen, this.messageid});
  MessageModel.fromMap(Map<String, dynamic> map) {
    messageid = map["messageid"];
    sender = map['Sender'];
    text = map['text'];
    seen = map["seen"];
    createdon = map["createdon"].toDate();
  }
  Map<String, dynamic> toMap() {
    return {"Sender": sender, "text": text, "createdon": createdon,"messageid":messageid};
  }
}
