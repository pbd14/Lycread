import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lycread/Screens/ProjectScreen/components/add_project.dart';
import 'package:lycread/Screens/ProjectScreen/components/background.dart';
import 'package:lycread/Screens/ProjectScreen/project_info_screen.dart';
import 'package:lycread/widgets/rounded_button.dart';
import 'package:lycread/widgets/slide_right_route_animation.dart';
import '../../constants.dart';
import '../loading_screen.dart';

class ProjectScreen extends StatefulWidget {
  @override
  _ProjectScreenState createState() => _ProjectScreenState();
}

class _ProjectScreenState extends State<ProjectScreen> {
  Size size;
  bool loading = true;
  List projects = [];

  Future<void> prepare() async {
    QuerySnapshot projectsSnap = await FirebaseFirestore.instance
        .collection('projects')
        .where('authors', arrayContains: FirebaseAuth.instance.currentUser.uid)
        .get();
    if (this.mounted) {
      setState(() {
        projects = projectsSnap.docs;
        loading = false;
      });
    } else {
      projects = projectsSnap.docs;
      loading = false;
    }
  }

  @override
  void initState() {
    prepare();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return loading
        ? LoadingScreen()
        : Scaffold(
            appBar: AppBar(
              backgroundColor: primaryColor,
              centerTitle: true,
              title: Text(
                'Projects',
                overflow: TextOverflow.ellipsis,
                textScaleFactor: 1,
                style: GoogleFonts.montserrat(
                  textStyle: TextStyle(
                    color: whiteColor,
                    fontSize: 20,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
            ),
            body: projects.length != 0
                ? Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        projects.length != 0
                            ? Expanded(
                                child: ListView.builder(
                                  itemCount: projects.length,
                                  itemBuilder:
                                      (BuildContext context, int index) =>
                                          Container(
                                    margin: EdgeInsets.all(10),
                                    child: CupertinoButton(
                                      padding: EdgeInsets.zero,
                                      onPressed: () {
                                        setState(() {
                                          loading = true;
                                        });
                                        Navigator.push(
                                            context,
                                            SlideRightRoute(
                                              page: ProjectInfoScreen(
                                                id: projects[index].id,
                                              ),
                                            ));
                                        setState(() {
                                          loading = false;
                                        });
                                      },
                                      child: Container(
                                        width: size.width * 0.9,
                                        child: Card(
                                          elevation: 10,
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Column(
                                              children: [
                                                Text(
                                                  projects[index]
                                                      .data()['name'],
                                                  textScaleFactor: 1,
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: GoogleFonts.montserrat(
                                                    textStyle: TextStyle(
                                                        color: darkPrimaryColor,
                                                        fontSize: 17,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                                SizedBox(height: 5),
                                                Text(
                                                  'Update: ' +
                                                      DateTime.fromMicrosecondsSinceEpoch(
                                                              projects[index]
                                                                  .data()[
                                                                      'last_update']
                                                                  .microsecondsSinceEpoch)
                                                          .day
                                                          .toString() +
                                                      '.' +
                                                      DateTime.fromMicrosecondsSinceEpoch(
                                                              projects[index]
                                                                  .data()[
                                                                      'last_update']
                                                                  .microsecondsSinceEpoch)
                                                          .month
                                                          .toString() +
                                                      '.' +
                                                      DateTime.fromMicrosecondsSinceEpoch(
                                                              projects[index]
                                                                  .data()[
                                                                      'last_update']
                                                                  .microsecondsSinceEpoch)
                                                          .year
                                                          .toString(),
                                                  textScaleFactor: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: GoogleFonts.montserrat(
                                                    textStyle: TextStyle(
                                                        color: darkPrimaryColor,
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : Container(),
                        Center(
                          child: CupertinoButton(
                            padding: EdgeInsets.zero,
                            onPressed: () {
                              setState(() {
                                loading = true;
                              });
                              Navigator.push(
                                  context,
                                  SlideRightRoute(
                                    page: AddProjectScreen(),
                                  ));
                              setState(() {
                                loading = false;
                              });
                            },
                            child: Container(
                              width: size.width * 0.8,
                              padding: EdgeInsets.all(15),
                              child: Card(
                                elevation: 0,
                                margin: EdgeInsets.all(15),
                                child: Column(
                                  children: [
                                    Icon(
                                      CupertinoIcons.plus_square_on_square,
                                      color: footyColor,
                                      size: 25,
                                    ),
                                    SizedBox(height: 5),
                                    Text(
                                      'Добавьте новый проект',
                                      textScaleFactor: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.montserrat(
                                        textStyle: TextStyle(
                                            color: darkPrimaryColor,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        )
                      ],
                    ),
                  )
                : Background(
                    child: SingleChildScrollView(
                      child: Container(
                        margin: EdgeInsets.fromLTRB(0, size.width, 0, 0),
                        color: Color.fromRGBO(0, 0, 0, 0.01),
                        padding: EdgeInsets.all(20),
                        child: ClipRRect(
                          child: BackdropFilter(
                            filter: ImageFilter.blur(
                              sigmaX: 6.0,
                              sigmaY: 6.0,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Откройте океан возможностей',
                                    textScaleFactor: 1,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.montserrat(
                                      textStyle: TextStyle(
                                          color: whiteColor,
                                          fontSize: 25,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    'Попробуйте командное авторство с LycHub',
                                    maxLines: 2,
                                    textScaleFactor: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.montserrat(
                                      textStyle: TextStyle(
                                          color: whiteColor,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w300),
                                    ),
                                  ),
                                  SizedBox(height: 20),
                                  Text(
                                    '• Создавайте проекты',
                                    textScaleFactor: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.montserrat(
                                      textStyle: TextStyle(
                                          color: whiteColor,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w300),
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    '• Приглашайте авторов',
                                    textScaleFactor: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.montserrat(
                                      textStyle: TextStyle(
                                          color: whiteColor,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w300),
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    '• Развивайте ветки',
                                    textScaleFactor: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.montserrat(
                                      textStyle: TextStyle(
                                          color: whiteColor,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w300),
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Align(
                                    alignment: Alignment.bottomCenter,
                                    child: RoundedButton(
                                      width: 0.5,
                                      ph: 45,
                                      text: 'Начать',
                                      press: () {
                                        setState(() {
                                          loading = true;
                                        });
                                        Navigator.push(
                                            context,
                                            SlideRightRoute(
                                              page: AddProjectScreen(),
                                            ));
                                        setState(() {
                                          loading = false;
                                        });
                                      },
                                      color: footyColor,
                                      textColor: whiteColor,
                                    ),
                                  ),
                                  SizedBox(height: 50),
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
