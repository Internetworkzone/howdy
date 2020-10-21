import 'package:cloud_firestore/cloud_firestore.dart';

class Status {
  Status({
    this.url,
    this.caption,
    this.timestamp,
  });
  final String url;
  final String caption;
  final Timestamp timestamp;

  factory Status.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data;
    return Status(
      url: data['url'],
      caption: data['caption'],
      timestamp: data['timestamp'],
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'url': this.url,
      'caption': this.caption,
      'timestamp': this.timestamp,
    };
  }
}

class StatusSummary {
  StatusSummary({
    this.lastStatusUrl,
    this.lastStatusType,
    this.lastStatusTimestamp,
    this.totalStatus,
    this.user,
  });
  final String user;
  final String lastStatusType;
  final String lastStatusUrl;
  final Timestamp lastStatusTimestamp;
  final int totalStatus;

  factory StatusSummary.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data;
    return StatusSummary(
      user: data['user'],
      lastStatusType: data['lastStatusType'],
      lastStatusUrl: data['lastStatusUrl'],
      lastStatusTimestamp: data['lastStatusTimestamp'],
      totalStatus: data['totalStatus'],
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'user': this.user,
      'lastStatusType': this.lastStatusType,
      'lastStatusUrl': this.lastStatusUrl,
      'lastStatusTimestamp': this.lastStatusTimestamp,
      'totalStatus': this.totalStatus,
    };
  }
}
