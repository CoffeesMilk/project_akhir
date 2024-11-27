import 'package:hive/hive.dart';
part 'user.g.dart';

@HiveType(typeId: 0)
class user extends HiveObject {
  @HiveField(0)
  String? id;

  @HiveField(1)
  late String email;

  @HiveField(2)
  late String username;

  @HiveField(3)
  late String password;

  @HiveField(4)
  List<String> like;

  user({
    this.email = '',
    this.username = '',
    this.password = '',
    this.like = const [''],
  });
}
