import 'package:md_financial/enums/record_enum.dart';
import 'package:objectbox/objectbox.dart';

@Entity()
class RecordEntityModel {
  @Id()
  int id;
  int type;
  int amount;
  String title;
  String description;

  @Property(type: PropertyType.date)
  DateTime date;

  RecordEnumType get dbType => RecordEnumType.values[type];

  set dbType(RecordEnumType value) {
    type = value.index;
  }

  RecordEntityModel({
    this.id = 0,
    required this.type,
    required this.amount,
    required this.title,
    required this.description,
    required this.date,
  });
}
