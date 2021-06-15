import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lycread/Models/PushNotificationMessage.dart';
import 'package:lycread/widgets/rounded_button.dart';
import 'package:overlay_support/overlay_support.dart';
import '../../constants.dart';
import '../loading_screen.dart';

class CommentReplyScreen extends StatefulWidget {
  Map data;
  List all;
  String post_id;
  CommentReplyScreen(
      {Key key,
      @required this.data,
      @required this.all,
      @required this.post_id})
      : super(key: key);
  @override
  _CommentReplyScreenState createState() => _CommentReplyScreenState();
}

class _CommentReplyScreenState extends State<CommentReplyScreen> {
  final _formKey = GlobalKey<FormState>();
  bool loading = true;
  String commentText;
  List replies = [];

  Future<void> prepare() async {
    if (this.mounted) {
      setState(() {
        if (widget.data['replies'] != null) {
          replies = widget.data['replies'];
        }
        loading = false;
      });
    } else {
      if (widget.data['replies'] != null) {
        replies = widget.data['replies'];
      }
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
    Size size = MediaQuery.of(context).size;
    return loading
        ? LoadingScreen()
        : Scaffold(
            appBar: AppBar(
              backgroundColor: primaryColor,
              centerTitle: true,
              title: Text(
                'Ответ',
                overflow: TextOverflow.ellipsis,
                textScaleFactor: 1,
                style: GoogleFonts.montserrat(
                  textStyle: TextStyle(
                    color: whiteColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            body: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  width: size.width - 20,
                  right: 5,
                  top: 1,
                  child: Column(
                    children: [
                      Container(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.data['text'],
                                      maxLines: 100,
                                      textScaleFactor: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.montserrat(
                                        textStyle: TextStyle(
                                          color: primaryColor,
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      widget.data['author'] != null
                                          ? widget.data['author']
                                          : 'No author',
                                      overflow: TextOverflow.ellipsis,
                                      textScaleFactor: 1,
                                      style: GoogleFonts.montserrat(
                                        textStyle: TextStyle(
                                          color: primaryColor,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w300,
                                        ),
                                      ),
                                    ),
                                    Divider(
                                      color: primaryColor,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      replies != null
                          ? replies.length != 0
                              ? ListView.builder(
                                  scrollDirection: Axis.vertical,
                                  shrinkWrap: true,
                                  padding: EdgeInsets.only(bottom: 10),
                                  itemCount: replies.length,
                                  itemBuilder:
                                      (BuildContext context, int index) =>
                                          Column(children: [
                                            Row(
                                              children: [
                                                replies[replies.length -
                                                                1 -
                                                                index]
                                                            ['author_id'] !=
                                                        null
                                                    ? replies[replies.length -
                                                                    1 -
                                                                    index]
                                                                ['author_id'] !=
                                                            null
                                                        ? replies[replies.length -
                                                                        1 -
                                                                        index]
                                                                    ['photo'] !=
                                                                'No Image'
                                                            ? Container(
                                                                width: 40,
                                                                height: 40,
                                                                child:
                                                                    ClipRRect(
                                                                        borderRadius:
                                                                            BorderRadius.circular(
                                                                                25.0),
                                                                        child:
                                                                            CachedNetworkImage(
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
                                                                          imageUrl: replies[replies.length -
                                                                              1 -
                                                                              index]['photo'],
                                                                        )),
                                                              )
                                                            : Container()
                                                        : Container()
                                                    : Container(),
                                                Expanded(
                                                  child: Container(
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Row(
                                                        children: [
                                                          Expanded(
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Text(
                                                                  replies[replies
                                                                              .length -
                                                                          1 -
                                                                          index]
                                                                      ['text'],
                                                                  maxLines: 100,
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
                                                                          primaryColor,
                                                                      fontSize:
                                                                          15,
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
                                                                  replies[replies.length - 1 - index]
                                                                              [
                                                                              'author'] !=
                                                                          null
                                                                      ? replies[replies
                                                                              .length -
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
                                                                          primaryColor,
                                                                      fontSize:
                                                                          10,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w300,
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
                                              ],
                                            ),
                                          ]))
                              : Center(
                                  child: Text(
                                    'No replies',
                                    textScaleFactor: 1,
                                    style: GoogleFonts.montserrat(
                                      textStyle: TextStyle(
                                          color: primaryColor,
                                          fontSize: 20,
                                          fontWeight: FontWeight.w300),
                                    ),
                                  ),
                                )
                          : Center(
                              child: Text(
                                'No replies',
                                textScaleFactor: 1,
                                style: GoogleFonts.montserrat(
                                  textStyle: TextStyle(
                                      color: primaryColor,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w300),
                                ),
                              ),
                            ),
                    ],
                  ),
                ),
                Positioned(
                  height: 85,
                  width: size.width - 20,
                  right: 5,
                  bottom: 1,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                cursorColor: primaryColor,
                                maxLines: null,
                                style: TextStyle(color: primaryColor),
                                validator: (val) => val.length > 1
                                    ? null
                                    : 'Минимум 2 символов',
                                keyboardType: TextInputType.text,
                                maxLength: 500,
                                onChanged: (value) {
                                  commentText = value;
                                },
                                decoration: InputDecoration(
                                  counterStyle: TextStyle(color: primaryColor),
                                  hintText: "Коммент",
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(color: primaryColor),
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
                                  replies.add({
                                    'date': DateTime.now(),
                                    'text': commentText.trim(),
                                    'author': FirebaseAuth
                                        .instance.currentUser.displayName,
                                    'photo': FirebaseAuth
                                        .instance.currentUser.photoURL,
                                    'author_id':
                                        FirebaseAuth.instance.currentUser.uid,
                                  });
                                  await FirebaseFirestore.instance
                                      .collection('writings')
                                      .doc(widget.post_id)
                                      .update({
                                    'comments': widget.all,
                                  }).catchError((error) {
                                    PushNotificationMessage notification =
                                        PushNotificationMessage(
                                      title: 'Ошибка',
                                      body: 'Неудалось добавить ответ',
                                    );
                                    showSimpleNotification(
                                      Container(child: Text(notification.body)),
                                      position: NotificationPosition.top,
                                      background: Colors.red,
                                    );
                                  });
                                  String nText = FirebaseAuth
                                      .instance.currentUser.displayName;
                                  print('USER');
                                  print(widget.data['author_id']);
                                  if (FirebaseAuth.instance.currentUser.uid !=
                                      widget.data['author_id']) {
                                    await FirebaseFirestore.instance
                                        .collection('users')
                                        .doc(widget.data['author_id'])
                                        .update({
                                      'actions': FieldValue.arrayUnion([
                                        {
                                          'author': FirebaseAuth
                                              .instance.currentUser.uid,
                                          'seen': false,
                                          'text':
                                              'Пользователь $nText ответил на ваш коммент',
                                          'type': 'Reply',
                                          'date': DateTime.now(),
                                          'post_id': widget.post_id,
                                        }
                                      ]),
                                    });
                                  }
                                  PushNotificationMessage notification =
                                      PushNotificationMessage(
                                    title: 'Успех',
                                    body: 'Ответ добавлен',
                                  );
                                  showSimpleNotification(
                                    Container(child: Text(notification.body)),
                                    position: NotificationPosition.top,
                                    background: footyColor,
                                  );
                                  setState(() {
                                    commentText = '';
                                  });
                                }
                              },
                              color: primaryColor,
                              textColor: whiteColor,
                            ),
                          ],
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
