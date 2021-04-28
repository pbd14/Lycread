import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screen_lock/screen_lock.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lycread/Models/PushNotificationMessage.dart';
import 'package:lycread/constants.dart';
import 'package:lycread/widgets/card.dart';
import 'package:lycread/widgets/rounded_button.dart';
import 'package:lycread/widgets/rounded_text_input.dart';
import 'package:lycread/widgets/slide_right_route_animation.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../loading_screen.dart';

class SettingsScreen extends StatefulWidget {
  final String errors;
  SettingsScreen({Key key, this.errors}) : super(key: key);
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _formKey1 = GlobalKey<FormState>();
  SharedPreferences prefs;
  var value1;
  bool expV1 = false;
  String error = '';
  String name;
  String bio;
  bool loading = true;
  bool noPhoto = true;
  File i1;
  TaskSnapshot a1;
  DocumentSnapshot data;
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
    prefs = await SharedPreferences.getInstance();
    value1 = prefs.getBool('local_auth') ?? false;
    if (value1) {
      Navigator.push(
        context,
        SlideRightRoute(
          page: ScreenLock(
            correctString: prefs.getString('local_password'),
            canCancel: false,
          ),
        ),
      );
    }
    if (this.mounted) {
      setState(() {
        expV1 = value1;
        loading = false;
      });
    } else {
      expV1 = value1;
      loading = false;
    }
  }

  void initState() {
    prepare();
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
                      SizedBox(
                        height: size.height * 0.5 - 225,
                      ),
                      Container(
                        width: 0.9 * size.width,
                        child: Card(
                          margin: EdgeInsets.all(5),
                          shadowColor: whiteColor,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Form(
                              key: _formKey1,
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
                                  Row(
                                    children: [
                                      Expanded(
                                        flex: 7,
                                        child: Text(
                                          'Локальный пароль',
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.montserrat(
                                            textStyle: TextStyle(
                                              color: primaryColor,
                                              fontSize: 17,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 5),
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: Switch(
                                          activeColor: footyColor,
                                          value: expV1,
                                          onChanged: (val) {
                                            if (this.mounted) {
                                              setState(() {
                                                expV1 = val;
                                                if (!val) {
                                                  prefs.setBool(
                                                      'local_auth', expV1);
                                                  PushNotificationMessage
                                                      notification =
                                                      PushNotificationMessage(
                                                    title: 'Сохранено',
                                                    body:
                                                        'Локальный пароль отключен',
                                                  );
                                                  showSimpleNotification(
                                                    Container(
                                                        child: Text(
                                                            notification.body)),
                                                    position:
                                                        NotificationPosition
                                                            .top,
                                                    background: Colors.red,
                                                  );
                                                }
                                              });
                                            }
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                  ExpansionPanelList(
                                    children: [
                                      ExpansionPanel(
                                        isExpanded: expV1,
                                        headerBuilder: (context, isOpen) {
                                          return Center(
                                            child: Container(
                                                margin: EdgeInsets.fromLTRB(
                                                    5, 2, 5, 2),
                                                child:
                                                    Text('4-значный пароль')),
                                          );
                                        },
                                        body: Center(
                                          child: RoundedTextInput(
                                            height: 110,
                                            length: 4,
                                            validator: (val) {
                                              if (val.length != 4) {
                                                return "Нужен 4-значный код";
                                              }
                                            },
                                            formatters: [
                                              FilteringTextInputFormatter.allow(
                                                  RegExp(r"[0-9]+|\s")),
                                            ],
                                            hintText: 'Пароль',
                                            type: TextInputType.number,
                                            onChanged: (value) {
                                              if (value.length == 4) {
                                                prefs.setBool(
                                                    'local_auth', expV1);
                                                prefs.setString(
                                                    'local_password', value);
                                                PushNotificationMessage
                                                    notification =
                                                    PushNotificationMessage(
                                                  title: 'Сохранено',
                                                  body:
                                                      'Локальный пароль включен',
                                                );
                                                showSimpleNotification(
                                                  Container(
                                                      child: Text(
                                                          notification.body)),
                                                  position:
                                                      NotificationPosition.top,
                                                  background: footyColor,
                                                );
                                              }
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Container(
                        width: 0.95 * size.width,
                        child: Card(
                          margin: EdgeInsets.all(5),
                          shadowColor: whiteColor,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Center(
                                      child: Text(
                                        'Данные',
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
                                    validator: (val) {
                                      if (names.contains(val)) {
                                        return "Имя уже занято";
                                      }
                                    },
                                    formatters: [
                                      FilteringTextInputFormatter.allow(
                                          RegExp(r"[a-zA-z0-9]+|\s")),
                                    ],
                                    hintText: FirebaseAuth
                                        .instance.currentUser.displayName,
                                    type: TextInputType.text,
                                    onChanged: (value) {
                                      if (value.length == 0) {
                                        this.name = null;
                                      } else {
                                        this.name = value;
                                      }
                                    },
                                  ),
                                  SizedBox(height: 15),
                                  Container(
                                    padding: EdgeInsets.fromLTRB(
                                        size.width * 0.05,
                                        0,
                                        size.width * 0.05,
                                        0),
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
                                          color: footyColor,
                                          shape: BoxShape.circle),
                                      width: size.width * 0.5,
                                      height: size.width * 0.5,
                                      child: i1 == null
                                          ? Container(
                                              width: size.width * 0.4,
                                              height: size.width * 0.4,
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(25.0),
                                                child: FirebaseAuth
                                                            .instance
                                                            .currentUser
                                                            .photoURL !=
                                                        null
                                                    ? FadeInImage.assetNetwork(
                                                        fit: BoxFit.cover,
                                                        placeholder:
                                                            'assets/images/User.png',
                                                        image: FirebaseAuth
                                                            .instance
                                                            .currentUser
                                                            .photoURL,
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
                                    ph: 55,
                                    text: 'Сохранить',
                                    press: () async {
                                      if (_formKey.currentState.validate()) {
                                        setState(() {
                                          loading = true;
                                        });
                                        String id = FirebaseAuth
                                            .instance.currentUser.uid;
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
                                                : FirebaseAuth.instance
                                                    .currentUser.displayName,
                                            photoURL:
                                                await a1.ref.getDownloadURL(),
                                          );
                                          FirebaseFirestore.instance
                                              .collection('users')
                                              .doc(FirebaseAuth
                                                  .instance.currentUser.uid)
                                              .update({
                                            'name': this.name != null
                                                ? this.name
                                                : FirebaseAuth.instance
                                                    .currentUser.displayName,
                                            'bio': this.bio != null
                                                ? this.bio
                                                : data.data()['bio'],
                                            'photo':
                                                await a1.ref.getDownloadURL(),
                                          }).catchError((error) {
                                            PushNotificationMessage
                                                notification =
                                                PushNotificationMessage(
                                              title: 'Fail',
                                              body: 'Failed to login',
                                            );
                                            showSimpleNotification(
                                              Container(
                                                  child:
                                                      Text(notification.body)),
                                              position:
                                                  NotificationPosition.top,
                                              background: Colors.red,
                                            );
                                          });
                                        } else {
                                          FirebaseAuth.instance.currentUser
                                              .updateProfile(
                                            displayName: this.name != null
                                                ? this.name
                                                : FirebaseAuth.instance
                                                    .currentUser.displayName,
                                          );
                                          FirebaseFirestore.instance
                                              .collection('users')
                                              .doc(FirebaseAuth
                                                  .instance.currentUser.uid)
                                              .update({
                                            'name': this.name != null
                                                ? this.name
                                                : FirebaseAuth.instance
                                                    .currentUser.displayName,
                                            'bio': this.bio != null
                                                ? this.bio
                                                : data.data()['bio'],
                                          }).catchError((error) {
                                            PushNotificationMessage
                                                notification =
                                                PushNotificationMessage(
                                              title: 'Fail',
                                              body: 'Failed to login',
                                            );
                                            showSimpleNotification(
                                              Container(
                                                  child:
                                                      Text(notification.body)),
                                              position:
                                                  NotificationPosition.top,
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
                                          Container(
                                              child: Text(notification.body)),
                                          position: NotificationPosition.top,
                                          background: footyColor,
                                        );
                                        // Navigator.push(
                                        //     context,
                                        //     SlideRightRoute(
                                        //       page: HomeScreen(),
                                        //     ));
                                        Navigator.pop(context);
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
