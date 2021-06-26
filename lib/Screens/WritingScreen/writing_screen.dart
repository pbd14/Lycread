import 'dart:convert';
import 'dart:io';
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
import 'package:intro_slider/intro_slider.dart';
import 'package:intro_slider/slide_object.dart';
import 'package:lycread/Models/PushNotificationMessage.dart';
import 'package:lycread/Models/Tags.dart';
import 'package:lycread/Screens/HomeScreen/home_screen.dart';
import 'package:lycread/widgets/rounded_button.dart';
import 'package:lycread/widgets/slide_right_route_animation.dart';
import 'package:lycread/widgets/text_field_container.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tuple/tuple.dart';
import '../../constants.dart';
import '../loading_screen.dart';

class WritingScreen extends StatefulWidget {
  String parentId;
  String parentAuthor;
  Map data;
  bool isEmpty;
  WritingScreen(
      {Key key,
      this.data,
      this.parentId: '',
      this.parentAuthor: '',
      this.isEmpty: true})
      : super(key: key);
  @override
  _WritingScreenState createState() => _WritingScreenState();
}

class _WritingScreenState extends State<WritingScreen> {
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
  SharedPreferences prefs;
  bool isError = false;
  bool isMonetized = false;
  bool loading = false;
  File i1;
  TaskSnapshot a1;
  QuillController _controller = QuillController.basic();
  DocumentSnapshot user;

  List<Slide> slides = [
    Slide(
      title: "Пишите",
      description: "На этой странице вы можете добавлять публикации",
      pathImage: "assets/images/wr_instr1.png",
      backgroundColor: primaryColor,
    ),
    Slide(
      title: "Инструменты",
      description:
          "Нажмите на текстовое поле и добавьте название и сам текст. Используйте текстовые инструменты",
      pathImage: "assets/images/wr_instr2.png",
      backgroundColor: primaryColor,
    ),
    Slide(
      title: "Теги",
      description:
          "Добавьте теги которые по теме публикации, а также титульное фото(необязательно)",
      pathImage: "assets/images/wr_instr3.png",
      backgroundColor: primaryColor,
    ),
    Slide(
      title: "Публикуйте",
      description:
          "Вы можете либо сразу опубликовать публикацию, либо сохранить в черновиках",
      pathImage: "assets/images/wr_instr4.png",
      backgroundColor: primaryColor,
    ),
  ];
  bool needInstr = false;

  void manageInstr() async {
    prefs = await SharedPreferences.getInstance();
    if (this.mounted) {
      setState(() {
        needInstr = prefs.getBool('ni_writing_screen') ?? true;
      });
    } else {
      needInstr = prefs.getBool('ni_writing_screen') ?? true;
    }
  }

  Future<void> prepare() async {
    DocumentSnapshot dcuser = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser.uid)
        .get();
    prefs = await SharedPreferences.getInstance();
    text = prefs.getString('draft') ?? 'Text';
    if (!widget.isEmpty) {
      var myJSON = jsonDecode(widget.data['rich_text']);
      _controller = QuillController(
        document: Document.fromJson(myJSON),
        selection: TextSelection.collapsed(offset: 0),
      );
    } else {
      if (widget.parentId.isEmpty) {
        _controller = QuillController(
          document: Document.fromJson([
            // {
            //   "insert": 'Text',
            //   "attributes": {"color": "#e53935", "bold": true},
            //   "insert": '\n',
            // }
            {
              "insert": text.trim() + "\n",
            },
          ]),
          selection: TextSelection.collapsed(offset: 0),
        );
      }
    }

