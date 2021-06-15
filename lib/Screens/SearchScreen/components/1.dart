import 'dart:async';

import 'package:animate_do/animate_do.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart' as cupertino;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lycread/Screens/ProfileScreen/view_profile_screen.dart';
import 'package:lycread/widgets/rounded_text_input.dart';
import 'package:lycread/widgets/slide_right_route_animation.dart';
import '../../../constants.dart';
import '../../loading_screen.dart';

class SearchScreen1 extends StatefulWidget {
  @override
  _SearchScreen1State createState() => _SearchScreen1State();
}

class _SearchScreen1State extends State<SearchScreen1>
    with AutomaticKeepAliveClientMixin<SearchScreen1> {
  @override
  bool get wantKeepAlive => true;
  List results = [];
  bool loading = true;
  bool loading1 = false;
  Size size;
  QuerySnapshot all_users;

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

  Future<void> getUsers() async {
    all_users = await FirebaseFirestore.instance.collection('users').get();
  }

  Future<void> prepare() async {
    QuerySnapshot qs = await FirebaseFirestore.instance
        .collection('users')
        .orderBy('followers_num', descending: true)
        .limit(20)
        .get();
    if (this.mounted) {
      setState(() {
        results = qs.docs;
        loading = false;
      });
    } else {
      results = qs.docs;
      loading = false;
    }
  }

  Future<void> search(String st) async {
    setState(() {
      loading1 = true;
    });
    setState(() {
      List preresults = [];
      for (var doc in all_users.docs) {
        if (doc.data()['name'].toLowerCase().contains(st.toLowerCase())) {
          preresults.add(doc);
        }
      }
      results = preresults;
      loading1 = false;
      preresults = [];
    });
  }

  @override
  void initState() {
    getUsers();
    prepare();
    super.initState();
  }

  Future<void> _refresh() {
    setState(() {
      loading = true;
      loading1 = false;
    });
    results = [];
    getUsers();
    prepare();
    Completer<Null> completer = new Completer<Null>();
    completer.complete();
    return completer.future;
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
              body: Column(
                children: [
                  SizedBox(height: 5),
                  Center(
                    child: RoundedTextInput(
                      validator: (val) =>
                          val.length > 1 ? null : 'Минимум 2 символов',
                      hintText: "Имя",
                      type: TextInputType.text,
                      height: 80,
                      onChanged: (value) {
                        value != null
                            ? value.length != 0
                                ? search(value)
                                : prepare()
                            : prepare();
                      },
                    ),
                  ),
                  SizedBox(height: 10),
                  Expanded(
                    child: loading1
                        ? LoadingScreen()
                        : ListView.builder(
                            itemCount: results.length,
                            itemBuilder: (BuildContext context, int index) =>
                                FadeInLeft(
                              child: Container(
                                height: 80,
                                margin: EdgeInsets.symmetric(horizontal: 20.0),
                                child: cupertino.CupertinoButton(
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
                                  child: Card(
                                    elevation: 10,
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
                                                    ? results[index].data()[
                                                            'isVerified']
                                                        ? Row(
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
                                                          )
                                                        : Text(
                                                            results[index]
                                                                .data()['name'],
                                                            textScaleFactor: 1,
                                                            overflow:
                                                                TextOverflow
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
                                                        overflow: TextOverflow
                                                            .ellipsis,
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
                                                      fontWeight:
                                                          FontWeight.w300,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            width: 40,
                                            height: 40,
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
                                          SizedBox(width: 15),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          );
  }
}
