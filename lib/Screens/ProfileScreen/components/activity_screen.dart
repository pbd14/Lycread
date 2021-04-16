import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lycread/Screens/loading_screen.dart';
import 'package:lycread/widgets/card.dart';

import '../../../constants.dart';

class ActivityScreen extends StatefulWidget {
  @override
  _ActivityScreenState createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  List results = [];
  List results1 = [];
  List update = [];
  bool loading = true;
  String author = '';
  Map names = {};
  Map names1 = {};

  Future<void> prepare() async {
    DocumentSnapshot qs = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser.uid)
        .get();
    if (this.mounted) {
      setState(() {
        for (var doc in qs.data()['actions']) {
          if (!doc['seen']) {
            results.add(doc);
          } else {
            results1.add(doc);
          }
        }
        loading = false;
      });
    } else {
      for (var doc in qs.data()['actions']) {
        if (!doc['seen']) {
          results.add(doc);
        } else {
          results1.add(doc);
        }
      }
      loading = false;
    }
    for (var res in results) {
      var data = await FirebaseFirestore.instance
          .collection('users')
          .doc(res['author'])
          .get();
      if (this.mounted) {
        setState(() {
          names.addAll({res['author']: data.data()['photo']});
        });
      } else {
        names.addAll({res['author']: data.data()['photo']});
      }
    }
    for (var res in results1) {
      var data = await FirebaseFirestore.instance
          .collection('users')
          .doc(res['author'])
          .get();
      if (this.mounted) {
        setState(() {
          names1.addAll({res['author']: data.data()['photo']});
        });
      } else {
        names1.addAll({res['author']: data.data()['photo']});
      }
    }

    for (var i in qs.data()['actions']) {
      if (i['seen']) {
        update.add(i);
      } else {
        i['seen'] = true;
        update.add(i);
      }
    }
    FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser.uid)
        .update({
      'actions': update,
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
            appBar: AppBar(
              backgroundColor: whiteColor,
              centerTitle: true,
              title: Text(
                'Активность',
                overflow: TextOverflow.ellipsis,
                textScaleFactor: 1,
                style: GoogleFonts.montserrat(
                  textStyle: TextStyle(
                    color: primaryColor,
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            body: Column(
              children: [
                SizedBox(height: 20),
                results.length != 0
                    ? Expanded(
                        child: Column(
                          children: [
                            Center(
                              child: Text(
                                'Новыe события',
                                overflow: TextOverflow.ellipsis,
                                textScaleFactor: 1,
                                style: GoogleFonts.montserrat(
                                  textStyle: TextStyle(
                                    color: primaryColor,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 10),
                            Expanded(
                              child: ListView.builder(
                                padding: EdgeInsets.only(bottom: 10),
                                itemCount: results.length,
                                itemBuilder:
                                    (BuildContext context, int index) =>
                                        FlatButton(
                                  onPressed: () {
                                    setState(() {
                                      loading = true;
                                    });
                                    // Navigator.push(
                                    //   context,
                                    //   SlideRightRoute(
                                    //     page: ServiceScreen(
                                    //       data: service,
                                    //       serviceId: widget.data['services']
                                    //           .indexOf(service),
                                    //       placeId: widget.data['id'],
                                    //     ),
                                    //   ),
                                    // );
                                    setState(() {
                                      loading = false;
                                    });
                                  },
                                  child: Container(
                                    child: CardW(
                                      ph: 105,
                                      child: Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              flex: 8,
                                              child: Column(
                                                children: [
                                                  Text(
                                                    results[results.length -
                                                        1 -
                                                        index]['type'],
                                                    textScaleFactor: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style:
                                                        GoogleFonts.montserrat(
                                                      textStyle: TextStyle(
                                                        color: primaryColor,
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 5,
                                                  ),
                                                  Text(
                                                    results[results.length -
                                                        1 -
                                                        index]['text'],
                                                    textScaleFactor: 1,
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style:
                                                        GoogleFonts.montserrat(
                                                      textStyle: TextStyle(
                                                        color: primaryColor,
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.w300,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Align(
                                              alignment: Alignment.centerRight,
                                              child: Container(
                                                width: 40,
                                                height: 40,
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          25.0),
                                                  child: names[results[results
                                                                      .length -
                                                                  1 -
                                                                  index]
                                                              ['author']] !=
                                                          null
                                                      ? FadeInImage
                                                          .assetNetwork(
                                                          fit: BoxFit.cover,
                                                          placeholder:
                                                              'assets/images/User.png',
                                                          image: names[results[
                                                                  results.length -
                                                                      1 -
                                                                      index]
                                                              ['author']],
                                                        )
                                                      : Image.asset(
                                                          'assets/images/User.png',
                                                          fit: BoxFit.cover,
                                                        ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 15),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : Container(),
                
                Divider(),
                results1.length != 0
                    ? Expanded(
                        child: Column(
                          children: [
                            Center(
                              child: Text(
                                'Старые события',
                                overflow: TextOverflow.ellipsis,
                                textScaleFactor: 1,
                                style: GoogleFonts.montserrat(
                                  textStyle: TextStyle(
                                    color: primaryColor,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 10),
                            Expanded(
                              child: ListView.builder(
                                padding: EdgeInsets.only(bottom: 10),
                                itemCount: results1.length,
                                itemBuilder:
                                    (BuildContext context, int index) =>
                                        FlatButton(
                                  onPressed: () {
                                    setState(() {
                                      loading = true;
                                    });
                                    // Navigator.push(
                                    //   context,
                                    //   SlideRightRoute(
                                    //     page: ServiceScreen(
                                    //       data: service,
                                    //       serviceId: widget.data['services']
                                    //           .indexOf(service),
                                    //       placeId: widget.data['id'],
                                    //     ),
                                    //   ),
                                    // );
                                    setState(() {
                                      loading = false;
                                    });
                                  },
                                  child: Container(
                                    child: CardW(
                                      ph: 105,
                                      child: Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              flex: 8,
                                              child: Column(
                                                children: [
                                                  Text(
                                                    results1[results1.length -
                                                        1 -
                                                        index]['type'],
                                                    textScaleFactor: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style:
                                                        GoogleFonts.montserrat(
                                                      textStyle: TextStyle(
                                                        color: primaryColor,
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 5,
                                                  ),
                                                  Text(
                                                    results1[results1.length -
                                                        1 -
                                                        index]['text'],
                                                    textScaleFactor: 1,
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style:
                                                        GoogleFonts.montserrat(
                                                      textStyle: TextStyle(
                                                        color: primaryColor,
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.w300,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Align(
                                              alignment: Alignment.centerRight,
                                              child: Container(
                                                width: 40,
                                                height: 40,
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          25.0),
                                                  child: names[results1[results1
                                                                      .length -
                                                                  1 -
                                                                  index]
                                                              ['author']] !=
                                                          null
                                                      ? FadeInImage
                                                          .assetNetwork(
                                                          fit: BoxFit.cover,
                                                          placeholder:
                                                              'assets/images/User.png',
                                                          image: names[results1[
                                                                  results1.length -
                                                                      1 -
                                                                      index]
                                                              ['author']],
                                                        )
                                                      : Image.asset(
                                                          'assets/images/User.png',
                                                          fit: BoxFit.cover,
                                                        ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 15),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 5),
                          ],
                        ),
                      )
                    : Container(),
              ],
            ),
          );
  }
}