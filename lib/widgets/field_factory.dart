import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/field_info.dart';
import '../utils/form_controller.dart';
import '../utils/common_utils.dart';
import 'checkbox_form_field.dart';
import 'password_form_field.dart';
import 'radio_group_form_field.dart';
import 'date_time_form_field.dart';
import 'file_form_field.dart';
import 'dropdown_form_field.dart';

class FieldWidgetFactory {
  static Widget create(FormFieldInfo fieldInfo, FormController controller) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, child) {
        if (!controller.isFieldEnabled(fieldInfo.name)) {
          return const SizedBox.shrink();
        }
        return _buildField(context, fieldInfo, controller);
      },
    );
  }

  static Widget _buildField(
    BuildContext context,
    FormFieldInfo fieldInfo,
    FormController controller,
  ) {
    Widget field;

    switch (fieldInfo.type) {
      case FieldType.textInput:
        field = TextFormField(
          decoration: InputDecoration(
            labelText: fieldInfo.label,
            hintText: fieldInfo.placeholder ?? fieldInfo.label,
            helperText: fieldInfo.hint,
            suffixIcon: fieldInfo.tooltip != null
                ? Tooltip(
                    message: fieldInfo.tooltip!,
                    child: const Icon(Icons.info_outline),
                  )
                : null,
          ),
          initialValue: fieldInfo.defaultValue,
          onSaved: (value) => controller.updateValue(fieldInfo.name, value),
          onChanged: (value) => controller.updateValue(fieldInfo.name, value),
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
        break;

      case FieldType.numberInput:
        field = TextFormField(
          decoration: InputDecoration(
            labelText: fieldInfo.label,
            hintText: fieldInfo.placeholder ?? fieldInfo.label,
            helperText: fieldInfo.hint,
            suffixIcon: fieldInfo.tooltip != null
                ? Tooltip(
                    message: fieldInfo.tooltip!,
                    child: const Icon(Icons.info_outline),
                  )
                : null,
          ),
          initialValue: fieldInfo.defaultValue,
          onSaved: (value) => controller.updateValue(fieldInfo.name, value),
          onChanged: (value) => controller.updateValue(fieldInfo.name, value),
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
        break;

      case FieldType.emailInput:
        field = TextFormField(
          decoration: InputDecoration(
            labelText: fieldInfo.label,
            hintText: fieldInfo.placeholder ?? fieldInfo.label,
            helperText: fieldInfo.hint,
            suffixIcon: fieldInfo.tooltip != null
                ? Tooltip(
                    message: fieldInfo.tooltip!,
                    child: const Icon(Icons.info_outline),
                  )
                : null,
          ),
          initialValue: fieldInfo.defaultValue,
          onSaved: (value) => controller.updateValue(fieldInfo.name, value),
          onChanged: (value) => controller.updateValue(fieldInfo.name, value),
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
        break;

      case FieldType.passwordInput:
        field = PasswordFormField(
          fieldInfo: fieldInfo,
          onSaved: (value) => controller.updateValue(fieldInfo.name, value),
        );
        break;

      case FieldType.textArea:
        field = TextFormField(
          decoration: InputDecoration(
            labelText: fieldInfo.label,
            hintText: fieldInfo.placeholder ?? fieldInfo.label,
            helperText: fieldInfo.hint,
            suffixIcon: fieldInfo.tooltip != null
                ? Tooltip(
                    message: fieldInfo.tooltip!,
                    child: const Icon(Icons.info_outline),
                  )
                : null,
          ),
          initialValue: fieldInfo.defaultValue,
          onSaved: (value) => controller.updateValue(fieldInfo.name, value),
          onChanged: (value) => controller.updateValue(fieldInfo.name, value),
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
        break;

      case FieldType.dropdown:
        field = EnhancedDropdownFormField(
          fieldInfo: fieldInfo,
          controller: controller,
        );
        break;

      case FieldType.checkbox:
        field = CheckboxFormField(
          fieldInfo: fieldInfo,
          onSaved: (value) => controller.updateValue(fieldInfo.name, value),
        );
        break;

      case FieldType.radio:
        field = RadioGroupFormField(
          fieldInfo: fieldInfo,
          controller: controller,
        );
        break;

      case FieldType.date:
        field = DateTimeFormField(
          fieldInfo: fieldInfo,
          controller: controller,
          isTime: false,
        );
        break;

      case FieldType.time:
        field = DateTimeFormField(
          fieldInfo: fieldInfo,
          controller: controller,
          isTime: true,
        );
        break;

      case FieldType.file:
        field = FileFormField(
          fieldInfo: fieldInfo,
          controller: controller,
        );
        break;

      default:
        field = Text('Unknown field type: ${fieldInfo.type}');
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: field,
    );
  }
}
