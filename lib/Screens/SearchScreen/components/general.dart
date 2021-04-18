import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lycread/Screens/WritingScreen/reading_screen.dart';
import 'package:lycread/Screens/loading_screen.dart';
import 'package:lycread/widgets/rounded_text_input.dart';
import 'package:lycread/widgets/slide_right_route_animation.dart';

import '../../../constants.dart';

class SearchScreenG extends StatefulWidget {
  String data;
  SearchScreenG({Key key, this.data}) : super(key: key);
  @override
  _SearchScreenGState createState() => _SearchScreenGState();
}

class _SearchScreenGState extends State<SearchScreenG>
    with AutomaticKeepAliveClientMixin<SearchScreenG> {
  @override
  bool get wantKeepAlive => true;
  List results = [];
  bool loading = true;
  bool loading1 = false;
  String author = '';
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
    return fnum1 + ' просмотров';
  }

  String getDate(int seconds) {
    String date = '';
    DateTime d = DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
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
    QuerySnapshot qs = await FirebaseFirestore.instance
        .collection('writings')
        .orderBy('rating', descending: true)
        .where('genre', isEqualTo: widget.data.toLowerCase())
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

  Future<void> search(String st) async {
    setState(() {
      loading1 = true;
    });
    QuerySnapshot qs = await FirebaseFirestore.instance
        .collection('writings')
        // .orderBy('rating', descending: true)
        .where('genre', isEqualTo: widget.data.toLowerCase())
        .limit(20)
        .get();
    setState(() {
      List preresults = [];
      for (var doc in qs.docs) {
        if (doc.data()['name'].toLowerCase().contains(st.toLowerCase())) {
          preresults.add(doc);
        }
      }
      results = preresults;
      loading1 = false;
      preresults = [];
    });
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
            body: Column(
              children: [
                SizedBox(height: 5),
                Center(
                  child: RoundedTextInput(
                    validator: (val) =>
                        val.length > 1 ? null : 'Минимум 2 символов',
                    hintText: "Название",
                    type: TextInputType.text,
                    height: 100,
                    onChanged: (value) {
                      value != null
                          ? value.length != 0
                              ? search(value)
                              : prepare()
                          : prepare();
                    },
                  ),
                ),
                SizedBox(height: 20),
                Expanded(
                  child: loading1
                      ? LoadingScreen()
                      : ListView.builder(
                          itemCount: results.length,
                          itemBuilder: (BuildContext context, int index) =>
                              Container(
                            padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                            child: Card(
                              margin: EdgeInsets.fromLTRB(10, 3, 10, 3),
                              elevation: 10,
                              child: TextButton(
                                onPressed: () {
                                  setState(() {
                                    loading = true;
                                  });
                                  Navigator.push(
                                      context,
                                      SlideRightRoute(
                                        page: ReadingScreen(
                                          data: results[index],
                                          author: names[
                                              results[index].data()['author']],
                                        ),
                                      ));
                                  setState(() {
                                    loading = false;
                                  });
                                },
                                child: Row(
                                  children: [
                                    results[index].data()['images'] !=
                                            'No Image'
                                        ? Container(
                                            width: size.width * 0.2,
                                            height: size.width * 0.2,
                                            child: CachedNetworkImage(
                                              filterQuality: FilterQuality.none,
                                              height: 100,
                                              width: 100,
                                              placeholder: (context, url) =>
                                                  Transform.scale(
                                                scale: 0.8,
                                                child:
                                                    CircularProgressIndicator(
                                                  strokeWidth: 2.0,
                                                  backgroundColor: footyColor,
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                          Color>(primaryColor),
                                                ),
                                              ),
                                              errorWidget:
                                                  (context, url, error) => Icon(
                                                Icons.error,
                                                color: footyColor,
                                              ),
                                              imageUrl: results[index]
                                                  .data()['images'][0],
                                            ),
                                          )
                                        : Container(),
                                    Expanded(
                                      child: Container(
                                        child: Padding(
                                          padding: const EdgeInsets.all(12.0),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  children: [
                                                    Text(
                                                      results[index]
                                                          .data()['name'],
                                                      textScaleFactor: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: GoogleFonts
                                                          .montserrat(
                                                        textStyle: TextStyle(
                                                          color: primaryColor,
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      height: 7,
                                                    ),
                                                    Text(
                                                      names[results[index]
                                                                      .data()[
                                                                  'author']] !=
                                                              null
                                                          ? names[results[index]
                                                              .data()['author']]
                                                          : 'Loading',
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      textScaleFactor: 1,
                                                      style: GoogleFonts
                                                          .montserrat(
                                                        textStyle: TextStyle(
                                                          color: primaryColor,
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.w300,
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      height: 7,
                                                    ),
                                                    Text(
                                                      results[index].data()[
                                                                  'reads'] !=
                                                              null
                                                          ? results[index]
                                                                      .data()[
                                                                  'genre'] +
                                                              ' | ' +
                                                              getFnum(results[
                                                                          index]
                                                                      .data()[
                                                                  'reads'])
                                                          : results[index]
                                                              .data()['genre'],
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      textScaleFactor: 1,
                                                      style: GoogleFonts
                                                          .montserrat(
                                                        textStyle: TextStyle(
                                                          color: primaryColor,
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.bold,
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
                                    Align(
                                      alignment: Alignment.bottomRight,
                                      child: Text(
                                        getDate(results[index]
                                            .data()['date']
                                            .seconds),
                                        textScaleFactor: 1,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.montserrat(
                                          textStyle: TextStyle(
                                            color: primaryColor,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
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
                ),
              ],
            ),
          );
  }
}
