import 'package:flutter/material.dart';
import 'package:flutter_form_generator/utils/common_utils.dart';

import '../models/field_info.dart';

class PasswordFormField extends StatefulWidget {
  const PasswordFormField({
    super.key,
    required this.fieldInfo,
    this.onSaved,
  });

  final FormFieldInfo fieldInfo;
  final void Function(String?)? onSaved;

  @override
  State<PasswordFormField> createState() => _PasswordFormFieldState();
}

class _PasswordFormFieldState extends State<PasswordFormField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: widget.fieldInfo.label,
        hintText: widget.fieldInfo.label,
        suffixIcon: IconButton(
          icon: Icon(
            _obscureText ? Icons.visibility : Icons.visibility_off,
            color: Theme.of(context).primaryColorDark,
          ),
          onPressed: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
        ),
      ),
      obscureText: _obscureText,
      onSaved: widget.onSaved,
      validator: (value) {
        if (widget.fieldInfo.required && (value?.isEmpty ?? true)) {
          return "Please enter some text";
        }

        return checkValidations(widget.fieldInfo.validations ?? [], value!);
      },
    );
  }
}