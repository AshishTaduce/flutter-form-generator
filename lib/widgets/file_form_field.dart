import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../models/field_info.dart';
import '../utils/form_controller.dart';

class FileFormField extends StatefulWidget {
  final FormFieldInfo fieldInfo;
  final FormController controller;

  const FileFormField({
    super.key,
    required this.fieldInfo,
    required this.controller,
  });

  @override
  State<FileFormField> createState() => _FileFormFieldState();
}

class _FileFormFieldState extends State<FileFormField> {
  String? _fileName;

  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      validator: (value) {
        if (widget.fieldInfo.required && (value == null || value.isEmpty)) {
          return 'Please select a file';
        }
        return null;
      },
      onSaved: (value) {
        if (value != null) {
          widget.controller.updateValue(widget.fieldInfo.name, value);
        }
      },
      builder: (FormFieldState<String> state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.fieldInfo.label,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (widget.fieldInfo.hint != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  widget.fieldInfo.hint!,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            const SizedBox(height: 8),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () async {
                    FilePickerResult? result = await FilePicker.platform.pickFiles();

                    if (result != null) {
                      // On web, path might be null, use bytes or name.
                      // For this example, we'll store the name. 
                      // In a real app, you'd handle bytes/upload.
                      String fileName = result.files.single.name;
                      setState(() {
                        _fileName = fileName;
                      });
                      state.didChange(fileName);
                      widget.controller.updateValue(widget.fieldInfo.name, fileName);
                    }
                  },
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Pick File'),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    _fileName ?? 'No file selected',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
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
