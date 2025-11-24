import 'package:flutter/material.dart';
import 'utils/action_engine.dart';
import 'utils/form_controller.dart';
import 'models/field_info.dart';
import 'widgets/field_factory.dart';

export 'models/field_info.dart' show FieldType;

class FormGenerator extends StatefulWidget {
  final Map<String, dynamic> formData;
  final void Function(Map<String, dynamic> values) onSuccess;
  final Map<String, String>? headers;
  final Map<String, dynamic>? initialValues;

  const FormGenerator({
    super.key,
    required this.formData,
    required this.onSuccess,
    this.headers,
    this.initialValues,
  });

  @override
  State<FormGenerator> createState() => _FormGeneratorState();
}

class _FormGeneratorState extends State<FormGenerator> {
  late final ActionEngine _actionEngine;
  late final FormController _formController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _actionEngine = ActionEngine(headers: widget.headers);
    _formController = FormController(initialValues: widget.initialValues);
    _initializeFields();
  }

  void _initializeFields() {
    final fieldsData = widget.formData['fields'] as List;
    for (var row in fieldsData) {
      if (row is List) {
        for (var fieldData in row) {
          _formController.registerField(FormFieldInfo.fromJson(fieldData));
        }
      } else {
        _formController.registerField(FormFieldInfo.fromJson(row));
      }
    }
  }

  @override
  void dispose() {
    _formController.dispose();
    super.dispose();
  }

  void _setLoading(bool loading) {
    setState(() {
      _isLoading = loading;
    });
  }

  void _handleSubmit() async {
    if (_formController.validate()) {
      _formController.save();
      final submitValues = _formController.getSubmitValues();

      final submitAction = widget.formData['submit']?['action'];

      if (submitAction != null) {
        _setLoading(true);

        await _actionEngine.executeAction(
          action: submitAction,
          context: context,
          formValues: submitValues,
          onSuccess: () {
            widget.onSuccess(submitValues);
          },
        );

        _setLoading(false);
      } else {
        debugPrint(submitValues.toString());
        widget.onSuccess(submitValues);
      }
    }
  }

  void _handleReset() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Reset Form'),
          content: Text('Are you sure you want to reset the form?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _formController.reset();
                Navigator.of(dialogContext).pop();
              },
              child: Text('Reset'),
            ),
          ],
        );
      },
    );
  }

  List<Widget> _generateRows(List<dynamic> fieldsData) {
    List<Widget> rows = [];
    for (var rowData in fieldsData) {
      if (rowData is List) {
        // Multi-column row
        rows.add(
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: rowData.map((fieldData) {
              final fieldInfo = FormFieldInfo.fromJson(fieldData);
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: FieldWidgetFactory.create(fieldInfo, _formController),
                ),
              );
            }).toList(),
          ),
        );
      } else {
        // Single column row
        final fieldInfo = FormFieldInfo.fromJson(rowData);
        rows.add(FieldWidgetFactory.create(fieldInfo, _formController));
      }
    }
    return rows;
  }

  Future<bool> _showExitConfirmation() async {
    final exitMsg =
        widget.formData['exit_message'] ??
        'You have unsaved changes. Are you sure you want to exit?';
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Unsaved Changes'),
            content: Text(exitMsg),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Exit', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        if (_formController.isDirty) {
          final shouldPop = await _showExitConfirmation();
          if (shouldPop && context.mounted) {
            Navigator.of(context).pop();
          }
        } else {
          Navigator.of(context).pop();
        }
      },
      child: Form(
        key: _formController.formKey,
        child: SingleChildScrollView(
          child: Column(
            spacing: 16.0,
            children: [
              if (widget.formData['title'] != null)
                Text(
                  widget.formData['title'],
                  style: const TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ..._generateRows(widget.formData['fields'] as List),
              const SizedBox(height: 8.0),
              Row(
                spacing: 16.0,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleSubmit,
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                widget.formData['submit']?['label'] ?? 'Submit',
                              ),
                      ),
                    ),
                  ),
                  if (widget.formData["reset"] == true)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: OutlinedButton(
                          onPressed: _isLoading ? null : _handleReset,
                          child: const Text('Reset'),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
