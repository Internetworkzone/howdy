import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:howdy/modals/call.dart';
import 'package:howdy/modals/user.dart';
import 'package:howdy/repository/call_repository.dart';

class CallType {
  static String voice = 'voice';
  static String video = 'video';
}

class CallService {
  CallRepository callRepository = CallRepository();
  Call call;

  Stream<DocumentSnapshot> getIncomingCall(uid) {
    return callRepository.incomingCall(uid);
  }

  Future<void> makeCall(Call call) async {
    // call = Call(
    //   callerName: caller.name,
    //   callerUid: caller.uid,
    //   receiverName: receiver.name,
    //   receiverUid: receiver.uid,
    //   calltype: type,
    //   timestamp: Timestamp.now(),
    // );

    await callRepository.connectCall(
        call.callerUid, call.receiverUid, call.toMap());
  }

  Future<void> disConnectCall(Call call) async {
    await callRepository.deleteIncomingCall(call.callerUid);
    await callRepository.deleteIncomingCall(call.receiverUid);
  }

  Future<void> addCallHistory(
      User caller, User receiver, elapsed, time, uid, type) async {
    call = Call(
      callerName: caller.name,
      callerUid: caller.uid,
      receiverName: receiver.name,
      receiverUid: receiver.uid,
      calltype: type,
      duration: elapsed,
      timestamp: time,
    );
    await callRepository.addToCallHistory(uid, call.toMap());
  }
}
