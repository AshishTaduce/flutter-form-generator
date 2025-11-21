import 'package:flutter/material.dart';
import 'package:flutter_form_generator/models/field_info.dart';

class CheckboxFormField extends FormField<bool> {
  CheckboxFormField({
    super.key,
    super.onSaved,
    bool super.initialValue = false,
    required FormFieldInfo fieldInfo,
  }) : super(
         builder: (FormFieldState<bool> state) {
           return CheckboxListTile(
             dense: state.hasError,
             title: Row(
               children: [
                 Text(fieldInfo.label),
                 if (fieldInfo.required)
                   Text(
                     ' *',
                     style: TextStyle(
                       color: Theme.of(state.context).colorScheme.error,
                       fontWeight: FontWeight.bold,
                     ),
                   ),
               ],
             ),
             value: state.value,
             onChanged: state.didChange,
             subtitle: state.hasError
                 ? Builder(
                     builder: (BuildContext context) => Text(
                       state.errorText ?? "",
                       style: TextStyle(
                         color: Theme.of(context).colorScheme.error,
                       ),
                     ),
                   )
                 : null,
             controlAffinity: ListTileControlAffinity.leading,
           );
         },
         validator: (value) {
           if (fieldInfo.required && (value == null || value == false)) {
             return "Please select checkbox to continue";
           }

           return null;
         },
       );
}