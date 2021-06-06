import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lycread/Screens/ProjectScreen/components/add_project.dart';
import 'package:lycread/widgets/slide_right_route_animation.dart';

import '../../constants.dart';
import '../loading_screen.dart';
import 'components/add_branch.dart';

class BranchInfoScreen extends StatefulWidget {
  String id;
  BranchInfoScreen({
    Key key,
    @required this.id,
  }) : super(key: key);
  @override
  _BranchInfoScreenState createState() => _BranchInfoScreenState();
}

class _BranchInfoScreenState extends State<BranchInfoScreen> {
  Size size;
  bool loading = true;
  List branches = [];

  Future<void> prepare() async {
    QuerySnapshot branchesSnap = await FirebaseFirestore.instance
        .collection('branches')
        .where('project_id', isEqualTo: widget.id)
        .get();
    if (this.mounted) {
      setState(() {
        branches = branchesSnap.docs;
        loading = false;
      });
    } else {
      branches = branchesSnap.docs;
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
    size = MediaQuery.of(context).size;
    return loading
        ? LoadingScreen()
        : Scaffold(
            appBar: AppBar(
              backgroundColor: primaryColor,
              centerTitle: true,
              title: Text(
                'Projects',
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
            body: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  branches.length != 0
                      ? Expanded(
                          child: ListView.builder(
                            itemCount: branches.length,
                            itemBuilder: (BuildContext context, int index) =>
                                Container(
                              margin: EdgeInsets.all(10),
                              child: CupertinoButton(
                                padding: EdgeInsets.zero,
                                onPressed: () {
                                  setState(() {
                                    loading = true;
                                  });
                                  Navigator.push(
                                      context,
                                      SlideRightRoute(
                                        page: AddProjectScreen(),
                                      ));
                                  setState(() {
                                    loading = false;
                                  });
                                },
                                child: Container(
                                  width: size.width * 0.8,
                                  child: Card(
                                    elevation: 10,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        children: [
                                          Text(
                                            branches[index].data()['name'],
                                            textScaleFactor: 1,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.montserrat(
                                              textStyle: TextStyle(
                                                  color: darkPrimaryColor,
                                                  fontSize: 17,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          SizedBox(height: 5),
                                          Text(
                                            'Update: ' +
                                                DateTime.fromMicrosecondsSinceEpoch(
                                                        branches[index]
                                                            .data()[
                                                                'last_update']
                                                            .microsecondsSinceEpoch)
                                                    .day
                                                    .toString() +
                                                '-' +
                                                DateTime.fromMicrosecondsSinceEpoch(
                                                        branches[index]
                                                            .data()[
                                                                'last_update']
                                                            .microsecondsSinceEpoch)
                                                    .month
                                                    .toString() +
                                                '-' +
                                                DateTime.fromMicrosecondsSinceEpoch(
                                                        branches[index]
                                                            .data()[
                                                                'last_update']
                                                            .microsecondsSinceEpoch)
                                                    .year
                                                    .toString(),
                                            textScaleFactor: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.montserrat(
                                              textStyle: TextStyle(
                                                  color: darkPrimaryColor,
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                      : Container(),
                  Center(
                    child: CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        setState(() {
                          loading = true;
                        });
                        Navigator.push(
                            context,
                            SlideRightRoute(
                              page: AddBranchScreen(
                                id: widget.id,
                              ),
                            ));
                        setState(() {
                          loading = false;
                        });
                      },
                      child: Container(
                        width: size.width * 0.8,
                        padding: EdgeInsets.all(15),
                        child: Card(
                          elevation: 0,
                          margin: EdgeInsets.all(15),
                          child: Column(
                            children: [
                              Icon(
                                CupertinoIcons.plus_square_on_square,
                                color: footyColor,
                                size: 25,
                              ),
                              SizedBox(height: 5),
                              Text(
                                'Добавьте новую суб-ветку',
                                textScaleFactor: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.montserrat(
                                  textStyle: TextStyle(
                                      color: darkPrimaryColor,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  )
                ],
              ),
            ),
          );
  }
}
