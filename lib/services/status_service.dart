import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:howdy/modals/status.dart';
import 'package:howdy/repository/status_repository.dart';

class StatusService {
  StatusRepository repository = StatusRepository();

  uploadStatus({
    bool isMultimedia,
    String uid,
    String path,
    String caption,
    String type,
    String userName,
  }) async {
    String url;
    if (isMultimedia) {
      url = await repository.uploadToStorage(uid, path, type);
    }
    Status status = Status(
      url: url,
      caption: caption,
      timestamp: Timestamp.now(),
    );
    StatusSummary summary = StatusSummary(
      lastStatusUrl: status.url,
      lastStatusTimestamp: status.timestamp,
      lastStatusType: 'Image',
      user: userName,
    );
    repository.uploadStatus(uid, status.toMap());
    repository.updateStatusSummary(uid, summary.toMap());
  }

  Future<QuerySnapshot> getStatus(String uid) async {
    return await repository.getStatus(uid);
  }

  Stream<QuerySnapshot> getAllStatus() {
    return repository.getAllStatus();
  }
}
