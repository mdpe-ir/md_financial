import 'package:objectbox/objectbox.dart';

@Entity()
class HashtagEntity {
  @Id()
  int id;
  String name;

  HashtagEntity({
    this.id = 0,
    required this.name,
  });
}
