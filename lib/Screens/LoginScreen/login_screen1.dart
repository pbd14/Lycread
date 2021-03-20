import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lycread/Models/PushNotificationMessage.dart';
import 'package:lycread/Screens/HomeScreen/home_screen.dart';
import 'package:lycread/widgets/card.dart';
import 'package:lycread/widgets/rounded_button.dart';
import 'package:lycread/widgets/rounded_text_input.dart';
import 'package:lycread/widgets/slide_right_route_animation.dart';
import 'package:overlay_support/overlay_support.dart';
import '../../constants.dart';
import '../loading_screen.dart';

class LoginScreen1 extends StatefulWidget {
  final String errors;
  LoginScreen1({Key key, this.errors}) : super(key: key);
  @override
  _LoginScreen1State createState() => _LoginScreen1State();
}

class _LoginScreen1State extends State<LoginScreen1> {
  final _formKey = GlobalKey<FormState>();

  String error = '';
  String name;

  bool loading = false;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    if (widget.errors != null) {
      setState(() {
        error = widget.errors;
      });
    }
    return loading
        ? LoadingScreen()
        : Scaffold(
            backgroundColor: primaryColor,
            body: Container(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: size.height * 0.5 - 225),
                    CardW(
                      shadow: whiteColor,
                      ph: 650,
                      width: 0.7,
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Center(
                                child: Text(
                                  'Create yout account',
                                  style: GoogleFonts.montserrat(
                                    textStyle: TextStyle(
                                      color: primaryColor,
                                      fontSize: 27,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 30),
                            RoundedTextInput(
                              validator: (val) => val.length >= 2
                                  ? null
                                  : 'Minimum 2 characters',
                              hintText: "Name",
                              type: TextInputType.text,
                              onChanged: (value) {
                                this.name = value;
                              },
                            ),
                            SizedBox(height: 30),
                            RoundedButton(
                              width: 0.7,
                              ph: 55,
                              text: 'CONTINUE',
                              press: () async {
                                if (_formKey.currentState.validate()) {
                                  setState(() {
                                    loading = true;
                                  });
                                  FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(
                                          FirebaseAuth.instance.currentUser.uid)
                                      .set({
                                    'name': this.name,
                                    'phones': FieldValue.arrayUnion([
                                      FirebaseAuth
                                          .instance.currentUser.phoneNumber
                                    ]),
                                    'followers_num': 0,
                                    'id': FirebaseAuth.instance.currentUser.uid,
                                  }).catchError((error) {
                                    PushNotificationMessage notification =
                                        PushNotificationMessage(
                                      title: 'Fail',
                                      body: 'Failed to login',
                                    );
                                    showSimpleNotification(
                                      Container(child: Text(notification.body)),
                                      position: NotificationPosition.top,
                                      background: Colors.red,
                                    );
                                  });
                                  Navigator.push(
                                      context,
                                      SlideRightRoute(
                                        page: HomeScreen(),
                                      ));
                                  setState(() {
                                    loading = false;
                                    this.name = '';
                                  });
                                }
                              },
                              color: darkPrimaryColor,
                              textColor: whiteColor,
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Text(
                                error,
                                style: GoogleFonts.montserrat(
                                  textStyle: TextStyle(
                                    color: Colors.red,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
  }
}
