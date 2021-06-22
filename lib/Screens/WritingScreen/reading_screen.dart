import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:docx_template/docx_template.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/models/documents/document.dart';
import 'package:flutter_quill/widgets/controller.dart';
import 'package:flutter_quill/widgets/default_styles.dart';
import 'package:flutter_quill/widgets/editor.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:lycread/Models/PushNotificationMessage.dart';
import 'package:lycread/Screens/ProfileScreen/view_profile_screen.dart';
import 'package:lycread/Screens/ProjectScreen/project_info_screen.dart';
import 'package:lycread/Screens/WritingScreen/comment_reply_screen.dart';
import 'package:lycread/Screens/WritingScreen/writing_screen.dart';
import 'package:lycread/Services/ad_service.dart';
import 'package:lycread/widgets/label_button.dart';
import 'package:lycread/widgets/rounded_button.dart';
import 'package:lycread/widgets/slide_right_route_animation.dart';
import 'package:lycread/widgets/up_button.dart';
import 'package:open_file/open_file.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';
import '../../constants.dart';
import '../loading_screen.dart';
import 'package:flutter/services.dart' show rootBundle;

class ReadingScreen extends StatefulWidget {
  QueryDocumentSnapshot data;
  String author;
  String id;
  ReadingScreen({Key key, this.data, this.author, this.id: null})
      : super(key: key);
  @override
  _ReadingScreenState createState() => _ReadingScreenState();
}

