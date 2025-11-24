import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/field_info.dart';
import '../utils/form_controller.dart';

class DateTimeFormField extends StatefulWidget {
  final FormFieldInfo fieldInfo;
  final FormController controller;
  final bool isTime;

  const DateTimeFormField({
    super.key,
    required this.fieldInfo,
    required this.controller,
    this.isTime = false,
  });

  @override
  State<DateTimeFormField> createState() => _DateTimeFormFieldState();
}

class _DateTimeFormFieldState extends State<DateTimeFormField> {
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.fieldInfo.defaultValue != null) {
      _textController.text = widget.fieldInfo.defaultValue!;
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, FormFieldState<String> state) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      final formatted = DateFormat('yyyy-MM-dd').format(picked);
      _textController.text = formatted;
      state.didChange(formatted);
      widget.controller.updateValue(widget.fieldInfo.name, formatted);
    }
  }

  Future<void> _selectTime(BuildContext context, FormFieldState<String> state) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      final formatted = picked.format(context);
      _textController.text = formatted;
      state.didChange(formatted);
      widget.controller.updateValue(widget.fieldInfo.name, formatted);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _textController,
      readOnly: true,
      decoration: InputDecoration(
        labelText: widget.fieldInfo.label,
        hintText: widget.fieldInfo.placeholder ?? (widget.isTime ? 'Select Time' : 'Select Date'),
        helperText: widget.fieldInfo.hint,
        suffixIcon: Icon(widget.isTime ? Icons.access_time : Icons.calendar_today),
      ),
      onTap: () async {
        // We need access to the FormFieldState to update it. 
        // Since TextFormField wraps FormField, we can't easily get the state directly here 
        // without wrapping it ourselves or using the controller.
        // But TextFormField handles validation via validator.
        // We just need to trigger the picker.
        
        // However, to properly integrate with FormField state for validation, 
        // we should probably wrap this logic. 
        // But TextFormField is already a FormField.
        
        if (widget.isTime) {
          final TimeOfDay? picked = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.now(),
          );
          if (picked != null) {
            // Use 24h format for internal value or keep it localized? 
            // Let's stick to localized for display and maybe standard for value?
            // For simplicity, using the formatted string.
            final formatted = picked.format(context);
            _textController.text = formatted;
            widget.controller.updateValue(widget.fieldInfo.name, formatted);
          }
        } else {
          final DateTime? picked = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(1900),
            lastDate: DateTime(2100),
          );
          if (picked != null) {
            final formatted = DateFormat('yyyy-MM-dd').format(picked);
            _textController.text = formatted;
            widget.controller.updateValue(widget.fieldInfo.name, formatted);
          }
        }
      },
      validator: (value) {
        if (widget.fieldInfo.required && (value == null || value.isEmpty)) {
          return 'Please select a ${widget.isTime ? "time" : "date"}';
        }
        return null;
      },
      onSaved: (value) {
        widget.controller.updateValue(widget.fieldInfo.name, value);
      },
    );
  }
}
