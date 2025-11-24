import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import '../models/field_info.dart';
import '../utils/form_controller.dart';

class EnhancedDropdownFormField extends StatefulWidget {
  final FormFieldInfo fieldInfo;
  final FormController controller;

  const EnhancedDropdownFormField({
    super.key,
    required this.fieldInfo,
    required this.controller,
  });

  @override
  State<EnhancedDropdownFormField> createState() => _EnhancedDropdownFormFieldState();
}

class _EnhancedDropdownFormFieldState extends State<EnhancedDropdownFormField> {
  final TextEditingController textEditingController = TextEditingController();

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField2<String>(
      isExpanded: true,
      decoration: InputDecoration(
        labelText: widget.fieldInfo.label,
        hintText: widget.fieldInfo.placeholder ?? widget.fieldInfo.label,
        helperText: widget.fieldInfo.hint,
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      hint: Text(
        widget.fieldInfo.placeholder ?? 'Select Option',
        style: TextStyle(fontSize: 14),
      ),
      items: (widget.fieldInfo.options ?? [])
          .map((item) => DropdownMenuItem<String>(
                value: item.value,
                child: Text(
                  item.label,
                  style: const TextStyle(
                    fontSize: 14,
                  ),
                ),
              ))
          .toList(),
      validator: (value) {
        if (widget.fieldInfo.required && (value == null || value.isEmpty)) {
          return 'Please select an option';
        }
        return null;
      },
      onChanged: (value) {
        widget.controller.updateValue(widget.fieldInfo.name, value);
      },
      onSaved: (value) {
        widget.controller.updateValue(widget.fieldInfo.name, value);
      },
      buttonStyleData: const ButtonStyleData(
        padding: EdgeInsets.only(right: 8),
      ),
      iconStyleData: const IconStyleData(
        icon: Icon(
          Icons.arrow_drop_down,
          color: Colors.black45,
        ),
        iconSize: 24,
      ),
      dropdownStyleData: DropdownStyleData(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      menuItemStyleData: const MenuItemStyleData(
        padding: EdgeInsets.symmetric(horizontal: 16),
      ),
      dropdownSearchData: widget.fieldInfo.isSearchable
          ? DropdownSearchData(
              searchController: textEditingController,
              searchInnerWidgetHeight: 50,
              searchInnerWidget: Container(
                height: 50,
                padding: const EdgeInsets.only(
                  top: 8,
                  bottom: 4,
                  right: 8,
                  left: 8,
                ),
                child: TextFormField(
                  expands: true,
                  maxLines: null,
                  controller: textEditingController,
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    hintText: 'Search for an item...',
                    hintStyle: const TextStyle(fontSize: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              searchMatchFn: (item, searchValue) {
                return item.value.toString().toLowerCase().contains(searchValue.toLowerCase());
              },
            )
          : null,
    );
  }
}
