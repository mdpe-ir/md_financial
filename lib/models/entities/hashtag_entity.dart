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


  // Override equality comparison
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HashtagEntity && other.name == name;
  }

  // Override hashCode to match the equality operator
  @override
  int get hashCode => name.hashCode;

}
