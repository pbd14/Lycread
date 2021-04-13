import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lycread/Models/PushNotificationMessage.dart';
import 'package:lycread/Screens/HomeScreen/home_screen.dart';
import 'package:lycread/Screens/ProfileScreen/profile_screen.dart';
import 'package:lycread/constants.dart';
import 'package:lycread/widgets/card.dart';
import 'package:lycread/widgets/rounded_button.dart';
import 'package:lycread/widgets/rounded_text_input.dart';
import 'package:lycread/widgets/slide_right_route_animation.dart';
import 'package:overlay_support/overlay_support.dart';

import '../../loading_screen.dart';

class SettingsScreen extends StatefulWidget {
  final String errors;
  SettingsScreen({Key key, this.errors}) : super(key: key);
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();

  String error = '';
  String name;
  String bio;
  bool loading = true;
  bool noPhoto = true;
  File i1;
  TaskSnapshot a1;
  DocumentSnapshot data;
  String path;

  Future _getImage() async {
    var picker = await ImagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 0,
    );

    setState(() {
      if (picker != null) {
        path = picker.path;
        i1 = File(picker.path);
        noPhoto = false;
      } else {
        path = 'assets/images/User.png';
        i1 = File('assets/images/User.png');
      }
    });
  }

  Future<void> prepare() async {
    data = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser.uid)
        .get();
    if (this.mounted) {
      setState(() {
        loading = false;
      });
    } else {
      loading = false;
    }
  }

  void initState() {
    prepare();
    super.initState();
  }

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
                      ph: 850,
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
                                  'Настройки',
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
                              formatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r"[a-zA-z0-9]+|\s")),
                              ],
                              hintText:
                                  FirebaseAuth.instance.currentUser.displayName,
                              type: TextInputType.text,
                              onChanged: (value) {
                                this.name = value;
                              },
                            ),
                            SizedBox(height: 15),
                            Container(
                              padding: EdgeInsets.fromLTRB(
                                  size.width * 0.05, 0, size.width * 0.05, 0),
                              child: TextFormField(
                                initialValue: data.data()['bio'],
                                maxLength: 200,
                                maxLines: null,
                                style: TextStyle(
                                  color: primaryColor,
                                ),
                                keyboardType: TextInputType.multiline,
                                onChanged: (value) {
                                  bio = value;
                                },
                                decoration: InputDecoration(
                                  hintText: data.data()['bio'],
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            SizedBox(height: 30),
                            Text(
                              'Фотография',
                              textScaleFactor: 1,
                              style: GoogleFonts.montserrat(
                                textStyle: TextStyle(
                                  color: primaryColor,
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Divider(),
                            SizedBox(
                              height: 10,
                            ),
                            GestureDetector(
                              onTap: () {
                                _getImage();
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                    color: footyColor, shape: BoxShape.circle),
                                width: size.width * 0.5,
                                height: size.width * 0.5,
                                child: i1 == null
                                    ? Container(
                                        width: size.width * 0.4,
                                        height: size.width * 0.4,
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(25.0),
                                          child: FirebaseAuth.instance
                                                      .currentUser.photoURL !=
                                                  null
                                              ? FadeInImage.assetNetwork(
                                                  fit: BoxFit.cover,
                                                  placeholder:
                                                      'assets/images/User.png',
                                                  image: FirebaseAuth.instance
                                                      .currentUser.photoURL,
                                                )
                                              : Image.asset(
                                                  'assets/images/User.png',
                                                  fit: BoxFit.cover,
                                                ),
                                        ),
                                      )
                                    : Container(
                                        decoration: ShapeDecoration(
                                            color: footyColor,
                                            shape: CircleBorder(
                                              side: BorderSide(
                                                  width: 1, color: footyColor),
                                            ),
                                            image: DecorationImage(
                                              image: AssetImage(path),
                                              fit: BoxFit.cover,
                                              alignment: Alignment.center,
                                            )),
                                      ),
                              ),
                            ),
                            SizedBox(height: 30),
                            RoundedButton(
                              width: 0.7,
                              ph: 55,
                              text: 'Сохранить',
                              press: () async {
                                if (_formKey.currentState.validate()) {
                                  setState(() {
                                    loading = true;
                                  });
                                  String id =
                                      FirebaseAuth.instance.currentUser.uid;
                                  String date = DateTime.now().toString();
                                  if (!noPhoto) {
                                    a1 = await FirebaseStorage.instance
                                        .ref('uploads')
                                        .child('$id/user/$date')
                                        .putFile(i1);
                                    FirebaseAuth.instance.currentUser
                                        .updateProfile(
                                      displayName: this.name != null
                                          ? this.name
                                          : FirebaseAuth
                                              .instance.currentUser.displayName,
                                      photoURL: await a1.ref.getDownloadURL(),
                                    );
                                    FirebaseFirestore.instance
                                        .collection('users')
                                        .doc(FirebaseAuth
                                            .instance.currentUser.uid)
                                        .update({
                                      'name': this.name != null
                                          ? this.name
                                          : FirebaseAuth
                                              .instance.currentUser.displayName,
                                      'bio': this.bio != null
                                          ? this.bio
                                          : data.data()['bio'],
                                      'photo': await a1.ref.getDownloadURL(),
                                    }).catchError((error) {
                                      PushNotificationMessage notification =
                                          PushNotificationMessage(
                                        title: 'Fail',
                                        body: 'Failed to login',
                                      );
                                      showSimpleNotification(
                                        Container(
                                            child: Text(notification.body)),
                                        position: NotificationPosition.top,
                                        background: Colors.red,
                                      );
                                    });
                                  } else {
                                    FirebaseAuth.instance.currentUser
                                        .updateProfile(
                                      displayName: this.name != null
                                          ? this.name
                                          : FirebaseAuth
                                              .instance.currentUser.displayName,
                                    );
                                    FirebaseFirestore.instance
                                        .collection('users')
                                        .doc(FirebaseAuth
                                            .instance.currentUser.uid)
                                        .update({
                                      'name': this.name != null
                                          ? this.name
                                          : FirebaseAuth
                                              .instance.currentUser.displayName,
                                      'bio': this.bio != null
                                          ? this.bio
                                          : data.data()['bio'],
                                    }).catchError((error) {
                                      PushNotificationMessage notification =
                                          PushNotificationMessage(
                                        title: 'Fail',
                                        body: 'Failed to login',
                                      );
                                      showSimpleNotification(
                                        Container(
                                            child: Text(notification.body)),
                                        position: NotificationPosition.top,
                                        background: Colors.red,
                                      );
                                    });
                                  }
                                  PushNotificationMessage notification =
                                      PushNotificationMessage(
                                    title: 'Сохранено',
                                    body: 'Данные обновлены',
                                  );
                                  showSimpleNotification(
                                    Container(child: Text(notification.body)),
                                    position: NotificationPosition.top,
                                    background: footyColor,
                                  );
                                  Navigator.push(
                                      context,
                                      SlideRightRoute(
                                        page: ProfileScreen(),
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
