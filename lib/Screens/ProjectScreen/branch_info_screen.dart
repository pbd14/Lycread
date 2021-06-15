import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lycread/Models/PushNotificationMessage.dart';
import 'package:lycread/Screens/WritingScreen/reading_screen.dart';
import 'package:lycread/widgets/slide_right_route_animation.dart';
import 'package:overlay_support/overlay_support.dart';
import '../../constants.dart';
import '../loading_screen.dart';
import 'components/branch_writing_screen.dart';
import 'components/edit_branch.dart';

class BranchInfoScreen extends StatefulWidget {
  String id;
  String project_name;
  String project_id;
  String project_owner;
  List project_authors;
  List branches = [];
  BranchInfoScreen({
    Key key,
    @required this.id,
    @required this.branches,
    @required this.project_name,
    @required this.project_id,
    @required this.project_owner,
    @required this.project_authors,
  }) : super(key: key);
  @override
  _BranchInfoScreenState createState() => _BranchInfoScreenState();
}

class _BranchInfoScreenState extends State<BranchInfoScreen> {
  Size size;
  bool loading = true;
  DocumentSnapshot branch;
  List<QueryDocumentSnapshot> writings = [];
  List<QueryDocumentSnapshot> hiddenwrs = [];
  List le_list = [];
  Map brNames = {};
  Map<String, QuerySnapshot> live_editors = {};
  StreamSubscription<QuerySnapshot> subscription;
  StreamSubscription<DocumentSnapshot> writingSubscription;

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

  void activateSubs(QueryDocumentSnapshot hid) {
    subscription = FirebaseFirestore.instance
        .collection('users')
        .where('id', whereIn: le_list.isNotEmpty ? le_list : ['1'])
        .snapshots()
        .listen((snap) {
      if (this.mounted) {
        setState(() {
          live_editors.addAll({hid.id: snap});
        });
      } else {
        live_editors.addAll({hid.id: snap});
      }
    });
  }

  Future<void> prepare() async {
    for (var br in widget.branches) {
      DocumentSnapshot preBr =
          await FirebaseFirestore.instance.collection('branches').doc(br).get();
      brNames.addAll({br: preBr.data()['name']});
    }
    branch = await FirebaseFirestore.instance
        .collection('branches')
        .doc(widget.id)
        .get();
    QuerySnapshot preWritings = await FirebaseFirestore.instance
        .collection('writings')
        .where('branch_id', isEqualTo: widget.id)
        .get();
    QuerySnapshot preHiddens = await FirebaseFirestore.instance
        .collection('hidden_writings')
        .where('branch_id', isEqualTo: widget.id)
        .get();
    for (QueryDocumentSnapshot hiddenWr in preHiddens.docs) {
      writingSubscription = FirebaseFirestore.instance
          .collection('hidden_writings')
          .doc(hiddenWr.id)
          .snapshots()
          .listen((snap) {
        if (this.mounted) {
          setState(() {
            if (snap.data()['live_editors_id'] != null) {
              le_list = snap.data()['live_editors_id'];
              activateSubs(hiddenWr);
            }
          });
        } else {
          if (snap.data()['live_editors_id'] != null) {
            le_list = snap.data()['live_editors_id'];
            activateSubs(hiddenWr);
          }
        }
      });
    }
    if (this.mounted) {
      setState(() {
        writings = preWritings.docs;
        hiddenwrs = preHiddens.docs;
        loading = false;
      });
    } else {
      writings = preWritings.docs;
      hiddenwrs = preHiddens.docs;
      loading = false;
    }
  }

