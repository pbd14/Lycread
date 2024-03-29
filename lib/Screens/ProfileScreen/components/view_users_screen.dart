import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lycread/Screens/ProfileScreen/view_profile_screen.dart';
import 'package:lycread/Screens/loading_screen.dart';
import 'package:lycread/widgets/card.dart';
import 'package:lycread/widgets/slide_right_route_animation.dart';
import '../../../constants.dart';

// ignore: must_be_immutable
class ViewUsersScreen extends StatefulWidget {
  List<dynamic> data;
  String text;
  ViewUsersScreen({Key key, this.data, this.text}) : super(key: key);
  @override
  _ViewUsersScreenState createState() => _ViewUsersScreenState();
}

class _ViewUsersScreenState extends State<ViewUsersScreen> {
  List results = [];
  bool loading = true;
  bool loading1 = false;
  Map names = {};

  String getFnum(int fnum) {
    String fnum1 = '';
    if (fnum > 999999) {
      double numb = fnum / 1000000;
      fnum1 = numb.toStringAsFixed(1) + 'M';
    } else if (fnum > 999) {
      double numb = fnum / 1000;
      fnum1 = numb.toStringAsFixed(1) + 'K';
    } else {
      fnum1 = fnum.toString();
    }
    return fnum1 + ' подписчиков';
  }

  Future<void> prepare() async {
    QuerySnapshot qs = await FirebaseFirestore.instance
        .collection('users')
        .orderBy('followers_num', descending: true)
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
  }

  @override
  void initState() {
    prepare();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? LoadingScreen()
        : Scaffold(
            appBar: AppBar(
              backgroundColor: primaryColor,
              centerTitle: true,
              title: Text(
                widget.text,
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
                                  CupertinoButton(
                                padding: EdgeInsets.zero,
                                onPressed: () {
                                  setState(() {
                                    loading = true;
                                  });
                                  Navigator.push(
                                      context,
                                      SlideRightRoute(
                                        page: VProfileScreen(
                                          data: results[index],
                                        ),
                                      ));
                                  setState(() {
                                    loading = false;
                                  });
                                },
                                child: CardW(
                                  ph: 80,
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: 8,
                                          child: Column(
                                            children: [
                                              results[index].data()[
                                                          'isVerified'] !=
                                                      null
                                                  ? results[index]
                                                          .data()['isVerified']
                                                      ? Center(
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Text(
                                                                results[index]
                                                                        .data()[
                                                                    'name'],
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
                                                                          17,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                  width: 5),
                                                              Icon(
                                                                CupertinoIcons
                                                                    .checkmark_seal_fill,
                                                                color:
                                                                    footyColor,
                                                                size: 17,
                                                              ),
                                                            ],
                                                          ),
                                                        )
                                                      : Text(
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
                                                              fontSize: 17,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                        )
                                                  : Text(
                                                      results[index]
                                                          .data()['name'],
                                                      textScaleFactor: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: GoogleFonts
                                                          .montserrat(
                                                        textStyle: TextStyle(
                                                          color: primaryColor,
                                                          fontSize: 17,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                              SizedBox(
                                                height: 5,
                                              ),
                                              Text(
                                                getFnum(results[index]
                                                    .data()['followers_num']),
                                                textScaleFactor: 1,
                                                style: GoogleFonts.montserrat(
                                                  textStyle: TextStyle(
                                                    color: primaryColor,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w300,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: Container(
                                            width: 30,
                                            height: 30,
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(25.0),
                                              child: results[index]
                                                          .data()['photo'] !=
                                                      null
                                                  ? CachedNetworkImage(
                                                      filterQuality:
                                                          FilterQuality.none,
                                                      fit: BoxFit.cover,
                                                      placeholder:
                                                          (context, url) =>
                                                              Transform.scale(
                                                        scale: 0.8,
                                                        child:
                                                            CircularProgressIndicator(
                                                          strokeWidth: 2.0,
                                                          backgroundColor:
                                                              footyColor,
                                                          valueColor:
                                                              AlwaysStoppedAnimation<
                                                                      Color>(
                                                                  primaryColor),
                                                        ),
                                                      ),
                                                      errorWidget: (context,
                                                              url, error) =>
                                                          Icon(
                                                        Icons.error,
                                                        color: footyColor,
                                                      ),
                                                      imageUrl: results[index]
                                                          .data()['photo'],
                                                    )
                                                  : Image.asset(
                                                      'assets/images/User.png',
                                                      fit: BoxFit.cover,
                                                    ),
                                            ),
                                          ),
                                          // Container(
                                          //   height: 50,
                                          //   width: 50,
                                          //   decoration: ShapeDecoration(
                                          //     shape: CircleBorder(
                                          //       side: BorderSide(
                                          //           width: 1, color: footyColor),
                                          //     ),
                                          //     image: DecorationImage(
                                          //       image: AssetImage(results[index]
                                          //                   .data()['photo'] !=
                                          //               null
                                          //           ? results[index].data()['photo']
                                          //           : 'assets/images/User.png'),
                                          //       fit: BoxFit.cover,
                                          //     ),
                                          //   ),
                                          // ),
                                        ),
                                        SizedBox(width: 15),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : Center(
                              child: Text(
                                'Нет данных',
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
