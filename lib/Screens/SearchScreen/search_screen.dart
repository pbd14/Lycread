import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lycread/Screens/SearchScreen/components/1.dart';
import 'package:lycread/Screens/SearchScreen/components/2.dart';
import 'package:lycread/Screens/SearchScreen/components/3.dart';
import '../../constants.dart';
import '../loading_screen.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  bool loading = false;
  List<Widget> tbvList = [
    SearchScreen1(),
    SecondScreen(),
    ThirdScreen(),
  ];
  List<Widget> tabs = [
    Tab(
      child: Text(
        'Писатели',
        textScaleFactor: 1,
        style: GoogleFonts.montserrat(
          textStyle: TextStyle(
              color: whiteColor, fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
    ),
    Tab(
      child: Text(
        'Истории',
        textScaleFactor: 1,
        style: GoogleFonts.montserrat(
          textStyle: TextStyle(
              color: whiteColor, fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
    ),
    Tab(
      child: Text(
        'Проекты',
        textScaleFactor: 1,
        style: GoogleFonts.montserrat(
          textStyle: TextStyle(
              color: whiteColor, fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
    ),
  ];

  // Future<void> prepare() async {
  //   await FirebaseFirestore.instance
  //       .collection('appData')
  //       .doc('LycRead')
  //       .get()
  //       .then((dc) {
  //     if (this.mounted) {
  //       setState(() {
  //         categs = dc.data()['genres'];
  //         for (String cat in categs) {
  //           tabs.add(
  //             Tab(
  //               child: Text(
  //                 cat,
  //                 textScaleFactor: 1,
  //                 style: GoogleFonts.montserrat(
  //                   textStyle: TextStyle(
  //                       color: whiteColor,
  //                       fontWeight: FontWeight.bold,
  //                       fontSize: 20),
  //                 ),
  //               ),
  //             ),
  //           );
  //           tbvList.add(
  //             SearchScreenG(
  //               data: cat,
  //             ),
  //           );
  //         }
  //         loading = false;
  //       });
  //     } else {
  //       categs = dc.data()['genres'];
  //       for (String cat in categs) {
  //         tabs.add(
  //           Tab(
  //             child: Text(
  //               cat,
  //               textScaleFactor: 1,
  //               style: GoogleFonts.montserrat(
  //                 textStyle: TextStyle(
  //                     color: whiteColor,
  //                     fontWeight: FontWeight.bold,
  //                     fontSize: 20),
  //               ),
  //             ),
  //           ),
  //         );
  //         tbvList.add(
  //           SearchScreenG(
  //             data: cat,
  //           ),
  //         );
  //       }
  //       loading = false;
  //     }
  //   });
  // }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return loading
        ? LoadingScreen()
        : DefaultTabController(
            length: 3,
            child: Scaffold(
              backgroundColor: whiteColor,
              appBar: AppBar(
                automaticallyImplyLeading: false,
                toolbarHeight: size.width * 0.17,
                backgroundColor: primaryColor,
                centerTitle: true,
                title: TabBar(
                  isScrollable: true,
                  indicatorColor: whiteColor,
                  tabs: tabs,
                ),
              ),
              body: TabBarView(
                children: tbvList,
              ),
            ),
          );
  }
}
