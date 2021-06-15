import 'dart:async';
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
import 'package:lycread/constants.dart';
import 'package:lycread/widgets/rounded_button.dart';
import 'package:lycread/widgets/text_field_container.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:tuple/tuple.dart';

import '../../loading_screen.dart';

// ignore: must_be_immutable
class BranchWritingScreen extends StatefulWidget {
  String parentId;
  String parentAuthor;
  String id;
  String project_name;
  String project_id;
  String project_owner;
  bool isEmpty;
  Map writing;
  String writingId;
  BranchWritingScreen({
    Key key,
    @required this.id,
    @required this.project_name,
    @required this.project_id,
    @required this.project_owner,
    this.isEmpty: true,
    this.writing,
    this.writingId,
  }) : super(key: key);
  @override
  _BranchWritingScreenState createState() => _BranchWritingScreenState();
}

class _BranchWritingScreenState extends State<BranchWritingScreen> {
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
  QuerySnapshot live_editors;
  List le_list = [];
  StreamSubscription<QuerySnapshot> subscription;
  StreamSubscription<DocumentSnapshot> writingSubscription;

  Future<void> prepare() async {
    DocumentSnapshot dcuser = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser.uid)
        .get();
    text = 'Text';
    if (!widget.isEmpty) {
      var myJSON = jsonDecode(widget.writing['rich_text']);
      _controller = QuillController(
        document: Document.fromJson(myJSON),
        selection: TextSelection.collapsed(offset: 0),
      );
    } else {
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

    DocumentSnapshot dc = await FirebaseFirestore.instance
        .collection('appData')
        .doc('LycRead')
        .get();
    List<Tag> tempTags = [];
    for (var tag in dc.data()['tags']) {
      tempTags.add(Tag(name: tag, number: dc.data()['tags_num'][tag]));
    }

    DocumentSnapshot tagsNum = await FirebaseFirestore.instance
        .collection('appData')
        .doc('LycRead')
        .get();
    List<Tag> preChosen = [];
    if (widget.writing != null) {
      for (var tag in widget.writing['tags']) {
        preChosen.add(Tag(name: tag, number: tagsNum.data()['tags_num'][tag]));
      }
    }
    if (this.mounted) {
      setState(() {
        user = dcuser;
        categs = dc.data()['genres'];
        tags = tempTags;
        if (widget.writing != null) {
          isMonetized = widget.writing['isMonetized'];
          name = widget.writing['name'];
        }
        chosenTags = preChosen;
      });
    } else {
      user = dcuser;
      categs = dc.data()['genres'];
      tags = tempTags;
      if (widget.writing != null) {
        isMonetized = widget.writing['isMonetized'];
        name = widget.writing['name'];
      }
      chosenTags = preChosen;
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

  void activateSubs(List le) {
    subscription = FirebaseFirestore.instance
        .collection('users')
        .where('id', whereIn: le.isNotEmpty ? le : ['1'])
        .snapshots()
        .listen((snap) {
      if (this.mounted) {
        setState(() {
          live_editors = snap;
        });
      } else {
        live_editors = snap;
      }
    });
  }

  @override
  void dispose() {
    if (!widget.isEmpty) {
      FirebaseFirestore.instance
          .collection('hidden_writings')
          .doc(widget.writingId)
          .update({
        'status': live_editors.docs.length < 2 ? 'stable' : 'isEdited',
        'live_editors_id':
            FieldValue.arrayRemove([FirebaseAuth.instance.currentUser.uid]),
      });
    }
    subscription.cancel();
    writingSubscription.cancel();
    super.dispose();
  }

  @override
  void initState() {
    if (!widget.isEmpty) {
      writingSubscription = FirebaseFirestore.instance
          .collection('hidden_writings')
          .doc(widget.writingId)
          .snapshots()
          .listen((snap) {
        if (this.mounted) {
          setState(() {
            if (snap.data()['live_editors_id'] != null) {
              le_list = snap.data()['live_editors_id'];
              activateSubs(le_list);
            }
          });
        } else {
          if (snap.data()['live_editors_id'] != null) {
            le_list = snap.data()['live_editors_id'];
            activateSubs(le_list);
          }
        }
      });
    }
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
                        live_editors != null
                            ? live_editors.docs.length != 0
                                ? live_editors.docs.length < 5
                                    ? Container(
                                        margin: EdgeInsets.all(10),
                                        child: Row(
                                          children: [
                                            for (QueryDocumentSnapshot editor
                                                in live_editors.docs)
                                              Container(
                                                width: 30,
                                                height: 30,
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          25.0),
                                                  child: editor.data()[
                                                              'photo'] !=
                                                          null
                                                      ? CachedNetworkImage(
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
                                                          imageUrl: editor
                                                              .data()['photo'],
                                                        )
                                                      : Image.asset(
                                                          'assets/images/User.png',
                                                          fit: BoxFit.cover,
                                                        ),
                                                ),
                                              )
                                          ],
                                        ),
                                      )
                                    : Container(
                                        margin: EdgeInsets.all(10),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 30,
                                              height: 30,
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(25.0),
                                                child: live_editors.docs[0]
                                                            .data()['photo'] !=
                                                        null
                                                    ? CachedNetworkImage(
                                                        filterQuality:
                                                            FilterQuality.none,
                                                        fit: BoxFit.cover,
                                                        placeholder:
                                                            (context, url) =>
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
                                                        imageUrl: live_editors
                                                            .docs[0]
                                                            .data()['photo'],
                                                      )
                                                    : Image.asset(
                                                        'assets/images/User.png',
                                                        fit: BoxFit.cover,
                                                      ),
                                              ),
                                            ),
                                            Container(
                                              width: 30,
                                              height: 30,
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(25.0),
                                                child: live_editors.docs[1]
                                                            .data()['photo'] !=
                                                        null
                                                    ? CachedNetworkImage(
                                                        filterQuality:
                                                            FilterQuality.none,
                                                        fit: BoxFit.cover,
                                                        placeholder:
                                                            (context, url) =>
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
                                                        imageUrl: live_editors
                                                            .docs[1]
                                                            .data()['photo'],
                                                      )
                                                    : Image.asset(
                                                        'assets/images/User.png',
                                                        fit: BoxFit.cover,
                                                      ),
                                              ),
                                            ),
                                            Container(
                                              width: 30,
                                              height: 30,
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(25.0),
                                                child: live_editors.docs[2]
                                                            .data()['photo'] !=
                                                        null
                                                    ? CachedNetworkImage(
                                                        filterQuality:
                                                            FilterQuality.none,
                                                        fit: BoxFit.cover,
                                                        placeholder:
                                                            (context, url) =>
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
                                                        imageUrl: live_editors
                                                            .docs[2]
                                                            .data()['photo'],
                                                      )
                                                    : Image.asset(
                                                        'assets/images/User.png',
                                                        fit: BoxFit.cover,
                                                      ),
                                              ),
                                            ),
                                            Container(
                                              width: 30,
                                              height: 30,
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(25.0),
                                                child: live_editors.docs[3]
                                                            .data()['photo'] !=
                                                        null
                                                    ? CachedNetworkImage(
                                                        filterQuality:
                                                            FilterQuality.none,
                                                        fit: BoxFit.cover,
                                                        placeholder:
                                                            (context, url) =>
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
                                                        imageUrl: live_editors
                                                            .docs[3]
                                                            .data()['photo'],
                                                      )
                                                    : Image.asset(
                                                        'assets/images/User.png',
                                                        fit: BoxFit.cover,
                                                      ),
                                              ),
                                            ),
                                            SizedBox(width: 5),
                                            Text(
                                              '+ ' +
                                                  (live_editors.docs.length - 4)
                                                      .toString(),
                                              textScaleFactor: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: GoogleFonts.montserrat(
                                                textStyle: TextStyle(
                                                  color: darkPrimaryColor,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      )
                                : Container()
                            : Container(),
                        // live_editors != null
                        //     ? live_editors.docs.length != 0
                        //         ? live_editors.docs.length > 2
                        //             ? Padding(
                        //                 padding: const EdgeInsets.all(10.0),
                        //                 child: Text(
                        //                   live_editors.docs.first
                        //                           .data()['name'] +
                        //                       ' ' +
                        //                       live_editors.docs.last
                        //                           .data()['name'] +
                        //                       ' и ' +
                        //                       (live_editors.docs.length - 2)
                        //                           .toString() +
                        //                       ' пользователей вносят изменения',
                        //                   textScaleFactor: 1,
                        //                   overflow: TextOverflow.ellipsis,
                        //                   maxLines: 3,
                        //                   style: GoogleFonts.montserrat(
                        //                     textStyle: TextStyle(
                        //                       color: footyColor,
                        //                       fontSize: 15,
                        //                       fontWeight: FontWeight.w400,
                        //                     ),
                        //                   ),
                        //                 ),
                        //               )
                        //             : Padding(
                        //                 padding: EdgeInsets.all(10.0),
                        //                 child: Text(
                        //                   live_editors.docs.last
                        //                               .data()['name'] !=
                        //                           live_editors.docs.first
                        //                               .data()['name']
                        //                       ? live_editors.docs.first
                        //                               .data()['name'] +
                        //                           ' и ' +
                        //                           live_editors.docs.last
                        //                               .data()['name'] +
                        //                           ' вносят изменения'
                        //                       : live_editors.docs.first
                        //                               .data()['name'] +
                        //                           ' вносит изменения',
                        //                   textScaleFactor: 1,
                        //                   overflow: TextOverflow.ellipsis,
                        //                   maxLines: 3,
                        //                   style: GoogleFonts.montserrat(
                        //                     textStyle: TextStyle(
                        //                       color: footyColor,
                        //                       fontSize: 15,
                        //                       fontWeight: FontWeight.w400,
                        //                     ),
                        //                   ),
                        //                 ),
                        //               )
                        //         : Container()
                        //     : Container(),

                        Container(
                          height: 110,
                          child: TextFieldContainer(
                            child: TextFormField(
                              // maxLength: length != null ? length : double.infinity.toInt(),
                              maxLength: 30,
                              style: TextStyle(color: primaryColor),
                              validator: (val) =>
                                  val.length > 1 ? null : 'Минимум 2 символов',
                              keyboardType: TextInputType.text,
                              onChanged: (value) {
                                name = value;
                              },
                              initialValue: widget.writing != null
                                  ? widget.writing['name']
                                  : '',
                              decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                      borderSide: BorderSide.none),
                                  hintText: widget.writing != null
                                      ? widget.writing['name']
                                      : "Название",
                                  hintStyle: TextStyle(fontSize: 20)),
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
                              String id = FirebaseAuth.instance.currentUser.uid;
                              TaskSnapshot task = await FirebaseStorage.instance
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
                                  ? widget.writing != null
                                      ? widget.writing['images'] != 'No Image'
                                          ? CachedNetworkImage(
                                              filterQuality: FilterQuality.none,
                                              fit: BoxFit.cover,
                                              placeholder: (context, url) =>
                                                  Transform.scale(
                                                scale: 0.8,
                                                child:
                                                    CircularProgressIndicator(
                                                  strokeWidth: 2.0,
                                                  backgroundColor: footyColor,
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                          Color>(primaryColor),
                                                ),
                                              ),
                                              imageUrl: widget.writing['images']
                                                  [0],
                                            )
                                          : Icon(Icons.add)
                                      : Icon(Icons.add)
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
                                  String timeId = DateTime.now()
                                      .millisecondsSinceEpoch
                                      .toString();
                                  if (a1 != null) {
                                    if (widget.isEmpty) {
                                      FirebaseFirestore.instance
                                          .collection('hidden_writings')
                                          .doc(timeId)
                                          .set({
                                        'id': timeId,
                                        'name': name,
                                        // 'text': text,
                                        'author': widget.project_owner,
                                        'images': [
                                          await a1.ref.getDownloadURL(),
                                        ],
                                        'status': 'stable',
                                        'live_editors_id': [],
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
                                        'project_id': widget.project_id,
                                        'project_name': widget.project_name,
                                        'branch_id': widget.id,
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
                                      FirebaseFirestore.instance
                                          .collection('hidden_writings')
                                          .doc(widget.writingId)
                                          .update({
                                        'id': widget.writingId,
                                        'name': name,
                                        // 'text': text,
                                        'author': widget.project_owner,
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
                                        'project_id': widget.project_id,
                                        'project_name': widget.project_name,
                                        'branch_id': widget.id,
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
                                  } else {
                                    if (widget.isEmpty) {
                                      FirebaseFirestore.instance
                                          .collection('hidden_writings')
                                          .doc(timeId)
                                          .set({
                                        'id': timeId,
                                        'name': name,
                                        'author': widget.project_owner,
                                        'images': 'No Image',
                                        'status': 'stable',
                                        'live_editors_id': [],
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
                                        'project_id': widget.project_id,
                                        'project_name': widget.project_name,
                                        'branch_id': widget.id,
                                      }).catchError((error) {
                                        print('MISTAKE HERE');
                                        print(error);
                                        PushNotificationMessage notification =
                                            PushNotificationMessage(
                                          title: 'Ошибка',
                                          body: 'Неудалось сохранить историю',
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
                                          .collection('hidden_writings')
                                          .doc(widget.writingId)
                                          .update({
                                        'id': widget.writingId,
                                        'name': name,
                                        // 'text': text,
                                        'author': widget.project_owner,
                                        'images': widget.writing['images'],
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
                                        'project_id': widget.project_id,
                                        'project_name': widget.project_name,
                                        'branch_id': widget.id,
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
                                  String authorName = FirebaseAuth
                                      .instance.currentUser.displayName;
                                  String _name = name;
                                  FirebaseFirestore.instance
                                      .collection('projects')
                                      .doc(widget.project_id)
                                      .update({
                                    'logs': FieldValue.arrayUnion([
                                      {
                                        'text': widget.isEmpty
                                            ? '$authorName добавил новую историю: $_name'
                                            : '$authorName изменил $_name',
                                        'date': DateTime.now(),
                                        'branch_id': widget.id,
                                        'author_id': FirebaseAuth
                                            .instance.currentUser.uid,
                                        'post_id': widget.isEmpty
                                            ? timeId
                                            : widget.writingId
                                      }
                                    ]),
                                    'last_update': DateTime.now(),
                                  });
                                  FirebaseFirestore.instance
                                      .collection('branches')
                                      .doc(widget.id)
                                      .update({'last_update': DateTime.now()});
                                  PushNotificationMessage notification =
                                      PushNotificationMessage(
                                    title: 'Успех',
                                    body: 'История сохранена',
                                  );
                                  showSimpleNotification(
                                    Container(child: Text(notification.body)),
                                    position: NotificationPosition.top,
                                    background: footyColor,
                                  );
                                  _controller = QuillController(
                                    document: Document.fromJson([
                                      {
                                        "insert": 'Text' + "\n",
                                      },
                                    ]),
                                    selection:
                                        TextSelection.collapsed(offset: 0),
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
  static Future<List<Tag>> getTags(String query, List<Tag> tags) async {
    return tags
        .where((tag) => tag.get().toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}
