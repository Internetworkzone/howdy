import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class StatusRepository {
  FirebaseStorage storage = FirebaseStorage.instance;
  Firestore firestore = Firestore.instance;

  Future<dynamic> uploadToStorage(String uid, String file, String type) async {
    StorageReference reference = storage
        .ref()
        .child('status/$uid/${DateTime.now().millisecondsSinceEpoch}.$type');

    StorageUploadTask task = reference.putFile(File(file));

    StorageTaskSnapshot snap = await task.onComplete;
    return snap.ref.getDownloadURL();
  }

  Future<void> uploadStatus(String uid, Map<String, dynamic> data) async {
    await firestore
        .collection('status')
        .document(uid)
        .collection('data')
        .add(data);
  }

  Future<QuerySnapshot> getStatus(String uid) async {
    return await firestore
        .collection('status')
        .document(uid)
        .collection('data')
        .orderBy('timestamp')
        .getDocuments();
  }

  Future<void> updateStatusSummary(
      String uid, Map<String, dynamic> data) async {
    data['totalStatus'] = FieldValue.increment(1);
    await firestore
        .collection('status')
        .document(uid)
        .setData(data, merge: true);
  }

  Stream<QuerySnapshot> getAllStatus() {
    return firestore.collection('status').snapshots();
  }
}
