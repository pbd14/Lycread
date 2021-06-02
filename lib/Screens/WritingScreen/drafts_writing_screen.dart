import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/models/documents/document.dart';
import 'package:flutter_quill/widgets/controller.dart';
import 'package:flutter_quill/widgets/default_styles.dart';
import 'package:flutter_quill/widgets/editor.dart';
import 'package:flutter_quill/widgets/toolbar.dart';
import 'package:flutter_tagging/flutter_tagging.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lycread/Models/PushNotificationMessage.dart';
import 'package:lycread/Models/Tags.dart';
import 'package:lycread/widgets/rounded_button.dart';
import 'package:lycread/widgets/text_field_container.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:tuple/tuple.dart';
import '../../constants.dart';
import '../loading_screen.dart';

class DraftsWritingScreen extends StatefulWidget {
  Map data;
  DraftsWritingScreen({Key key, @required this.data}) : super(key: key);
  @override
  _DraftsWritingScreenState createState() => _DraftsWritingScreenState();
}

class _DraftsWritingScreenState extends State<DraftsWritingScreen> {
  final _formKey = GlobalKey<FormState>();
  List categs;
  String name;
  String text;
  String category = 'Общее';
  String error = '';
  List<Tag> tags = [];
  List<String> writingTags = [];
  List<Tag> newTags = [];
  List<Tag> chosenTags = [];
  bool isError = false;
  bool isMonetized = false;
  bool loading = false;
  File i1;
  TaskSnapshot a1;
  QuillController _controller = QuillController.basic();
  DocumentSnapshot user;

