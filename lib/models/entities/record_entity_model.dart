import 'package:objectbox/objectbox.dart';
import 'hashtag_entity.dart';

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

  ToMany<HashtagEntity> hashtags = ToMany();

  RecordEntityModel({
    this.id = 0,
    required this.type,
    required this.amount,
    required this.title,
    required this.description,
    required this.date,
    required this.hashtags,
  });
}
