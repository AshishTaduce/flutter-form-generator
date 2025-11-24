class FormFieldInfo {
  final FieldType type;
  final String name;
  final String label;
  final String? placeholder;
  final String? hint;
  final String? tooltip;
  final bool required;
  final int? maxLength;
  final int? minLength;
  final num? min;
  final num? max;
  final List<ValidationRule>? validations;
  final List<DropdownOption>? options;
  final dynamic defaultValue;
  final bool isSearchable;
  final DependencyRule? enabledIf;

  FormFieldInfo({
    required this.type,
    required this.name,
    required this.label,
    this.placeholder,
    this.hint,
    this.tooltip,
    this.required = false,
    this.maxLength,
    this.minLength,
    this.min,
    this.max,
    this.validations,
    this.options,
    this.defaultValue,
    this.isSearchable = false,
    this.enabledIf,
  });

  factory FormFieldInfo.fromJson(Map<String, dynamic> json) {
    return FormFieldInfo(
      type: FieldType.fromString(json['type'] as String),
      name: json['name'] as String,
      label: json['label'] as String,
      placeholder: json['placeholder'] as String?,
      hint: json['hint'] as String?,
      tooltip: json['tooltip'] as String?,
      required: json['required'] as bool? ?? false,
      maxLength: json['maxLength'] as int?,
      minLength: json['minLength'] as int?,
      min: json['min'] as num?,
      max: json['max'] as num?,
      validations: json['validations'] != null
          ? (json['validations'] as List)
                .map((validation) => ValidationRule.fromJson(validation))
                .toList()
          : null,
      options: json['options'] != null
          ? (json['options'] as List)
                .map((opt) => DropdownOption.fromJson(opt))
                .toList()
          : null,
      defaultValue: json['defaultValue'],
      isSearchable: json['isSearchable'] as bool? ?? false,
      enabledIf: json['enabledIf'] != null
          ? DependencyRule.fromJson(json['enabledIf'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.value,
      'name': name,
      'label': label,
      if (placeholder != null) 'placeholder': placeholder,
      if (hint != null) 'hint': hint,
      if (tooltip != null) 'tooltip': tooltip,
      'required': required,
      if (maxLength != null) 'maxLength': maxLength,
      if (minLength != null) 'minLength': minLength,
      if (min != null) 'min': min,
      if (max != null) 'max': max,
      if (validations != null)
        'validations': validations
            ?.map((validation) => validation.toJson())
            .toList(),
      if (options != null) 'options': options!.map((o) => o.toJson()).toList(),
      if (defaultValue != null) 'defaultValue': defaultValue,
      'isSearchable': isSearchable,
      if (enabledIf != null) 'enabledIf': enabledIf!.toJson(),
    };
  }
}

/// Field types enum
enum FieldType {
  textInput,
  emailInput,
  numberInput,
  passwordInput,
  textArea,
  dropdown,
  checkbox,
  radio,
  date,
  time,
  file;

  String get value {
    switch (this) {
      case FieldType.textInput:
        return 'text_input';
      case FieldType.emailInput:
        return 'email_input';
      case FieldType.numberInput:
        return 'number_input';
      case FieldType.passwordInput:
        return 'password_input';
      case FieldType.textArea:
        return 'text_area';
      case FieldType.dropdown:
        return 'dropdown';
      case FieldType.checkbox:
        return 'checkbox';
      case FieldType.radio:
        return 'radio';
      case FieldType.date:
        return 'date';
      case FieldType.time:
        return 'time';
      case FieldType.file:
        return 'file';
    }
  }

  static FieldType fromString(String value) {
    switch (value) {
      case 'text_input':
        return FieldType.textInput;
      case 'email_input':
        return FieldType.emailInput;
      case 'number_input':
        return FieldType.numberInput;
      case 'password_input':
        return FieldType.passwordInput;
      case 'text_area':
        return FieldType.textArea;
      case 'dropdown':
        return FieldType.dropdown;
      case 'checkbox':
        return FieldType.checkbox;
      case 'radio':
        return FieldType.radio;
      case 'date':
        return FieldType.date;
      case 'time':
        return FieldType.time;
      case 'file':
        return FieldType.file;
      default:
        throw ArgumentError('Unknown field type: $value');
    }
  }

  @override
  String toString() {
    switch (this) {
      case FieldType.textInput:
        return 'Text Input';
      case FieldType.emailInput:
        return 'Email Input';
      case FieldType.numberInput:
        return 'Number Input';
      case FieldType.passwordInput:
        return 'Password Input';
      case FieldType.textArea:
        return 'Text Area';
      case FieldType.dropdown:
        return 'Dropdown';
      case FieldType.checkbox:
        return 'Checkbox';
      case FieldType.radio:
        return 'Radio';
      case FieldType.date:
        return 'Date';
      case FieldType.time:
        return 'Time';
      case FieldType.file:
        return 'File';
    }
  }
}

/// Validation rule model
class ValidationRule {
  final String? regex;
  final String? errorMessage;

  ValidationRule({this.regex, this.errorMessage});

  factory ValidationRule.fromJson(Map<String, dynamic> json) {
    return ValidationRule(
      regex: json['regex'] as String?,
      errorMessage: json['error_message'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (regex != null) 'regex': regex,
      if (errorMessage != null) 'error_message': errorMessage,
    };
  }
}

/// Dropdown option model
class DropdownOption {
  final String label;
  final String value;

  DropdownOption({required this.label, required this.value});

  factory DropdownOption.fromJson(Map<String, dynamic> json) {
    return DropdownOption(
      label: json['label'] as String,
      value: json['value'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'label': label, 'value': value};
  }
}

class DependencyRule {
  final String field;
  final String operator;
  final dynamic value;

  DependencyRule({
    required this.field,
    required this.operator,
    required this.value,
  });

  factory DependencyRule.fromJson(Map<String, dynamic> json) {
    return DependencyRule(
      field: json['field'] as String,
      operator: json['operator'] as String,
      value: json['value'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'field': field, 'operator': operator, 'value': value};
  }
}
