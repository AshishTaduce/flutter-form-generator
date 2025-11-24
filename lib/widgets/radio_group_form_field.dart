import 'package:flutter/material.dart';
import '../models/field_info.dart';
import '../utils/form_controller.dart';

class RadioGroupFormField extends StatelessWidget {
  final FormFieldInfo fieldInfo;
  final FormController controller;

  const RadioGroupFormField({
    super.key,
    required this.fieldInfo,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      initialValue: fieldInfo.defaultValue,
      validator: (value) {
        if (fieldInfo.required && (value == null || value.isEmpty)) {
          return 'Please select an option';
        }
        return null;
      },
      onSaved: (value) {
        if (value != null) {
          controller.updateValue(fieldInfo.name, value);
        }
      },
      builder: (FormFieldState<String> state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              fieldInfo.label,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (fieldInfo.hint != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  fieldInfo.hint!,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ...(fieldInfo.options ?? []).map((option) {
              return RadioListTile<String>(
                title: Text(option.label),
                value: option.value,
                groupValue: state.value,
                onChanged: (value) {
                  state.didChange(value);
                  controller.updateValue(fieldInfo.name, value);
                },
              );
            }),
            if (state.hasError)
              Padding(
                padding: const EdgeInsets.only(left: 12.0, top: 8.0),
                child: Text(
                  state.errorText!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
