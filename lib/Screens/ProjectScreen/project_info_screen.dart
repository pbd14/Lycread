import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lycread/Screens/ProfileScreen/view_profile_screen.dart';
import 'package:lycread/Screens/ProjectScreen/components/add_project.dart';
import 'package:lycread/widgets/slide_right_route_animation.dart';
import '../../constants.dart';
import '../loading_screen.dart';
import 'components/add_branch.dart';

class ProjectInfoScreen extends StatefulWidget {
  String id;
  ProjectInfoScreen({
    Key key,
    @required this.id,
  }) : super(key: key);
  @override
  _ProjectInfoScreenState createState() => _ProjectInfoScreenState();
}

class _ProjectInfoScreenState extends State<ProjectInfoScreen> {
  Size size;
  bool loading = true;
  List branches = [];
  List authors = [];
  DocumentSnapshot project;

  Future<void> prepare() async {
    project = await FirebaseFirestore.instance
        .collection('projects')
        .doc(widget.id)
        .get();
    QuerySnapshot authorsSnap = await FirebaseFirestore.instance
        .collection('users')
        .where('id', whereIn: project.data()['authors'])
        .get();
    QuerySnapshot branchesSnap = await FirebaseFirestore.instance
        .collection('branches')
        .where('project_id', isEqualTo: widget.id)
        .get();
    if (this.mounted) {
      setState(() {
        branches = branchesSnap.docs;
        authors = authorsSnap.docs;
        loading = false;
      });
    } else {
      branches = branchesSnap.docs;
      authors = authorsSnap.docs;
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
                project.data()['name'],
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
            body: SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.all(10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      project.data()['name'],
                      textScaleFactor: 1,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.montserrat(
                        textStyle: TextStyle(
                            color: darkPrimaryColor,
                            fontSize: 30,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    Text(
                      project.data()['bio'],
                      textScaleFactor: 1,
                      maxLines: 5,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.montserrat(
                        textStyle: TextStyle(
                            color: darkPrimaryColor,
                            fontSize: 20,
                            fontWeight: FontWeight.w300),
                      ),
                    ),
                    SizedBox(height: 10),
                    Container(
                      margin: EdgeInsets.fromLTRB(0, 0, 0, 10),
                      child: Card(
                        elevation: 10,
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Авторы',
                                textScaleFactor: 1,
                                maxLines: 5,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.montserrat(
                                  textStyle: TextStyle(
                                      color: darkPrimaryColor,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                              for (QueryDocumentSnapshot author in authors)
                                Container(
                                  margin: EdgeInsets.fromLTRB(0, 0, 0, 5),
                                  child: CupertinoButton(
                                    padding: EdgeInsets.zero,
                                    onPressed: () async {
                                      setState(() {
                                        loading = true;
                                      });
                                      var data = await FirebaseFirestore
                                          .instance
                                          .collection('users')
                                          .doc(author.id)
                                          .get();
                                      Navigator.push(
                                        context,
                                        SlideRightRoute(
                                          page: VProfileScreen(
                                            data: data,
                                          ),
                                        ),
                                      );
                                      setState(() {
                                        loading = false;
                                      });
                                    },
                                    child: Row(
                                      children: [
                                        author.data()['photo'] != null
                                            ? author.data()['photo'] !=
                                                    'No Image'
                                                ? Container(
                                                    width: 40,
                                                    height: 40,
                                                    child: ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(25.0),
                                                        child:
                                                            CachedNetworkImage(
                                                          filterQuality:
                                                              FilterQuality
                                                                  .none,
                                                          fit: BoxFit.cover,
                                                          placeholder: (context,
                                                                  url) =>
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
                                                          imageUrl: author
                                                              .data()['photo'],
                                                        )),
                                                  )
                                                : Container(
                                                    width: 40,
                                                    height: 40,
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              25.0),
                                                      child: Image.asset(
                                                        'assets/images/User.png',
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  )
                                            : Container(
                                                width: 40,
                                                height: 40,
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          25.0),
                                                  child: Image.asset(
                                                    'assets/images/User.png',
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                        SizedBox(width: 5),
                                        Text(
                                          author.data()['name'],
                                          textScaleFactor: 1,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.montserrat(
                                            textStyle: TextStyle(
                                                color: darkPrimaryColor,
                                                fontSize: 15,
                                                fontWeight: FontWeight.w300),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Ветки',
                      textScaleFactor: 1,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.montserrat(
                        textStyle: TextStyle(
                            color: darkPrimaryColor,
                            fontSize: 25,
                            fontWeight: FontWeight.w400),
                      ),
                    ),
                    SizedBox(height: 5),
                    for (var branch in branches)
                      branches.length != 0
                          ? Container(
                              margin: EdgeInsets.fromLTRB(5, 0, 5, 5),
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
                                  width: size.width * 0.9,
                                  child: Card(
                                    elevation: 10,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        children: [
                                          Text(
                                            branch.data()['name'],
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
                                                        branch
                                                            .data()[
                                                                'last_update']
                                                            .microsecondsSinceEpoch)
                                                    .day
                                                    .toString() +
                                                '-' +
                                                DateTime.fromMicrosecondsSinceEpoch(
                                                        branch
                                                            .data()[
                                                                'last_update']
                                                            .microsecondsSinceEpoch)
                                                    .month
                                                    .toString() +
                                                '-' +
                                                DateTime.fromMicrosecondsSinceEpoch(
                                                        branch
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
                                  'Добавьте новую ветку',
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
            ),
          );
  }
}
