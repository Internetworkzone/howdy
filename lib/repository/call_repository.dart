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

  addToCallHistory(uid, Map data) {
    firestore.collection('users').document(uid).collection('calls').add(data);
  }
}
