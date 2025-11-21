import '../models/field_info.dart';

String? checkValidations (List<ValidationRule> validation, String value) {
  for (var validationRule in validation) {
    if (!RegExp(validationRule.regex!).hasMatch(value)) {
      return validationRule.errorMessage;
    }
  }
  return null;
}
