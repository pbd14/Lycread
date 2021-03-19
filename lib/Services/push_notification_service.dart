import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:lycread/Models/PushNotificationMessage.dart';
import 'package:overlay_support/overlay_support.dart';

import '../constants.dart';

class PushNotificationService {
  final FirebaseMessaging _fcm;

  PushNotificationService(this._fcm);

  Future init() async {
    if (Platform.isIOS) {
      _fcm.requestNotificationPermissions(IosNotificationSettings());
    }

    String token = await _fcm.getToken();
    if (FirebaseAuth.instance.currentUser != null) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser.uid)
          .update({'fcm_token': token});
    }

    print("FirebaseMessaging token: $token");
    _fcm.configure(
      onMessage: (Map<String, dynamic> message) async {
        // Navigator.of(context).push(SlideRightRoute(page: HistoryScreen()));
        // if (Platform.isAndroid) {
        PushNotificationMessage notification = PushNotificationMessage(
          title: message['notification']['title'],
          body: message['notification']['body'],
        );
        showSimpleNotification(
          Container(child: Text(notification.body)),
          position: NotificationPosition.top,
          background: darkPrimaryColor,
        );
        // }
      },
      onLaunch: (Map<String, dynamic> message) async {
        if (Platform.isAndroid || Platform.isIOS) {
          PushNotificationMessage notification = PushNotificationMessage(
            title: message['notification']['title'],
            body: message['notification']['body'],
          );
          showSimpleNotification(
            Container(child: Text(notification.body)),
            position: NotificationPosition.top,
            background: darkPrimaryColor,
          );
        }
        if (Platform.isAndroid || Platform.isIOS) {
          PushNotificationMessage notification = PushNotificationMessage(
            title: message['notification']['title'],
            body: message['notification']['body'],
          );
          showSimpleNotification(
            Container(child: Text(notification.body)),
            position: NotificationPosition.top,
            background: darkPrimaryColor,
          );
        }
      },
      onResume: (Map<String, dynamic> message) async {
        if (Platform.isAndroid || Platform.isIOS) {
          PushNotificationMessage notification = PushNotificationMessage(
            title: message['notification']['title'],
            body: message['notification']['body'],
          );
          showSimpleNotification(
            Container(child: Text(notification.body)),
            position: NotificationPosition.top,
            background: darkPrimaryColor,
          );
        }
        if (Platform.isAndroid || Platform.isIOS) {
          PushNotificationMessage notification = PushNotificationMessage(
            title: message['notification']['title'],
            body: message['notification']['body'],
          );
          showSimpleNotification(
            Container(child: Text(notification.body)),
            position: NotificationPosition.top,
            background: darkPrimaryColor,
          );
        }
      },
    );
  }
}

// import 'dart:async';
// import 'dart:io';
// import 'package:intl/intl.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_complete_guide/Models/Booking.dart';
// import 'package:flutter_complete_guide/Models/PushNotificationMessage.dart';
// import 'package:flutter_complete_guide/constants.dart';
// import 'package:overlay_support/overlay_support.dart';

// class PushNotificationService {
//   final FirebaseMessaging _fcm;
//   List _bookings = [];

//   PushNotificationService(this._fcm);

//   Future init() async {
//     if (Platform.isIOS) {
//       _fcm.requestNotificationPermissions(IosNotificationSettings());
//     }

//     String token = await _fcm.getToken();
//     print("FirebaseMessaging token: $token");

