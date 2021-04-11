import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lycread/Screens/ProfileScreen/view_profile_screen.dart';
import 'package:lycread/Screens/WritingScreen/reading_screen.dart';
import 'package:lycread/Screens/loading_screen.dart';
import 'package:lycread/widgets/card.dart';
import 'package:lycread/widgets/rounded_text_input.dart';
import 'package:lycread/widgets/slide_right_route_animation.dart';

import '../../../constants.dart';

class FavouritesScreen extends StatefulWidget {
  List<dynamic> data;
  FavouritesScreen({Key key, this.data}) : super(key: key);
  @override
  _FavouritesScreenState createState() => _FavouritesScreenState();
}

class _FavouritesScreenState extends State<FavouritesScreen> {
  List results = [];
  bool loading = true;
  bool loading1 = false;
  String author = '';
  Map names = {};

  Future<void> prepare() async {
    QuerySnapshot qs = await FirebaseFirestore.instance
        .collection('writings')
        .orderBy('rating', descending: true)
        // .limit(20)
        // .where('id', whereIn: widget.data != null ? widget.data : ['test'])
        .get();
    if (this.mounted) {
      setState(() {
        for (QueryDocumentSnapshot doc in qs.docs) {
          if (widget.data.contains(doc.id)) {
            results.add(doc);
          }
        }
        loading = false;
      });
    } else {
      for (QueryDocumentSnapshot doc in qs.docs) {
        if (widget.data.contains(doc.id)) {
          results.add(doc);
        }
      }
      loading = false;
    }
    for (var res in results) {
      var data = await FirebaseFirestore.instance
          .collection('users')
          .doc(res.data()['author'])
          .get();
      if (this.mounted) {
        setState(() {
          names.addAll({res.data()['author']: data.data()['name']});
        });
      } else {
        names.addAll({res.data()['author']: data.data()['name']});
      }
    }
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
              backgroundColor: primaryColor,
              centerTitle: true,
              title: Text(
                'Избранные',
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
            body: Column(
              children: [
                SizedBox(height: 20),
                Expanded(
                  child: loading1
                      ? LoadingScreen()
                      : results.length != 0
                          ? ListView.builder(
                              padding: EdgeInsets.only(bottom: 10),
                              itemCount: results.length,
                              itemBuilder: (BuildContext context, int index) =>
                                  Container(
                                padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                                child: Card(
                                  elevation: 10,
                                  child: FlatButton(
                                    onPressed: () {
                                      setState(() {
                                        loading = true;
                                      });
                                      Navigator.push(
                                          context,
                                          SlideRightRoute(
                                            page: ReadingScreen(
                                              data: results[index],
                                              author: names[results[index]
                                                  .data()['author']],
                                            ),
                                          ));
                                      setState(() {
                                        loading = false;
                                      });
                                    },
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          width: 10,
                                        ),
                                        results[index].data()['images'] !=
                                                'No Image'
                                            ? Container(
                                                width: size.width * 0.35,
                                                child: FadeInImage.assetNetwork(
                                                  height: 150,
                                                  width: 150,
                                                  placeholder:
                                                      'assets/images/1.png',
                                                  image: results[index]
                                                      .data()['images'][0],
                                                ),
                                              )
                                            : Container(
                                                width: size.width * 0.35,
                                                child: Image.asset(
                                                  'assets/images/1.png',
                                                  height: 150,
                                                  width: 150,
                                                ),
                                              ),
                                        Expanded(
                                          child: Container(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(12.0),
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    child: Column(
                                                      children: [
                                                        Text(
                                                          results[index]
                                                              .data()['name'],
                                                          textScaleFactor: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: GoogleFonts
                                                              .montserrat(
                                                            textStyle:
                                                                TextStyle(
                                                              color:
                                                                  primaryColor,
                                                              fontSize: 25,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          height: 10,
                                                        ),
                                                        Text(
                                                          names[results[index]
                                                                          .data()[
                                                                      'author']] !=
                                                                  null
                                                              ? names[results[
                                                                          index]
                                                                      .data()[
                                                                  'author']]
                                                              : 'Loading',
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          textScaleFactor: 1,
                                                          style: GoogleFonts
                                                              .montserrat(
                                                            textStyle:
                                                                TextStyle(
                                                              color:
                                                                  primaryColor,
                                                              fontSize: 15,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w300,
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          height: 10,
                                                        ),
                                                        Text(
                                                          results[index]
                                                              .data()['genre'],
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          textScaleFactor: 1,
                                                          style: GoogleFonts
                                                              .montserrat(
                                                            textStyle:
                                                                TextStyle(
                                                              color:
                                                                  primaryColor,
                                                              fontSize: 15,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w300,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        Divider(
                                          color: darkPrimaryColor,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : Center(
                              child: Text(
                                'Нет избранных',
                                overflow: TextOverflow.ellipsis,
                                textScaleFactor: 1,
                                style: GoogleFonts.montserrat(
                                  textStyle: TextStyle(
                                    color: lightPrimaryColor,
                                    fontSize: 25,
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                              ),
                            ),
                ),
              ],
            ),
          );
  }
}
