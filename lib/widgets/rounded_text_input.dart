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
  const RoundedTextInput({
    Key key,
    this.hintText,
    this.type,
    this.validator,
    this.icon = Icons.person,
    this.onChanged,
    this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      height: 90,
      child: TextFieldContainer(
        child: TextFormField(
          style: TextStyle(color: primaryColor),
          controller: controller,
          validator: validator,
          keyboardType: type,
          onChanged: onChanged,
          cursorColor: whiteColor,
          decoration: InputDecoration(
            hintText: hintText,
            border: OutlineInputBorder(),
          ),
        ),
      ),
    );
  }
}
