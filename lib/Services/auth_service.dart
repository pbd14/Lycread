import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:lycread/Screens/HomeScreen/home_screen.dart';
import 'package:lycread/Screens/LoginScreen/login_screen.dart';
import 'package:lycread/Screens/sww_screen.dart';
import 'package:lycread/Services/push_notification_service.dart';
import 'package:lycread/widgets/slide_right_route_animation.dart';

class AuthService {
  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;

  handleAuth() {
    return StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (BuildContext context, snapshot) {
          if (snapshot.hasData) {
            final pushNotificationService =
                PushNotificationService(_firebaseMessaging);
            pushNotificationService.init();
            return HomeScreen();
          } else {
            return LoginScreen();
          }
        });
  }

  signOut(BuildContext context) {
    dynamic res = FirebaseAuth.instance.signOut().catchError((error) {
      Navigator.push(
          context,
          SlideRightRoute(
              page: SomethingWentWrongScreen(
            error: "Failed to sign out: ${error.message}",
          )));
    });
    return res;
  }

  signIn(PhoneAuthCredential authCredential, BuildContext context) {
    try {
      dynamic res = FirebaseAuth.instance
          .signInWithCredential(authCredential)
          .catchError((error) {
        Navigator.push(
            context,
            SlideRightRoute(
                page: SomethingWentWrongScreen(
              error: "Something went wrong: ${error.message}",
            )));
      });
      final pushNotificationService =
          PushNotificationService(_firebaseMessaging);
      pushNotificationService.init();
      return res;
    } catch (e) {
      return null;
    }
  }

  signInWithOTP(smsCode, verId, BuildContext context) {
    try {
      PhoneAuthCredential authCredential = PhoneAuthProvider.credential(
        verificationId: verId,
        smsCode: smsCode,
      );
      dynamic res = signIn(authCredential, context);
      return res;
    } catch (e) {
      return null;
    }
  }
}
