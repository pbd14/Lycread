import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lycread/widgets/text_field_container.dart';

import '../constants.dart';

class RoundedTextInput extends StatelessWidget {
  final String hintText, initialValue;
  final TextInputType type;
  final Function validator;
  final IconData icon;
  final ValueChanged<String> onChanged;
  final TextEditingController controller;
  final int length;
  final double height;
  final List<TextInputFormatter> formatters;
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
    this.formatters: null,
    this.initialValue: null,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      child: TextFieldContainer(
        child: TextFormField(
          initialValue: this.initialValue,
          // maxLength: length != null ? length : double.infinity.toInt(),
          maxLength: length,
          style: TextStyle(color: primaryColor),
          controller: controller,
          validator: validator,
          keyboardType: type,
          onChanged: onChanged,
          inputFormatters: formatters != null ? formatters : [],
          decoration: InputDecoration(
            hintText: hintText,
            border: OutlineInputBorder(),
          ),
        ),
      ),
    );
  }
}
