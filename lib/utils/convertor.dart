import 'package:flutter/material.dart';
import 'package:md_financial/enums/record_enum.dart';

class Convertor {
  static String typeToString(RecordEnumType type) {
    if (type == RecordEnumType.income) {
      return "درآمد";
    }
    if (type == RecordEnumType.expense) {
      return "هزینه";
    }
    return "";
  }
  static Widget? typeToIcon(RecordEnumType type) {
    if (type == RecordEnumType.income) {
      return Icon(Icons.payments);
    }
    if (type == RecordEnumType.expense) {
      return Icon(Icons.paid);
    }
    return null;
  }
}
