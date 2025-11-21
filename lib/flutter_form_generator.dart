import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'utils/common_utils.dart';

import 'models/field_info.dart';
import 'widgets/checkbox_form_field.dart';
import 'widgets/password_form_field.dart';

class FormGenerator {
  final Map<String, dynamic> _values = {};

  Widget generateForm(Map<String, dynamic> formData) {
    GlobalKey<FormState> formKey = GlobalKey<FormState>();

    return Form(
      key: formKey,
      child: SingleChildScrollView(
        child: Column(
          spacing: 16.0,
          children: [
            ..._generateFields(
              (formData['fields'] as List)
                  .map((field) => FormFieldInfo.fromJson(field))
                  .toList(),
            ),
            SizedBox(height: 8.0),
            Row(
              spacing: 16.0,
              children: [
                if (formData['submit'] != null)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ElevatedButton(
                      onPressed: () => _handleSubmit(formKey),
                      child: Text(formData['submit']?['label'] ?? 'Submit'),
                    ),
                  ),
                ),
                if (formData['reset'] != null)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: OutlinedButton(
                      onPressed: () => _handleReset(formKey),
                      child: Text('Reset'),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _handleSubmit(GlobalKey<FormState> formKey) {
    if (formKey.currentState?.validate() ?? false) {
      formKey.currentState?.save();
      debugPrint(_values.toString());
    }
  }

  void _handleReset(GlobalKey<FormState> formKey) {
    final context = formKey.currentContext;
    if (context == null) return;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Reset Form'),
          content: Text('Are you sure you want to reset the form?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                formKey.currentState?.reset();
                _values.clear();
                Navigator.of(dialogContext).pop();
              },
              child: Text('Reset'),
            ),
          ],
        );
      },
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
          onSaved: (value) => _values[fieldInfo.name] = value,
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
              return "Only ${fieldInfo.maxLength} at-most characters allowed";
            }
            if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value!)) {
              return "Only text allowed";
            }

            return checkValidations(fieldInfo.validations ?? [], value);
          },
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^[a-zA-Z\s]+$')),
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
          onSaved: (value) => _values[fieldInfo.name] = value,
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
          onSaved: (value) => _values[fieldInfo.name] = value,
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
        field = PasswordFormField(
          fieldInfo: fieldInfo,
          onSaved: (value) => _values[fieldInfo.name] = value,
        );

      case FieldType.textArea:
        field = TextFormField(
          decoration: InputDecoration(
            labelText: fieldLabel,
            hintText: fieldLabel,
          ),
          onSaved: (value) => _values[fieldInfo.name] = value,
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
              return "Only ${fieldInfo.maxLength} at-most characters allowed";
            }

            return checkValidations(fieldInfo.validations ?? [], value!);
          },
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^[a-zA-Z\s]+$')),
          ],
          maxLength: fieldInfo.maxLength,
          maxLengthEnforcement: MaxLengthEnforcement.enforced,
          maxLines: 5,
          minLines: 3,
        );

      case FieldType.dropdown:
        field = DropdownButtonFormField(
          decoration: InputDecoration(
            labelText: fieldLabel,
            hintText: fieldLabel,
          ),
          onSaved: (value) => _values[fieldInfo.name] = value,
          onChanged: (value) {},
          items: (fieldInfo.options ?? [])
              .map(
                (optionInfo) => DropdownMenuItem(
                  value: optionInfo.value,
                  child: Text(optionInfo.label),
                ),
              )
              .toList(),
          validator: (value) {
            if (fieldInfo.required && (value == null || value.isEmpty)) {
              return "Please select an option";
            }

            return checkValidations(
              fieldInfo.validations ?? [],
              value?.toString() ?? '',
            );
          },
        );

      case FieldType.checkbox:
        field = CheckboxFormField(
          fieldInfo: fieldInfo,
          onSaved: (value) => _values[fieldInfo.name] = value,
        );

      default:
        field = Text(fieldInfo.type.toString());
    }

    return field;
  }
}
