import 'dart:async';

import 'package:animate_do/animate_do.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lycread/Models/PushNotificationMessage.dart';
import 'package:lycread/Screens/ProfileScreen/view_profile_screen.dart';
import 'package:lycread/Screens/ProjectScreen/branch_info_screen.dart';
import 'package:lycread/Screens/ProjectScreen/components/edit_project.dart';
import 'package:lycread/widgets/rounded_text_input.dart';
import 'package:lycread/widgets/slide_right_route_animation.dart';
import 'package:overlay_support/overlay_support.dart';
import '../../constants.dart';
import '../loading_screen.dart';
import 'components/add_branch.dart';

// ignore: must_be_immutable
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
  QuerySnapshot all_users;
  List added_users = [];
  List listed_users = [];

  String getDate(int millisecondsSinceEpoch) {
    String date = '';
    DateTime d = DateTime.fromMillisecondsSinceEpoch(millisecondsSinceEpoch);
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

  Future<void> search(String st) async {
    setState(() {
      List preresults = [];
      for (var doc in all_users.docs) {
        if (doc.data()['name'].toLowerCase().contains(st.toLowerCase())) {
          if (!added_users.contains(doc)) {
            if (!project.data()['authors'].contains(doc.id)) {
              preresults.add(doc);
            }
          }
        }
      }
      listed_users = preresults;
      preresults = [];
      print('SEARCHED ');
      print(listed_users);
    });
  }

  Future<void> prepare() async {
    all_users = await FirebaseFirestore.instance.collection('users').get();
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

  Future<void> _refresh() {
    setState(() {
      loading = true;
    });
    branches = [];
    authors = [];
    added_users = [];
    listed_users = [];
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
                actions: [
                  project.data()['owner'] ==
                          FirebaseAuth.instance.currentUser.uid
                      ? IconButton(
                          color: whiteColor,
                          icon: Icon(
                            CupertinoIcons.pencil,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              SlideRightRoute(
                                page: EditProjectScreen(
                                    project: project.data(), id: project.id),
                              ),
                            );
                          },
                        )
                      : Container(),
                ],
              ),
              body: SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.all(10),
                  child: FadeInDown(
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
                        SlideInLeft(
                          child: Container(
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
                                    for (QueryDocumentSnapshot author
                                        in authors)
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
                                                                      .circular(
                                                                          25.0),
                                                              child:
                                                                  CachedNetworkImage(
                                                                filterQuality:
                                                                    FilterQuality
                                                                        .none,
                                                                fit: BoxFit
                                                                    .cover,
                                                                placeholder: (context,
                                                                        url) =>
                                                                    Transform
                                                                        .scale(
                                                                  scale: 0.8,
                                                                  child:
                                                                      CircularProgressIndicator(
                                                                    strokeWidth:
                                                                        2.0,
                                                                    backgroundColor:
                                                                        footyColor,
                                                                    valueColor:
                                                                        AlwaysStoppedAnimation<Color>(
                                                                            primaryColor),
                                                                  ),
                                                                ),
                                                                errorWidget:
                                                                    (context,
                                                                            url,
                                                                            error) =>
                                                                        Icon(
                                                                  Icons.error,
                                                                  color:
                                                                      footyColor,
                                                                ),
                                                                imageUrl: author
                                                                        .data()[
                                                                    'photo'],
                                                              )),
                                                        )
                                                      : Container(
                                                          width: 40,
                                                          height: 40,
                                                          child: ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
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
                                                            BorderRadius
                                                                .circular(25.0),
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
                                                      fontWeight:
                                                          FontWeight.w300),
                                                ),
                                              ),
                                              SizedBox(width: 5),
                                              project.data()['owner'] ==
                                                      author.id
                                                  ? Icon(
                                                      CupertinoIcons
                                                          .star_circle_fill,
                                                      color: footyColor,
                                                    )
                                                  : Container(),
                                            ],
                                          ),
                                        ),
                                      ),
                                    project.data()['owner'] ==
                                            FirebaseAuth
                                                .instance.currentUser.uid
                                        ? Container(
                                            height: (added_users.length * 20 +
                                                    listed_users.length * 20 +
                                                    250)
                                                .toDouble(),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Center(
                                                  child: RoundedTextInput(
                                                    validator: (val) => val
                                                                .length >
                                                            1
                                                        ? null
                                                        : 'Минимум 2 символов',
                                                    hintText: "Имя",
                                                    type: TextInputType.text,
                                                    height: 80,
                                                    onChanged: (value) {
                                                      value != null
                                                          ? value.length != 0
                                                              ? search(value)
                                                              : setState(() {
                                                                  listed_users =
                                                                      [];
                                                                })
                                                          : setState(() {
                                                              added_users = [];
                                                              listed_users = [];
                                                            });
                                                    },
                                                  ),
                                                ),
                                                listed_users.isNotEmpty
                                                    ? Expanded(
                                                        child: ListView.builder(
                                                          itemCount:
                                                              listed_users
                                                                  .length,
                                                          itemBuilder: (BuildContext
                                                                      context,
                                                                  int index) =>
                                                              CupertinoButton(
                                                            padding:
                                                                EdgeInsets.zero,
                                                            onPressed: () {
                                                              setState(() {
                                                                added_users.add(
                                                                    listed_users[
                                                                        index]);
                                                                listed_users.remove(
                                                                    listed_users[
                                                                        index]);
                                                              });
                                                            },
                                                            child: Row(
                                                              children: [
                                                                listed_users[index].data()[
                                                                            'photo'] !=
                                                                        null
                                                                    ? listed_users[index].data()['photo'] !=
                                                                            'No Image'
                                                                        ? Container(
                                                                            width:
                                                                                40,
                                                                            height:
                                                                                40,
                                                                            child: ClipRRect(
                                                                                borderRadius: BorderRadius.circular(25.0),
                                                                                child: CachedNetworkImage(
                                                                                  filterQuality: FilterQuality.none,
                                                                                  fit: BoxFit.cover,
                                                                                  placeholder: (context, url) => Transform.scale(
                                                                                    scale: 0.8,
                                                                                    child: CircularProgressIndicator(
                                                                                      strokeWidth: 2.0,
                                                                                      backgroundColor: footyColor,
                                                                                      valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                                                                                    ),
                                                                                  ),
                                                                                  errorWidget: (context, url, error) => Icon(
                                                                                    Icons.error,
                                                                                    color: footyColor,
                                                                                  ),
                                                                                  imageUrl: listed_users[index].data()['photo'],
                                                                                )),
                                                                          )
                                                                        : Container(
                                                                            width:
                                                                                40,
                                                                            height:
                                                                                40,
                                                                            child:
                                                                                ClipRRect(
                                                                              borderRadius: BorderRadius.circular(25.0),
                                                                              child: Image.asset(
                                                                                'assets/images/User.png',
                                                                                fit: BoxFit.cover,
                                                                              ),
                                                                            ),
                                                                          )
                                                                    : Container(
                                                                        width:
                                                                            40,
                                                                        height:
                                                                            40,
                                                                        child:
                                                                            ClipRRect(
                                                                          borderRadius:
                                                                              BorderRadius.circular(25.0),
                                                                          child:
                                                                              Image.asset(
                                                                            'assets/images/User.png',
                                                                            fit:
                                                                                BoxFit.cover,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                SizedBox(
                                                                    width: 5),
                                                                Text(
                                                                  listed_users[
                                                                          index]
                                                                      .data()['name'],
                                                                  textScaleFactor:
                                                                      1,
                                                                  maxLines: 1,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  style: GoogleFonts
                                                                      .montserrat(
                                                                    textStyle: TextStyle(
                                                                        color:
                                                                            darkPrimaryColor,
                                                                        fontSize:
                                                                            15,
                                                                        fontWeight:
                                                                            FontWeight.w300),
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                    width: 5),
                                                                project.data()[
                                                                            'owner'] ==
                                                                        listed_users[index]
                                                                            .id
                                                                    ? Icon(
                                                                        CupertinoIcons
                                                                            .star_circle_fill,
                                                                        color:
                                                                            footyColor,
                                                                      )
                                                                    : Container(),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      )
                                                    : Container(),
                                                Divider(
                                                  thickness: 1,
                                                  color: darkPrimaryColor,
                                                ),
                                                added_users.isNotEmpty
                                                    ? Text(
                                                        'Выбранные',
                                                        textScaleFactor: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: GoogleFonts
                                                            .montserrat(
                                                          textStyle: TextStyle(
                                                              color:
                                                                  darkPrimaryColor,
                                                              fontSize: 15,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                      )
                                                    : Container(),
                                                added_users.isNotEmpty
                                                    ? Expanded(
                                                        child: ListView.builder(
                                                          itemCount: added_users
                                                              .length,
                                                          itemBuilder: (BuildContext
                                                                      context,
                                                                  int index) =>
                                                              CupertinoButton(
                                                            padding:
                                                                EdgeInsets.zero,
                                                            onPressed: () {
                                                              setState(() {
                                                                added_users.remove(
                                                                    added_users[
                                                                        index]);
                                                              });
                                                            },
                                                            child: Row(
                                                              children: [
                                                                added_users[index].data()[
                                                                            'photo'] !=
                                                                        null
                                                                    ? added_users[index].data()['photo'] !=
                                                                            'No Image'
                                                                        ? Container(
                                                                            width:
                                                                                40,
                                                                            height:
                                                                                40,
                                                                            child: ClipRRect(
                                                                                borderRadius: BorderRadius.circular(25.0),
                                                                                child: CachedNetworkImage(
                                                                                  filterQuality: FilterQuality.none,
                                                                                  fit: BoxFit.cover,
                                                                                  placeholder: (context, url) => Transform.scale(
                                                                                    scale: 0.8,
                                                                                    child: CircularProgressIndicator(
                                                                                      strokeWidth: 2.0,
                                                                                      backgroundColor: footyColor,
                                                                                      valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                                                                                    ),
                                                                                  ),
                                                                                  errorWidget: (context, url, error) => Icon(
                                                                                    Icons.error,
                                                                                    color: footyColor,
                                                                                  ),
                                                                                  imageUrl: added_users[index].data()['photo'],
                                                                                )),
                                                                          )
                                                                        : Container(
                                                                            width:
                                                                                40,
                                                                            height:
                                                                                40,
                                                                            child:
                                                                                ClipRRect(
                                                                              borderRadius: BorderRadius.circular(25.0),
                                                                              child: Image.asset(
                                                                                'assets/images/User.png',
                                                                                fit: BoxFit.cover,
                                                                              ),
                                                                            ),
                                                                          )
                                                                    : Container(
                                                                        width:
                                                                            40,
                                                                        height:
                                                                            40,
                                                                        child:
                                                                            ClipRRect(
                                                                          borderRadius:
                                                                              BorderRadius.circular(25.0),
                                                                          child:
                                                                              Image.asset(
                                                                            'assets/images/User.png',
                                                                            fit:
                                                                                BoxFit.cover,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                SizedBox(
                                                                    width: 5),
                                                                Text(
                                                                  added_users[index]
                                                                          .data()[
                                                                      'name'],
                                                                  textScaleFactor:
                                                                      1,
                                                                  maxLines: 1,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  style: GoogleFonts
                                                                      .montserrat(
                                                                    textStyle: TextStyle(
                                                                        color:
                                                                            darkPrimaryColor,
                                                                        fontSize:
                                                                            15,
                                                                        fontWeight:
                                                                            FontWeight.w300),
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                    width: 5),
                                                                project.data()[
                                                                            'owner'] ==
                                                                        added_users[index]
                                                                            .id
                                                                    ? Icon(
                                                                        CupertinoIcons
                                                                            .star_circle_fill,
                                                                        color:
                                                                            footyColor,
                                                                      )
                                                                    : Container(),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      )
                                                    : Container(),
                                                CupertinoButton(
                                                  padding: EdgeInsets.zero,
                                                  onPressed: () {
                                                    if (added_users
                                                        .isNotEmpty) {
                                                      showDialog(
                                                        context: context,
                                                        builder: (BuildContext
                                                            context) {
                                                          return AlertDialog(
                                                            title: const Text(
                                                                'Пригласить?'),
                                                            content: const Text(
                                                                'Уверены что хотите пригласить этих пользователей?'),
                                                            actions: <Widget>[
                                                              TextButton(
                                                                onPressed: () {
                                                                  setState(() {
                                                                    loading =
                                                                        true;
                                                                  });
                                                                  String name = FirebaseAuth
                                                                      .instance
                                                                      .currentUser
                                                                      .displayName;
                                                                  String
                                                                      project_name =
                                                                      project.data()[
                                                                          'name'];
                                                                  for (QueryDocumentSnapshot user
                                                                      in added_users) {
                                                                    FirebaseFirestore
                                                                        .instance
                                                                        .collection(
                                                                            'users')
                                                                        .doc(user
                                                                            .id)
                                                                        .update({
                                                                      'actions':
                                                                          FieldValue
                                                                              .arrayUnion([
                                                                        {
                                                                          'author': FirebaseAuth
                                                                              .instance
                                                                              .currentUser
                                                                              .uid,
                                                                          'seen':
                                                                              false,
                                                                          'text':
                                                                              '$name пригласил в $project_name',
                                                                          'type':
                                                                              'Invitation',
                                                                          'date':
                                                                              DateTime.now(),
                                                                          'metadata':
                                                                              {
                                                                            'project_id':
                                                                                project.id,
                                                                          },
                                                                        }
                                                                      ]),
                                                                    }).catchError(
                                                                            (error) {
                                                                      print(
                                                                          'MISTAKE HERE');
                                                                      print(
                                                                          error);
                                                                      Navigator.of(
                                                                              context)
                                                                          .pop(
                                                                              false);
                                                                      PushNotificationMessage
                                                                          notification =
                                                                          PushNotificationMessage(
                                                                        title:
                                                                            'Ошибка',
                                                                        body: 'Неудалось удалить пригласить ' +
                                                                            user.data()['name'],
                                                                      );
                                                                      showSimpleNotification(
                                                                        Container(
                                                                            child:
                                                                                Text(notification.body)),
                                                                        position:
                                                                            NotificationPosition.top,
                                                                        background:
                                                                            Colors.red,
                                                                      );
                                                                    });
                                                                  }

                                                                  PushNotificationMessage
                                                                      notification =
                                                                      PushNotificationMessage(
                                                                    title:
                                                                        'Успех',
                                                                    body:
                                                                        'Приглашения отправлены',
                                                                  );
                                                                  showSimpleNotification(
                                                                    Container(
                                                                        child: Text(
                                                                            notification.body)),
                                                                    position:
                                                                        NotificationPosition
                                                                            .top,
                                                                    background:
                                                                        footyColor,
                                                                  );
                                                                  setState(() {
                                                                    added_users =
                                                                        [];
                                                                    listed_users =
                                                                        [];
                                                                    loading =
                                                                        false;
                                                                  });
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop(
                                                                          true);
                                                                },
                                                                child:
                                                                    const Text(
                                                                  'Yes',
                                                                  style: TextStyle(
                                                                      color:
                                                                          footyColor),
                                                                ),
                                                              ),
                                                              TextButton(
                                                                onPressed: () =>
                                                                    Navigator.of(
                                                                            context)
                                                                        .pop(
                                                                            false),
                                                                child:
                                                                    const Text(
                                                                  'No',
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .red),
                                                                ),
                                                              ),
                                                            ],
                                                          );
                                                        },
                                                      );
                                                    }
                                                  },
                                                  child: Container(
                                                    width: size.width * 0.8,
                                                    padding: EdgeInsets.all(15),
                                                    child: Column(
                                                      children: [
                                                        Icon(
                                                          CupertinoIcons
                                                              .person_crop_circle_fill_badge_plus,
                                                          color: footyColor,
                                                          size: 20,
                                                        ),
                                                        SizedBox(height: 5),
                                                        Text(
                                                          'Добавить',
                                                          textScaleFactor: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: GoogleFonts
                                                              .montserrat(
                                                            textStyle: TextStyle(
                                                                color:
                                                                    darkPrimaryColor,
                                                                fontSize: 15,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                        : Container(),
                                  ],
                                ),
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
                              ? SlideInLeft(
                                  child: Container(
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
                                              page: BranchInfoScreen(
                                                id: branch.id,
                                                branches:
                                                    project.data()['branches'],
                                                project_name:
                                                    project.data()['name'],
                                                project_id: project.id,
                                                project_owner:
                                                    project.data()['owner'],
                                                project_authors:
                                                    project.data()['authors'],
                                              ),
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
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: GoogleFonts.montserrat(
                                                    textStyle: TextStyle(
                                                        color: darkPrimaryColor,
                                                        fontSize: 17,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                                SizedBox(height: 5),
                                                Text(
                                                  getDate(branch
                                                      .data()['last_update']
                                                      .millisecondsSinceEpoch)
                                                  // 'Update: ' +
                                                  //     DateTime.fromMicrosecondsSinceEpoch(
                                                  //             branch
                                                  //                 .data()[
                                                  //                     'last_update']
                                                  //                 .microsecondsSinceEpoch)
                                                  //         .day
                                                  //         .toString() +
                                                  //     '.' +
                                                  //     DateTime.fromMicrosecondsSinceEpoch(
                                                  //             branch
                                                  //                 .data()[
                                                  //                     'last_update']
                                                  //                 .microsecondsSinceEpoch)
                                                  //         .month
                                                  //         .toString() +
                                                  //     '.' +
                                                  //     DateTime.fromMicrosecondsSinceEpoch(
                                                  //             branch
                                                  //                 .data()[
                                                  //                     'last_update']
                                                  //                 .microsecondsSinceEpoch)
                                                  //         .year
                                                  //         .toString()
                                                  ,
                                                  textScaleFactor: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: GoogleFonts.montserrat(
                                                    textStyle: TextStyle(
                                                        color: darkPrimaryColor,
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              : Container(),
                        project
                                .data()['authors']
                                .contains(FirebaseAuth.instance.currentUser.uid)
                            ? Center(
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
                                            CupertinoIcons
                                                .plus_square_on_square,
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
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : Container(),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          'Логи',
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
                        if (project.data()['logs'].length < 20)
                          for (int i = 0;
                              i < project.data()['logs'].length - 1;
                              i++)
                            CupertinoButton(
                              padding: EdgeInsets.zero,
                              onPressed: () {
                                setState(() {
                                  loading = true;
                                });
                                Navigator.push(
                                    context,
                                    SlideRightRoute(
                                      page: BranchInfoScreen(
                                        id: project.data()['logs'][
                                            project.data()['logs'].length -
                                                1 -
                                                i]['branch_id'],
                                        branches: project.data()['branches'],
                                        project_name: project.data()['name'],
                                        project_id: project.id,
                                        project_owner: project.data()['owner'],
                                        project_authors:
                                            project.data()['authors'],
                                      ),
                                    ));
                                setState(() {
                                  loading = false;
                                });
                              },
                              child: Container(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      project.data()['logs'][
                                          project.data()['logs'].length -
                                              1 -
                                              i]['text'],
                                      textScaleFactor: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.montserrat(
                                        textStyle: TextStyle(
                                          color: darkPrimaryColor,
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      getDate(project
                                          .data()['logs'][
                                              project.data()['logs'].length -
                                                  1 -
                                                  i]['date']
                                          .millisecondsSinceEpoch),
                                      textScaleFactor: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.montserrat(
                                        textStyle: TextStyle(
                                          color: darkPrimaryColor,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        if (project.data()['logs'].length >= 20)
                          for (int i = 0; i < 20; i++)
                            CupertinoButton(
                              padding: EdgeInsets.zero,
                              onPressed: () {
                                setState(() {
                                  loading = true;
                                });
                                Navigator.push(
                                    context,
                                    SlideRightRoute(
                                      page: BranchInfoScreen(
                                        id: project.data()['logs'][
                                            project.data()['logs'].length -
                                                1 -
                                                i]['branch_id'],
                                        branches: project.data()['branches'],
                                        project_name: project.data()['name'],
                                        project_id: project.id,
                                        project_owner: project.data()['owner'],
                                        project_authors:
                                            project.data()['authors'],
                                      ),
                                    ));
                                setState(() {
                                  loading = false;
                                });
                              },
                              child: Container(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      project.data()['logs'][
                                          project.data()['logs'].length -
                                              1 -
                                              i]['text'],
                                      textScaleFactor: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.montserrat(
                                        textStyle: TextStyle(
                                          color: darkPrimaryColor,
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      getDate(project
                                          .data()['logs'][
                                              project.data()['logs'].length -
                                                  1 -
                                                  i]['date']
                                          .millisecondsSinceEpoch),
                                      textScaleFactor: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.montserrat(
                                        textStyle: TextStyle(
                                          color: darkPrimaryColor,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
  }
}