class _ReadingScreenState extends State<ReadingScreen> {
  final _formKey = GlobalKey<FormState>();
  bool loading = false;
  bool isComm = false;
  bool isYellow = false;
  bool allLinksShown = false;
  Color firstColor = whiteColor;
  Color yellowColor = Color.fromRGBO(255, 255, 225, 1.0);
  Color secondColor = Color.fromRGBO(43, 43, 43, 1.0);
  int rates = 0;
  String ratStr = '';
  String commentText = '';
  StreamSubscription<DocumentSnapshot> subscription;
  QuillController _controller = QuillController.basic();
  List comments = [];
  List ids = [];
  Map photos = {};
  BannerAd bannerAd;
  QuerySnapshot childLinks;
  TextEditingController controller = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final adState = Provider.of<AdService>(context);
    adState.initialization.then((status) => {
          setState(() {
            bannerAd = BannerAd(
              adUnitId: adState.bannerAdUnitId,
              request: AdRequest(),
              size: AdSize.largeBanner,
              listener: adState.adListener,
            )..load();
          })
        });
  }

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }

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

  Future<void> getPhotos() async {
    for (var comment in comments) {
      if (comment['author_id'] != null) {
        DocumentSnapshot data = await FirebaseFirestore.instance
            .collection('users')
            .doc(comment['author_id'])
            .get();
        if (this.mounted) {
          setState(() {
            photos.addAll({comment['author_id']: data.data()['photo']});
          });
        } else {
          photos.addAll({comment['author_id']: data.data()['photo']});
        }
      } else {
        if (this.mounted) {
          setState(() {
            photos.addAll({comment['author_id']: 'No Image'});
          });
        } else {
          photos.addAll({comment['author_id']: 'No Image'});
        }
      }
    }
  }

  Future<void> manageTags() async {
    DocumentSnapshot user = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser.uid)
        .get();
    Map userStats = user.data()['stats'];
    List tags = [];
    List tagsRec = [];
    List recoms = widget.data.data()['tags'];
    for (String tag in widget.data.data()['tags']) {
      if (userStats[tag] != null) {
        userStats[tag] = userStats[tag] + 1;
      } else {
        userStats[tag] = 1;
      }
    }
    tags = userStats.values.toList();
    tags.sort();
    tagsRec.add(tags.reversed.first);
    tagsRec.add(tags.reversed.elementAt(1));
    tagsRec.add(tags.reversed.elementAt(2));
    userStats.forEach((key, value) {
      if (tagsRec.contains(value)) {
        recoms.add(key);
      }
    });
    print("RECOMS");
    print(recoms);
    FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser.uid)
        .update({'stats': userStats, 'recommendations': recoms});
  }

  Future<void> manageFinances() async {
    FirebaseFirestore.instance
        .collection('users')
        .doc(widget.data.data()['author'])
        .update({
      'balance': FieldValue.increment(1.0),
      'membershipLogs': FieldValue.arrayUnion([
        {
          'date': DateTime.now().toString(),
          'wr_id': widget.data.id,
          'sum': 1.0,
        }
      ])
    });
  }

  Future<void> prepare() async {
    if (widget.id != null) {
      QuerySnapshot datas = await FirebaseFirestore.instance
          .collection('writings')
          .where('id', isEqualTo: widget.id)
          .get();
      widget.data = datas.docs.first;
    }
    if (widget.data.data()['children'] != null &&
        widget.data.data()['children'].length != 0) {
      for (Map m in widget.data.data()['children']) {
        ids.add(m['id']);
      }
      QuerySnapshot middleChildLnks = await FirebaseFirestore.instance
          .collection('writings')
          .where('id', whereIn: ids)
          .orderBy('rating')
          .limit(2)
          .get();
      if (this.mounted) {
        setState(() {
          childLinks = middleChildLnks;
        });
      } else {
        childLinks = middleChildLnks;
      }
    }

    if (widget.data.data()['rich_text'] != null) {
      var myJSON = jsonDecode(widget.data.data()['rich_text']);
      _controller = QuillController(
        document: Document.fromJson(myJSON),
        selection: TextSelection.collapsed(offset: 0),
      );
    }
    if (widget.data.data()['users_read'] != null) {
      if (!widget.data
          .data()['users_read']
          .contains(FirebaseAuth.instance.currentUser.uid)) {
        if (widget.data.data()['tags'] != null) {
          manageTags();
        }
        if (widget.data.data()['isMonetized'] != null &&
            widget.data.data()['isMonetized']) {
          manageFinances();
        }
        FirebaseFirestore.instance
            .collection('writings')
            .doc(widget.data.id)
            .update({
          'reads': widget.data.data()['reads'] + 1,
          'users_read':
              FieldValue.arrayUnion([FirebaseAuth.instance.currentUser.uid]),
        });
        FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser.uid)
            .update({
          'reads': FieldValue.arrayUnion([widget.data.id]),
        });
      }
    }
    subscription = FirebaseFirestore.instance
        .collection('writings')
        .doc(widget.data.id)
        .snapshots()
        .listen((docsnap) {
      if (docsnap.data()['rating'] != null) {
        if (this.mounted) {
          setState(() {
            docsnap.data()['comments'].length != 0
                ? comments = docsnap.data()['comments']
                : comments = [];
            if (docsnap.data()['rating'] > 999999) {
              rates = docsnap.data()['rating'];
              double numb = docsnap.data()['rating'] / 1000000;
              ratStr = numb.toStringAsFixed(1) + 'M';
            } else if (docsnap.data()['rating'] > 999) {
              rates = docsnap.data()['rating'];
              double numb = docsnap.data()['rating'] / 1000;
              ratStr = numb.toStringAsFixed(1) + 'K';
            } else {
              rates = docsnap.data()['rating'];
              ratStr = docsnap.data()['rating'].toString();
            }
            getPhotos();
          });
        } else {
          docsnap.data()['comments'].length != 0
              ? comments = docsnap.data()['comments']
              : comments = [];
          if (docsnap.data()['rating'] > 999999) {
            rates = docsnap.data()['rating'];
            double numb = docsnap.data()['rating'] / 1000000;
            ratStr = numb.toStringAsFixed(1) + 'M';
          } else if (docsnap.data()['rating'] > 999) {
            rates = docsnap.data()['rating'];
            double numb = docsnap.data()['rating'] / 1000;
            ratStr = numb.toStringAsFixed(1) + 'K';
          } else {
            rates = docsnap.data()['rating'];
            ratStr = docsnap.data()['rating'].toString();
          }
          getPhotos();
        }
      }
    });
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
              centerTitle: false,
              iconTheme: IconThemeData(color: firstColor),
              backgroundColor: secondColor,
              title: Text(
                'Публикация',
                textScaleFactor: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.montserrat(
                  textStyle: TextStyle(
                      color: firstColor,
                      fontSize: 20,
                      fontWeight: FontWeight.w300),
                ),
              ),
              actions: [
                TextButton(
                  child: Text(
                    'RePub',
                    textScaleFactor: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.montserrat(
                      textStyle: TextStyle(
                          color: footyColor,
                          fontSize: 17,
                          fontWeight: FontWeight.w300),
                    ),
                  ),
                  onPressed: () {
                    showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Выберите способ'),
                          content: Container(
                            height: size.height * 0.2,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                TextButton(
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
                                        page: WritingScreen(
                                          parentId: widget.data.id,
                                          data: widget.data.data(),
                                          parentAuthor: widget.author,
                                          isEmpty: true,
                                        ),
                                      ),
                                    );
                                    setState(() {
                                      loading = false;
                                    });
                                  },
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        CupertinoIcons.doc,
                                        color: primaryColor,
                                        size: 30,
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        'Без текста',
                                        textScaleFactor: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.montserrat(
                                          textStyle: TextStyle(
                                              color: primaryColor,
                                              fontSize: 15,
                                              fontWeight: FontWeight.w300),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 20),
                                TextButton(
                                  style: ButtonStyle(
                                      padding: MaterialStateProperty.all(
                                          EdgeInsets.zero)),
                                  onPressed: () {
                                    setState(() {
                                      loading = true;
                                    });
                                    Navigator.push(
                                      context,
                                      SlideRightRoute(
                                        page: WritingScreen(
                                          parentId: widget.data.id,
                                          data: widget.data.data(),
                                          parentAuthor: widget.author,
                                          isEmpty: false,
                                        ),
                                      ),
                                    );
                                    setState(() {
                                      loading = false;
                                    });
                                  },
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        CupertinoIcons.doc_richtext,
                                        color: primaryColor,
                                        size: 30,
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        'Скопировать',
                                        textScaleFactor: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.montserrat(
                                          textStyle: TextStyle(
                                              color: primaryColor,
                                              fontSize: 15,
                                              fontWeight: FontWeight.w300),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text(
                                'Отменить',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
                FirebaseAuth.instance.currentUser.uid ==
                        widget.data.data()['author']
                    ? IconButton(
                        color: Colors.red,
                        icon: Icon(
                          CupertinoIcons.trash,
                        ),
                        onPressed: () {
                          showDialog(
                            barrierDismissible: false,
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Удалить?'),
                                content:
                                    const Text('Хотите ли вы удалить историю?'),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () {
                                      setState(() {
                                        loading = true;
                                      });
                                      FirebaseFirestore.instance
                                          .collection('writings')
                                          .doc(widget.data.id)
                                          .delete()
                                          .catchError((error) {
                                        print('MISTAKE HERE');
                                        print(error);
                                        Navigator.of(context).pop(false);
                                        PushNotificationMessage notification =
                                            PushNotificationMessage(
                                          title: 'Ошибка',
                                          body: 'Неудалось удалить историю',
                                        );
                                        showSimpleNotification(
                                          Container(
                                              child: Text(notification.body)),
                                          position: NotificationPosition.top,
                                          background: Colors.red,
                                        );
                                      });
                                      setState(() {
                                        loading = false;
                                      });
                                      Navigator.of(context).pop(true);
                                      Navigator.pop(context);
                                    },
                                    child: const Text(
                                      'Yes',
                                      style: TextStyle(color: footyColor),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(false),
                                    child: const Text(
                                      'No',
                                      style: TextStyle(color: Colors.red),
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
            ),
            backgroundColor: firstColor,
            body: CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: size.height * 0.5,
                  backgroundColor: whiteColor,
                  floating: false,
                  pinned: false,
                  snap: false,
                  flexibleSpace: Stack(
                    children: [
                      Container(
                        height: size.height * 0.5,
                        width: size.width,
                        child: CachedNetworkImage(
                          fit: BoxFit.cover,
                          filterQuality: FilterQuality.none,
                          placeholder: (context, url) => Transform.scale(
                            scale: 0.2,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.0,
                              backgroundColor: footyColor,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(primaryColor),
                            ),
                          ),
                          errorWidget: (context, url, error) => Icon(
                            Icons.error,
                            color: whiteColor,
                          ),
                          imageUrl: widget.data.data()['images'][0],
                        ),
                      ),
                      Container(
                        alignment: Alignment.bottomLeft,
                        height: size.height * 0.5,
                        width: size.width,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            stops: [0, 0.8],
                            colors: [
                              Color.fromRGBO(33, 33, 33, 0),
                              primaryColor
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        child: Container(
                          width: size.width * 0.5,
                          padding: EdgeInsets.all(15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                widget.data.data()['name'],
                                textScaleFactor: 1,
                                textAlign: TextAlign.start,
                                overflow: TextOverflow.fade,
                                maxLines: 3,
                                style: GoogleFonts.montserrat(
                                  textStyle: TextStyle(
                                      color: whiteColor,
                                      fontSize: 27,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              TextButton(
                                onPressed: () async {
                                  setState(() {
                                    loading = true;
                                  });
                                  var data = await FirebaseFirestore.instance
                                      .collection('users')
                                      // .where('id',
                                      //     isEqualTo: widget.data.data()['author'])
                                      .doc(widget.data.data()['author'])
                                      .get();
                                  if (widget.data.data()['project_id'] !=
                                      null) {
                                    Navigator.push(
                                      context,
                                      SlideRightRoute(
                                        page: ProjectInfoScreen(
                                            id: widget.data
                                                .data()['project_id']),
                                      ),
                                    );
                                  } else {
                                    Navigator.push(
                                      context,
                                      SlideRightRoute(
                                        page: VProfileScreen(
                                          data: data,
                                        ),
                                      ),
                                    );
                                  }
                                  setState(() {
                                    loading = false;
                                  });
                                },
                                child: Text(
                                  'By ' + widget.author,
                                  textScaleFactor: 1,
                                  textAlign: TextAlign.start,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.montserrat(
                                    textStyle: TextStyle(
                                        color: whiteColor,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w300),
                                  ),
                                ),
                              ),
                              Text(
                                widget.data.data()['reads'] != null
                                    ? getFnum(widget.data.data()['reads']) +
                                        ' | ' +
                                        getDate(
                                            widget.data.data()['date'].seconds)
                                    : widget.data.data()['genre'],
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                textScaleFactor: 1,
                                style: GoogleFonts.montserrat(
                                  textStyle: TextStyle(
                                    color: whiteColor,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: size.width * 0.5,
                          alignment: Alignment.centerRight,
                          margin: EdgeInsets.all(5),
                          child: Row(
                            children: [
                              IconButton(
                                color: whiteColor,
                                icon: Icon(CupertinoIcons.book_solid),
                                onPressed: () {
                                  setState(() {
                                    if (!isComm) {
                                      isYellow
                                          ? firstColor = whiteColor
                                          : firstColor = yellowColor;
                                    } else {
                                      isYellow
                                          ? secondColor = whiteColor
                                          : secondColor = yellowColor;
                                    }
                                    isYellow = !isYellow;
                                  });
                                },
                              ),
                              LabelButton(
                                isC: false,
                                reverse: FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(FirebaseAuth.instance.currentUser.uid),
                                containsValue: widget.data.id,
                                color1: footyColor,
                                color2: whiteColor,
                                ph: 30,
                                pw: 30,
                                size: 30,
                                onTap: () {
                                  setState(() {
                                    FirebaseFirestore.instance
                                        .collection('users')
                                        .doc(FirebaseAuth
                                            .instance.currentUser.uid)
                                        .update({
                                      'favourites': FieldValue.arrayUnion(
                                          [widget.data.id])
                                    }).catchError((error) {
                                      PushNotificationMessage notification =
                                          PushNotificationMessage(
                                        title: 'Fail',
                                        body: 'Failed to update favourites',
                                      );
                                      showSimpleNotification(
                                        Container(
                                            child: Text(notification.body)),
                                        position: NotificationPosition.top,
                                        background: Colors.red,
                                      );
                                      if (this.mounted) {
                                        setState(() {
                                          loading = false;
                                        });
                                      } else {
                                        loading = false;
                                      }
                                    });
                                  });
                                },
                                onTap2: () {
                                  setState(() {
                                    FirebaseFirestore.instance
                                        .collection('users')
                                        .doc(FirebaseAuth
                                            .instance.currentUser.uid)
                                        .update({
                                      'favourites': FieldValue.arrayRemove(
                                          [widget.data.id])
                                    }).catchError((error) {
                                      PushNotificationMessage notification =
                                          PushNotificationMessage(
                                        title: 'Fail',
                                        body: 'Failed to update favourites',
                                      );
                                      showSimpleNotification(
                                        Container(
                                            child: Text(notification.body)),
                                        position: NotificationPosition.top,
                                        background: Colors.red,
                                      );
                                      if (this.mounted) {
                                        setState(() {
                                          loading = false;
                                        });
                                      } else {
                                        loading = false;
                                      }
                                    });
                                  });
                                },
                              ),
                              Column(
                                children: [
                                  UpButton(
                                    isC: false,
                                    reverse: FirebaseFirestore.instance
                                        .collection('writings')
                                        .doc(widget.data.id),
                                    containsValue:
                                        FirebaseAuth.instance.currentUser.uid,
                                    color1: footyColor,
                                    color2: whiteColor,
                                    ph: 30,
                                    pw: 30,
                                    size: 30,
                                    onTap: () {
                                      setState(() {
                                        FirebaseFirestore.instance
                                            .collection('writings')
                                            .doc(widget.data.id)
                                            .update({
                                          'rating': rates + 1,
                                          'users_rated': FieldValue.arrayUnion([
                                            FirebaseAuth
                                                .instance.currentUser.uid
                                          ]),
                                        }).catchError((error) {
                                          PushNotificationMessage notification =
                                              PushNotificationMessage(
                                            title: 'Fail',
                                            body: 'Failed to up',
                                          );
                                          showSimpleNotification(
                                            Container(
                                                child: Text(notification.body)),
                                            position: NotificationPosition.top,
                                            background: Colors.red,
                                          );
                                          if (this.mounted) {
                                            setState(() {
                                              loading = false;
                                            });
                                          } else {
                                            loading = false;
                                          }
                                        });
                                      });
                                    },
                                    onTap2: () {
                                      setState(() {
                                        FirebaseFirestore.instance
                                            .collection('writings')
                                            .doc(widget.data.id)
                                            .update({
                                          'rating': rates - 1,
                                          'users_rated':
                                              FieldValue.arrayRemove([
                                            FirebaseAuth
                                                .instance.currentUser.uid
                                          ])
                                        }).catchError((error) {
                                          PushNotificationMessage notification =
                                              PushNotificationMessage(
                                            title: 'Fail',
                                            body: 'Failed tp up',
                                          );
                                          showSimpleNotification(
                                            Container(
                                                child: Text(notification.body)),
                                            position: NotificationPosition.top,
                                            background: Colors.red,
                                          );
                                          if (this.mounted) {
                                            setState(() {
                                              loading = false;
                                            });
                                          } else {
                                            loading = false;
                                          }
                                        });
                                      });
                                    },
                                  ),
                                  Text(
                                    ratStr,
                                    textScaleFactor: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.montserrat(
                                      textStyle: TextStyle(
                                          color: whiteColor,
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      Container(
                        padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
                        child: Column(
                          children: [
                            if (widget.data.data()['parent'] != null)
                              SizedBox(height: 20),
                            if (widget.data.data()['parent'] != null)
                              Text(
                                'RePub из',
                                textScaleFactor: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.montserrat(
                                  textStyle: TextStyle(
                                      color: primaryColor,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w300),
                                ),
                              ),
                            if (widget.data.data()['parent'] != null)
                              widget.data.data()['parent'] != null
                                  ? TextButton(
                                      style: ButtonStyle(
                                          padding: MaterialStateProperty.all(
                                              EdgeInsets.zero)),
                                      onPressed: () async {
                                        setState(() {
                                          loading = true;
                                        });
                                        QuerySnapshot story =
                                            await FirebaseFirestore.instance
                                                .collection('writings')
                                                .where('id',
                                                    isEqualTo: widget.data
                                                        .data()['parent']['id'])
                                                .limit(1)
                                                .get();
                                        if (story.docs.first != null) {
                                          Navigator.push(
                                            context,
                                            SlideRightRoute(
                                              page: ReadingScreen(
                                                data: story.docs.first,
                                                author: widget.data
                                                    .data()['parent']['author'],
                                              ),
                                            ),
                                          );
                                        }
                                        setState(() {
                                          loading = false;
                                        });
                                      },
                                      child: Container(
                                        margin:
                                            EdgeInsets.fromLTRB(15, 0, 15, 0),
                                        child: Card(
                                          child: Padding(
                                            padding: EdgeInsets.fromLTRB(
                                                10, 15, 10, 15),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  CupertinoIcons.link,
                                                  size: 30,
                                                  color: primaryColor,
                                                ),
                                                SizedBox(width: 20),
                                                Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      widget.data
                                                              .data()['parent']
                                                          ['data']['name'],
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
                                                      height: 5,
                                                    ),
                                                    Text(
                                                      widget.data.data()[
                                                                      'parent']
                                                                  ['author'] !=
                                                              null
                                                          ? widget.data.data()[
                                                                  'parent']
                                                              ['author']
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
                                                  ],
                                                )
                                              ],
                                            ),
                                          ),
                                          color: footyColor,
                                        ),
                                      ),
                                    )
                                  : Container(),
                            SizedBox(height: 20),
                            if (bannerAd == null)
                              Container()
                            else
                              widget.data.data()['isMonetized'] != null
                                  ? widget.data.data()['isMonetized']
                                      ? Container(
                                          height: 100,
                                          child: AdWidget(
                                            ad: bannerAd,
                                          ),
                                        )
                                      : Container()
                                  : Container(),
                            widget.data.data()['isMonetized'] != null
                                ? widget.data.data()['isMonetized']
                                    ? Text(
                                        'Реклама от автора',
                                        textScaleFactor: 1,
                                        style: GoogleFonts.montserrat(
                                          textStyle: TextStyle(
                                              color: secondColor,
                                              fontSize: 15,
                                              fontWeight: FontWeight.w300),
                                        ),
                                      )
                                    : Container()
                                : Container(),
                            SizedBox(height: 20),
                            widget.data.data()['text'] != null
                                ? Center(
                                    child: Container(
                                      width: double.infinity,
                                      child: Text(
                                        widget.data.data()['text'],
                                        textScaleFactor: 1,
                                        style: GoogleFonts.montserrat(
                                          textStyle: TextStyle(
                                              color: secondColor,
                                              fontSize: 20,
                                              fontWeight: FontWeight.w300),
                                        ),
                                      ),
                                    ),
                                  )
                                : Container(),
                            SizedBox(height: 10),
                            widget.data.data()['rich_text'] != null
                                ? Container(
                                    margin: EdgeInsets.all(3),
                                    padding: EdgeInsets.all(10),
                                    width: double.infinity,
                                    child: QuillEditor(
                                      customStyles: DefaultStyles(
                                        placeHolder: DefaultTextBlockStyle(
                                          TextStyle(
                                              color: secondColor, fontSize: 20),
                                          Tuple2<double, double>(10, 10),
                                          Tuple2<double, double>(3, 3),
                                          BoxDecoration(),
                                        ),
                                        paragraph: DefaultTextBlockStyle(
                                          TextStyle(
                                              color: secondColor, fontSize: 20),
                                          Tuple2<double, double>(10, 10),
                                          Tuple2<double, double>(3, 3),
                                          BoxDecoration(),
                                        ),
                                        // h1: DefaultTextBlockStyle(
                                        //   TextStyle(color: secondColor),
                                        //   Tuple2<double, double>(5, 5),
                                        //   Tuple2<double, double>(3, 3),
                                        //   BoxDecoration(),
                                        // ),
                                      ),
                                      focusNode: FocusNode(),
                                      autoFocus: true,
                                      expands: false,
                                      scrollable: false,
                                      scrollController: ScrollController(),
                                      readOnly: true,
                                      showCursor: false,
                                      padding: EdgeInsets.all(5),
                                      controller: _controller,
                                    ),
                                  )
                                : Container(),
                            SizedBox(height: 20),
                            if (widget.data.data()['children'] != null &&
                                widget.data.data()['children'].length != 0 &&
                                childLinks != null)
                              Center(
                                child: Text(
                                  'Линки',
                                  textScaleFactor: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.montserrat(
                                    textStyle: TextStyle(
                                        color: primaryColor,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w300),
                                  ),
                                ),
                              ),
                            if (widget.data.data()['children'] != null &&
                                widget.data.data()['children'].length != 0 &&
                                childLinks != null)
                              for (QueryDocumentSnapshot child
                                  in childLinks.docs)
                                TextButton(
                                  style: ButtonStyle(
                                    padding: MaterialStateProperty.all(
                                        EdgeInsets.zero),
                                  ),
                                  onPressed: () async {
                                    setState(() {
                                      loading = true;
                                    });
                                    Navigator.push(
                                      context,
                                      SlideRightRoute(
                                        page: ReadingScreen(
                                          data: child,
                                          author: child.data()['author'],
                                        ),
                                      ),
                                    );
                                    setState(() {
                                      loading = false;
                                    });
                                  },
                                  child: Container(
                                    margin: EdgeInsets.all(10),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          CupertinoIcons.link,
                                          size: 20,
                                          color: primaryColor,
                                        ),
                                        SizedBox(width: 20),
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              child.data()['name'],
                                              textScaleFactor: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: GoogleFonts.montserrat(
                                                textStyle: TextStyle(
                                                  color: primaryColor,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                            if (widget.data.data()['children'] != null &&
                                widget.data.data()['children'].length != 0 &&
                                childLinks != null &&
                                !allLinksShown)
                              Center(
                                child: TextButton(
                                  style: ButtonStyle(
                                    padding: MaterialStateProperty.all(
                                        EdgeInsets.zero),
                                  ),
                                  onPressed: () async {
                                    QuerySnapshot middleChildLnks =
                                        await FirebaseFirestore.instance
                                            .collection('writings')
                                            .where('id', whereIn: ids)
                                            .orderBy('rating')
                                            .get();
                                    setState(() {
                                      allLinksShown = true;
                                      childLinks = middleChildLnks;
                                    });
                                  },
                                  child: Text(
                                    'Показать все',
                                    textScaleFactor: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.montserrat(
                                      textStyle: TextStyle(
                                          color: primaryColor,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w300),
                                    ),
                                  ),
                                ),
                              ),
                            Center(
                              child: CupertinoButton(
                                onPressed: () async {
                                  // Uint8List tempBytes = await FirebaseStorage
                                  //     .instance
                                  //     .ref()
                                  //     .child('template.docx')
                                  //     .getData();
                                  // final template = File.fromRawPath(tempBytes);

                                  // final docx = await DocxTemplate.fromBytes(
                                  //     await template.readAsBytes());
                                  final data = await rootBundle
                                      .load('assets/images/template.docx');
                                  final bytes = data.buffer.asUint8List();

                                  final docx =
                                      await DocxTemplate.fromBytes(bytes);
                                  Content content = Content();
                                  content
                                    ..add(TextContent(
                                        "docname", widget.data.data()['name']))
                                    ..add(
                                      TextContent(
                                        "multilineText",
                                        Document.fromJson(jsonDecode(widget.data
                                                .data()['rich_text']))
                                            .toPlainText(),
                                      ),
                                    );
                                  Directory appDocDir =
                                      await getApplicationDocumentsDirectory();
                                  String appDocPath = appDocDir.path;
                                  final file = File(
                                      appDocPath + widget.data.id + ".docx");
                                  final d = await docx.generate(content);
                                  if (d != null) await file.writeAsBytes(d);
                                  OpenFile.open(file.path);
                                },
                                padding: EdgeInsets.zero,
                                child: Container(
                                  width: size.width * 0.5,
                                  child: Card(
                                    color: Colors.blue,
                                    child: Padding(
                                      padding: EdgeInsets.all(10),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            CupertinoIcons.tray_arrow_down,
                                            size: 23,
                                            color: whiteColor,
                                          ),
                                          SizedBox(width: 5),
                                          Text(
                                            'Word file',
                                            textScaleFactor: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.montserrat(
                                              textStyle: TextStyle(
                                                  color: whiteColor,
                                                  fontSize: 17,
                                                  fontWeight: FontWeight.w300),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 10),
                            Divider(
                              color: secondColor,
                              thickness: 2,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(14.0),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: TextFormField(
                                            controller: controller,
                                            cursorColor: secondColor,
                                            maxLines: null,
                                            style:
                                                TextStyle(color: secondColor),
                                            validator: (val) => val.length > 1
                                                ? null
                                                : 'Минимум 2 символа',
                                            keyboardType:
                                                TextInputType.multiline,
                                            maxLength: 500,
                                            onChanged: (value) {
                                              commentText = value;
                                            },
                                            decoration: InputDecoration(
                                              counterStyle:
                                                  TextStyle(color: secondColor),
                                              hintText: "Коммент",
                                              border: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: secondColor),
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        RoundedButton(
                                          width: 0.2,
                                          ph: 40,
                                          text: 'Ok',
                                          press: () async {
                                            if (_formKey.currentState
                                                .validate()) {
                                              await FirebaseFirestore.instance
                                                  .collection('writings')
                                                  .doc(widget.data.id)
                                                  .update({
                                                'comments':
                                                    FieldValue.arrayUnion([
                                                  {
                                                    'date': DateTime.now(),
                                                    'text': commentText.trim(),
                                                    'author': FirebaseAuth
                                                        .instance
                                                        .currentUser
                                                        .displayName,
                                                    'author_id': FirebaseAuth
                                                        .instance
                                                        .currentUser
                                                        .uid,
                                                  }
                                                ])
                                              }).catchError((error) {
                                                PushNotificationMessage
                                                    notification =
                                                    PushNotificationMessage(
                                                  title: 'Ошибка',
                                                  body:
                                                      'Неудалось добавить комментарий',
                                                );
                                                showSimpleNotification(
                                                  Container(
                                                      child: Text(
                                                          notification.body)),
                                                  position:
                                                      NotificationPosition.top,
                                                  background: Colors.red,
                                                );
                                              });
                                              String nText = FirebaseAuth
                                                  .instance
                                                  .currentUser
                                                  .displayName;
                                              String nText1 =
                                                  widget.data.data()['name'];
                                              if (FirebaseAuth.instance
                                                      .currentUser.uid !=
                                                  widget.data
                                                      .data()['author']) {
                                                await FirebaseFirestore.instance
                                                    .collection('users')
                                                    .doc(widget.data
                                                        .data()['author'])
                                                    .update({
                                                  'actions':
                                                      FieldValue.arrayUnion([
                                                    {
                                                      'author': FirebaseAuth
                                                          .instance
                                                          .currentUser
                                                          .uid,
                                                      'seen': false,
                                                      'text':
                                                          '$nText прокомментировал $nText1',
                                                      'type': 'New comment',
                                                      'date': DateTime.now(),
                                                      'post_id': widget.data.id,
                                                    }
                                                  ]),
                                                });
                                              }
                                              PushNotificationMessage
                                                  notification =
                                                  PushNotificationMessage(
                                                title: 'Успех',
                                                body: 'Комментарий добавлен',
                                              );
                                              showSimpleNotification(
                                                Container(
                                                    child: Text(
                                                        notification.body)),
                                                position:
                                                    NotificationPosition.top,
                                                background: footyColor,
                                              );
                                              setState(() {
                                                controller.clear();
                                                commentText = '';
                                              });
                                            }
                                          },
                                          color: secondColor,
                                          textColor: firstColor,
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    comments.length != 0
                                        ? ListView.builder(
                                            physics:
                                                new NeverScrollableScrollPhysics(),
                                            scrollDirection: Axis.vertical,
                                            shrinkWrap: true,
                                            padding:
                                                EdgeInsets.only(bottom: 10),
                                            itemCount: comments.length,
                                            itemBuilder: (BuildContext context,
                                                    int index) =>
                                                Column(
                                              children: [
                                                Row(
                                                  children: [
                                                    comments[comments.length -
                                                                    1 -
                                                                    index]
                                                                ['author_id'] !=
                                                            null
                                                        ? photos[comments[comments
                                                                            .length -
                                                                        1 -
                                                                        index][
                                                                    'author_id']] !=
                                                                null
                                                            ? photos[comments[comments
                                                                                .length -
                                                                            1 -
                                                                            index]
                                                                        [
                                                                        'author_id']] !=
                                                                    'No Image'
                                                                ? Container(
                                                                    width: 40,
                                                                    height: 40,
                                                                    child: ClipRRect(
                                                                        borderRadius: BorderRadius.circular(25.0),
                                                                        child: CachedNetworkImage(
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
                                                                          imageUrl: photos[comments[comments.length -
                                                                              1 -
                                                                              index]['author_id']],
                                                                        )),
                                                                  )
                                                                : Container(
                                                                    width: 40,
                                                                    height: 40,
                                                                    child:
                                                                        ClipRRect(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              25.0),
                                                                      child: Image
                                                                          .asset(
                                                                        'assets/images/User.png',
                                                                        fit: BoxFit
                                                                            .cover,
                                                                      ),
                                                                    ),
                                                                  )
                                                            : Container(
                                                                width: 40,
                                                                height: 40,
                                                                child:
                                                                    ClipRRect(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              25.0),
                                                                  child: Image
                                                                      .asset(
                                                                    'assets/images/User.png',
                                                                    fit: BoxFit
                                                                        .cover,
                                                                  ),
                                                                ),
                                                              )
                                                        : Container(
                                                            width: 40,
                                                            height: 40,
                                                            child: ClipRRect(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          25.0),
                                                              child:
                                                                  Image.asset(
                                                                'assets/images/User.png',
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                            ),
                                                          ),
                                                    Expanded(
                                                      child: Container(
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: Row(
                                                            children: [
                                                              Expanded(
                                                                child: Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Text(
                                                                      comments[comments
                                                                              .length -
                                                                          1 -
                                                                          index]['text'],
                                                                      maxLines:
                                                                          100,
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
                                                                              secondColor,
                                                                          fontSize:
                                                                              15,
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    SizedBox(
                                                                      height: 5,
                                                                    ),
                                                                    Text(
                                                                      comments[comments.length - 1 - index]['author'] !=
                                                                              null
                                                                          ? comments[comments.length -
                                                                              1 -
                                                                              index]['author']
                                                                          : 'No author',
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                      textScaleFactor:
                                                                          1,
                                                                      style: GoogleFonts
                                                                          .montserrat(
                                                                        textStyle:
                                                                            TextStyle(
                                                                          color:
                                                                              secondColor,
                                                                          fontSize:
                                                                              10,
                                                                          fontWeight:
                                                                              FontWeight.w300,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              TextButton(
                                                                onPressed: () {
                                                                  setState(() {
                                                                    loading =
                                                                        true;
                                                                  });
                                                                  Navigator
                                                                      .push(
                                                                    context,
                                                                    SlideRightRoute(
                                                                      page:
                                                                          CommentReplyScreen(
                                                                        post_id: widget
                                                                            .data
                                                                            .id,
                                                                        all:
                                                                            comments,
                                                                        data: comments[comments.length -
                                                                            1 -
                                                                            index],
                                                                      ),
                                                                    ),
                                                                  );
                                                                  setState(() {
                                                                    loading =
                                                                        false;
                                                                  });
                                                                },
                                                                child: Text(
                                                                  comments[comments.length - 1 - index]
                                                                              [
                                                                              'replies'] !=
                                                                          null
                                                                      ? comments[comments.length - 1 - index]['replies']
                                                                              .length
                                                                              .toString() +
                                                                          ' replies'
                                                                      : 'Reply',
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  textScaleFactor:
                                                                      1,
                                                                  style: GoogleFonts
                                                                      .montserrat(
                                                                    textStyle:
                                                                        TextStyle(
                                                                      color: Colors
                                                                          .blue,
                                                                      fontSize:
                                                                          12,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w300,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Divider(
                                                  color: secondColor,
                                                ),
                                              ],
                                            ),
                                          )
                                        : Center(
                                            child: Text(
                                              'No comments',
                                              textScaleFactor: 1,
                                              style: GoogleFonts.montserrat(
                                                textStyle: TextStyle(
                                                    color: secondColor,
                                                    fontSize: 20,
                                                    fontWeight:
                                                        FontWeight.w300),
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
                    ],
                  ),
                ),
              ],
            ),
          );
  }
}
