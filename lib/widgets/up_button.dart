import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class UpButton extends StatefulWidget {
  const UpButton({
    Key key,
    this.color1,
    this.color2,
    this.ph,
    this.pw,
    this.size,
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
  final double size;
  final Function onTap, onTap2;
  final DocumentReference reverse;
  final String containsValue;
  final bool isC;

  @override
  _UpButtonState createState() => _UpButtonState();
}

class _UpButtonState extends State<UpButton> {
  bool isColored = false;
  bool isOne = true;
  Color labelColor;
  // ignore: cancel_subscriptions
  StreamSubscription<DocumentSnapshot> subscription;
  List res = [];

  @override
  void initState() {
    super.initState();
    subscription = widget.reverse.snapshots().listen((docsnap) {
      if (docsnap.data()['users_rated'] != null) {
        if (docsnap.data()['users_rated'].contains(widget.containsValue)) {
          if (this.mounted) {
            setState(() {
              isColored = true;
              isOne = false;
            });
          }
        } else if (!docsnap
            .data()['users_rated']
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
    }
    if (isColored) {
      labelColor = widget.color1;
    } else {
      labelColor = widget.color2;
    }
    return TextButton(
      // highlightColor: darkPrimaryColor,
      // height: widget.ph,
      // minWidth: widget.pw,
      onPressed: () {
        setState(() {
          isColored = !isColored;
          if (isColored) {
            labelColor = widget.color1;
          } else {
            labelColor = widget.color2;
          }
        });
        isOne ? widget.onTap() : widget.onTap2();
        isOne = !isOne;
      },
      child: Container(
        height: widget.ph,
        width: widget.pw,
        child: Icon(
          CupertinoIcons.heart_fill,
          color: labelColor == null ? widget.color2 : labelColor,
          size: widget.size,
        ),
      ),
    );
  }
}