  Future<void> prepare() async {
    DocumentSnapshot dcuser = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser.uid)
        .get();
    DocumentSnapshot dc = await FirebaseFirestore.instance
        .collection('appData')
        .doc('LycRead')
        .get();
    var myJSON = jsonDecode(widget.data['rich_text']);
    _controller = QuillController(
      document: Document.fromJson(myJSON),
      selection: TextSelection.collapsed(offset: 0),
    );
    List<Tag> tempTags = [];
    for (var tag in dc.data()['tags']) {
      tempTags.add(Tag(name: tag, number: dc.data()['tags_num'][tag]));
    }
    if (this.mounted) {
      setState(() {
        user = dcuser;
        name = widget.data['name'];
        text = widget.data['text'];
        category = widget.data['genre'];
        categs = dc.data()['genres'];
        tags = tempTags;
      });
    } else {
      user = dcuser;
      name = widget.data['name'];
      text = widget.data['text'];
      category = widget.data['genre'];
      categs = dc.data()['genres'];
      tags = tempTags;
    }
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
    return fnum1;
  }

  Future _getImage() async {
    var picker = await ImagePicker.platform.pickImage(
      source: ImageSource.gallery,
      imageQuality: 25,
    );

    setState(() {
      if (picker != null) {
        i1 = File(picker.path);
      }
      // else {
      //   error = 'No image selected';
      //   isError = true;
      // }
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
              centerTitle: true,
              iconTheme: IconThemeData(color: whiteColor),
              backgroundColor: primaryColor,
              title: Text(
                'Черновик',
                textScaleFactor: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.montserrat(
                  textStyle: TextStyle(
                      color: whiteColor,
                      fontSize: 20,
                      fontWeight: FontWeight.w300),
                ),
              ),
            ),
            backgroundColor: whiteColor,
            body: SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.fromLTRB(0, 40, 0, 30),
                child: Center(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        SizedBox(
                          height: size.height * 0.1,
                        ),
                        // Text(
                        //   'Добавьте историю',
                        //   textScaleFactor: 1,
                        //   style: GoogleFonts.montserrat(
                        //     textStyle: TextStyle(
                        //       color: primaryColor,
                        //       fontSize: 30,
                        //       fontWeight: FontWeight.bold,
                        //     ),
                        //   ),
                        // ),
                        // Divider(),
                        // SizedBox(
                        //   height: 20,
                        // ),
                        // RoundedTextInput(
                        //   initialValue: widget.data['name'],
                        //   validator: (val) =>
                        //       val.length > 2 ? null : 'Минимум 2 символов',
                        //   hintText: "Название",
                        //   type: TextInputType.text,
                        //   length: 30,
                        //   height: 110,
                        //   onChanged: (value) {
                        //     name = value;
                        //   },
                        // ),
                        // SizedBox(
                        //   height: 20,
                        // ),
                        widget.data['parent'] != null
                            ? Container(
                                margin: EdgeInsets.fromLTRB(15, 0, 15, 0),
                                child: Card(
                                  child: Padding(
                                    padding:
                                        EdgeInsets.fromLTRB(10, 15, 10, 15),
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
                                              widget.data['parent']['data']
                                                  ['name'],
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
                                            SizedBox(
                                              height: 5,
                                            ),
                                            Text(
                                              widget.data['parent']['author'] !=
                                                      null
                                                  ? widget.data['parent']
                                                      ['author']
                                                  : 'Loading',
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
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                  color: footyColor,
                                ),
                              )
                            : Container(),
                        SizedBox(height: 20),
                        Container(
                          height: 110,
                          child: TextFieldContainer(
                            child: TextFormField(
                              initialValue: widget.data['name'],
                              // maxLength: length != null ? length : double.infinity.toInt(),
                              maxLength: 30,
                              style: TextStyle(color: primaryColor),
                              validator: (val) =>
                                  val.length > 1 ? null : 'Минимум 2 символов',
                              keyboardType: TextInputType.text,
                              onChanged: (value) {
                                name = value;
                              },
                              decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                      borderSide: BorderSide.none),
                                  hintText: "Название",
                                  hintStyle: TextStyle(fontSize: 20)),
                            ),
                          ),
                        ),
                        // Container(
                        //   padding: EdgeInsets.fromLTRB(
                        //       size.width * 0.05, 0, size.width * 0.05, 0),
                        //   child: TextFormField(
                        //     initialValue: widget.data['text'],
                        //     maxLines: null,
                        //     style: TextStyle(color: primaryColor),
                        //     validator: (val) => val.length > 1
                        //         ? null
                        //         : 'Минимум 2 символов',
                        //     keyboardType: TextInputType.multiline,
                        //     onChanged: (value) {
                        //       text = value;
                        //     },
                        //     decoration: InputDecoration(
                        //       hintText: "Текст",
                        //       border: OutlineInputBorder(),
                        //     ),
                        //   ),
                        // ),
                        // SizedBox(
                        //   height: 20,
                        // ),
                        Container(
                          width: size.width * 0.9,
                          child: QuillToolbar.basic(
                            controller: _controller,
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.all(10),
                          padding: EdgeInsets.all(10),
                          width: size.width * 0.9,
                          child: Container(
                            // decoration: BoxDecoration(
                            //   border: Border.all(
                            //     color: lightPrimaryColor,
                            //   ),
                            //   borderRadius: BorderRadius.circular(10.0),
                            // ),
                            margin: EdgeInsets.all(10),
                            padding: EdgeInsets.all(10),
                            child:
                                // QuillEditor(
                                //   focusNode: FocusNode(),
                                //   autoFocus: false,
                                //   expands: false,
                                //   scrollable: false,
                                //   scrollController: ScrollController(),
                                //   readOnly: false,
                                //   padding: EdgeInsets.all(5),
                                //   controller: _controller,
                                // )
                                QuillEditor(
                              placeholder: 'Text',
                              customStyles: DefaultStyles(
                                placeHolder: DefaultTextBlockStyle(
                                  TextStyle(color: lightPrimaryColor),
                                  Tuple2<double, double>(10, 10),
                                  Tuple2<double, double>(3, 3),
                                  BoxDecoration(),
                                ),
                                paragraph: DefaultTextBlockStyle(
                                  TextStyle(color: primaryColor),
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
                              autoFocus: false,
                              expands: false,
                              scrollable: false,
                              scrollController: ScrollController(),
                              readOnly: false,
                              showCursor: true,
                              padding: EdgeInsets.all(5),
                              controller: _controller,
                            ),
                            //     QuillEditor.basic(
                            //   controller: _controller,
                            //   readOnly: false, // true for view only mode
                            // ),
                          ),
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        Container(
                          width: size.width * 0.9,
                          child: FlutterTagging<Tag>(
                            enableImmediateSuggestion: true,
                            initialItems: chosenTags,
                            findSuggestions: (pattern) async {
                              return await TagsService.getTags(pattern, tags);
                            },
                            textFieldConfiguration: TextFieldConfiguration(
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                filled: true,
                                fillColor: whiteColor,
                                hintText: 'Теги',
                              ),
                            ),
                            onAdded: (tag) {
                              newTags.add(
                                Tag(
                                  name: tag.name,
                                  number: tag.number,
                                ),
                              );
                              tags.add(
                                Tag(
                                  name: tag.name,
                                  number: tag.number,
                                ),
                              );
                              // api calls here, triggered when add to tag button is pressed
                              return Tag(
                                  name: tag.get(), number: tag.getNumber());
                            },
                            configureSuggestion: (tag) {
                              return SuggestionConfiguration(
                                title: Text(tag.name),
                                subtitle: Text(getFnum(tag.number)),
                                additionWidget: Chip(
                                  avatar: Icon(
                                    Icons.add_circle,
                                    color: Colors.white,
                                  ),
                                  label: Text('Добавить тег'),
                                  labelStyle: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w300,
                                  ),
                                  backgroundColor: primaryColor,
                                ),
                              );
                            },
                            configureChip: (tag) {
                              return ChipConfiguration(
                                label: Text(tag.name),
                                backgroundColor: primaryColor,
                                labelStyle: TextStyle(color: footyColor),
                                deleteIconColor: footyColor,
                              );
                            },
                            onChanged: () {},
                            additionCallback: (value) {
                              return Tag(
                                name: value,
                                number: 0,
                              );
                            },
                          ),
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        Container(
                          padding: EdgeInsets.fromLTRB(
                              size.width * 0.2, 0, size.width * 0.2, 0),
                          child: DropdownButton<String>(
                            isExpanded: true,
                            hint: Text(
                              category != null ? category : 'Жанры',
                              textScaleFactor: 1,
                              style: GoogleFonts.montserrat(
                                textStyle: TextStyle(
                                  color: darkPrimaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            items: categs != null
                                ? categs.map((dynamic value) {
                                    return new DropdownMenuItem<String>(
                                      value: value.toString().toUpperCase(),
                                      child: new Text(
                                        value,
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
                                category = value;
                              });
                            },
                          ),
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        // Text(
                        //   'Фотография',
                        //   textScaleFactor: 1,
                        //   style: GoogleFonts.montserrat(
                        //     textStyle: TextStyle(
                        //       color: primaryColor,
                        //       fontSize: 25,
                        //       fontWeight: FontWeight.bold,
                        //     ),
                        //   ),
                        // ),
                        // Divider(),
                        // SizedBox(
                        //   height: 10,
                        // ),
                        GestureDetector(
                          onTap: () {
                            _getImage();
                          },
                          child: Card(
                            elevation: 5,
                            child: Container(
                              width: size.width * 0.5,
                              height: size.width * 0.5,
                              child: i1 == null
                                  ? widget.data['images'] != 'No Image'
                                      ? CachedNetworkImage(
                                          filterQuality: FilterQuality.none,
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) =>
                                              Transform.scale(
                                            scale: 0.8,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.0,
                                              backgroundColor: footyColor,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                      primaryColor),
                                            ),
                                          ),
                                          imageUrl: widget.data['images'][0],
                                        )
                                      : Container()
                                  : Image.file(i1),
                            ),
                          ),
                        ),
                        error.length != 0
                            ? SizedBox(
                                height: 20,
                              )
                            : Container(),
                        error.length != 0
                            ? Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Text(
                                  error,
                                  textScaleFactor: 1,
                                  style: GoogleFonts.montserrat(
                                    textStyle: TextStyle(
                                      color: Colors.red,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              )
                            : Container(),
                        SizedBox(
                          height: 20,
                        ),
                        user != null
                            ? user.data()['isMember'] != null
                                ? user.data()['isMember']
                                    ? Padding(
                                        padding: const EdgeInsets.all(15.0),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              flex: 7,
                                              child: Text(
                                                'Монетизация',
                                                overflow: TextOverflow.ellipsis,
                                                style: GoogleFonts.montserrat(
                                                  textStyle: TextStyle(
                                                    color: primaryColor,
                                                    fontSize: 17,
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 5),
                                            Align(
                                              alignment: Alignment.centerRight,
                                              child: Switch(
                                                activeColor: footyColor,
                                                value: isMonetized,
                                                onChanged: (val) {
                                                  if (this.mounted) {
                                                    setState(() {
                                                      isMonetized = val;
                                                    });
                                                  }
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    : Container()
                                : Container()
                            : Container(),
                        SizedBox(
                          height: 40,
                        ),
                        RoundedButton(
                          width: 0.5,
                          ph: 45,
                          text: 'Добавить',
                          press: () async {
                            for (Tag tt in chosenTags) {
                              writingTags.add(tt.name);
                            }
                            if (writingTags.isNotEmpty) {
                              if (writingTags.length < 20) {
                                if (_formKey.currentState.validate()) {
                                  setState(() {
                                    loading = true;
                                  });
                                  String id =
                                      FirebaseAuth.instance.currentUser.uid;
                                  String date = DateTime.now().toString();
                                  if (i1 != null) {
                                    a1 = await FirebaseStorage.instance
                                        .ref('uploads')
                                        .child('$id/writings/$date')
                                        .putFile(i1);
                                  }
                                  if (a1 != null) {
                                    String id = DateTime.now()
                                        .millisecondsSinceEpoch
                                        .toString();
                                    if (widget.data != null) {
                                      FirebaseFirestore.instance
                                          .collection('writings')
                                          .doc(widget.data['parent']['id'])
                                          .update({
                                        'children': FieldValue.arrayUnion([
                                          {
                                            'author': FirebaseAuth.instance
                                                .currentUser.displayName,
                                            'id': id,
                                          }
                                        ])
                                      });
                                    }
                                    FirebaseFirestore.instance
                                        .collection('writings')
                                        .doc(id)
                                        .set({
                                      'id': id,
                                      'name': name,
                                      // 'text': text,
                                      'author':
                                          FirebaseAuth.instance.currentUser.uid,
                                      'images': [
                                        await a1.ref.getDownloadURL(),
                                      ],
                                      'genre': category.toLowerCase(),
                                      'date': DateTime.now(),
                                      'rich_text': jsonEncode(_controller
                                          .document
                                          .toDelta()
                                          .toJson()),
                                      'isMonetized': isMonetized,
                                      'rating': 0,
                                      'users_rated': [],
                                      'tags': writingTags,
                                      'reads': 0,
                                      'users_read': [],
                                      'comments': [],
                                      'parent': widget.data['parent'] != null
                                          ? widget.data['parent']
                                          : null,
                                    }).catchError((error) {
                                      print('MISTAKE HERE');
                                      print(error);
                                      PushNotificationMessage notification =
                                          PushNotificationMessage(
                                        title: 'Ошибка',
                                        body: 'Неудалось добавить историю',
                                      );
                                      showSimpleNotification(
                                        Container(
                                            child: Text(notification.body)),
                                        position: NotificationPosition.top,
                                        background: Colors.red,
                                      );
                                    });
                                  } else {
                                    if (widget.data['images'][0] !=
                                        'No Image') {
                                      String id = DateTime.now()
                                          .millisecondsSinceEpoch
                                          .toString();
                                      if (widget.data != null) {
                                        FirebaseFirestore.instance
                                            .collection('writings')
                                            .doc(widget.data['parent']['id'])
                                            .update({
                                          'children': FieldValue.arrayUnion([
                                            {
                                              'author': FirebaseAuth.instance
                                                  .currentUser.displayName,
                                              'id': id,
                                            }
                                          ])
                                        });
                                      }
                                      FirebaseFirestore.instance
                                          .collection('writings')
                                          .doc(id)
                                          .set({
                                        'id': id,
                                        'name': name,
                                        // 'text': text,
                                        'author': FirebaseAuth
                                            .instance.currentUser.uid,
                                        'images': [widget.data['images'][0]],
                                        'genre': category.toLowerCase(),
                                        'date': DateTime.now(),
                                        'rich_text': jsonEncode(_controller
                                            .document
                                            .toDelta()
                                            .toJson()),
                                        'isMonetized': isMonetized,
                                        'tags': writingTags,
                                        'rating': 0,
                                        'reads': 0,
                                        'users_read': [],
                                        'users_rated': [],
                                        'comments': [],
                                        'parent': widget.data['parent'] != null
                                            ? widget.data['parent']
                                            : null,
                                      }).catchError((error) {
                                        print('MISTAKE HERE');
                                        print(error);
                                        PushNotificationMessage notification =
                                            PushNotificationMessage(
                                          title: 'Ошибка',
                                          body: 'Неудалось добавить историю',
                                        );
                                        showSimpleNotification(
                                          Container(
                                              child: Text(notification.body)),
                                          position: NotificationPosition.top,
                                          background: Colors.red,
                                        );
                                      });
                                    } else {
                                      String id = DateTime.now()
                                          .millisecondsSinceEpoch
                                          .toString();
                                      if (widget.data != null) {
                                        FirebaseFirestore.instance
                                            .collection('writings')
                                            .doc(widget.data['parent']['id'])
                                            .update({
                                          'children': FieldValue.arrayUnion([
                                            {
                                              'author': FirebaseAuth.instance
                                                  .currentUser.displayName,
                                              'id': id,
                                            }
                                          ])
                                        });
                                      }
                                      FirebaseFirestore.instance
                                          .collection('writings')
                                          .doc(id)
                                          .set({
                                        'id': id,
                                        'name': name,
                                        // 'text': text,
                                        'author': FirebaseAuth
                                            .instance.currentUser.uid,
                                        'images': 'No Image',
                                        'genre': category.toLowerCase(),
                                        'date': DateTime.now(),
                                        'rich_text': jsonEncode(_controller
                                            .document
                                            .toDelta()
                                            .toJson()),
                                        'isMonetized': isMonetized,
                                        'tags': writingTags,
                                        'rating': 0,
                                        'reads': 0,
                                        'users_read': [],
                                        'users_rated': [],
                                        'comments': [],
                                        'parent': widget.data['parent'] != null
                                            ? widget.data['parent']
                                            : null,
                                      }).catchError((error) {
                                        print('MISTAKE HERE');
                                        print(error);
                                        PushNotificationMessage notification =
                                            PushNotificationMessage(
                                          title: 'Ошибка',
                                          body: 'Неудалось добавить историю',
                                        );
                                        showSimpleNotification(
                                          Container(
                                              child: Text(notification.body)),
                                          position: NotificationPosition.top,
                                          background: Colors.red,
                                        );
                                      });
                                    }
                                  }
                                  PushNotificationMessage notification =
                                      PushNotificationMessage(
                                    title: 'Успех',
                                    body: 'История добавлена',
                                  );
                                  showSimpleNotification(
                                    Container(child: Text(notification.body)),
                                    position: NotificationPosition.top,
                                    background: footyColor,
                                  );
                                  if (newTags.length != 0) {
                                    List nTags = [];
                                    for (Tag t in newTags) {
                                      nTags.add(t.name);
                                    }

                                    FirebaseFirestore.instance
                                        .collection('appData')
                                        .doc('LycRead')
                                        .update({
                                      'tags': FieldValue.arrayUnion(nTags),
                                    });
                                  }
                                  Map tNums = {};
                                  for (Tag tag in tags) {
                                    if (writingTags.contains(tag.name)) {
                                      tNums.addAll({tag.name: tag.number + 1});
                                      tag.number = tag.number + 1;
                                    } else {
                                      tNums.addAll({tag.name: 1});
                                    }
                                  }
                                  FirebaseFirestore.instance
                                      .collection('appData')
                                      .doc('LycRead')
                                      .update({'tags_num': tNums});
                                  setState(() {
                                    writingTags = [];
                                    chosenTags = [];
                                    newTags = [];
                                    error = '';
                                    loading = false;
                                  });
                                }
                              } else {
                                setState(() {
                                  error = 'Максимум 20 тегов';
                                  loading = false;
                                });
                              }
                            } else {
                              setState(() {
                                error = 'Выберите теги';
                                loading = false;
                              });
                            }
                          },
                          color: darkPrimaryColor,
                          textColor: footyColor,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        RoundedButton(
                          width: 0.7,
                          ph: 45,
                          text: 'Сохранить как черновик',
                          press: () async {
                            if (_formKey.currentState.validate()) {
                              setState(() {
                                loading = true;
                              });
                              String id = FirebaseAuth.instance.currentUser.uid;
                              String date = DateTime.now().toString();
                              if (i1 != null) {
                                a1 = await FirebaseStorage.instance
                                    .ref('uploads')
                                    .child('$id/writings/$date')
                                    .putFile(i1);
                              }
                              if (a1 != null) {
                                FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(FirebaseAuth.instance.currentUser.uid)
                                    .update({
                                  'drafts': FieldValue.arrayUnion([
                                    {
                                      'name': name,
                                      // 'text': text,
                                      'rich_text': jsonEncode(_controller
                                          .document
                                          .toDelta()
                                          .toJson()),
                                      'date': DateTime.now(),
                                      'images': [
                                        await a1.ref.getDownloadURL(),
                                      ],
                                      'genre': category.toLowerCase(),
                                      'parent': widget.data['parent'] != null
                                          ? widget.data['parent']
                                          : null,
                                    }
                                  ]),
                                  // 'name': name,
                                  // 'text': text,
                                  // 'author':
                                  //     FirebaseAuth.instance.currentUser.uid,
                                  // 'images': [
                                  //   await a1.ref.getDownloadURL(),
                                  // ],
                                  // 'genre': category.toLowerCase(),
                                  // 'date': DateTime.now(),
                                  // 'rating': 0,
                                  // 'users_rated': [],
                                  // 'reads': 0,
                                  // 'users_read': [],
                                  // 'comments': [],
                                }).catchError((error) {
                                  print('MISTAKE HERE');
                                  print(error);
                                  PushNotificationMessage notification =
                                      PushNotificationMessage(
                                    title: 'Ошибка',
                                    body: 'Неудалось добавить черновик',
                                  );
                                  showSimpleNotification(
                                    Container(child: Text(notification.body)),
                                    position: NotificationPosition.top,
                                    background: Colors.red,
                                  );
                                });
                              } else {
                                if (widget.data['images'][0] != 'No Image') {
                                  FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(
                                          FirebaseAuth.instance.currentUser.uid)
                                      .update({
                                    'drafts': FieldValue.arrayUnion([
                                      {
                                        'name': name,
                                        // 'text': text,
                                        'date': DateTime.now(),
                                        'rich_text': jsonEncode(_controller
                                            .document
                                            .toDelta()
                                            .toJson()),
                                        'images': [widget.data['images'][0]],
                                        'genre': category.toLowerCase(),
                                        'parent': widget.data['parent'] != null
                                            ? widget.data['parent']
                                            : null,
                                      }
                                    ]),
                                    // 'name': name,
                                    // 'text': text,
                                    // 'author':
                                    //     FirebaseAuth.instance.currentUser.uid,
                                    // 'images': 'No Image',
                                    // 'genre': category.toLowerCase(),
                                    // 'date': DateTime.now(),
                                    // 'rating': 0,
                                    // 'reads': 0,
                                    // 'users_read': [],
                                    // 'users_rated': [],
                                    // 'comments': [],
                                  }).catchError((error) {
                                    print('MISTAKE HERE');
                                    print(error);
                                    PushNotificationMessage notification =
                                        PushNotificationMessage(
                                      title: 'Ошибка',
                                      body: 'Неудалось добавить историю',
                                    );
                                    showSimpleNotification(
                                      Container(child: Text(notification.body)),
                                      position: NotificationPosition.top,
                                      background: Colors.red,
                                    );
                                  });
                                } else {
                                  FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(
                                          FirebaseAuth.instance.currentUser.uid)
                                      .update({
                                    'drafts': FieldValue.arrayUnion([
                                      {
                                        'name': name,
                                        // 'text': text,
                                        'date': DateTime.now(),
                                        'rich_text': jsonEncode(_controller
                                            .document
                                            .toDelta()
                                            .toJson()),
                                        'images': 'No Image',
                                        'genre': category.toLowerCase(),
                                        'parent': widget.data['parent'] != null
                                            ? widget.data['parent']
                                            : null,
                                      }
                                    ]),
                                    // 'name': name,
                                    // 'text': text,
                                    // 'author':
                                    //     FirebaseAuth.instance.currentUser.uid,
                                    // 'images': 'No Image',
                                    // 'genre': category.toLowerCase(),
                                    // 'date': DateTime.now(),
                                    // 'rating': 0,
                                    // 'reads': 0,
                                    // 'users_read': [],
                                    // 'users_rated': [],
                                    // 'comments': [],
                                  }).catchError((error) {
                                    print('MISTAKE HERE');
                                    print(error);
                                    PushNotificationMessage notification =
                                        PushNotificationMessage(
                                      title: 'Ошибка',
                                      body: 'Неудалось добавить историю',
                                    );
                                    showSimpleNotification(
                                      Container(child: Text(notification.body)),
                                      position: NotificationPosition.top,
                                      background: Colors.red,
                                    );
                                  });
                                }
                              }
                              PushNotificationMessage notification =
                                  PushNotificationMessage(
                                title: 'Успех',
                                body: 'Черновик добавлен',
                              );
                              showSimpleNotification(
                                Container(child: Text(notification.body)),
                                position: NotificationPosition.top,
                                background: footyColor,
                              );
                              setState(() {
                                loading = false;
                              });
                            }
                          },
                          color: lightPrimaryColor,
                          textColor: whiteColor,
                        ),
                        SizedBox(
                          height: 70,
                        ),
                        Container(
                          padding: EdgeInsets.fromLTRB(
                              size.width * 0.05, 0, size.width * 0.05, 0),
                          child: Text(
                            'Контент должен соответствовать всем правилам приложения. Вы как автор несете ответственность за выполнение всех условий',
                            textScaleFactor: 1,
                            style: GoogleFonts.montserrat(
                              textStyle: TextStyle(
                                color: primaryColor,
                                fontSize: 15,
                                fontWeight: FontWeight.w100,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
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

class TagsService {
  /// Mocks fetching language from network API with delay of 500ms.
  static Future<List<Tag>> getTags(String query, List<Tag> tags) async {
    return tags
        .where((tag) => tag.get().toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}
