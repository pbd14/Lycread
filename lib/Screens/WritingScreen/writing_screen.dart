import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lycread/Models/PushNotificationMessage.dart';
import 'package:lycread/widgets/rounded_button.dart';
import 'package:lycread/widgets/rounded_text_input.dart';
import 'package:overlay_support/overlay_support.dart';
import '../../constants.dart';
import '../loading_screen.dart';

class WritingScreen extends StatefulWidget {
  @override
  _WritingScreenState createState() => _WritingScreenState();
}

class _WritingScreenState extends State<WritingScreen> {
  final _formKey = GlobalKey<FormState>();
  List categs;
  String name;
  String text;
  String category = 'Общее';
  String error = '';
  bool isError = false;
  bool loading = false;
  File i1;
  TaskSnapshot a1;

  Future<void> prepare() async {
    DocumentSnapshot dc = await FirebaseFirestore.instance
        .collection('appData')
        .doc('LycRead')
        .get();
    if (this.mounted) {
      setState(() {
        categs = dc.data()['genres'];
      });
    } else {
      categs = dc.data()['genres'];
    }
  }

  Future _getImage() async {
    var picker = await ImagePicker.platform.pickImage(
      source: ImageSource.gallery,
      imageQuality: 25,
    );

    setState(() {
      if (picker != null) {
        i1 = File(picker.path);
      }
      // else {
      //   error = 'No image selected';
      //   isError = true;
      // }
    });
  }

