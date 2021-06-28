import 'dart:async';
import 'dart:ui';
import 'package:animate_do/animate_do.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intro_slider/intro_slider.dart';
import 'package:intro_slider/slide_object.dart';
import 'package:lycread/Screens/ProjectScreen/components/add_project.dart';
import 'package:lycread/Screens/ProjectScreen/components/background.dart';
import 'package:lycread/Screens/ProjectScreen/project_info_screen.dart';
import 'package:lycread/widgets/rounded_button.dart';
import 'package:lycread/widgets/slide_right_route_animation.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  SharedPreferences prefs;
  List<Slide> slides = [
    Slide(
      title: "Проекты",
      description: "Проекты позволяют писать на общие темы командам авторов",
      pathImage: "assets/images/project_instr1.png",
      backgroundColor: primaryColor,
    ),
    Slide(
      title: "Авторы",
      description:
          "У каждого проекта есть несколько авторов, которые могут изменять и писать истории. Но только владелец может добавлять авторов и публиковать истории.",
      pathImage: "assets/images/project_instr2.png",
      backgroundColor: primaryColor,
    ),
    Slide(
      title: "Ветки",
      description:
          "Проекты состоят из веток, которые отвечают за специфические темы",
      pathImage: "assets/images/project_instr3.png",
      backgroundColor: primaryColor,
    ),
    Slide(
      title: "Истории",
      description:
          "В каждой ветке есть истории(опубликованные и неопубликованные).",
      pathImage: "assets/images/project_instr4.png",
      backgroundColor: primaryColor,
    ),
  ];

  String getDate(int millisecondsSinceEpoch) {
    String date = '';
    DateTime d = DateTime.fromMillisecondsSinceEpoch(millisecondsSinceEpoch);
    if (d.year == DateTime.now().year) {
      if (d.month == DateTime.now().month) {
        if (d.day == DateTime.now().day) {
          date = 'сегодня';
        } else {
          int n = DateTime.now().day - d.day;
          switch (n) {
            case 1:
              date = 'вчера';
              break;
            case 2:
              date = 'позавчера';
              break;
            case 3:
              date = n.toString() + ' дня назад';
              break;
            case 4:
              date = n.toString() + ' дня назад';
              break;
            default:
              date = n.toString() + ' дней назад';
          }
        }
      } else {
        int n = DateTime.now().month - d.month;
        switch (n) {
          case 1:
            date = 'месяц назад';
            break;
          case 2:
            date = n.toString() + ' месяца назад';
            break;
          case 3:
            date = n.toString() + ' месяца назад';
            break;
          case 4:
            date = n.toString() + ' месяца назад';
            break;
          default:
            date = n.toString() + ' месяцев назад';
        }
      }
    } else {
      int n = DateTime.now().year - d.year;
      switch (n) {
        case 1:
          date = 'год назад';
          break;
        case 2:
          date = n.toString() + ' года назад';
          break;
        case 3:
          date = n.toString() + ' года назад';
          break;
        case 4:
          date = n.toString() + ' года назад';
          break;
        default:
          date = n.toString() + ' лет назад';
      }
    }
    return date;
  }

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
    manageInstr();
    super.initState();
  }

  Future<void> _refresh() {
    setState(() {
      loading = true;
    });
    projects = [];
    prepare();
    Completer<Null> completer = new Completer<Null>();
    completer.complete();
    return completer.future;
  }

  bool needInstr = false;

  void manageInstr() async {
    prefs = await SharedPreferences.getInstance();
    if (this.mounted) {
      setState(() {
        needInstr = prefs.getBool('ni_project_screen') ?? true;
      });
    } else {
      needInstr = prefs.getBool('ni_project_screen') ?? true;
    }
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return loading
        ? LoadingScreen()
        : RefreshIndicator(
            color: footyColor,
            onRefresh: _refresh,
            child: Scaffold(
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
                actions: [
                  IconButton(
                    color: whiteColor,
                    icon: Icon(
                      CupertinoIcons.arrow_2_circlepath,
                    ),
                    onPressed: () {
                      _refresh();
                    },
                  ),
                ],
              ),
              body: projects.length != 0
                  ? needInstr
                      ? Stack(
                          alignment: Alignment.center,
                          children: [
                            SingleChildScrollView(
                              child: Container(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    for (var project in projects)
                                      projects.length != 0
                                          ? SlideInLeft(
                                              child: Container(
                                                margin: EdgeInsets.all(3),
                                                child: CupertinoButton(
                                                  padding: EdgeInsets.zero,
                                                  onPressed: () {
                                                    setState(() {
                                                      loading = true;
                                                    });
                                                    Navigator.push(
                                                        context,
                                                        SlideRightRoute(
                                                          page:
                                                              ProjectInfoScreen(
                                                            id: project.id,
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
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: Column(
                                                          children: [
                                                            Text(
                                                              project.data()[
                                                                  'name'],
                                                              textScaleFactor:
                                                                  1,
                                                              maxLines: 2,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style: GoogleFonts
                                                                  .montserrat(
                                                                textStyle: TextStyle(
                                                                    color:
                                                                        darkPrimaryColor,
                                                                    fontSize:
                                                                        17,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              ),
                                                            ),
                                                            SizedBox(height: 5),
                                                            Text(
                                                              getDate(project
                                                                  .data()[
                                                                      'last_update']
                                                                  .millisecondsSinceEpoch),
                                                              // 'Update: ' +
                                                              //     DateTime.fromMicrosecondsSinceEpoch(
                                                              //             projects[index]
                                                              //                 .data()[
                                                              //                     'last_update']
                                                              //                 .microsecondsSinceEpoch)
                                                              //         .day
                                                              //         .toString() +
                                                              //     '.' +
                                                              //     DateTime.fromMicrosecondsSinceEpoch(
                                                              //             projects[index]
                                                              //                 .data()[
                                                              //                     'last_update']
                                                              //                 .microsecondsSinceEpoch)
                                                              //         .month
                                                              //         .toString() +
                                                              //     '.' +
                                                              //     DateTime.fromMicrosecondsSinceEpoch(
                                                              //             projects[index]
                                                              //                 .data()[
                                                              //                     'last_update']
                                                              //                 .microsecondsSinceEpoch)
                                                              //         .year
                                                              //         .toString(),
                                                              textScaleFactor:
                                                                  1,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style: GoogleFonts
                                                                  .montserrat(
                                                                textStyle: TextStyle(
                                                                    color:
                                                                        darkPrimaryColor,
                                                                    fontSize:
                                                                        15,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              ),
                                                            ),
                                                          ],
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
                                                  CupertinoIcons
                                                      .plus_square_on_square,
                                                  color: footyColor,
                                                  size: 25,
                                                ),
                                                SizedBox(height: 5),
                                                Text(
                                                  'Добавьте новый проект',
                                                  textScaleFactor: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: GoogleFonts.montserrat(
                                                    textStyle: TextStyle(
                                                        color: darkPrimaryColor,
                                                        fontSize: 20,
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
                                    SizedBox(
                                      height: 10,
                                    )
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.all(15),
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30.0),
                                ),
                                elevation: 10,
                                child: IntroSlider(
                                  slides: slides,
                                  onDonePress: () {
                                    prefs.setBool('ni_project_screen', false);
                                    if (this.mounted) {
                                      setState(() {
                                        needInstr = false;
                                      });
                                    } else {
                                      needInstr = false;
                                    }
                                  },
                                ),
                              ),
                            ),
                          ],
                        )
                      : SingleChildScrollView(
                          child: Container(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                for (var project in projects)
                                  projects.length != 0
                                      ? SlideInLeft(
                                          child: Container(
                                            margin: EdgeInsets.all(3),
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
                                                        id: project.id,
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
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Column(
                                                      children: [
                                                        Text(
                                                          project
                                                              .data()['name'],
                                                          textScaleFactor: 1,
                                                          maxLines: 2,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: GoogleFonts
                                                              .montserrat(
                                                            textStyle: TextStyle(
                                                                color:
                                                                    darkPrimaryColor,
                                                                fontSize: 17,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                        ),
                                                        SizedBox(height: 5),
                                                        Text(
                                                          getDate(project
                                                              .data()[
                                                                  'last_update']
                                                              .millisecondsSinceEpoch),
                                                          // 'Update: ' +
                                                          //     DateTime.fromMicrosecondsSinceEpoch(
                                                          //             projects[index]
                                                          //                 .data()[
                                                          //                     'last_update']
                                                          //                 .microsecondsSinceEpoch)
                                                          //         .day
                                                          //         .toString() +
                                                          //     '.' +
                                                          //     DateTime.fromMicrosecondsSinceEpoch(
                                                          //             projects[index]
                                                          //                 .data()[
                                                          //                     'last_update']
                                                          //                 .microsecondsSinceEpoch)
                                                          //         .month
                                                          //         .toString() +
                                                          //     '.' +
                                                          //     DateTime.fromMicrosecondsSinceEpoch(
                                                          //             projects[index]
                                                          //                 .data()[
                                                          //                     'last_update']
                                                          //                 .microsecondsSinceEpoch)
                                                          //         .year
                                                          //         .toString(),
                                                          textScaleFactor: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: GoogleFonts
                                                              .montserrat(
                                                            textStyle: TextStyle(
                                                                color:
                                                                    darkPrimaryColor,
                                                                fontSize: 15,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                        ),
                                                      ],
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
                                              CupertinoIcons
                                                  .plus_square_on_square,
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
                                SizedBox(
                                  height: 10,
                                )
                              ],
                            ),
                          ),
                        )
                  : Background(
                      child: SingleChildScrollView(
                        child: SlideInUp(
                          child: Container(
                            margin:
                                EdgeInsets.fromLTRB(0, size.height * 0.5, 0, 0),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Откройте океан возможностей',
                                        textScaleFactor: 1,
                                        maxLines: 2,
                                        textAlign: TextAlign.center,
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
                                        'Попробуйте командное авторство с LycTree',
                                        textAlign: TextAlign.center,
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
                                      Container(
                                        height: 30,
                                        child: DefaultTextStyle(
                                          style: const TextStyle(
                                            color: primaryColor,
                                            fontSize: 20,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          child: AnimatedTextKit(
                                            repeatForever: true,
                                            animatedTexts: [
                                              RotateAnimatedText(
                                                'Создавайте проекты',
                                                textAlign: TextAlign.center,
                                                textStyle:
                                                    GoogleFonts.montserrat(
                                                  textStyle: TextStyle(
                                                      color: whiteColor,
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.w500),
                                                ),
                                              ),
                                              RotateAnimatedText(
                                                'Приглашайте авторов',
                                                textAlign: TextAlign.center,
                                                textStyle:
                                                    GoogleFonts.montserrat(
                                                  textStyle: TextStyle(
                                                      color: whiteColor,
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.w500),
                                                ),
                                              ),
                                              RotateAnimatedText(
                                                'Развивайте ветки',
                                                textAlign: TextAlign.center,
                                                textStyle:
                                                    GoogleFonts.montserrat(
                                                  textStyle: TextStyle(
                                                      color: whiteColor,
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.w500),
                                                ),
                                              ),
                                            ],
                                          ),
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
                    ),
            ),
          );
  }
}
