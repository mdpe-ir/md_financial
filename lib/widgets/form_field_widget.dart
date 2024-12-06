import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class ThousandsFormatter extends TextInputFormatter {
  final NumberFormat _formatter = NumberFormat('#,###');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final formattedValue = _formatter
        .format(double.tryParse(newValue.text.replaceAll(',', '')) ?? 0);

    final selectionOffset = newValue.selection.baseOffset +
        (formattedValue.length - newValue.text.length);

    return TextEditingValue(
      text: formattedValue,
      selection: TextSelection.collapsed(offset: selectionOffset),
    );
  }
}

class FormFieldWidget extends StatelessWidget {
  const FormFieldWidget({
    super.key,
    required this.label,
    this.minLines = 1,
    this.maxLines = 1,
    this.isReadOnly = false,
    this.onTap,
    this.suffix,
    this.onChanged,
    this.inputFormatters,
    this.value,
    this.controller,
    this.prefixIcon,
  });

  final TextEditingController? controller;
  final Function(String)? onChanged;
  final void Function()? onTap;
  final int? minLines;
  final int? maxLines;
  final String label;
  final String? value;
  final bool isReadOnly;
  final Widget? suffix;
  final Widget? prefixIcon;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        readOnly: isReadOnly,
        minLines: minLines,
        maxLines: maxLines,
        onTap: onTap,
        inputFormatters: inputFormatters,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          labelText: label,
          prefixIcon: prefixIcon,
          suffix: suffix,
        ),
      ),
    );
  }
}
