import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lycread/Screens/ProfileScreen/view_profile_screen.dart';
import 'package:lycread/Screens/loading_screen.dart';
import 'package:lycread/widgets/card.dart';
import 'package:lycread/widgets/rounded_text_input.dart';
import 'package:lycread/widgets/slide_right_route_animation.dart';

import '../../../constants.dart';

class SearchScreenG extends StatefulWidget {
  String data;
  SearchScreenG({Key key, this.data}) : super(key: key);
  @override
  _SearchScreenGState createState() => _SearchScreenGState();
}

class _SearchScreenGState extends State<SearchScreenG> {
  List results = [];
  bool loading = true;
  bool loading1 = false;
  String author = '';
  Map names = {};

  Future<void> prepare() async {
    QuerySnapshot qs = await FirebaseFirestore.instance
        .collection('writings')
        // .orderBy('rating', descending: true)
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
                          itemBuilder: (BuildContext context, int index) => Row(
                            children: [
                              SizedBox(
                                width: 10,
                              ),
                              results[index].data()['images'] != 'No Image'
                                  ? Container(
                                      width: size.width * 0.35,
                                      child: FadeInImage.assetNetwork(
                                        height: 150,
                                        width: 150,
                                        placeholder: 'assets/images/1.png',
                                        image: results[index].data()['images']
                                            [0],
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
                                    padding: const EdgeInsets.all(12.0),
                                    child: Row(
                                      children: [
                                        Expanded(
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
                                                names[results[index].data()[
                                                            'author']] !=
                                                        null
                                                    ? names[results[index]
                                                        .data()['author']]
                                                    : 'Loading',
                                                overflow: TextOverflow.ellipsis,
                                                textScaleFactor: 1,
                                                style: GoogleFonts.montserrat(
                                                  textStyle: TextStyle(
                                                    color: primaryColor,
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w300,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              Text(
                                                results[index].data()['genre'],
                                                overflow: TextOverflow.ellipsis,
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
              ],
            ),
          );
  }
}
