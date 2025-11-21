import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'utils/common_utils.dart';

import 'models/field_info.dart';
import 'widgets/password_form_field.dart';

class FormGenerator {
  Widget generateForm(Map<String, dynamic> formData) {
    return SingleChildScrollView(
      child: Column(
        children: _generateFields(
          (formData['fields'] as List)
              .map((field) => FormFieldInfo.fromJson(field))
              .toList(),
        ),
      ),
    );
  }

  List<Widget> _generateFields(List<FormFieldInfo> fieldsList) {
    List<Widget> fields = [];
    for (var field in fieldsList) {
      fields.add(_generateField(field));
    }
    return fields;
  }

  Widget _generateField(FormFieldInfo fieldInfo) {
    late Widget field;
    String fieldLabel = fieldInfo.label;

    switch (fieldInfo.type) {
      case FieldType.textInput:
        field = TextFormField(
          decoration: InputDecoration(
            labelText: fieldLabel,
            hintText: fieldLabel,
          ),
          validator: (value) {
            if (fieldInfo.required && (value?.isEmpty ?? true)) {
              return "Please enter some text";
            }
            if (fieldInfo.minLength != null &&
                ((value?.length ?? 0) < fieldInfo.minLength!)) {
              return "Please enter at least ${fieldInfo.minLength} characters";
            }
            if (fieldInfo.maxLength != null &&
                ((value?.length ?? 0) > fieldInfo.maxLength!)) {
              return "Only ${fieldInfo.minLength} at-most characters allowed";
            }
            if (!RegExp(r'^[a-zA-Z]+$').hasMatch(value!)) {
              return "Only text allowed";
            }

            return checkValidations(fieldInfo.validations ?? [], value);
          },
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^[a-zA-Z]+$')),
          ],
          maxLength: fieldInfo.maxLength,
          maxLengthEnforcement: MaxLengthEnforcement.enforced,
        );

      case FieldType.numberInput:
        field = TextFormField(
          decoration: InputDecoration(
            labelText: fieldLabel,
            hintText: fieldLabel,
          ),
          validator: (value) {
            if (fieldInfo.required && (value?.isEmpty ?? true)) {
              return "Please enter some text";
            }
            if (!RegExp(r'^[0-9]+$').hasMatch(value!)) {
              return "Only numbers allowed";
            }
            if (fieldInfo.max != null && (num.parse(value) > fieldInfo.max!)) {
              return "Provide value lesser than ${fieldInfo.max}";
            }
            if (fieldInfo.min != null && (int.parse(value) < fieldInfo.min!)) {
              return "Provide value greater than ${fieldInfo.min}";
            }
            return checkValidations(fieldInfo.validations ?? [], value);
          },
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^[0-9]+$')),
          ],
        );

      case FieldType.emailInput:
        field = TextFormField(
          decoration: InputDecoration(
            labelText: fieldLabel,
            hintText: fieldLabel,
          ),
          validator: (value) {
            if (fieldInfo.required && (value?.isEmpty ?? true)) {
              return "Please enter some text";
            }
            if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
              return "Please enter a valid email";
            }
            return checkValidations(fieldInfo.validations ?? [], value);
          },
        );

      case FieldType.passwordInput:
        field = PasswordFormField(fieldInfo: fieldInfo);
      default:
        field = Text(fieldInfo.type.toString());
    }

    return field;
  }

}