    DocumentSnapshot dc = await FirebaseFirestore.instance
        .collection('appData')
        .doc('LycRead')
        .get();
    List<Tag> tempTags = [];
    for (var tag in dc.data()['tags']) {
      tempTags.add(Tag(name: tag, number: dc.data()['tags_num'][tag]));
    }
    _controller.addListener(() {
      if (_controller.document.toPlainText().trim().isNotEmpty) {
        if (_controller.document.toPlainText().characters.length != 0) {
          prefs.setString('draft', _controller.document.toPlainText());
        } else {
          prefs.setString('draft', 'Text');
        }
      } else {
        prefs.setString('draft', 'Text');
      }
    });
    if (this.mounted) {
      setState(() {
        user = dcuser;
        categs = dc.data()['genres'];
        tags = tempTags;
      });
    } else {
      user = dcuser;
      categs = dc.data()['genres'];
      tags = tempTags;
    }
  }

  String getFnum(int fnum) {
    String fnum1 = '';
    if (fnum != null) {
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
    manageInstr();
    prepare();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return loading
        ? LoadingScreen()
        : Scaffold(
            backgroundColor: whiteColor,
            body: needInstr
                ? Stack(
                    alignment: Alignment.center,
                    children: [
                      SingleChildScrollView(
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
                                  //   validator: (val) => val.length > 2
                                  //       ? null
                                  //       : 'Минимум 2 символов',
                                  //   hintText: "Название",
                                  //   type: TextInputType.text,
                                  //   length: 30,
                                  //   height: 110,
                                  //   onChanged: (value) {
                                  //     name = value;
                                  //   },
                                  // ),
                                  widget.data != null
                                      ? Container(
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
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Text(
                                                        widget.data['name'],
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
                                                      SizedBox(
                                                        height: 5,
                                                      ),
                                                      Text(
                                                        widget.parentAuthor !=
                                                                null
                                                            ? widget
                                                                .parentAuthor
                                                            : 'Loading',
                                                        overflow: TextOverflow
                                                            .ellipsis,
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
                                        )
                                      : Container(),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Container(
                                    height: 120,
                                    child: TextFieldContainer(
                                      child: TextFormField(
                                        // maxLength: length != null ? length : double.infinity.toInt(),
                                        maxLength: 30,
                                        style: TextStyle(
                                            color: primaryColor, fontSize: 30),
                                        validator: (val) => val.length > 1
                                            ? null
                                            : 'Минимум 2 символов',
                                        keyboardType: TextInputType.text,
                                        onChanged: (value) {
                                          name = value;
                                        },
                                        decoration: InputDecoration(
                                            border: OutlineInputBorder(
                                                borderSide: BorderSide.none),
                                            hintText: "Название",
                                            hintStyle: TextStyle(fontSize: 30)),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  // Container(
                                  //   padding: EdgeInsets.fromLTRB(
                                  //       size.width * 0.05,
                                  //       0,
                                  //       size.width * 0.05,
                                  //       0),
                                  //   child: TextFormField(
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
                                    width: size.width * 0.8,
                                    child: QuillToolbar.basic(
                                      controller: _controller,
                                      onImagePickCallback: (File file) async {
                                        DateTime date = DateTime.now();
                                        String id = FirebaseAuth
                                            .instance.currentUser.uid;
                                        TaskSnapshot task =
                                            await FirebaseStorage.instance
                                                .ref('uploads')
                                                .child('$id/writings/$date')
                                                .putFile(file);
                                        return task.ref.getDownloadURL();
                                      },
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
                                            TextStyle(
                                                color: lightPrimaryColor,
                                                fontSize: 20),
                                            Tuple2<double, double>(10, 10),
                                            Tuple2<double, double>(3, 3),
                                            BoxDecoration(),
                                          ),
                                          paragraph: DefaultTextBlockStyle(
                                            TextStyle(
                                                color: darkPrimaryColor,
                                                fontSize: 20),
                                            Tuple2<double, double>(10, 10),
                                            Tuple2<double, double>(3, 3),
                                            BoxDecoration(),
                                          ),
                                          h1: DefaultTextBlockStyle(
                                              TextStyle(
                                                fontSize: 35,
                                                color: primaryColor,
                                                height: 1.15,
                                                fontWeight: FontWeight.w300,
                                              ),
                                              const Tuple2(16, 0),
                                              const Tuple2(0, 0),
                                              null),
                                          h2: DefaultTextBlockStyle(
                                              TextStyle(
                                                fontSize: 30,
                                                color: primaryColor,
                                                height: 1.15,
                                                fontWeight: FontWeight.normal,
                                              ),
                                              const Tuple2(8, 0),
                                              const Tuple2(0, 0),
                                              null),
                                          h3: DefaultTextBlockStyle(
                                              TextStyle(
                                                fontSize: 25,
                                                color: primaryColor,
                                                height: 1.25,
                                                fontWeight: FontWeight.w500,
                                              ),
                                              const Tuple2(8, 0),
                                              const Tuple2(0, 0),
                                              null),
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
                                        return await TagsService.getTags(
                                            pattern, tags);
                                      },
                                      textFieldConfiguration:
                                          TextFieldConfiguration(
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
                                            name: tag.get(),
                                            number: tag.getNumber());
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
                                          labelStyle:
                                              TextStyle(color: footyColor),
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
                                  // SizedBox(
                                  //   height: 30,
                                  // ),
                                  // Container(
                                  //   padding: EdgeInsets.fromLTRB(
                                  //       size.width * 0.2, 0, size.width * 0.2, 0),
                                  //   child: DropdownButton<String>(
                                  //     isExpanded: true,
                                  //     hint: Text(
                                  //       category != null ? category : 'Жанры',
                                  //       textScaleFactor: 1,
                                  //       style: GoogleFonts.montserrat(
                                  //         textStyle: TextStyle(
                                  //           color: darkPrimaryColor,
                                  //           fontWeight: FontWeight.bold,
                                  //         ),
                                  //       ),
                                  //     ),
                                  //     items: categs != null
                                  //         ? categs.map((dynamic value) {
                                  //             return new DropdownMenuItem<String>(
                                  //               value: value.toString().toUpperCase(),
                                  //               child: new Text(
                                  //                 value,
                                  //                 textScaleFactor: 1,
                                  //               ),
                                  //             );
                                  //           }).toList()
                                  //         : [
                                  //             new DropdownMenuItem<String>(
                                  //               value: '-',
                                  //               child: new Text(
                                  //                 '-',
                                  //                 textScaleFactor: 1,
                                  //               ),
                                  //             )
                                  //           ],
                                  //     onChanged: (value) {
                                  //       setState(() {
                                  //         category = value;
                                  //       });
                                  //     },
                                  //   ),
                                  // ),
                                  SizedBox(
                                    height: 30,
                                  ),
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
                                            ? Icon(Icons.add)
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
                                                  padding: const EdgeInsets.all(
                                                      15.0),
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                        flex: 7,
                                                        child: Text(
                                                          'Монетизация',
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: GoogleFonts
                                                              .montserrat(
                                                            textStyle:
                                                                TextStyle(
                                                              color:
                                                                  primaryColor,
                                                              fontSize: 17,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(width: 5),
                                                      Align(
                                                        alignment: Alignment
                                                            .centerRight,
                                                        child: Switch(
                                                          activeColor:
                                                              footyColor,
                                                          value: isMonetized,
                                                          onChanged: (val) {
                                                            if (this.mounted) {
                                                              setState(() {
                                                                isMonetized =
                                                                    val;
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
                                          if (_formKey.currentState
                                              .validate()) {
                                            setState(() {
                                              loading = true;
                                            });
                                            String id = FirebaseAuth
                                                .instance.currentUser.uid;
                                            String date =
                                                DateTime.now().toString();
                                            if (i1 != null) {
                                              a1 = await FirebaseStorage
                                                  .instance
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
                                                    .doc(widget.parentId)
                                                    .update({
                                                  'children':
                                                      FieldValue.arrayUnion([
                                                    {
                                                      'author': FirebaseAuth
                                                          .instance
                                                          .currentUser
                                                          .displayName,
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
                                                'images': [
                                                  await a1.ref.getDownloadURL(),
                                                ],
                                                'genre': category.toLowerCase(),
                                                'date': DateTime.now(),
                                                'rich_text': jsonEncode(
                                                    _controller.document
                                                        .toDelta()
                                                        .toJson()),
                                                'isMonetized': isMonetized,
                                                'rating': 0,
                                                'users_rated': [],
                                                'tags': writingTags,
                                                'reads': 0,
                                                'users_read': [],
                                                'comments': [],
                                                'parent': widget.data != null
                                                    ? {
                                                        'id': widget.parentId,
                                                        'author':
                                                            widget.parentAuthor,
                                                        'data': widget.data,
                                                      }
                                                    : null,
                                              }).catchError((error) {
                                                print('MISTAKE HERE');
                                                print(error);
                                                PushNotificationMessage
                                                    notification =
                                                    PushNotificationMessage(
                                                  title: 'Ошибка',
                                                  body:
                                                      'Неудалось добавить историю',
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
                                            } else {
                                              String id = DateTime.now()
                                                  .millisecondsSinceEpoch
                                                  .toString();
                                              if (widget.data != null) {
                                                FirebaseFirestore.instance
                                                    .collection('writings')
                                                    .doc(widget.parentId)
                                                    .update({
                                                  'children':
                                                      FieldValue.arrayUnion([
                                                    {
                                                      'author': FirebaseAuth
                                                          .instance
                                                          .currentUser
                                                          .displayName,
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
                                                'rich_text': jsonEncode(
                                                    _controller.document
                                                        .toDelta()
                                                        .toJson()),
                                                'isMonetized': isMonetized,
                                                'rating': 0,
                                                'reads': 0,
                                                'tags': writingTags,
                                                'users_read': [],
                                                'users_rated': [],
                                                'comments': [],
                                                'parent': widget.data != null
                                                    ? {
                                                        'id': widget.parentId,
                                                        'author':
                                                            widget.parentAuthor,
                                                        'data': widget.data,
                                                      }
                                                    : null,
                                              }).catchError((error) {
                                                print('MISTAKE HERE');
                                                print(error);
                                                PushNotificationMessage
                                                    notification =
                                                    PushNotificationMessage(
                                                  title: 'Ошибка',
                                                  body:
                                                      'Неудалось добавить историю',
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
                                            }
                                            PushNotificationMessage
                                                notification =
                                                PushNotificationMessage(
                                              title: 'Успех',
                                              body: 'История добавлена',
                                            );
                                            showSimpleNotification(
                                              Container(
                                                  child:
                                                      Text(notification.body)),
                                              position:
                                                  NotificationPosition.top,
                                              background: footyColor,
                                            );
                                            prefs.setString('draft', 'Text');
                                            _controller = QuillController(
                                              document: Document.fromJson([
                                                {
                                                  "insert": 'Text' + "\n",
                                                },
                                              ]),
                                              selection:
                                                  TextSelection.collapsed(
                                                      offset: 0),
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
                                                'tags': FieldValue.arrayUnion(
                                                    nTags),
                                              });
                                            }
                                            Map tNums = {};
                                            for (Tag tag in tags) {
                                              if (writingTags
                                                  .contains(tag.name)) {
                                                tNums.addAll(
                                                    {tag.name: tag.number + 1});
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
                                              i1 = null;
                                              name = null;
                                              error = '';
                                              category = 'Общее';
                                              text = 'Text';
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
                                        String id = FirebaseAuth
                                            .instance.currentUser.uid;
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
                                              .doc(FirebaseAuth
                                                  .instance.currentUser.uid)
                                              .update({
                                            'drafts': FieldValue.arrayUnion([
                                              {
                                                'name': name,
                                                // 'text': text,
                                                'date': DateTime.now(),
                                                'rich_text': jsonEncode(
                                                    _controller.document
                                                        .toDelta()
                                                        .toJson()),
                                                'images': [
                                                  await a1.ref.getDownloadURL(),
                                                ],
                                                'genre': category.toLowerCase(),
                                                'parent': widget.data != null
                                                    ? {
                                                        'id': widget.parentId,
                                                        'author':
                                                            widget.parentAuthor,
                                                        'data': widget.data,
                                                      }
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
                                            PushNotificationMessage
                                                notification =
                                                PushNotificationMessage(
                                              title: 'Ошибка',
                                              body:
                                                  'Неудалось добавить черновик',
                                            );
                                            showSimpleNotification(
                                              Container(
                                                  child:
                                                      Text(notification.body)),
                                              position:
                                                  NotificationPosition.top,
                                              background: Colors.red,
                                            );
                                          });
                                        } else {
                                          FirebaseFirestore.instance
                                              .collection('users')
                                              .doc(FirebaseAuth
                                                  .instance.currentUser.uid)
                                              .update({
                                            'drafts': FieldValue.arrayUnion([
                                              {
                                                'name': name,
                                                // 'text': text,
                                                'date': DateTime.now(),
                                                'images': 'No Image',
                                                'rich_text': jsonEncode(
                                                    _controller.document
                                                        .toDelta()
                                                        .toJson()),
                                                'genre': category.toLowerCase(),
                                                'parent': widget.data != null
                                                    ? {
                                                        'id': widget.parentId,
                                                        'author':
                                                            widget.parentAuthor,
                                                        'data': widget.data,
                                                      }
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
                                            PushNotificationMessage
                                                notification =
                                                PushNotificationMessage(
                                              title: 'Ошибка',
                                              body:
                                                  'Неудалось добавить историю',
                                            );
                                            showSimpleNotification(
                                              Container(
                                                  child:
                                                      Text(notification.body)),
                                              position:
                                                  NotificationPosition.top,
                                              background: Colors.red,
                                            );
                                          });
                                        }
                                        PushNotificationMessage notification =
                                            PushNotificationMessage(
                                          title: 'Успех',
                                          body: 'Черновик добавлен',
                                        );
                                        showSimpleNotification(
                                          Container(
                                              child: Text(notification.body)),
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
                                        size.width * 0.05,
                                        0,
                                        size.width * 0.05,
                                        0),
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
                              prefs.setBool('ni_writing_screen', false);
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
                : SingleChildScrollView(
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
                              //   validator: (val) => val.length > 2
                              //       ? null
                              //       : 'Минимум 2 символов',
                              //   hintText: "Название",
                              //   type: TextInputType.text,
                              //   length: 30,
                              //   height: 110,
                              //   onChanged: (value) {
                              //     name = value;
                              //   },
                              // ),
                              widget.data != null
                                  ? Container(
                                      margin: EdgeInsets.fromLTRB(15, 0, 15, 0),
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
                                                    widget.data['name'],
                                                    textScaleFactor: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style:
                                                        GoogleFonts.montserrat(
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
                                                    widget.parentAuthor != null
                                                        ? widget.parentAuthor
                                                        : 'Loading',
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    textScaleFactor: 1,
                                                    style:
                                                        GoogleFonts.montserrat(
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
                                    )
                                  : Container(),
                              SizedBox(
                                height: 20,
                              ),
                              Container(
                                height: 120,
                                child: TextFieldContainer(
                                  child: TextFormField(
                                    // maxLength: length != null ? length : double.infinity.toInt(),
                                    maxLength: 30,
                                    style: TextStyle(
                                        color: primaryColor, fontSize: 30),
                                    validator: (val) => val.length > 1
                                        ? null
                                        : 'Минимум 2 символов',
                                    keyboardType: TextInputType.text,
                                    onChanged: (value) {
                                      name = value;
                                    },
                                    decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                            borderSide: BorderSide.none),
                                        hintText: "Название",
                                        hintStyle: TextStyle(fontSize: 30)),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              // Container(
                              //   padding: EdgeInsets.fromLTRB(
                              //       size.width * 0.05,
                              //       0,
                              //       size.width * 0.05,
                              //       0),
                              //   child: TextFormField(
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
                                width: size.width * 0.8,
                                child: QuillToolbar.basic(
                                  controller: _controller,
                                  onImagePickCallback: (File file) async {
                                    DateTime date = DateTime.now();
                                    String id =
                                        FirebaseAuth.instance.currentUser.uid;
                                    TaskSnapshot task = await FirebaseStorage
                                        .instance
                                        .ref('uploads')
                                        .child('$id/writings/$date')
                                        .putFile(file);
                                    return task.ref.getDownloadURL();
                                  },
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
                                        TextStyle(
                                          color: lightPrimaryColor,
                                          fontSize: 20,
                                        ),
                                        Tuple2<double, double>(10, 10),
                                        Tuple2<double, double>(3, 3),
                                        BoxDecoration(),
                                      ),
                                      paragraph: DefaultTextBlockStyle(
                                        TextStyle(
                                          color: primaryColor,
                                          fontSize: 20,
                                        ),
                                        Tuple2<double, double>(10, 10),
                                        Tuple2<double, double>(3, 3),
                                        BoxDecoration(),
                                      ),
                                      h1: DefaultTextBlockStyle(
                                          TextStyle(
                                            fontSize: 38,
                                            color: primaryColor,
                                            height: 1.15,
                                            fontWeight: FontWeight.w300,
                                          ),
                                          const Tuple2(16, 0),
                                          const Tuple2(0, 0),
                                          null),
                                      h2: DefaultTextBlockStyle(
                                          TextStyle(
                                            fontSize: 33,
                                            color: primaryColor,
                                            height: 1.15,
                                            fontWeight: FontWeight.w300,
                                          ),
                                          const Tuple2(8, 0),
                                          const Tuple2(0, 0),
                                          null),
                                      h3: DefaultTextBlockStyle(
                                          TextStyle(
                                            fontSize: 28,
                                            color: primaryColor,
                                            height: 1.25,
                                            fontWeight: FontWeight.w300,
                                          ),
                                          const Tuple2(8, 0),
                                          const Tuple2(0, 0),
                                          null),
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
                                    return await TagsService.getTags(
                                        pattern, tags);
                                  },
                                  textFieldConfiguration:
                                      TextFieldConfiguration(
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
                                        name: tag.get(),
                                        number: tag.getNumber());
                                  },
                                  configureSuggestion: (tag) {
                                    return SuggestionConfiguration(
                                      title: Text(tag.name),
                                      subtitle: Text(getFnum(tag.number) != null
                                          ? getFnum(tag.number)
                                          : 'Нет тегов'),
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
                              // SizedBox(
                              //   height: 30,
                              // ),
                              // Container(
                              //   padding: EdgeInsets.fromLTRB(
                              //       size.width * 0.2, 0, size.width * 0.2, 0),
                              //   child: DropdownButton<String>(
                              //     isExpanded: true,
                              //     hint: Text(
                              //       category != null ? category : 'Жанры',
                              //       textScaleFactor: 1,
                              //       style: GoogleFonts.montserrat(
                              //         textStyle: TextStyle(
                              //           color: darkPrimaryColor,
                              //           fontWeight: FontWeight.bold,
                              //         ),
                              //       ),
                              //     ),
                              //     items: categs != null
                              //         ? categs.map((dynamic value) {
                              //             return new DropdownMenuItem<String>(
                              //               value: value.toString().toUpperCase(),
                              //               child: new Text(
                              //                 value,
                              //                 textScaleFactor: 1,
                              //               ),
                              //             );
                              //           }).toList()
                              //         : [
                              //             new DropdownMenuItem<String>(
                              //               value: '-',
                              //               child: new Text(
                              //                 '-',
                              //                 textScaleFactor: 1,
                              //               ),
                              //             )
                              //           ],
                              //     onChanged: (value) {
                              //       setState(() {
                              //         category = value;
                              //       });
                              //     },
                              //   ),
                              // ),
                              SizedBox(
                                height: 30,
                              ),
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
                                        ? Icon(Icons.add)
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
                                              padding:
                                                  const EdgeInsets.all(15.0),
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    flex: 7,
                                                    child: Text(
                                                      'Монетизация',
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: GoogleFonts
                                                          .montserrat(
                                                        textStyle: TextStyle(
                                                          color: primaryColor,
                                                          fontSize: 17,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(width: 5),
                                                  Align(
                                                    alignment:
                                                        Alignment.centerRight,
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
                                        String id = FirebaseAuth
                                            .instance.currentUser.uid;
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
                                                .doc(widget.parentId)
                                                .update({
                                              'children':
                                                  FieldValue.arrayUnion([
                                                {
                                                  'author': FirebaseAuth
                                                      .instance
                                                      .currentUser
                                                      .displayName,
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
                                            'parent': widget.data != null
                                                ? {
                                                    'id': widget.parentId,
                                                    'author':
                                                        widget.parentAuthor,
                                                    'data': widget.data,
                                                  }
                                                : null,
                                          }).catchError((error) {
                                            print('MISTAKE HERE');
                                            print(error);
                                            PushNotificationMessage
                                                notification =
                                                PushNotificationMessage(
                                              title: 'Ошибка',
                                              body:
                                                  'Неудалось добавить историю',
                                            );
                                            showSimpleNotification(
                                              Container(
                                                  child:
                                                      Text(notification.body)),
                                              position:
                                                  NotificationPosition.top,
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
                                                .doc(widget.parentId)
                                                .update({
                                              'children':
                                                  FieldValue.arrayUnion([
                                                {
                                                  'author': FirebaseAuth
                                                      .instance
                                                      .currentUser
                                                      .displayName,
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
                                            'rating': 0,
                                            'reads': 0,
                                            'tags': writingTags,
                                            'users_read': [],
                                            'users_rated': [],
                                            'comments': [],
                                            'parent': widget.data != null
                                                ? {
                                                    'id': widget.parentId,
                                                    'author':
                                                        widget.parentAuthor,
                                                    'data': widget.data,
                                                  }
                                                : null,
                                          }).catchError((error) {
                                            print('MISTAKE HERE');
                                            print(error);
                                            PushNotificationMessage
                                                notification =
                                                PushNotificationMessage(
                                              title: 'Ошибка',
                                              body:
                                                  'Неудалось добавить историю',
                                            );
                                            showSimpleNotification(
                                              Container(
                                                  child:
                                                      Text(notification.body)),
                                              position:
                                                  NotificationPosition.top,
                                              background: Colors.red,
                                            );
                                          });
                                        }
                                        PushNotificationMessage notification =
                                            PushNotificationMessage(
                                          title: 'Успех',
                                          body: 'История добавлена',
                                        );
                                        showSimpleNotification(
                                          Container(
                                              child: Text(notification.body)),
                                          position: NotificationPosition.top,
                                          background: footyColor,
                                        );
                                        prefs.setString('draft', 'Text');
                                        _controller = QuillController(
                                          document: Document.fromJson([
                                            {
                                              "insert": 'Text' + "\n",
                                            },
                                          ]),
                                          selection: TextSelection.collapsed(
                                              offset: 0),
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
                                            'tags':
                                                FieldValue.arrayUnion(nTags),
                                          });
                                        }
                                        Map tNums = {};
                                        for (Tag tag in tags) {
                                          if (writingTags.contains(tag.name)) {
                                            tNums.addAll(
                                                {tag.name: tag.number + 1});
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
                                          i1 = null;
                                          name = null;
                                          error = '';
                                          category = 'Общее';
                                          text = 'Text';
                                          loading = false;
                                        });
                                        Navigator.push(
                                          context,
                                          SlideRightRoute(
                                            page: HomeScreen(),
                                          ),
                                        );
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
                                      FirebaseFirestore.instance
                                          .collection('users')
                                          .doc(FirebaseAuth
                                              .instance.currentUser.uid)
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
                                            'images': [
                                              await a1.ref.getDownloadURL(),
                                            ],
                                            'genre': category.toLowerCase(),
                                            'parent': widget.data != null
                                                ? {
                                                    'id': widget.parentId,
                                                    'author':
                                                        widget.parentAuthor,
                                                    'data': widget.data,
                                                  }
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
                                          Container(
                                              child: Text(notification.body)),
                                          position: NotificationPosition.top,
                                          background: Colors.red,
                                        );
                                      });
                                    } else {
                                      FirebaseFirestore.instance
                                          .collection('users')
                                          .doc(FirebaseAuth
                                              .instance.currentUser.uid)
                                          .update({
                                        'drafts': FieldValue.arrayUnion([
                                          {
                                            'name': name,
                                            // 'text': text,
                                            'date': DateTime.now(),
                                            'images': 'No Image',
                                            'rich_text': jsonEncode(_controller
                                                .document
                                                .toDelta()
                                                .toJson()),
                                            'genre': category.toLowerCase(),
                                            'parent': widget.data != null
                                                ? {
                                                    'id': widget.parentId,
                                                    'author':
                                                        widget.parentAuthor,
                                                    'data': widget.data,
                                                  }
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
                                          Container(
                                              child: Text(notification.body)),
                                          position: NotificationPosition.top,
                                          background: Colors.red,
                                        );
                                      });
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
                                child: CupertinoButton(
                                  onPressed: () {
                                    showDialog(
                                      barrierDismissible: true,
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title:
                                              const Text('Правила Пользования'),
                                          content: SingleChildScrollView(
                                            child: Container(
                                                child: Center(
                                              child: Text(
                                                policy,
                                                textScaleFactor: 1,
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1000,
                                                style: GoogleFonts.montserrat(
                                                  textStyle: TextStyle(
                                                      color: primaryColor,
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.w500),
                                                ),
                                              ),
                                            )),
                                          ),
                                          actions: <Widget>[
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.of(context)
                                                      .pop(false),
                                              child: const Text(
                                                'Отменить',
                                                style: TextStyle(
                                                    color: Colors.red),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  padding: EdgeInsets.zero,
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
