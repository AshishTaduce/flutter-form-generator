import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'utils/action_engine.dart';
import 'utils/common_utils.dart';

import 'models/field_info.dart';
import 'widgets/checkbox_form_field.dart';
import 'widgets/password_form_field.dart';

class FormGenerator {
  final Map<String, String>? headers;
  final void Function(Map<String, dynamic> values)? onSuccess;

  late final ActionEngine _actionEngine;
  final Map<GlobalKey<FormState>, Map<String, dynamic>> _formValues = {};

  FormGenerator({
    this.headers,
    this.onSuccess,
  }) {
    _actionEngine = ActionEngine(headers: headers);
  }

  Widget generateForm(Map<String, dynamic> formData) {
    GlobalKey<FormState> formKey = GlobalKey<FormState>();
    _formValues[formKey] = {};

    return _FormGeneratorWidget(
      formKey: formKey,
      formData: formData,
      formGenerator: this,
    );
  }

  void _handleSubmit(
      GlobalKey<FormState> formKey,
      Map<String, dynamic> formData,
      BuildContext context,
      Function(bool) setLoading,
      ) async {
    if (formKey.currentState?.validate() ?? false) {
      formKey.currentState?.save();

      final submitAction = formData['submit']?['action'];

      if (submitAction != null) {
        setLoading(true);

        await _actionEngine.executeAction(
          action: submitAction,
          context: context,
          formValues: _formValues[formKey],
          onSuccess: () {
            if (onSuccess != null) {
              onSuccess!(_formValues[formKey]!);
            }
          },
        );

        setLoading(false);
      } else {
        print(_formValues[formKey]);
        if (onSuccess != null) {
          onSuccess!(_formValues[formKey]!);
        }
      }
    }
  }

  void _handleReset(GlobalKey<FormState> formKey, BuildContext context) {
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
                _formValues[formKey]?.clear();
                Navigator.of(dialogContext).pop();
              },
              child: Text('Reset'),
            ),
          ],
        );
      },
    );
  }

  List<Widget> _generateFields(
      List<FormFieldInfo> fieldsList,
      GlobalKey<FormState> formKey,
      ) {
    List<Widget> fields = [];
    for (var field in fieldsList) {
      fields.add(_generateField(field, formKey));
    }
    return fields;
  }

  Widget _generateField(FormFieldInfo fieldInfo, GlobalKey<FormState> formKey) {
    late Widget field;
    String fieldLabel = fieldInfo.label;

    switch (fieldInfo.type) {
      case FieldType.textInput:
        field = TextFormField(
          decoration: InputDecoration(
            labelText: fieldLabel,
            hintText: fieldLabel,
          ),
          onSaved: (value) => _formValues[formKey]![fieldInfo.name] = value,
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
          onSaved: (value) => _formValues[formKey]![fieldInfo.name] = value,
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
          onSaved: (value) => _formValues[formKey]![fieldInfo.name] = value,
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
          onSaved: (value) => _formValues[formKey]![fieldInfo.name] = value,
        );

      case FieldType.textArea:
        field = TextFormField(
          decoration: InputDecoration(
            labelText: fieldLabel,
            hintText: fieldLabel,
          ),
          onSaved: (value) => _formValues[formKey]![fieldInfo.name] = value,
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
          onSaved: (value) => _formValues[formKey]![fieldInfo.name] = value,
          onChanged: (value) {},
          items: (fieldInfo.options ?? [])
              .map((optionInfo) => DropdownMenuItem(
            value: optionInfo.value,
            child: Text(optionInfo.label),
          ))
              .toList(),
          validator: (value) {
            if (fieldInfo.required && (value == null || value.isEmpty)) {
              return "Please select an option";
            }

            return checkValidations(
                fieldInfo.validations ?? [], value?.toString() ?? '');
          },
        );

      case FieldType.checkbox:
        field = CheckboxFormField(
          fieldInfo: fieldInfo,
          onSaved: (value) => _formValues[formKey]![fieldInfo.name] = value,
        );

      default:
        field = Text(fieldInfo.type.toString());
    }

    return field;
  }
}

class _FormGeneratorWidget extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final Map<String, dynamic> formData;
  final FormGenerator formGenerator;

  const _FormGeneratorWidget({
    required this.formKey,
    required this.formData,
    required this.formGenerator,
  });

  @override
  State<_FormGeneratorWidget> createState() => _FormGeneratorWidgetState();
}

class _FormGeneratorWidgetState extends State<_FormGeneratorWidget> {
  bool _isLoading = false;

  void _setLoading(bool loading) {
    setState(() {
      _isLoading = loading;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: SingleChildScrollView(
        child: Column(
          spacing: 16.0,
          children: [
            ...widget.formGenerator._generateFields(
              (widget.formData['fields'] as List)
                  .map((field) => FormFieldInfo.fromJson(field))
                  .toList(),
              widget.formKey,
            ),
            SizedBox(height: 8.0),
            Row(
              spacing: 16.0,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ElevatedButton(
                      onPressed: _isLoading
                          ? null
                          : () => widget.formGenerator._handleSubmit(
                        widget.formKey,
                        widget.formData,
                        context,
                        _setLoading,
                      ),
                      child: _isLoading
                          ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                          : Text(
                        widget.formData['submit']?['label'] ?? 'Submit',
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: OutlinedButton(
                      onPressed: _isLoading
                          ? null
                          : () => widget.formGenerator._handleReset(
                        widget.formKey,
                        context,
                      ),
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
}