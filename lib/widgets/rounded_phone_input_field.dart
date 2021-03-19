import 'package:flutter/material.dart';
import 'package:lycread/widgets/text_field_container.dart';

import '../constants.dart';

class RoundedPhoneInputField extends StatelessWidget {
  final String hintText;
  final IconData icon;
  final ValueChanged<String> onChanged;
  const RoundedPhoneInputField({
    Key key,
    this.hintText,
    this.icon = Icons.person,
    this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      child: TextFieldContainer(
        child: TextFormField(
          style: TextStyle(color: primaryColor),
          validator: (val) => val.isEmpty ? 'Enter the phone' : null,
          keyboardType: TextInputType.phone,
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
