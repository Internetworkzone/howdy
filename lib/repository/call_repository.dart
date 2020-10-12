import 'package:cloud_firestore/cloud_firestore.dart';

class CallRepository {
  final Firestore firestore = Firestore.instance;

  Future<bool> connectCall(String caller, String receiver, Map data) async {
    bool isCallCreated;
    await firestore
        .collection('users')
        .document(receiver)
        .collection('calls')
        .document('currentCall')
        .get()
        .then((value) async {
      if (value.exists) {
        isCallCreated = false;
      } else {
        await firestore
            .collection('users')
            .document(receiver)
            .collection('calls')
            .document('currentCall')
            .setData(data);
        await firestore
            .collection('users')
            .document(caller)
            .collection('calls')
            .document('currentCall')
            .setData(data);
        isCallCreated = true;
      }
    });
    return isCallCreated;
  }

  Stream<DocumentSnapshot> incomingCall(uid) {
    return firestore
        .collection('users')
        .document(uid)
        .collection('calls')
        .document('currentCall')
        .snapshots();
  }

  Future<void> deleteIncomingCall(uid) {
    return firestore
        .collection('users')
        .document(uid)
        .collection('calls')
        .document('currentCall')
        .delete();
  }

  Future<void> addToCallHistory(uid, Map data) async {
    await firestore
        .collection('users')
        .document(uid)
        .collection('callHistory')
        .add(data);
  }

  Future<QuerySnapshot> getCallHistory(String uid) async {
    return await firestore
        .collection('users')
        .document(uid)
        .collection('callHistory')
        .orderBy('timestamp', descending: true)
        .getDocuments();
  }
}
