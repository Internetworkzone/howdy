import 'package:cloud_firestore/cloud_firestore.dart';

class Call {
  final String callerName;
  final String callerUid;
  final String receiverName;
  final String receiverUid;
  final String calltype;
  final String channelName;
  final double duration;
  final Timestamp timestamp;
  Call({
    this.callerName,
    this.callerUid,
    this.receiverName,
    this.receiverUid,
    this.calltype,
    this.channelName,
    this.duration,
    this.timestamp,
  });

  factory Call.fromFirestore(DocumentSnapshot doc) {
    var data = doc.data;
    return Call(
      callerName: data['callerName'],
      callerUid: data['callerUid'],
      receiverName: data['receiverName'],
      receiverUid: data['receiverUid'],
      channelName: data['channelName'],
      calltype: data['calltype'],
      duration: data['duration'],
      timestamp: data['timestamp'],
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'callerName': this.callerName,
      'callerUid': this.callerUid,
      'receiverName': this.receiverName,
      'receiverUid': this.receiverUid,
      'channelName': this.channelName,
      'calltype': this.calltype,
      'duration': this.duration,
      'timestamp': this.timestamp,
    };
  }
}
