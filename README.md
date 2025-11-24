# Flutter Form Generator Ecosystem

A comprehensive toolkit for building dynamic, JSON-driven forms in Flutter. This project consists of three main components:

1.  **`flutter_form_generator`**: A robust Flutter plugin for rendering forms from JSON.
2.  **`flutter_form_builder`**: A web-based visual editor to create and export form JSON.
3.  **`flutter_form_example`**: A demo app showcasing the plugin's capabilities.

---

## 1. Flutter Form Generator (Plugin)

A lightweight Flutter plugin that takes a JSON schema and renders a fully functional, validated form.

### ✨ Features
-   **Dynamic Rendering**: Render complex forms from simple JSON.
-   **Rich Field Types**: Text, Email, Number, Password, TextArea, Dropdown (Searchable), Checkbox, Radio, Time, File.
-   **Advanced Validation**: Required checks, regex patterns, length limits.
-   **Conditional Logic**: Enable/disable fields based on other field values (`enabledIf`).
-   **State Management**: Built-in `FormController` for handling values and validation.
-   **Initial Values**: Pre-fill forms with data from APIs or local storage.
-   **Actions**: Handle form submission with built-in HTTP actions (GET/POST).

### 📦 Installation
Add it as a path dependency in your `pubspec.yaml`:

```yaml
dependencies:
  flutter_form_generator:
    path: ../path/to/flutter_form_generator
```

### 🚀 Usage

```dart
import 'package:flutter_form_generator/flutter_form_generator.dart';

// ...

FormGenerator(
  formData: myFormJson, // Map<String, dynamic>
  initialValues: {'name': 'John Doe'}, // Optional: Pre-fill data
  onSuccess: (values) {
    print("Form Submitted: $values");
  },
)
```

### 📝 Supported Fields

| Type | Description | Key Properties |
| :--- | :--- | :--- |
| `text_input` | Basic text field | `label`, `placeholder`, `required`, `minLength`, `maxLength` |
| `email_input` | Email validation | `label`, `placeholder`, `required` |
| `number_input` | Numeric input | `label`, `min`, `max` |
| `password_input` | Obscured text | `label`, `validations` |
| `text_area` | Multi-line text | `label`, `maxLines` |
| `dropdown` | Selection list | `options`, `isSearchable` |
| `radio` | Radio buttons | `options` |
| `checkbox` | Boolean toggle | `label`, `defaultValue` |
| `time` | Time picker | `label` |
| `file` | File picker | `label`, `allowedExtensions` |

---

## 2. Flutter Form Builder (Web App)

A visual tool to design forms without writing JSON manually.

### ✨ Features
-   **Drag-and-Drop**: Reorder rows and fields easily.
-   **Visual Editing**: Click to edit field properties (labels, validations, dependencies).
-   **Row Layout**: Organize fields into multi-column rows.
-   **JSON Import/Export**: Import existing JSON to edit or export your design to use in your app.
-   **Preview**: Live preview of the generated form.

### 🏃‍♂️ How to Run
```bash
cd flutter_form_builder
flutter run -d chrome
```

---

## 3. Flutter Form Example

A reference app demonstrating various form configurations and features.

### 🏃‍♂️ How to Run
```bash
cd flutter_form_example
flutter run
```

---

## 📄 JSON Schema Example

```json
{
  "title": "User Profile",
  "fields": [
    [
      {
        "type": "text_input",
        "name": "first_name",
        "label": "First Name",
        "required": true
      },
      {
        "type": "text_input",
        "name": "last_name",
        "label": "Last Name",
        "required": true
      }
    ],
    {
      "type": "dropdown",
      "name": "role",
      "label": "Role",
      "options": [
        {"label": "Admin", "value": "admin"},
        {"label": "User", "value": "user"}
      ],
      "isSearchable": true
    },
    {
      "type": "checkbox",
      "name": "newsletter",
      "label": "Subscribe to newsletter",
      "defaultValue": true
    }
  ],
  "submit": {
    "label": "Save Profile",
    "action": {
      "type": "api_call",
      "method": "POST",
      "url": "https://api.example.com/profile"
    }
  }
}
```