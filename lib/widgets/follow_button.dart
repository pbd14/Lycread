import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants.dart';

class FollowButton extends StatefulWidget {
  const FollowButton({
    Key key,
    this.color1,
    this.color2,
    this.ph,
    this.pw,
    this.onTap,
    this.onTap2,
    this.reverse,
    this.containsValue,
    this.isC,
  }) : super(key: key);

  final Color color1;
  final Color color2;
  final double ph;
  final double pw;
  final Function onTap, onTap2;
  final DocumentReference reverse;
  final String containsValue;
  final bool isC;

  @override
  _FollowButtonState createState() => _FollowButtonState();
}

class _FollowButtonState extends State<FollowButton> {
  bool isColored = false;
  bool isOne = true;
  Color labelColor;
  Color textColor;
  // ignore: cancel_subscriptions
  StreamSubscription<DocumentSnapshot> subscription;
  List res = [];

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    subscription = widget.reverse.snapshots().listen((docsnap) {
      if (docsnap.data()['following'] != null) {
        if (docsnap.data()['following'].contains(widget.containsValue)) {
          if (this.mounted) {
            setState(() {
              isColored = true;
              isOne = false;
            });
          }
        } else if (!docsnap
            .data()['following']
            .contains(widget.containsValue)) {
          if (this.mounted) {
            setState(() {
              isColored = false;
              isOne = true;
            });
          }
        }
      }
    });
    if (widget.isC) {
      setState(() {
        isOne = false;
        isColored = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (labelColor == null) {
      labelColor = widget.color2;
      textColor = widget.color1;
    }
    if (isColored) {
      labelColor = widget.color1;
      textColor = widget.color2;
    } else {
      labelColor = widget.color2;
      textColor = widget.color1;
    }
    return TextButton(
      onPressed: () {
        setState(() {
          isColored = !isColored;
          if (isColored) {
            labelColor = widget.color1;
            textColor = widget.color2;
          } else {
            labelColor = widget.color2;
            textColor = widget.color1;
          }
        });
        isOne ? widget.onTap() : widget.onTap2();
        isOne = !isOne;
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          height: widget.ph,
          width: widget.pw,
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          color: labelColor == null ? widget.color2 : labelColor,
          child: Center(
            child: Text(
              isColored ? 'Unfollow' : 'Follow',
              textScaleFactor: 1,
              style: GoogleFonts.montserrat(
                  textStyle: TextStyle(
                fontSize: 15,
                color: textColor,
              )),
            ),
          ),
        ),
      ),
    );
  }
}