  @override
  void initState() {
    prepare();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return loading
        ? LoadingScreen()
        : Scaffold(
            backgroundColor: footyColor,
            body: SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.fromLTRB(0, 40, 0, 30),
                child: Center(
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 20.0),
                    child: Card(
                      elevation: 10,
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            SizedBox(
                              height: size.height * 0.1,
                            ),
                            Text(
                              'Добавьте историю',
                              textScaleFactor: 1,
                              style: GoogleFonts.montserrat(
                                textStyle: TextStyle(
                                  color: primaryColor,
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Divider(),
                            SizedBox(
                              height: 20,
                            ),
                            RoundedTextInput(
                              validator: (val) =>
                                  val.length > 2 ? null : 'Минимум 2 символов',
                              hintText: "Название",
                              type: TextInputType.text,
                              length: 30,
                              height: 110,
                              onChanged: (value) {
                                name = value;
                              },
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Container(
                              padding: EdgeInsets.fromLTRB(
                                  size.width * 0.05, 0, size.width * 0.05, 0),
                              child: TextFormField(
                                maxLines: null,
                                style: TextStyle(color: primaryColor),
                                validator: (val) => val.length > 1
                                    ? null
                                    : 'Минимум 2 символов',
                                keyboardType: TextInputType.multiline,
                                onChanged: (value) {
                                  text = value;
                                },
                                decoration: InputDecoration(
                                  hintText: "Текст",
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Container(
                              padding: EdgeInsets.fromLTRB(
                                  size.width * 0.05, 0, size.width * 0.05, 0),
                              child: DropdownButton<String>(
                                isExpanded: true,
                                hint: Text(
                                  category != null ? category : 'Жанры',
                                  textScaleFactor: 1,
                                  style: GoogleFonts.montserrat(
                                    textStyle: TextStyle(
                                      color: darkPrimaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                items: categs != null
                                    ? categs.map((dynamic value) {
                                        return new DropdownMenuItem<String>(
                                          value: value.toString().toUpperCase(),
                                          child: new Text(
                                            value,
                                            textScaleFactor: 1,
                                          ),
                                        );
                                      }).toList()
                                    : [
                                        new DropdownMenuItem<String>(
                                          value: '-',
                                          child: new Text(
                                            '-',
                                            textScaleFactor: 1,
                                          ),
                                        )
                                      ],
                                onChanged: (value) {
                                  setState(() {
                                    category = value;
                                  });
                                },
                              ),
                            ),
                            SizedBox(
                              height: 30,
                            ),
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
                                width: size.width * 0.5,
                                height: size.width * 0.5,
                                child: i1 == null
                                    ? Icon(Icons.add)
                                    : Image.file(i1),
                                color: footyColor,
                              ),
                            ),
                            error.length != 0
                                ? SizedBox(
                                    height: 20,
                                  )
                                : Container(),
                            error.length != 0
                                ? Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: Text(
                                      error,
                                      textScaleFactor: 1,
                                      style: GoogleFonts.montserrat(
                                        textStyle: TextStyle(
                                          color: Colors.red,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  )
                                : Container(),
                            SizedBox(
                              height: 40,
                            ),
                            RoundedButton(
                              width: 0.5,
                              ph: 45,
                              text: 'Добавить',
                              press: () async {
                                if (_formKey.currentState.validate()) {
                                  setState(() {
                                    loading = true;
                                  });
                                  String id =
                                      FirebaseAuth.instance.currentUser.uid;
                                  String date = DateTime.now().toString();
                                  if (i1 != null) {
                                    a1 = await FirebaseStorage.instance
                                        .ref('uploads')
                                        .child('$id/writings/$date')
                                        .putFile(i1);
                                  }
                                  if (a1 != null) {
                                    FirebaseFirestore.instance
                                        .collection('writings')
                                        .doc()
                                        .set({
                                      'name': name,
                                      'text': text,
                                      'author':
                                          FirebaseAuth.instance.currentUser.uid,
                                      'images': [
                                        await a1.ref.getDownloadURL(),
                                      ],
                                      'genre': category.toLowerCase(),
                                      'date': DateTime.now(),
                                      'rating': 0,
                                      'users_rated': [],
                                      'reads': 0,
                                      'users_read': [],
                                      'comments': [],
                                    }).catchError((error) {
                                      print('MISTAKE HERE');
                                      print(error);
                                      PushNotificationMessage notification =
                                          PushNotificationMessage(
                                        title: 'Ошибка',
                                        body: 'Неудалось добавить историю',
                                      );
                                      showSimpleNotification(
                                        Container(
                                            child: Text(notification.body)),
                                        position: NotificationPosition.top,
                                        background: Colors.red,
                                      );
                                    });
                                  } else {
                                    FirebaseFirestore.instance
                                        .collection('writings')
                                        .doc()
                                        .set({
                                      'name': name,
                                      'text': text,
                                      'author':
                                          FirebaseAuth.instance.currentUser.uid,
                                      'images': 'No Image',
                                      'genre': category.toLowerCase(),
                                      'date': DateTime.now(),
                                      'rating': 0,
                                      'reads': 0,
                                      'users_read': [],
                                      'users_rated': [],
                                      'comments': [],
                                    }).catchError((error) {
                                      print('MISTAKE HERE');
                                      print(error);
                                      PushNotificationMessage notification =
                                          PushNotificationMessage(
                                        title: 'Ошибка',
                                        body: 'Неудалось добавить историю',
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
                                    title: 'Успех',
                                    body: 'История добавлена',
                                  );
                                  showSimpleNotification(
                                    Container(child: Text(notification.body)),
                                    position: NotificationPosition.top,
                                    background: footyColor,
                                  );
                                  setState(() {
                                    i1 = null;
                                    name = null;
                                    error = '';
                                    category = 'Общее';
                                    text = null;
                                    loading = false;
                                  });
                                }
                              },
                              color: darkPrimaryColor,
                              textColor: footyColor,
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            RoundedButton(
                              width: 0.7,
                              ph: 45,
                              text: 'Сохранить как черновик',
                              press: () async {
                                if (_formKey.currentState.validate()) {
                                  setState(() {
                                    loading = true;
                                  });
                                  String id =
                                      FirebaseAuth.instance.currentUser.uid;
                                  String date = DateTime.now().toString();
                                  if (i1 != null) {
                                    a1 = await FirebaseStorage.instance
                                        .ref('uploads')
                                        .child('$id/writings/$date')
                                        .putFile(i1);
                                  }
                                  if (a1 != null) {
                                    FirebaseFirestore.instance
                                        .collection('users')
                                        .doc(FirebaseAuth
                                            .instance.currentUser.uid)
                                        .update({
                                      'drafts': FieldValue.arrayUnion([
                                        {
                                          'name': name,
                                          'text': text,
                                          'date': DateTime.now(),
                                          'images': [
                                            await a1.ref.getDownloadURL(),
                                          ],
                                          'genre': category.toLowerCase(),
                                        }
                                      ]),
                                      // 'name': name,
                                      // 'text': text,
                                      // 'author':
                                      //     FirebaseAuth.instance.currentUser.uid,
                                      // 'images': [
                                      //   await a1.ref.getDownloadURL(),
                                      // ],
                                      // 'genre': category.toLowerCase(),
                                      // 'date': DateTime.now(),
                                      // 'rating': 0,
                                      // 'users_rated': [],
                                      // 'reads': 0,
                                      // 'users_read': [],
                                      // 'comments': [],
                                    }).catchError((error) {
                                      print('MISTAKE HERE');
                                      print(error);
                                      PushNotificationMessage notification =
                                          PushNotificationMessage(
                                        title: 'Ошибка',
                                        body: 'Неудалось добавить черновик',
                                      );
                                      showSimpleNotification(
                                        Container(
                                            child: Text(notification.body)),
                                        position: NotificationPosition.top,
                                        background: Colors.red,
                                      );
                                    });
                                  } else {
                                    FirebaseFirestore.instance
                                        .collection('users')
                                        .doc(FirebaseAuth
                                            .instance.currentUser.uid)
                                        .update({
                                      'drafts': FieldValue.arrayUnion([
                                        {
                                          'name': name,
                                          'text': text,
                                          'date': DateTime.now(),
                                          'images': 'No Image',
                                          'genre': category.toLowerCase(),
                                        }
                                      ]),
                                      // 'name': name,
                                      // 'text': text,
                                      // 'author':
                                      //     FirebaseAuth.instance.currentUser.uid,
                                      // 'images': 'No Image',
                                      // 'genre': category.toLowerCase(),
                                      // 'date': DateTime.now(),
                                      // 'rating': 0,
                                      // 'reads': 0,
                                      // 'users_read': [],
                                      // 'users_rated': [],
                                      // 'comments': [],
                                    }).catchError((error) {
                                      print('MISTAKE HERE');
                                      print(error);
                                      PushNotificationMessage notification =
                                          PushNotificationMessage(
                                        title: 'Ошибка',
                                        body: 'Неудалось добавить историю',
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
                                    title: 'Успех',
                                    body: 'Черновик добавлен',
                                  );
                                  showSimpleNotification(
                                    Container(child: Text(notification.body)),
                                    position: NotificationPosition.top,
                                    background: footyColor,
                                  );
                                  setState(() {
                                    loading = false;
                                  });
                                }
                              },
                              color: lightPrimaryColor,
                              textColor: whiteColor,
                            ),
                            SizedBox(
                              height: 70,
                            ),
                            Container(
                              padding: EdgeInsets.fromLTRB(
                                  size.width * 0.05, 0, size.width * 0.05, 0),
                              child: Text(
                                'Контент должен соответствовать всем правилам приложения. Вы как автор несете ответственность за выполнение всех условий',
                                textScaleFactor: 1,
                                style: GoogleFonts.montserrat(
                                  textStyle: TextStyle(
                                    color: primaryColor,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w100,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
  }
}
