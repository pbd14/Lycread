import 'dart:async';
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
import 'package:lycread/constants.dart';
import 'package:lycread/widgets/card.dart';
import 'package:lycread/widgets/rounded_button.dart';
import 'package:lycread/widgets/rounded_text_input.dart';
import 'package:lycread/widgets/slide_right_route_animation.dart';
import 'package:overlay_support/overlay_support.dart';
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
  String bio;
  bool loading = false;
  File i1;
  TaskSnapshot a1;
  String path;
  List names = [];
  StreamSubscription<QuerySnapshot> subscription;

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }

  Future _getImage() async {
    var picker = await ImagePicker.platform.pickImage(
      source: ImageSource.gallery,
      imageQuality: 0,
    );

    setState(() {
      if (picker != null) {
        path = picker.path;
        i1 = File(picker.path);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    subscription = FirebaseFirestore.instance
        .collection('users')
        .snapshots()
        .listen((event) {
      for (QueryDocumentSnapshot user in event.docs) {
        if (this.mounted) {
          setState(() {
            names.add(user.data()['name']);
          });
        } else {
          names.add(user.data()['name']);
        }
      }
    });
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
                child: Center(
                  child: Column(
                    children: [
                      SizedBox(height: size.height * 0.5 - 225),
                      Container(
                        width: size.width * 0.9,
                        child: Card(
                          margin: EdgeInsets.all(5),
                          shadowColor: whiteColor,
                          child: Padding(
                            padding: const EdgeInsets.all(25.0),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Center(
                                      child: Text(
                                        'Создайте аккаунт',
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
                                    validator: (val) {
                                      if (names.contains(val)) {
                                        return "Имя уже занято";
                                      }
                                      return val.length >= 1
                                          ? null
                                          : 'Минимум 2 символа';
                                    },
                                    hintText: "Имя",
                                    type: TextInputType.text,
                                    onChanged: (value) {
                                      this.name = value;
                                    },
                                  ),
                                  SizedBox(height: 20),
                                  Container(
                                    padding: EdgeInsets.fromLTRB(
                                        size.width * 0.05,
                                        0,
                                        size.width * 0.05,
                                        0),
                                    child: TextFormField(
                                      maxLength: 200,
                                      maxLines: null,
                                      style: TextStyle(
                                        color: primaryColor,
                                      ),
                                      validator: (val) => val.length > 1
                                          ? null
                                          : 'Минимум 2 символов',
                                      keyboardType: TextInputType.multiline,
                                      onChanged: (value) {
                                        bio = value;
                                      },
                                      decoration: InputDecoration(
                                        hintText: 'Bio',
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
                                          color: footyColor,
                                          shape: BoxShape.circle),
                                      width: size.width * 0.5,
                                      height: size.width * 0.5,
                                      child: i1 == null
                                          ? Icon(Icons.add)
                                          : Container(
                                              decoration: ShapeDecoration(
                                                  color: footyColor,
                                                  shape: CircleBorder(
                                                    side: BorderSide(
                                                        width: 1,
                                                        color: footyColor),
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
                                    ph: 45,
                                    text: 'CONTINUE',
                                    press: () async {
                                      if (_formKey.currentState.validate()) {
                                        setState(() {
                                          loading = true;
                                        });
                                        String id = FirebaseAuth
                                            .instance.currentUser.uid;
                                        String date = DateTime.now().toString();
                                        if (i1 != null) {
                                          a1 = await FirebaseStorage.instance
                                              .ref('uploads')
                                              .child('$id/user/$date')
                                              .putFile(i1);
                                        }
                                        FirebaseAuth.instance.currentUser
                                            .updateProfile(
                                          displayName: this.name,
                                          photoURL: i1 != null
                                              ? await a1.ref.getDownloadURL()
                                              : null,
                                        );
                                        FirebaseFirestore.instance
                                            .collection('users')
                                            .doc(FirebaseAuth
                                                .instance.currentUser.uid)
                                            .set({
                                          'name': this.name,
                                          'phones': FieldValue.arrayUnion([
                                            FirebaseAuth.instance.currentUser
                                                .phoneNumber
                                          ]),
                                          'followers_num': 0,
                                          'following_num': 0,
                                          'photo': i1 != null
                                              ? await a1.ref.getDownloadURL()
                                              : null,
                                          'bio': bio,
                                          'actions': [],
                                          'reads': [],
                                          'stats': {},
                                          'recommendations': ['lycread'],
                                          'isVerified': false,
                                          'id': FirebaseAuth
                                              .instance.currentUser.uid,
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
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
  }
}