//     var dataGlobal = await FirebaseFirestore.instance
//         .collection('bookings')
//         .orderBy(
//           'timestamp_date',
//           descending: true,
//         )
//         .where(
//           'status',
//           whereIn: ['unfinished', 'verification_needed'],
//         )
//         .where(
//           'userId',
//           isEqualTo: FirebaseAuth.instance.currentUser.uid,
//         )
//         .where(
//           'date',
//           isEqualTo: DateTime(
//             DateTime.now().year,
//             DateTime.now().month,
//             DateTime.now().day,
//             0,
//           ).toString(),
//         )
//         .get();
//     _bookings = dataGlobal.docs;
//     if (_bookings.length != 0) {
//       _fcm.configure(
//         onMessage: (Map<String, dynamic> message) async {
//           var data = await FirebaseFirestore.instance
//               .collection('bookings')
//               .orderBy(
//                 'timestamp_date',
//                 descending: true,
//               )
//               .where(
//                 'status',
//                 whereIn: ['unfinished', 'verification_needed'],
//               )
//               .where(
//                 'userId',
//                 isEqualTo: FirebaseAuth.instance.currentUser.uid,
//               )
//               .where(
//                 'date',
//                 isEqualTo: DateTime(
//                   DateTime.now().year,
//                   DateTime.now().month,
//                   DateTime.now().day,
//                   0,
//                 ).toString(),
//               )
//               .get();
//           _bookings = data.docs;
//           if (_bookings.length != 0) {
//             for (dynamic book in _bookings) {
//               TimeOfDay bookingTo = TimeOfDay.fromDateTime(
//                   DateFormat.Hm().parse(Booking.fromSnapshot(book).to));
//               TimeOfDay bookingFrom = TimeOfDay.fromDateTime(
//                   DateFormat.Hm().parse(Booking.fromSnapshot(book).from));
//               double dbookingTo = bookingTo.minute + bookingTo.hour * 60.0;
//               double dbookingFrom =
//                   bookingFrom.minute + bookingFrom.hour * 60.0;
//               double dnow = DateTime.now().minute + DateTime.now().hour * 60.0;
//               if (dnow == dbookingFrom) {
//                 FirebaseFirestore.instance
//                     .collection('users')
//                     .doc(FirebaseAuth.instance.currentUser.uid)
//                     .update({'status': 'on booking'});
//                 FirebaseFirestore.instance
//                     .collection('bookings')
//                     .doc(book.id)
//                     .update({'status': 'in process'});
//                 print("onMessage: $message");
//                 if (Platform.isAndroid) {
//                   PushNotificationMessage notification =
//                       PushNotificationMessage(
//                     title: message['notification']['title'],
//                     body: message['notification']['body'],
//                   );
//                   showSimpleNotification(
//                     Container(child: Text(notification.body)),
//                     position: NotificationPosition.top,
//                     background: darkPrimaryColor,
//                   );
//                 }
//               }
//               if (dnow > dbookingFrom && dnow < dbookingTo) {
//                 FirebaseFirestore.instance
//                     .collection('users')
//                     .doc(FirebaseAuth.instance.currentUser.uid)
//                     .update({'status': 'on booking'});
//                 FirebaseFirestore.instance
//                     .collection('bookings')
//                     .doc(book.id)
//                     .update({'status': 'in process'});
//                 print("onMessage: $message");
//                 if (Platform.isAndroid) {
//                   PushNotificationMessage notification =
//                       PushNotificationMessage(
//                     title: message['notification']['title'],
//                     body: message['notification']['body'],
//                   );
//                   showSimpleNotification(
//                     Container(child: Text(notification.body)),
//                     position: NotificationPosition.top,
//                     background: darkPrimaryColor,
//                   );
//                 }
//               }

