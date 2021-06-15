import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lycread/Models/PushNotificationMessage.dart';
import 'package:lycread/widgets/rounded_button.dart';
import 'package:lycread/widgets/rounded_text_input.dart';
import 'package:overlay_support/overlay_support.dart';

import '../../../constants.dart';
import '../../loading_screen.dart';

class AddProjectScreen extends StatefulWidget {
  @override
  _AddProjectScreenState createState() => _AddProjectScreenState();
}

class _AddProjectScreenState extends State<AddProjectScreen> {
  Size size;
  bool loading = false;
  bool loading1 = false;
  String error = '';
  String name;
  String bio;
  List names = [];
  final _formKey = GlobalKey<FormState>();
  StreamSubscription<QuerySnapshot> subscription;

  Future<void> prepare() async {}

  @override
  void dispose(){
    subscription.cancel();
    super.dispose();
  }

  @override
  void initState() {
    prepare();
    super.initState();
    subscription = FirebaseFirestore.instance
        .collection('projects')
        .snapshots()
        .listen((event) {
      for (QueryDocumentSnapshot project in event.docs) {
        if (this.mounted) {
          setState(() {
            names.add(project.data()['name']);
          });
        } else {
          names.add(project.data()['name']);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
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
                        height: size.height * 0.2,
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
                                        'Создайте проект',
                                        style: GoogleFonts.montserrat(
                                          textStyle: TextStyle(
                                            color: primaryColor,
                                            fontSize: 23,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 30),
                                  RoundedTextInput(
                                    validator: (val) {
                                      if (names.contains(val.trim())) {
                                        return "Имя уже занято";
                                      }
                                    },
                                    hintText: 'Название',
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
                                      maxLength: 2000,
                                      style: TextStyle(
                                        color: primaryColor,
                                      ),
                                      keyboardType: TextInputType.multiline,
                                      onChanged: (value) {
                                        bio = value;
                                      },
                                      decoration: InputDecoration(
                                        hintText: 'Описание',
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 30),
                                  RoundedButton(
                                    width: 0.7,
                                    ph: 55,
                                    text: 'Добавить',
                                    press: () async {
                                      if (_formKey.currentState.validate()) {
                                        setState(() {
                                          loading = true;
                                        });
                                        String id = DateTime.now()
                                            .millisecondsSinceEpoch
                                            .toString();
                                        FirebaseFirestore.instance
                                            .collection('projects')
                                            .doc(id)
                                            .set({
                                          'id': id,
                                          'name': name.trim(),
                                          'bio': bio,
                                          'authors': [
                                            FirebaseAuth
                                                .instance.currentUser.uid
                                          ],
                                          'owner': FirebaseAuth
                                              .instance.currentUser.uid,
                                          'branches': [],
                                          'logs': [],
                                          'date': DateTime.now(),
                                          'last_update': DateTime.now(),
                                        }).catchError((error) {
                                          print('MISTAKE HERE');
                                          print(error);
                                          PushNotificationMessage notification =
                                              PushNotificationMessage(
                                            title: 'Ошибка',
                                            body: 'Неудалось добавить проект',
                                          );
                                          showSimpleNotification(
                                            Container(
                                                child: Text(notification.body)),
                                            position: NotificationPosition.top,
                                            background: Colors.red,
                                          );
                                        });
                                        PushNotificationMessage notification =
                                            PushNotificationMessage(
                                          title: 'Сохранено',
                                          body: 'Проект добавлен',
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
