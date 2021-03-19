import 'package:flutter/material.dart';
import 'package:lycread/widgets/text_field_container.dart';

import '../constants.dart';

class RoundedTextInput extends StatelessWidget {
  final String hintText;
  final TextInputType type;
  final Function validator;
  final IconData icon;
  final ValueChanged<String> onChanged;
  final TextEditingController controller;
  final int length;
  final double height;
  const RoundedTextInput({
    Key key,
    this.hintText,
    this.type,
    this.validator,
    this.icon = Icons.person,
    this.onChanged,
    this.controller,
    this.length: null,
    this.height: 90,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      height: height,
      child: TextFieldContainer(
        child: TextFormField(
          // maxLength: length != null ? length : double.infinity.toInt(),
          maxLength: length,
          style: TextStyle(color: primaryColor),
          controller: controller,
          validator: validator,
          keyboardType: type,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hintText,
            border: OutlineInputBorder(),
          ),
        ),
      ),
    );
  }
}
