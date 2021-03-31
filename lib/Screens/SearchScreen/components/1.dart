import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lycread/Screens/ProfileScreen/view_profile_screen.dart';
import 'package:lycread/widgets/card.dart';
import 'package:lycread/widgets/rounded_text_input.dart';
import 'package:lycread/widgets/slide_right_route_animation.dart';
import '../../../constants.dart';
import '../../loading_screen.dart';

class SearchScreen1 extends StatefulWidget {
  @override
  _SearchScreen1State createState() => _SearchScreen1State();
}

class _SearchScreen1State extends State<SearchScreen1> {
  List results = [];
  bool loading = true;
  bool loading1 = false;

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
    QuerySnapshot qs =
        await FirebaseFirestore.instance.collection('users').limit(20).get();
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
            body: Column(
              children: [
                SizedBox(height: 5),
                Center(
                  child: RoundedTextInput(
                    validator: (val) =>
                        val.length > 1 ? null : 'Минимум 2 символов',
                    hintText: "Имя",
                    type: TextInputType.text,
                    length: 30,
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
                                    Column(
                                      children: [
                                        Text(
                                          results[index].data()['name'],
                                          textScaleFactor: 1,
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
                                          results[index]
                                                  .data()['followers_num']
                                                  .toString() +
                                              ' подписчиков',
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
                                    )
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
