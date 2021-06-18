import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intro_slider/intro_slider.dart';
import 'package:intro_slider/slide_object.dart';
import 'package:lycread/Screens/SearchScreen/components/1.dart';
import 'package:lycread/Screens/SearchScreen/components/2.dart';
import 'package:lycread/Screens/SearchScreen/components/3.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  List<Slide> slides = [
    Slide(
      title: "Поиск",
      description: "Ищите истории, проекты и авторов",
      pathImage: "assets/images/search_instr1.png",
      backgroundColor: primaryColor,
    ),
    Slide(
      title: "Разделы",
      description:
          "Выберите нужный для себя раздел и введите Имя в поисковую строку",
      pathImage: "assets/images/search_instr2.png",
      backgroundColor: primaryColor,
    ),
  ];
  SharedPreferences prefs;
  bool needInstr = false;

  void manageInstr() async {
    prefs = await SharedPreferences.getInstance();
    if (this.mounted) {
      setState(() {
        needInstr = prefs.getBool('ni_search_screen') ?? true;
      });
    } else {
      needInstr = prefs.getBool('ni_search_screen') ?? true;
    }
  }

  @override
  void initState() {
    manageInstr();
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
              body: needInstr
                  ? Stack(
                      alignment: Alignment.center,
                      children: [
                        TabBarView(
                          children: tbvList,
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
                                prefs.setBool('ni_search_screen', false);
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
                  : TabBarView(
                      children: tbvList,
                    ),
            ),
          );
  }
}