//               if (dnow >= dbookingTo) {
//                 FirebaseFirestore.instance
//                     .collection('users')
//                     .doc(FirebaseAuth.instance.currentUser.uid)
//                     .update({'status': 'default'});
//                 FirebaseFirestore.instance
//                     .collection('bookings')
//                     .doc(book.id)
//                     .update({'status': 'finished'});
//               } else if (dbookingFrom > dnow && dbookingFrom < dnow + 120) {
//                 FirebaseFirestore.instance
//                     .collection('users')
//                     .doc(FirebaseAuth.instance.currentUser.uid)
//                     .update({'status': 'on booking'});
//                 FirebaseFirestore.instance
//                     .collection('bookings')
//                     .doc(book.id)
//                     .update({'status': 'in process'});
//                 print("onMessage: $message");
//                 if (Platform.isAndroid) {
//                   PushNotificationMessage notification =
//                       PushNotificationMessage(
//                     title: 'Soon',
//                     body: 'You have a booking soon',
//                   );
//                   showSimpleNotification(
//                     Container(child: Text(notification.body)),
//                     position: NotificationPosition.top,
//                     background: darkPrimaryColor,
//                   );
//                 }
//               } else if (dbookingTo > dnow && dbookingTo < dnow + 120) {
//                 FirebaseFirestore.instance
//                     .collection('users')
//                     .doc(FirebaseAuth.instance.currentUser.uid)
//                     .update({'status': 'on booking'});
//                 FirebaseFirestore.instance
//                     .collection('bookings')
//                     .doc(book.id)
//                     .update({'status': 'in process'});
//                 print("onMessage: $message");
//                 if (Platform.isAndroid) {
//                   PushNotificationMessage notification =
//                       PushNotificationMessage(
//                     title: message['notification']['title'],
//                     body: message['notification']['body'],
//                   );
//                   showSimpleNotification(
//                     Container(child: Text(notification.body)),
//                     position: NotificationPosition.top,
//                     background: darkPrimaryColor,
//                   );
//                 }
//               }
//             }
//           }
//         },
//         onLaunch: (Map<String, dynamic> message) async {
//           var data = await FirebaseFirestore.instance
//               .collection('bookings')
//               .orderBy(
//                 'timestamp_date',
//                 descending: true,
//               )
//               .where(
//                 'status',
//                 whereIn: ['unfinished', 'verification_needed'],
//               )
//               .where(
//                 'userId',
//                 isEqualTo: FirebaseAuth.instance.currentUser.uid,
//               )
//               .where(
//                 'date',
//                 isEqualTo: DateTime(
//                   DateTime.now().year,
//                   DateTime.now().month,
//                   DateTime.now().day,
//                   0,
//                 ).toString(),
//               )
//               .get();
//           _bookings = data.docs;
//           if (_bookings.length != 0) {
//             for (dynamic book in _bookings) {
//               TimeOfDay bookingTo = TimeOfDay.fromDateTime(
//                   DateFormat.Hm().parse(Booking.fromSnapshot(book).to));
//               TimeOfDay bookingFrom = TimeOfDay.fromDateTime(
//                   DateFormat.Hm().parse(Booking.fromSnapshot(book).from));
//               double dbookingTo = bookingTo.minute + bookingTo.hour * 60.0;
//               double dbookingFrom =
//                   bookingFrom.minute + bookingFrom.hour * 60.0;
//               double dnow = DateTime.now().minute + DateTime.now().hour * 60.0;
//               if (dnow == dbookingFrom) {
//                 FirebaseFirestore.instance
//                     .collection('users')
//                     .doc(FirebaseAuth.instance.currentUser.uid)
//                     .update({'status': 'on booking'});
//                 FirebaseFirestore.instance
//                     .collection('bookings')
//                     .doc(book.id)
//                     .update({'status': 'in process'});
//                 print("onLaunch: $message");
//                 if (Platform.isAndroid) {
//                 }
//               }
//               if (dnow > dbookingFrom && dnow < dbookingTo) {
//                 FirebaseFirestore.instance
//                     .collection('users')
//                     .doc(FirebaseAuth.instance.currentUser.uid)
//                     .update({'status': 'on booking'});
//                 FirebaseFirestore.instance
//                     .collection('bookings')
//                     .doc(book.id)
//                     .update({'status': 'in process'});
//                 print("onLaunch: $message");
//                 if (Platform.isAndroid) {
//                 }
//               }
//               if (dnow >= dbookingTo) {
//                 FirebaseFirestore.instance
//                     .collection('users')
//                     .doc(FirebaseAuth.instance.currentUser.uid)
//                     .update({'status': 'default'});
//                 FirebaseFirestore.instance
//                     .collection('bookings')
//                     .doc(book.id)
//                     .update({'status': 'finished'});
//               }

