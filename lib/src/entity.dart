// Entity
//
// This is the bridge between the model and the database representation.
// The model classes extend this interface and, by doing so, enable the
// model class to become instances of database objects.
//
import 'dart:convert';

typedef DatabaseMap = Map<String, dynamic>;

class DBMember<T> {
  final String key;
  T value;
  final bool primary;

  DBMember(this.key, this.value, [this.primary = false]);

  /// This method is used when creating the data member from the database map.
  void fromDB(dynamic v) => value = v;

  /// This method is used when sending this data member to the database map.
  dynamic toDB() => value;

  /// This method is used when describing the table to which this data member
  /// belongs.
  String get type => value.runtimeType.toString();
}

class EnumDBMember<T extends Enum> extends DBMember<int> {
  EnumDBMember(String key, T value, [primary = false])
      : super(key, value.index, primary);
}

class BoolDBMember extends DBMember<bool> {
  BoolDBMember(super.key, super.value, [super.primary = false]);

  @override
  void fromDB(dynamic v) => value = v == 1 ? true : false;

  @override
  dynamic toDB() => value ? 1 : 0;

  @override
  String get type => "INT";
}

class DateTimeDBMember extends DBMember<DateTime> {
  DateTimeDBMember(super.key, super.value, [super.primary = false]);

  @override
  void fromDB(dynamic v) => value = DateTime.parse(v);

  @override
  dynamic toDB() => value.toIso8601String();
}

class DurationDBMember extends DBMember<Duration> {
  DurationDBMember(super.key, super.value, [super.primary = false]);

  @override
  void fromDB(dynamic v) => value = Duration(microseconds: v);

  @override
  dynamic toDB() => value.inMicroseconds;

  @override
  String get type => "BIGINT";
}

abstract class Serializable {
  Future fromJson(DatabaseMap map);
  DatabaseMap toJson();
}

class ListDBMember<T extends Serializable> extends DBMember<List<T>> {
  final T Function() _creator;

  ListDBMember(this._creator, super.key, super.value, [super.primary = false]);

  @override
  void fromDB(dynamic v) async {
    for (DatabaseMap e in json.decode(v)) {
      dynamic item = await _creator().fromJson(e);
      if (item != null) {
        value.add(item);
      }
    }
  }

  @override
  dynamic toDB() => json.encode(value);

  @override
  String get type => "STRING";
}

class Entity<T> {
  List<DBMember> members = [];
  final T Function() _creator;

  /// The _creator parameter is a function that constructs an object of type T
  /// and returns it.  This is used to construct objects from the database map
  /// values.
  Entity(this._creator);

  /// The first database member in the sub-class is always going to be the
  /// primary key.  This returns the name of the column.
  dynamic get idColumn => members.first.key;

  /// The first database member in the sub-class is always going to be the
  /// primary key.  This returns the name.
  dynamic get id => members.first.value;

  /// The dynamically determined runtime type of the sub-class is the table name.
  String get table => "$runtimeType";

  /// Describe the SQL table based on the table name and individual members.
  String describeTable() {
    String description = "$table (";
    for (var member in members) {
      description += "${member.key} ${member.type},";
    }

    bool first = true;
    description += "PRIMARY KEY (";
    for (var member in members) {
      if (member.primary) {
        if (first) {
          first = false;
        } else {
          description += ",";
        }
        description += member.key;
      }
    }
    description += "))";
    return description;
  }

  /// Iterate over the members and create a database map out of them.
  DatabaseMap toDatabaseMap() {
    DatabaseMap map = {};
    for (var member in members) {
      map[member.key] = member.toDB();
    }
    return map;
  }

  /// Create a T object from the map retrieved from the database.
  Future<T> fromDatabaseMap(DatabaseMap map) async {
    final T obj = _creator();
    final Entity<T> entity = obj as Entity<T>;
    for (var member in entity.members) {
      if (map.containsKey(member.key)) {
        member.fromDB(map[member.key]);
      } else {
        throw "Unknown data member key: ${member.key}";
      }
    }
    return obj;
  }
}
