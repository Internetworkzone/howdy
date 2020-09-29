// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
// import 'package:howdy/modals/messages.dart';

// class NotificationPage extends StatefulWidget {
//   @override
//   _NotificationPageState createState() => _NotificationPageState();
// }

// class _NotificationPageState extends State<NotificationPage> {
//   final FirebaseMessaging messaging = FirebaseMessaging();
//   List<Messages> messages = [];

//   @override
//   void initState() {
//     super.initState();
//     messaging.configure(
//       onMessage: (Map<String, dynamic> message) async {
//         print("onMessage: $message");
//         final notification = message['notification'];
//         setState(() {
//           messages.add(
//             Messages(
//               title: notification['title'],
//               body: notification['body'],
//             ),
//           );
//         });
//       },
//       onLaunch: (Map<String, dynamic> message) async {
//         print("onMessage: $message");
//       },
//       onResume: (Map<String, dynamic> message) async {
//         print("onMessage: $message");
//       },
//     );

//     messaging.requestNotificationPermissions(IosNotificationSettings(
//       sound: true,
//       badge: true,
//       alert: true,
//     ));
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(),
//       body: ListView(
//         children: messages.map(buildMessage).toList(),
//       ),
//     );
//   }

//   Widget buildMessage(Messages messages) => ListTile(
//         title: Text(messages.title),
//         subtitle: Text(messages.body),
//       );
// }