  @override
  void dispose() {
    writingSubscription.cancel();
    subscription.cancel();
    super.dispose();
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
    writings = [];
    hiddenwrs = [];
    le_list = [];
    brNames = {};
    live_editors = {};
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
        : Scaffold(
            appBar: AppBar(
              backgroundColor: primaryColor,
              centerTitle: true,
              title: Text(
                branch.data()['name'],
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
                widget.project_owner == FirebaseAuth.instance.currentUser.uid
                    ? IconButton(
                        color: whiteColor,
                        icon: Icon(
                          CupertinoIcons.pencil,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            SlideRightRoute(
                              page: EditBranchScreen(
                                  project_id: widget.project_id,
                                  branch: branch.data(),
                                  id: branch.id),
                            ),
                          );
                        },
                      )
                    : Container(),
              ],
            ),
            body: RefreshIndicator(
              color: footyColor,
              onRefresh: _refresh,
              child: SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        branch.data()['name'],
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
                        branch.data()['bio'],
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
                        padding: EdgeInsets.fromLTRB(
                            size.width * 0.2, 0, size.width * 0.2, 0),
                        child: DropdownButton<String>(
                          isExpanded: true,
                          hint: Text(
                            branch.data()['name'] != null
                                ? branch.data()['name']
                                : 'no name',
                            textScaleFactor: 1,
                            style: GoogleFonts.montserrat(
                              textStyle: TextStyle(
                                color: darkPrimaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          items: widget.branches != null
                              ? widget.branches.map((dynamic value) {
                                  return new DropdownMenuItem<String>(
                                    value: value,
                                    child: new Text(
                                      brNames[value].toString(),
                                      textScaleFactor: 1,
                                    ),
                                  );
                                }).toList()
                              : [
                                  new DropdownMenuItem<String>(
                                    value: '-',
                                    child: new Text(
                                      '-',
                                      textScaleFactor: 1,
                                    ),
                                  )
                                ],
                          onChanged: (value) {
                            setState(() {
                              loading = true;
                            });
                            widget.id = value;
                            prepare();
                          },
                        ),
                      ),
                      for (QueryDocumentSnapshot hwriting in hiddenwrs)
                        hiddenwrs.isNotEmpty
                            ? Container(
                                width: size.width * 0.95,
                                // height: hwriting.data()['images'] != null
                                //     ? hwriting.data()['images'] != 'No Image'
                                //         ? 200
                                //         : 90
                                //     : 90,
                                padding: EdgeInsets.all(10),
                                child: TextButton(
                                  style: ButtonStyle(
                                    padding: MaterialStateProperty.all(
                                        EdgeInsets.zero),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      loading = true;
                                    });
                                    if (widget.project_authors.contains(
                                        FirebaseAuth
                                            .instance.currentUser.uid)) {
                                      FirebaseFirestore.instance
                                          .collection('hidden_writings')
                                          .doc(hwriting.id)
                                          .update({
                                        'status': 'isEdited',
                                        'live_editors_id':
                                            FieldValue.arrayUnion([
                                          FirebaseAuth.instance.currentUser.uid
                                        ]),
                                      });
                                      Navigator.push(
                                        context,
                                        SlideRightRoute(
                                          page: BranchWritingScreen(
                                            id: widget.id,
                                            project_id: widget.project_id,
                                            project_name: widget.project_name,
                                            isEmpty: false,
                                            writing: hwriting.data(),
                                            writingId: hwriting.id,
                                            project_owner: widget.project_owner,
                                          ),
                                        ),
                                      );
                                    }
                                    setState(() {
                                      loading = false;
                                    });
                                  },
                                  child: Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30.0),
                                    ),
                                    clipBehavior: Clip.antiAlias,
                                    elevation: 11,
                                    child: Padding(
                                      padding: EdgeInsets.all(5.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          hwriting.data()['images'] != null
                                              ? hwriting.data()['images'] !=
                                                      'No Image'
                                                  ? Container(
                                                      height: 110,
                                                      width: size.width,
                                                      child: CachedNetworkImage(
                                                        fit: BoxFit.cover,
                                                        filterQuality:
                                                            FilterQuality.none,
                                                        height: 110,
                                                        width: 100,
                                                        placeholder:
                                                            (context, url) =>
                                                                Container(
                                                          height: 50,
                                                          width: 50,
                                                          child:
                                                              Transform.scale(
                                                            scale: 0.1,
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
                                                        ),
                                                        errorWidget: (context,
                                                                url, error) =>
                                                            Icon(
                                                          Icons.error,
                                                          color: footyColor,
                                                        ),
                                                        imageUrl:
                                                            hwriting.data()[
                                                                'images'][0],
                                                      ),
                                                    )
                                                  : Container()
                                              : Container(),
                                          SizedBox(height: 10),
                                          Container(
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Container(
                                                      width: size.width * 0.6,
                                                      child: Text(
                                                        hwriting.data()['name'],
                                                        textScaleFactor: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
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
                                                    ),
                                                    SizedBox(
                                                      height: 5,
                                                    ),
                                                    Text(
                                                      getDate(hwriting
                                                          .data()['date']
                                                          .seconds),
                                                      textScaleFactor: 1,
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: GoogleFonts
                                                          .montserrat(
                                                        textStyle: TextStyle(
                                                          color: primaryColor,
                                                          fontSize: 10,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(width: 10),
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.end,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    widget.project_owner ==
                                                            FirebaseAuth
                                                                .instance
                                                                .currentUser
                                                                .uid
                                                        ? IconButton(
                                                            icon: Icon(
                                                              CupertinoIcons
                                                                  .rectangle_stack_fill_badge_plus,
                                                              color: footyColor,
                                                            ),
                                                            onPressed: () {
                                                              showDialog(
                                                                barrierDismissible:
                                                                    false,
                                                                context:
                                                                    context,
                                                                builder:
                                                                    (BuildContext
                                                                        context) {
                                                                  return AlertDialog(
                                                                    title: const Text(
                                                                        'Опубликовать?'),
                                                                    content:
                                                                        const Text(
                                                                            'Хотите ли вы опубликовать эту историю?'),
                                                                    actions: <
                                                                        Widget>[
                                                                      TextButton(
                                                                        onPressed:
                                                                            () {
                                                                          FirebaseFirestore
                                                                              .instance
                                                                              .collection('writings')
                                                                              .doc(hwriting.id)
                                                                              .set(hwriting.data())
                                                                              .catchError((error) {
                                                                            print('MISTAKE HERE');
                                                                            print(error);
                                                                            PushNotificationMessage
                                                                                notification =
                                                                                PushNotificationMessage(
                                                                              title: 'Ошибка',
                                                                              body: 'Неудалось опубликовать историю',
                                                                            );
                                                                            showSimpleNotification(
                                                                              Container(child: Text(notification.body)),
                                                                              position: NotificationPosition.top,
                                                                              background: Colors.red,
                                                                            );
                                                                          });
                                                                          FirebaseFirestore
                                                                              .instance
                                                                              .collection('hidden_writings')
                                                                              .doc(hwriting.id)
                                                                              .delete()
                                                                              .catchError((error) {
                                                                            print('MISTAKE HERE');
                                                                            print(error);
                                                                            PushNotificationMessage
                                                                                notification =
                                                                                PushNotificationMessage(
                                                                              title: 'Ошибка',
                                                                              body: 'Неудалось опубликовать историю',
                                                                            );
                                                                            showSimpleNotification(
                                                                              Container(child: Text(notification.body)),
                                                                              position: NotificationPosition.top,
                                                                              background: Colors.red,
                                                                            );
                                                                          });
                                                                          setState(
                                                                              () {
                                                                            writings.add(hwriting);
                                                                            hiddenwrs.remove(hwriting);
                                                                          });
                                                                          PushNotificationMessage
                                                                              notification =
                                                                              PushNotificationMessage(
                                                                            title:
                                                                                'Успех',
                                                                            body:
                                                                                'История опубликована',
                                                                          );
                                                                          showSimpleNotification(
                                                                            Container(child: Text(notification.body)),
                                                                            position:
                                                                                NotificationPosition.top,
                                                                            background:
                                                                                footyColor,
                                                                          );
                                                                        },
                                                                        child:
                                                                            const Text(
                                                                          'Yes',
                                                                          style:
                                                                              TextStyle(color: footyColor),
                                                                        ),
                                                                      ),
                                                                      TextButton(
                                                                        onPressed:
                                                                            () =>
                                                                                Navigator.of(context).pop(false),
                                                                        child:
                                                                            const Text(
                                                                          'No',
                                                                          style:
                                                                              TextStyle(color: Colors.red),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  );
                                                                },
                                                              );
                                                            },
                                                          )
                                                        : Container(),
                                                  ],
                                                )
                                              ],
                                            ),
                                          ),
                                          live_editors[hwriting.id] != null
                                              ? live_editors[hwriting.id]
                                                          .docs
                                                          .length !=
                                                      0
                                                  ? live_editors[hwriting.id]
                                                              .docs
                                                              .length <
                                                          5
                                                      ? Container(
                                                          margin:
                                                              EdgeInsets.all(
                                                                  10),
                                                          child: Row(
                                                            children: [
                                                              for (QueryDocumentSnapshot editor
                                                                  in live_editors[
                                                                          hwriting
                                                                              .id]
                                                                      .docs)
                                                                Container(
                                                                  width: 30,
                                                                  height: 30,
                                                                  child:
                                                                      ClipRRect(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            25.0),
                                                                    child: editor.data()['photo'] !=
                                                                            null
                                                                        ? CachedNetworkImage(
                                                                            filterQuality:
                                                                                FilterQuality.none,
                                                                            fit:
                                                                                BoxFit.cover,
                                                                            placeholder: (context, url) =>
                                                                                Transform.scale(
                                                                              scale: 0.8,
                                                                              child: CircularProgressIndicator(
                                                                                strokeWidth: 2.0,
                                                                                backgroundColor: footyColor,
                                                                                valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                                                                              ),
                                                                            ),
                                                                            errorWidget: (context, url, error) =>
                                                                                Icon(
                                                                              Icons.error,
                                                                              color: footyColor,
                                                                            ),
                                                                            imageUrl:
                                                                                editor.data()['photo'],
                                                                          )
                                                                        : Image
                                                                            .asset(
                                                                            'assets/images/User.png',
                                                                            fit:
                                                                                BoxFit.cover,
                                                                          ),
                                                                  ),
                                                                )
                                                            ],
                                                          ),
                                                        )
                                                      : Container(
                                                          margin:
                                                              EdgeInsets.all(
                                                                  10),
                                                          child: Row(
                                                            children: [
                                                              Container(
                                                                width: 30,
                                                                height: 30,
                                                                child:
                                                                    ClipRRect(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              25.0),
                                                                  child: live_editors[hwriting.id].docs[0].data()[
                                                                              'photo'] !=
                                                                          null
                                                                      ? CachedNetworkImage(
                                                                          filterQuality:
                                                                              FilterQuality.none,
                                                                          fit: BoxFit
                                                                              .cover,
                                                                          placeholder: (context, url) =>
                                                                              Transform.scale(
                                                                            scale:
                                                                                0.8,
                                                                            child:
                                                                                CircularProgressIndicator(
                                                                              strokeWidth: 2.0,
                                                                              backgroundColor: footyColor,
                                                                              valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                                                                            ),
                                                                          ),
                                                                          errorWidget: (context, url, error) =>
                                                                              Icon(
                                                                            Icons.error,
                                                                            color:
                                                                                footyColor,
                                                                          ),
                                                                          imageUrl: live_editors[hwriting.id]
                                                                              .docs[0]
                                                                              .data()['photo'],
                                                                        )
                                                                      : Image
                                                                          .asset(
                                                                          'assets/images/User.png',
                                                                          fit: BoxFit
                                                                              .cover,
                                                                        ),
                                                                ),
                                                              ),
                                                              Container(
                                                                width: 30,
                                                                height: 30,
                                                                child:
                                                                    ClipRRect(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              25.0),
                                                                  child: live_editors[hwriting.id].docs[1].data()[
                                                                              'photo'] !=
                                                                          null
                                                                      ? CachedNetworkImage(
                                                                          filterQuality:
                                                                              FilterQuality.none,
                                                                          fit: BoxFit
                                                                              .cover,
                                                                          placeholder: (context, url) =>
                                                                              Transform.scale(
                                                                            scale:
                                                                                0.8,
                                                                            child:
                                                                                CircularProgressIndicator(
                                                                              strokeWidth: 2.0,
                                                                              backgroundColor: footyColor,
                                                                              valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                                                                            ),
                                                                          ),
                                                                          errorWidget: (context, url, error) =>
                                                                              Icon(
                                                                            Icons.error,
                                                                            color:
                                                                                footyColor,
                                                                          ),
                                                                          imageUrl: live_editors[hwriting.id]
                                                                              .docs[1]
                                                                              .data()['photo'],
                                                                        )
                                                                      : Image
                                                                          .asset(
                                                                          'assets/images/User.png',
                                                                          fit: BoxFit
                                                                              .cover,
                                                                        ),
                                                                ),
                                                              ),
                                                              Container(
                                                                width: 30,
                                                                height: 30,
                                                                child:
                                                                    ClipRRect(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              25.0),
                                                                  child: live_editors[hwriting.id].docs[2].data()[
                                                                              'photo'] !=
                                                                          null
                                                                      ? CachedNetworkImage(
                                                                          filterQuality:
                                                                              FilterQuality.none,
                                                                          fit: BoxFit
                                                                              .cover,
                                                                          placeholder: (context, url) =>
                                                                              Transform.scale(
                                                                            scale:
                                                                                0.8,
                                                                            child:
                                                                                CircularProgressIndicator(
                                                                              strokeWidth: 2.0,
                                                                              backgroundColor: footyColor,
                                                                              valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                                                                            ),
                                                                          ),
                                                                          errorWidget: (context, url, error) =>
                                                                              Icon(
                                                                            Icons.error,
                                                                            color:
                                                                                footyColor,
                                                                          ),
                                                                          imageUrl: live_editors[hwriting.id]
                                                                              .docs[2]
                                                                              .data()['photo'],
                                                                        )
                                                                      : Image
                                                                          .asset(
                                                                          'assets/images/User.png',
                                                                          fit: BoxFit
                                                                              .cover,
                                                                        ),
                                                                ),
                                                              ),
                                                              Container(
                                                                width: 30,
                                                                height: 30,
                                                                child:
                                                                    ClipRRect(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              25.0),
                                                                  child: live_editors[hwriting.id].docs[3].data()[
                                                                              'photo'] !=
                                                                          null
                                                                      ? CachedNetworkImage(
                                                                          filterQuality:
                                                                              FilterQuality.none,
                                                                          fit: BoxFit
                                                                              .cover,
                                                                          placeholder: (context, url) =>
                                                                              Transform.scale(
                                                                            scale:
                                                                                0.8,
                                                                            child:
                                                                                CircularProgressIndicator(
                                                                              strokeWidth: 2.0,
                                                                              backgroundColor: footyColor,
                                                                              valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                                                                            ),
                                                                          ),
                                                                          errorWidget: (context, url, error) =>
                                                                              Icon(
                                                                            Icons.error,
                                                                            color:
                                                                                footyColor,
                                                                          ),
                                                                          imageUrl: live_editors[hwriting.id]
                                                                              .docs[3]
                                                                              .data()['photo'],
                                                                        )
                                                                      : Image
                                                                          .asset(
                                                                          'assets/images/User.png',
                                                                          fit: BoxFit
                                                                              .cover,
                                                                        ),
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                  width: 5),
                                                              Text(
                                                                '+ ' +
                                                                    (live_editors[hwriting.id].docs.length -
                                                                            4)
                                                                        .toString(),
                                                                textScaleFactor:
                                                                    1,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                style: GoogleFonts
                                                                    .montserrat(
                                                                  textStyle:
                                                                      TextStyle(
                                                                    color:
                                                                        darkPrimaryColor,
                                                                    fontSize:
                                                                        10,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400,
                                                                  ),
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                        )
                                                  : Container()
                                              : Container(),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : Container(),
                      Divider(
                        thickness: 1,
                        color: darkPrimaryColor,
                      ),
                      for (QueryDocumentSnapshot writing in writings)
                        writings.isNotEmpty
                            ? Container(
                                width: size.width * 0.95,
                                height: writing.data()['images'] != null
                                    ? writing.data()['images'] != 'No Image'
                                        ? 200
                                        : 90
                                    : 90,
                                padding: EdgeInsets.all(10),
                                child: TextButton(
                                  style: ButtonStyle(
                                    padding: MaterialStateProperty.all(
                                        EdgeInsets.zero),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      loading = true;
                                    });
                                    Navigator.push(
                                        context,
                                        SlideRightRoute(
                                          page: ReadingScreen(
                                            data: writing,
                                            author: widget.project_name,
                                          ),
                                        ));
                                    setState(() {
                                      loading = false;
                                    });
                                  },
                                  child: Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30.0),
                                    ),
                                    clipBehavior: Clip.antiAlias,
                                    elevation: 11,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        writing.data()['images'] != null
                                            ? writing.data()['images'] !=
                                                    'No Image'
                                                ? Container(
                                                    height: 110,
                                                    width: size.width,
                                                    child: CachedNetworkImage(
                                                      fit: BoxFit.cover,
                                                      filterQuality:
                                                          FilterQuality.none,
                                                      height: 110,
                                                      width: 100,
                                                      placeholder:
                                                          (context, url) =>
                                                              Container(
                                                        height: 50,
                                                        width: 50,
                                                        child: Transform.scale(
                                                          scale: 0.1,
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
                                                      ),
                                                      errorWidget: (context,
                                                              url, error) =>
                                                          Icon(
                                                        Icons.error,
                                                        color: footyColor,
                                                      ),
                                                      imageUrl: writing
                                                          .data()['images'][0],
                                                    ),
                                                  )
                                                : Container()
                                            : Container(),
                                        SizedBox(height: 10),
                                        Container(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    width: size.width * 0.6,
                                                    child: Text(
                                                      writing.data()['name'],
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
                                                  ),
                                                ],
                                              ),
                                              SizedBox(width: 10),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                children: [
                                                  Text(
                                                    getDate(writing
                                                        .data()['date']
                                                        .seconds),
                                                    textScaleFactor: 1,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style:
                                                        GoogleFonts.montserrat(
                                                      textStyle: TextStyle(
                                                        color: primaryColor,
                                                        fontSize: 10,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            : Container(),
                      widget.project_authors
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
                                        page: BranchWritingScreen(
                                          id: widget.id,
                                          project_id: widget.project_id,
                                          project_name: widget.project_name,
                                          project_owner: widget.project_owner,
                                          isEmpty: true,
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
                                          CupertinoIcons.doc_on_doc_fill,
                                          color: footyColor,
                                          size: 15,
                                        ),
                                        SizedBox(height: 5),
                                        Text(
                                          'Добавьте новую историю',
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
                            )
                          : Container(),
                      SizedBox(
                        height: 10,
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
  }
}
