# Flutter Form Generator

A lightweight Flutter plugin for dynamically generating forms from JSON schemas. Perfect for rapid prototyping, admin panels, or any app needing flexible, validated forms with built-in submission handling (e.g., API calls).

## ✨ Features

- **Dynamic Form Generation**: Build forms from simple JSON structures—no boilerplate code.
- **Rich Field Types**: Support for text inputs, emails, numbers, passwords, dropdowns, checkboxes, and text areas.
- **Validation**: Built-in required checks, length limits, and custom regex validations.
- **Submission Actions**: Easy API integration (POST/GET) with headers, loading states, and success/error handling.
- **Customization**: Add reset buttons, custom headers (e.g., auth tokens), and success callbacks.
- **Responsive UI**: Forms are scrollable, centered, and mobile-friendly out of the box.
- **Lightweight**: Minimal dependencies; works with Flutter's core widgets.

## 📦 Installation

Since this is a local plugin, add it as a path dependency in your app's `pubspec.yaml`:

```yaml
dependencies:
  flutter_form_generator:
    path: ../path/to/flutter_form_generator  # Adjust path as needed
```

Then run:
```bash
flutter pub get
```

## 🚀 Quick Start

### 1. Initialize the Form Generator
```dart
import 'package:flutter_form_generator/flutter_form_generator.dart';

final formGenerator = FormGenerator(
  headers: {'Authorization': 'Bearer your-token'},  // Optional: Custom headers
);
```

### 2. Define Your Form Schema
Forms are defined as a `Map<String, dynamic>` (JSON-like structure):

```dart
final formData = {
  "type": "form",
  "title": "User Registration",
  "fields": [
    {
      "type": "text_input",
      "name": "full_name",
      "label": "Full Name",
      "placeholder": "Enter your full name",
      "required": true,
      "maxLength": 50,
    },
    {
      "type": "email_input",
      "name": "email",
      "label": "Email Address",
      "placeholder": "example@mail.com",
      "required": true,
      "validations": [  // Optional: List of custom checks
        {
          "regex": r"^[\\w.-]+@[\\w.-]+\\\\.\\w{2,}$",  // Escaped for Dart strings
          "error_message": "Enter a valid email",
        },
      ],
    },
    // ... more fields
  ],
  "submit": {
    "type": "button",
    "label": "Register",
    "action": {
      "type": "api_call",
      "method": "POST",
      "url": "https://jsonplaceholder.typicode.com/users",  // Demo endpoint
      "success_message": "Registration successful",
      "error_message": "Registration failed",
    },
  },
  "reset": true,  // Optional: Adds a reset button
};
```

### 3. Generate and Display the Form
```dart
// In your widget build method
formGenerator.generateForm(
  formData,
  onSuccess: (values) {
    // Handle success (e.g., show SnackBar, navigate)
    print('Form values: $values');
    // Example: {'full_name': 'John Doe', 'email': 'john@example.com'}
  },
);
```

Wrap it in a `Scaffold` for full-screen display:
```dart
Scaffold(
  appBar: AppBar(title: const Text('Dynamic Form')),
  body: Center(
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: formGenerator.generateForm(formData, onSuccess: ...),
    ),
  ),
);
```

## 📝 Supported Field Types

| Type          | Description | Key Properties | Example |
|---------------|-------------|----------------|---------|
| `text_input` | Single-line text field | `label`, `placeholder`, `required`, `minLength`, `maxLength` | Basic name input with text-only filter. |
| `email_input` | Email field with built-in regex | `label`, `placeholder`, `required`, `validations` | Validates format like `test@example.com`. |
| `number_input` | Numeric input | `label`, `placeholder`, `required`, `min`, `max` | Age field (e.g., 18-100). |
| `password_input` | Secure password field | `label`, `placeholder`, `required`, `minLength`, `validations` | Obfuscated; supports strength checks. |
| `text_area` | Multi-line text | `label`, `placeholder`, `required`, `minLength`, `maxLength` | Message field (3-5 lines). |
| `dropdown`    | Select from options | `label`, `options` (list of `{label, value}`), `required` | Gender: `[{"label": "Male", "value": "male"}]` |
| `checkbox`    | Toggle agreement | `label`, `required` | Terms & Conditions checkbox. |

### Custom Validations
Add as a list under `validations`:
```dart
"validations": [
  {
    "regex": r"^.{8,}\\$",  // Escaped $ for Dart; checks length >=8
    "error_message": "At least 8 characters"
  },
  // More rules...
]
```
For passwords, chain rules like uppercase, digits, and special chars (see examples below).

## 🔗 Actions & Submission

- **API Calls**: Uses `http` package under the hood. Supports `POST`, `GET`, etc. Body is JSON from form values.
- **Success/Error Handling**: Built-in loading spinner, SnackBars, and `onSuccess` callback.
- **No Action**: If no `action`, just logs values and calls `onSuccess`.

## 📱 Example App

An example app is included as a submodule in the `example/` directory. It demonstrates multiple forms (registration, login, contact, feedback) with real API calls to [JSONPlaceholder](https://jsonplaceholder.typicode.com) for testing.

### Setup & Run
1. Initialize the submodule:
   ```bash
   git submodule update --init --recursive
   ```
2. Navigate to example:
   ```bash
   cd example
   flutter pub get
   ```
3. Run:
   ```bash
   flutter run
   ```
    - Tap buttons on the home screen to launch forms.
    - Submit to see API responses (no real backend needed).

### Password Validations Example
In the login form:
```dart
"validations": [
  {"regex": r"^.{8,}\\$", "error_message": "At least 8 characters"},
  {"regex": r"^(?=.*[A-Z]).*\\$", "error_message": "One uppercase letter"},
  {"regex": r"^(?=.*[a-z]).*\\$", "error_message": "One lowercase letter"},
  {"regex": r"^(?=.*\\d).*\\$", "error_message": "One digit"},
  {"regex": r"^(?=.*[!@#\\$%^&*()_+\\-=\\[\\]{};':\"\\\\|,.<>/?~]).*\\$", "error_message": "One special character"},
]
```
(Note: `$` escaped as `\\$` for Dart strings.)

## 📄 License

MIT License. See [LICENSE](LICENSE) for details.