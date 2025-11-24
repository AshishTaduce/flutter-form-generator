import 'package:flutter/material.dart';
import '../models/field_info.dart';

class FormController extends ChangeNotifier {
  final Map<String, dynamic> _values = {};
  final Map<String, dynamic> _initialValues = {};
  final Map<String, FormFieldInfo> _fields = {};
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final Map<String, dynamic>? _externalInitialValues;

  FormController({Map<String, dynamic>? initialValues})
    : _externalInitialValues = initialValues;

  Map<String, dynamic> get values => _values;

  bool get isDirty {
    // Check if any current value differs from initial value
    for (var key in _values.keys) {
      if (_values[key] != _initialValues[key]) {
        return true;
      }
    }
    return false;
  }

  void registerField(FormFieldInfo field) {
    _fields[field.name] = field;

    dynamic initialValue;

    // Priority: External Initial Value > Field Default Value > null
    if (_externalInitialValues != null &&
        _externalInitialValues!.containsKey(field.name)) {
      initialValue = _externalInitialValues![field.name];
    } else {
      initialValue = field.defaultValue;
    }

    if (initialValue != null) {
      _values[field.name] = initialValue;
      _initialValues[field.name] = initialValue;
    } else {
      _initialValues[field.name] = null;
    }
  }

  void updateValue(String name, dynamic value) {
    _values[name] = value;
    notifyListeners();
  }

  dynamic getValue(String name) {
    return _values[name];
  }

  bool isFieldEnabled(String fieldName) {
    final field = _fields[fieldName];
    if (field == null || field.enabledIf == null) return true;

    final rule = field.enabledIf!;
    final dependentValue = _values[rule.field];

    switch (rule.operator) {
      case '==':
        return dependentValue.toString() == rule.value.toString();
      case '!=':
        return dependentValue.toString() != rule.value.toString();
      case '>':
        if (dependentValue is num && rule.value is num) {
          return dependentValue > rule.value;
        }
        return false;
      case '<':
        if (dependentValue is num && rule.value is num) {
          return dependentValue < rule.value;
        }
        return false;
      // Add more operators as needed
      default:
        return false;
    }
  }

  Map<String, dynamic> getSubmitValues() {
    final Map<String, dynamic> submitValues = {};
    _values.forEach((key, value) {
      if (isFieldEnabled(key)) {
        submitValues[key] = value;
      }
    });
    return submitValues;
  }

  bool validate() {
    return formKey.currentState?.validate() ?? false;
  }

  void save() {
    formKey.currentState?.save();
  }

  void reset() {
    formKey.currentState?.reset();
    _values.clear();
    // Re-apply default values
    _fields.forEach((name, field) {
      if (field.defaultValue != null) {
        _values[name] = field.defaultValue;
      } else {
        _values[name] = null;
      }
    });
    notifyListeners();
  }
}
