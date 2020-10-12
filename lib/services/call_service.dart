import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:howdy/modals/call.dart';
import 'package:howdy/modals/user.dart';
import 'package:howdy/repository/call_repository.dart';

class CallType {
  static String voice = 'voice';
  static String video = 'video';
}

class CallStatus {
  static final missed = 'missed';
  static final dialled = 'dialled';
  static final received = 'received';
}

class CallService {
  CallRepository callRepository = CallRepository();
  Call call;
  Timestamp timestamp;

  Stream<DocumentSnapshot> getIncomingCall(uid) {
    return callRepository.incomingCall(uid);
  }

  Future<void> makeCall(Call call) async {
    timestamp = Timestamp.now();
    Map<String, dynamic> data = call.toMap();
    data['timestamp'] = timestamp;
    await callRepository.connectCall(call.callerUid, call.receiverUid, data);
  }

  Future<void> disConnectCall(Call call, bool isPicked) async {
    await callRepository.deleteIncomingCall(call.callerUid);
    await callRepository.deleteIncomingCall(call.receiverUid);
    addCallHistory(call, isPicked);
  }

  Future<void> addCallHistory(Call call, bool isPicked) async {
    Map<String, dynamic> data = call.toMap();
    data['timestamp'] = timestamp;
    await callRepository.addToCallHistory(call.callerUid, data);
    data['callStatus'] = isPicked ? CallStatus.received : CallStatus.missed;
    await callRepository.addToCallHistory(call.receiverUid, data);
  }

  Future<QuerySnapshot> getHistory(String uid) async {
    return await callRepository.getCallHistory(uid);
  }
}
