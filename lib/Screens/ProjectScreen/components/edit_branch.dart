import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lycread/Models/PushNotificationMessage.dart';
import 'package:lycread/Screens/ProjectScreen/project_info_screen.dart';
import 'package:lycread/widgets/rounded_button.dart';
import 'package:lycread/widgets/rounded_text_input.dart';
import 'package:lycread/widgets/slide_right_route_animation.dart';
import 'package:overlay_support/overlay_support.dart';
import '../../../constants.dart';
import '../../loading_screen.dart';

// ignore: must_be_immutable
class EditBranchScreen extends StatefulWidget {
  Map branch;
  String id;
  String project_id;
  EditBranchScreen({
    Key key,
    @required this.id,
    @required this.project_id,
    @required this.branch,
  }) : super(key: key);
  @override
  _EditBranchScreenState createState() => _EditBranchScreenState();
}

class _EditBranchScreenState extends State<EditBranchScreen> {
  Size size;
  bool loading = false;
  bool loading1 = false;
  String error = '';
  String name;
  String bio;
  List names = [];
  final _formKey = GlobalKey<FormState>();
  StreamSubscription<QuerySnapshot> subscription;

  @override
  void dispose(){
    subscription.cancel();
    super.dispose();
  }

  @override
  void initState() {
    name = widget.branch['name'];
    bio = widget.branch['bio'];
    super.initState();
    subscription = FirebaseFirestore.instance
        .collection('branches')
        .where('project_id', isEqualTo: widget.project_id)
        .snapshots()
        .listen((event) {
      for (QueryDocumentSnapshot branch in event.docs) {
        if (this.mounted) {
          setState(() {
            names.add(branch.data()['name']);
          });
        } else {
          names.add(branch.data()['name']);
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
                                        'Измените ветку ' +
                                            widget.branch['name'],
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
                                        if (val != widget.branch['name']) {
                                          return "Имя уже занято";
                                        }
                                      }
                                    },
                                    initialValue: widget.branch['name'],
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
                                      initialValue: widget.branch['bio'],
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
                                    text: 'Сохранить',
                                    press: () async {
                                      if (_formKey.currentState.validate()) {
                                        setState(() {
                                          loading = true;
                                        });
                                        FirebaseFirestore.instance
                                            .collection('branches')
                                            .doc(widget.id)
                                            .update({
                                          'name': name.trim(),
                                          'bio': bio,
                                          'last_update': DateTime.now(),
                                        }).catchError((error) {
                                          print('MISTAKE HERE');
                                          print(error);
                                          PushNotificationMessage notification =
                                              PushNotificationMessage(
                                            title: 'Ошибка',
                                            body:
                                                'Неудалось сохранить изменения',
                                          );
                                          showSimpleNotification(
                                            Container(
                                                child: Text(notification.body)),
                                            position: NotificationPosition.top,
                                            background: Colors.red,
                                          );
                                        });
                                        FirebaseFirestore.instance
                                            .collection('projects')
                                            .doc(widget.project_id)
                                            .update({
                                          'branches': FieldValue.arrayUnion(
                                              [widget.id]),
                                          'last_update': DateTime.now(),
                                        });
                                        PushNotificationMessage notification =
                                            PushNotificationMessage(
                                          title: 'Сохранено',
                                          body: 'Ветка изменена',
                                        );
                                        showSimpleNotification(
                                          Container(
                                              child: Text(notification.body)),
                                          position: NotificationPosition.top,
                                          background: footyColor,
                                        );
                                        Navigator.push(
                                            context,
                                            SlideRightRoute(
                                              page: ProjectInfoScreen(
                                                id: widget.project_id,
                                              ),
                                            ));
                                        // Navigator.pop(context);
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
