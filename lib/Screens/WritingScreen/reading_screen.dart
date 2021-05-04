import 'dart:async';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/models/documents/document.dart';
import 'package:flutter_quill/widgets/controller.dart';
import 'package:flutter_quill/widgets/editor.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lycread/Models/PushNotificationMessage.dart';
import 'package:lycread/Screens/ProfileScreen/view_profile_screen.dart';
import 'package:lycread/Screens/WritingScreen/comment_reply_screen.dart';
import 'package:lycread/widgets/label_button.dart';
import 'package:lycread/widgets/rounded_button.dart';
import 'package:lycread/widgets/slide_right_route_animation.dart';
import 'package:lycread/widgets/up_button.dart';
import 'package:overlay_support/overlay_support.dart';
import '../../constants.dart';
import '../loading_screen.dart';

class ReadingScreen extends StatefulWidget {
  QueryDocumentSnapshot data;
  String author;
  ReadingScreen({Key key, this.data, this.author}) : super(key: key);
  @override
  _ReadingScreenState createState() => _ReadingScreenState();
}

class _ReadingScreenState extends State<ReadingScreen> {
  final _formKey = GlobalKey<FormState>();
  bool loading = false;
  bool isComm = false;
  bool isYellow = false;
  Color firstColor = whiteColor;
  Color yellowColor = Color.fromRGBO(255, 255, 225, 1.0);
  Color secondColor = Color.fromRGBO(43, 43, 43, 1.0);
  int rates = 0;
  String ratStr = '';
  String commentText = '';
  StreamSubscription<DocumentSnapshot> subscription;
  QuillController _controller = QuillController.basic();
  List comments = [];
  Map photos = {};

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
    print('HERE');
    print(photos);
  }

  @override
  void initState() {
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
          'reads':
              FieldValue.arrayUnion([FirebaseAuth.instance.currentUser.uid]),
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
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return loading
        ? LoadingScreen()
        : Scaffold(
            appBar: AppBar(
              centerTitle: true,
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
                FirebaseAuth.instance.currentUser.uid ==
                        widget.data.data()['author']
                    ? RoundedButton(
                        pw: 85,
                        ph: 45,
                        text: 'Удалить',
                        press: () async {
                          showDialog(
                            barrierDismissible: false,
                            context: context,
                            builder: (BuildContext context) {
                              return CupertinoAlertDialog(
                                title: const Text('Удалить?'),
                                content:
                                    const Text('Хотите ли вы удалить историю?'),
                                actions: <Widget>[
                                  CupertinoDialogAction(
                                      onPressed: () =>
                                          Navigator.of(context).pop(false),
                                      child: const Text('No')),
                                  CupertinoDialogAction(
                                    isDestructiveAction: true,
                                    onPressed: () async {
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
                                    child: const Text('Yes'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        color: Colors.red,
                        textColor: whiteColor,
                      )
                    : Container(),
              ],
            ),
            backgroundColor: firstColor,
            // appBar: AppBar(
            //   elevation: 10,
            //   toolbarHeight: size.height * 0.1,
            //   backgroundColor: whiteColor,
            //   title: Text(
            //     widget.data.data()['name'],
            //     textScaleFactor: 1,
            //     overflow: TextOverflow.ellipsis,
            //     style: GoogleFonts.montserrat(
            //       textStyle: TextStyle(
            //           color: darkPrimaryColor,
            //           fontSize: 30,
            //           fontWeight: FontWeight.bold),
            //     ),
            //   ),
            // ),
            body: SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.fromLTRB(25.0, 30, 25, 30),
                child: Column(
                  children: [
                    SizedBox(
                      height: 10,
                    ),
                    Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                      Column(
                        children: [
                          IconButton(
                            color: secondColor,
                            icon: Icon(Icons.bedtime),
                            onPressed: () {
                              // ignore: non_constant_identifier_names
                              Color _1 = secondColor;
                              // ignore: non_constant_identifier_names
                              Color _2 = firstColor;
                              setState(() {
                                firstColor = _1;
                                secondColor = _2;
                                isComm = !isComm;
                              });
                            },
                          ),
                          IconButton(
                            color: secondColor,
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
                        ],
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              widget.data.data()['name'],
                              textScaleFactor: 1,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.fade,
                              maxLines: 1000,
                              style: GoogleFonts.montserrat(
                                textStyle: TextStyle(
                                    color: secondColor,
                                    fontSize: 27,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            SizedBox(height: 10),
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
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  padding: EdgeInsets.all(10),
                                  color: secondColor,
                                  child: Text(
                                    'By ' + widget.author,
                                    textScaleFactor: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.montserrat(
                                      textStyle: TextStyle(
                                          color: footyColor,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w300),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        children: [
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
                                color2: secondColor,
                                ph: 45,
                                pw: 45,
                                size: 40,
                                onTap: () {
                                  setState(() {
                                    FirebaseFirestore.instance
                                        .collection('writings')
                                        .doc(widget.data.id)
                                        .update({
                                      'rating': rates + 1,
                                      'users_rated': FieldValue.arrayUnion([
                                        FirebaseAuth.instance.currentUser.uid
                                      ]),
                                    }).catchError((error) {
                                      PushNotificationMessage notification =
                                          PushNotificationMessage(
                                        title: 'Fail',
                                        body: 'Failed to update',
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
                                  // Scaffold.of(context).showSnackBar(
                                  //   SnackBar(
                                  //     duration: Duration(seconds: 2),
                                  //     backgroundColor: darkPrimaryColor,
                                  //     content: Text(
                                  //       'Успешно',
                                  //       style: GoogleFonts.montserrat(
                                  //         textStyle: TextStyle(
                                  //           color: whiteColor,
                                  //           fontSize: 15,
                                  //         ),
                                  //       ),
                                  //     ),
                                  //   ),
                                  // );
                                },
                                onTap2: () {
                                  setState(() {
                                    FirebaseFirestore.instance
                                        .collection('writings')
                                        .doc(widget.data.id)
                                        .update({
                                      'rating': rates - 1,
                                      'users_rated': FieldValue.arrayRemove([
                                        FirebaseAuth.instance.currentUser.uid
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
                                  // Scaffold.of(context).showSnackBar(
                                  //   SnackBar(
                                  //     duration: Duration(seconds: 2),
                                  //     backgroundColor: Colors.red,
                                  //     content: Text(
                                  //       'Removed from favourites',
                                  //       style: GoogleFonts.montserrat(
                                  //         textStyle: TextStyle(
                                  //           color: whiteColor,
                                  //           fontSize: 15,
                                  //         ),
                                  //       ),
                                  //     ),
                                  //   ),
                                  // );
                                },
                              ),
                              Text(
                                ratStr,
                                textScaleFactor: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.montserrat(
                                  textStyle: TextStyle(
                                      color: secondColor,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          LabelButton(
                            isC: false,
                            reverse: FirebaseFirestore.instance
                                .collection('users')
                                .doc(FirebaseAuth.instance.currentUser.uid),
                            containsValue: widget.data.id,
                            color1: footyColor,
                            color2: secondColor,
                            ph: 45,
                            pw: 45,
                            size: 40,
                            onTap: () {
                              setState(() {
                                FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(FirebaseAuth.instance.currentUser.uid)
                                    .update({
                                  'favourites':
                                      FieldValue.arrayUnion([widget.data.id])
                                }).catchError((error) {
                                  PushNotificationMessage notification =
                                      PushNotificationMessage(
                                    title: 'Fail',
                                    body: 'Failed to update favourites',
                                  );
                                  showSimpleNotification(
                                    Container(child: Text(notification.body)),
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
                                    .doc(FirebaseAuth.instance.currentUser.uid)
                                    .update({
                                  'favourites':
                                      FieldValue.arrayRemove([widget.data.id])
                                }).catchError((error) {
                                  PushNotificationMessage notification =
                                      PushNotificationMessage(
                                    title: 'Fail',
                                    body: 'Failed to update favourites',
                                  );
                                  showSimpleNotification(
                                    Container(child: Text(notification.body)),
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
                        ],
                      ),
                    ]),
                    SizedBox(height: 10),
                    Center(
                      child: Text(
                        widget.data.data()['reads'] != null
                            ? widget.data.data()['genre'] +
                                ' | ' +
                                getFnum(widget.data.data()['reads']) +
                                ' | ' +
                                getDate(widget.data.data()['date'].seconds)
                            : widget.data.data()['genre'],
                        overflow: TextOverflow.ellipsis,
                        textScaleFactor: 1,
                        style: GoogleFonts.montserrat(
                          textStyle: TextStyle(
                            color: secondColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Divider(
                      color: secondColor,
                      thickness: 2,
                    ),
                    widget.data.data()['images'] != 'No Image'
                        ? SizedBox(
                            height: 20,
                          )
                        : Container(),
                    widget.data.data()['images'] != 'No Image'
                        ? Container(
                            child: CachedNetworkImage(
                              filterQuality: FilterQuality.none,
                              placeholder: (context, url) => Transform.scale(
                                scale: 0.8,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.0,
                                  backgroundColor: footyColor,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      primaryColor),
                                ),
                              ),
                              errorWidget: (context, url, error) => Icon(
                                Icons.error,
                                color: footyColor,
                              ),
                              imageUrl: widget.data.data()['images'][0],
                            ),
                          )
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
                            margin: EdgeInsets.all(10),
                            padding: EdgeInsets.all(10),
                            width: double.infinity,
                            child: QuillEditor(
                              focusNode: FocusNode(),
                              autoFocus: false,
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
                    SizedBox(height: 10),
                    Divider(
                      color: secondColor,
                      thickness: 2,
                    ),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  cursorColor: secondColor,
                                  maxLines: null,
                                  style: TextStyle(color: secondColor),
                                  validator: (val) => val.length > 1
                                      ? null
                                      : 'Минимум 2 символов',
                                  keyboardType: TextInputType.multiline,
                                  maxLength: 500,
                                  onChanged: (value) {
                                    commentText = value;
                                  },
                                  decoration: InputDecoration(
                                    counterStyle: TextStyle(color: secondColor),
                                    hintText: "Коммент",
                                    border: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: secondColor),
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
                                  if (_formKey.currentState.validate()) {
                                    setState(() {
                                      loading = true;
                                    });
                                    await FirebaseFirestore.instance
                                        .collection('writings')
                                        .doc(widget.data.id)
                                        .update({
                                      'comments': FieldValue.arrayUnion([
                                        {
                                          'date': DateTime.now(),
                                          'text': commentText,
                                          'author': FirebaseAuth
                                              .instance.currentUser.displayName,
                                          'author_id': FirebaseAuth
                                              .instance.currentUser.uid,
                                          'replies': [],
                                        }
                                      ])
                                    }).catchError((error) {
                                      PushNotificationMessage notification =
                                          PushNotificationMessage(
                                        title: 'Ошибка',
                                        body: 'Неудалось добавить комментарий',
                                      );
                                      showSimpleNotification(
                                        Container(
                                            child: Text(notification.body)),
                                        position: NotificationPosition.top,
                                        background: Colors.red,
                                      );
                                    });
                                    String nText = FirebaseAuth
                                        .instance.currentUser.displayName;
                                    String nText1 = widget.data.data()['name'];
                                    if (FirebaseAuth.instance.currentUser.uid !=
                                        widget.data.data()['author']) {
                                      await FirebaseFirestore.instance
                                          .collection('users')
                                          .doc(widget.data.data()['author'])
                                          .update({
                                        'actions': FieldValue.arrayUnion([
                                          {
                                            'author': FirebaseAuth
                                                .instance.currentUser.uid,
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
                                    PushNotificationMessage notification =
                                        PushNotificationMessage(
                                      title: 'Успех',
                                      body: 'Комментарий добавлен',
                                    );
                                    showSimpleNotification(
                                      Container(child: Text(notification.body)),
                                      position: NotificationPosition.top,
                                      background: footyColor,
                                    );
                                    setState(() {
                                      loading = false;
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
                                  physics: new NeverScrollableScrollPhysics(),
                                  scrollDirection: Axis.vertical,
                                  shrinkWrap: true,
                                  padding: EdgeInsets.only(bottom: 10),
                                  itemCount: comments.length,
                                  itemBuilder:
                                      (BuildContext context, int index) =>
                                          Column(
                                    children: [
                                      Row(
                                        children: [
                                          comments[comments.length - 1 - index]
                                                      ['author_id'] !=
                                                  null
                                              ? photos[comments[
                                                              comments.length -
                                                                  1 -
                                                                  index]
                                                          ['author_id']] !=
                                                      null
                                                  ? photos[comments[comments
                                                                      .length -
                                                                  1 -
                                                                  index]
                                                              ['author_id']] !=
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
                                                                imageUrl: photos[comments[
                                                                        comments.length -
                                                                            1 -
                                                                            index]
                                                                    [
                                                                    'author_id']],
                                                              )),
                                                        )
                                                      : Container()
                                                  : Container()
                                              : Container(),
                                          Expanded(
                                            child: Container(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
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
                                                            maxLines: 100,
                                                            textScaleFactor: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: GoogleFonts
                                                                .montserrat(
                                                              textStyle:
                                                                  TextStyle(
                                                                color:
                                                                    secondColor,
                                                                fontSize: 15,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            height: 5,
                                                          ),
                                                          Text(
                                                            comments[comments.length -
                                                                            1 -
                                                                            index]
                                                                        [
                                                                        'author'] !=
                                                                    null
                                                                ? comments[comments
                                                                        .length -
                                                                    1 -
                                                                    index]['author']
                                                                : 'No author',
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            textScaleFactor: 1,
                                                            style: GoogleFonts
                                                                .montserrat(
                                                              textStyle:
                                                                  TextStyle(
                                                                color:
                                                                    secondColor,
                                                                fontSize: 10,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w300,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    TextButton(
                                                      onPressed: () {
                                                        setState(() {
                                                          loading = true;
                                                        });
                                                        Navigator.push(
                                                          context,
                                                          SlideRightRoute(
                                                            page:
                                                                CommentReplyScreen(
                                                              post_id: widget
                                                                  .data.id,
                                                              all: comments,
                                                              data: comments[
                                                                  comments.length -
                                                                      1 -
                                                                      index],
                                                            ),
                                                          ),
                                                        );
                                                        setState(() {
                                                          loading = false;
                                                        });
                                                      },
                                                      child: Text(
                                                        comments[comments.length -
                                                                        1 -
                                                                        index][
                                                                    'replies'] !=
                                                                null
                                                            ? comments[comments.length -
                                                                            1 -
                                                                            index]
                                                                        [
                                                                        'replies']
                                                                    .length
                                                                    .toString() +
                                                                ' replies'
                                                            : 'Reply',
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        textScaleFactor: 1,
                                                        style: GoogleFonts
                                                            .montserrat(
                                                          textStyle: TextStyle(
                                                            color: Colors.blue,
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight.w300,
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

                                  //         Card(
                                  //   shadowColor: secondColor,
                                  //   color: firstColor,
                                  //   elevation: 10,
                                  //   child: Row(
                                  //     children: [
                                  //       SizedBox(
                                  //         width: 10,
                                  //       ),
                                  //       Expanded(
                                  //         child: Container(
                                  //           child: Padding(
                                  //             padding:
                                  //                 const EdgeInsets.all(12.0),
                                  //             child: Row(
                                  //               children: [
                                  //                 Expanded(
                                  //                   child: Column(
                                  //                     crossAxisAlignment:
                                  //                         CrossAxisAlignment
                                  //                             .start,
                                  //                     children: [
                                  //                       Text(
                                  //                         comments[index]
                                  //                             ['text'],
                                  //                         textScaleFactor: 1,
                                  //                         style: GoogleFonts
                                  //                             .montserrat(
                                  //                           textStyle:
                                  //                               TextStyle(
                                  //                             color:
                                  //                                 secondColor,
                                  //                             fontSize: 20,
                                  //                             fontWeight:
                                  //                                 FontWeight
                                  //                                     .bold,
                                  //                           ),
                                  //                         ),
                                  //                       ),
                                  //                       SizedBox(
                                  //                         height: 10,
                                  //                       ),
                                  //                       Text(
                                  //                         comments[index][
                                  //                                     'author'] !=
                                  //                                 null
                                  //                             ? comments[
                                  //                                     index]
                                  //                                 ['author']
                                  //                             : 'No author',
                                  //                         overflow:
                                  //                             TextOverflow
                                  //                                 .ellipsis,
                                  //                         textScaleFactor: 1,
                                  //                         style: GoogleFonts
                                  //                             .montserrat(
                                  //                           textStyle:
                                  //                               TextStyle(
                                  //                             color:
                                  //                                 secondColor,
                                  //                             fontSize: 15,
                                  //                             fontWeight:
                                  //                                 FontWeight
                                  //                                     .w300,
                                  //                           ),
                                  //                         ),
                                  //                       ),
                                  //                     ],
                                  //                   ),
                                  //                 ),
                                  //               ],
                                  //             ),
                                  //           ),
                                  //         ),
                                  //       ),
                                  //       Divider(
                                  //         thickness: 0.1,
                                  //         color: secondColor,
                                  //       ),
                                  //     ],
                                  //   ),
                                  // ),
                                )
                              : Center(
                                  child: Text(
                                    'No comments',
                                    textScaleFactor: 1,
                                    style: GoogleFonts.montserrat(
                                      textStyle: TextStyle(
                                          color: secondColor,
                                          fontSize: 20,
                                          fontWeight: FontWeight.w300),
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
          );
  }
}