//               if (dbookingFrom > dnow && dbookingFrom < dnow + 120) {
//                 FirebaseFirestore.instance
//                     .collection('users')
//                     .doc(FirebaseAuth.instance.currentUser.uid)
//                     .update({'status': 'on booking'});
//                 FirebaseFirestore.instance
//                     .collection('bookings')
//                     .doc(book.id)
//                     .update({'status': 'in process'});
//                 print("onMessage: $message");
//                 if (Platform.isAndroid) {
//                   PushNotificationMessage notification =
//                       PushNotificationMessage(
//                     title: 'Soon',
//                     body: 'You have a booking soon',
//                   );
//                   showSimpleNotification(
//                     Container(child: Text(notification.body)),
//                     position: NotificationPosition.top,
//                     background: darkPrimaryColor,
//                   );
//                 }
//               } else if (dbookingTo > dnow && dbookingTo < dnow + 120) {
//                 FirebaseFirestore.instance
//                     .collection('users')
//                     .doc(FirebaseAuth.instance.currentUser.uid)
//                     .update({'status': 'on booking'});
//                 FirebaseFirestore.instance
//                     .collection('bookings')
//                     .doc(book.id)
//                     .update({'status': 'in process'});
//                 print("onMessage: $message");
//                 if (Platform.isAndroid) {
//                   PushNotificationMessage notification =
//                       PushNotificationMessage(
//                     title: message['notification']['title'],
//                     body: message['notification']['body'],
//                   );
//                   showSimpleNotification(
//                     Container(child: Text(notification.body)),
//                     position: NotificationPosition.top,
//                     background: darkPrimaryColor,
//                   );
//                 }
//               }
//             }
//           }
//         },
//         onResume: (Map<String, dynamic> message) async {
//           var data = await FirebaseFirestore.instance
//               .collection('bookings')
//               .orderBy(
//                 'timestamp_date',
//                 descending: true,
//               )
//               .where(
//                 'status',
//                 whereIn: ['unfinished', 'verification_needed'],
//               )
//               .where(
//                 'userId',
//                 isEqualTo: FirebaseAuth.instance.currentUser.uid,
//               )
//               .where(
//                 'date',
//                 isEqualTo: DateTime(
//                   DateTime.now().year,
//                   DateTime.now().month,
//                   DateTime.now().day,
//                   0,
//                 ).toString(),
//               )
//               .get();
//           _bookings = data.docs;
//           if (_bookings.length != 0) {
//             for (dynamic book in _bookings) {
//               TimeOfDay bookingTo = TimeOfDay.fromDateTime(
//                   DateFormat.Hm().parse(Booking.fromSnapshot(book).to));
//               TimeOfDay bookingFrom = TimeOfDay.fromDateTime(
//                   DateFormat.Hm().parse(Booking.fromSnapshot(book).from));
//               double dbookingTo = bookingTo.minute + bookingTo.hour * 60.0;
//               double dbookingFrom =
//                   bookingFrom.minute + bookingFrom.hour * 60.0;
//               double dnow = DateTime.now().minute + DateTime.now().hour * 60.0;
//               if (dnow == dbookingFrom) {
//                 FirebaseFirestore.instance
//                     .collection('users')
//                     .doc(FirebaseAuth.instance.currentUser.uid)
//                     .update({'status': 'on booking'});
//                 FirebaseFirestore.instance
//                     .collection('bookings')
//                     .doc(book.id)
//                     .update({'status': 'in process'});
//                 print("onResume: $message");
//                 if (Platform.isAndroid) {
//                 }
//               }
//               if (dnow > dbookingFrom && dnow < dbookingTo) {
//                 FirebaseFirestore.instance
//                     .collection('users')
//                     .doc(FirebaseAuth.instance.currentUser.uid)
//                     .update({'status': 'on booking'});
//                 FirebaseFirestore.instance
//                     .collection('bookings')
//                     .doc(book.id)
//                     .update({'status': 'in process'});
//                 print("onResume: $message");
//                 if (Platform.isAndroid) {
//                 }
//               }
//               if (dnow >= dbookingTo) {
//                 FirebaseFirestore.instance
//                     .collection('users')
//                     .doc(FirebaseAuth.instance.currentUser.uid)
//                     .update({'status': 'default'});
//                 FirebaseFirestore.instance
//                     .collection('bookings')
//                     .doc(book.id)
//                     .update({'status': 'finished'});
//               }

//               if (dbookingFrom > dnow && dbookingFrom < dnow + 120) {
//                 FirebaseFirestore.instance
//                     .collection('users')
//                     .doc(FirebaseAuth.instance.currentUser.uid)
//                     .update({'status': 'on booking'});
//                 FirebaseFirestore.instance
//                     .collection('bookings')
//                     .doc(book.id)
//                     .update({'status': 'in process'});
//                 print("onMessage: $message");
//                 if (Platform.isAndroid) {
//                   PushNotificationMessage notification =
//                       PushNotificationMessage(
//                     title: 'Soon',
//                     body: 'You have a booking soon',
//                   );
//                   showSimpleNotification(
//                     Container(child: Text(notification.body)),
//                     position: NotificationPosition.top,
//                     background: darkPrimaryColor,
//                   );
//                 }
//               } else if (dbookingTo > dnow && dbookingTo < dnow + 120) {
//                 FirebaseFirestore.instance
//                     .collection('users')
//                     .doc(FirebaseAuth.instance.currentUser.uid)
//                     .update({'status': 'on booking'});
//                 FirebaseFirestore.instance
//                     .collection('bookings')
//                     .doc(book.id)
//                     .update({'status': 'in process'});
//                 print("onMessage: $message");
//                 if (Platform.isAndroid) {
//                   PushNotificationMessage notification =
//                       PushNotificationMessage(
//                     title: message['notification']['title'],
//                     body: message['notification']['body'],
//                   );
//                   showSimpleNotification(
//                     Container(child: Text(notification.body)),
//                     position: NotificationPosition.top,
//                     background: darkPrimaryColor,
//                   );
//                 }
//               }
//             }
//           }
//         },
//       );
//     }
//   }
// }
