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
    Size size = MediaQuery.of(context).size;
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
                                  FlatButton(
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
                                  ph: 125,
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: 8,
                                          child: Column(
                                            children: [
                                              Text(
                                                results[index].data()['name'],
                                                textScaleFactor: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: GoogleFonts.montserrat(
                                                  textStyle: TextStyle(
                                                    color: primaryColor,
                                                    fontSize: 25,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              Text(
                                                getFnum(results[index]
                                                    .data()['followers_num']),
                                                textScaleFactor: 1,
                                                style: GoogleFonts.montserrat(
                                                  textStyle: TextStyle(
                                                    color: primaryColor,
                                                    fontSize: 15,
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
                                            width: 50,
                                            height: 50,
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(25.0),
                                              child: results[index]
                                                          .data()['photo'] !=
                                                      null
                                                  ? FadeInImage.assetNetwork(
                                                      fit: BoxFit.cover,
                                                      placeholder:
                                                          'assets/images/User.png',
                                                      image: results[index]
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
