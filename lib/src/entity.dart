// Entity
//
// This is the bridge between the model and the database representation.
// The model classes extend this interface and, by doing so, enable the
// model class to become instances of database objects.
//
import 'dart:convert';
import 'dart:typed_data';

typedef DatabaseMap = Map<String, dynamic>;

class DBMember<T> {
  final String key;
  T value;
  final bool primary;

  /// Use this to represent int, double, or String.
  ///
  /// The first parameter is the column name for this data member.
  ///
  /// The second parameter is the initial data member value.
  ///
  /// The third parameter indicates if this column is part of the primary
  /// key.  The first member of the Entity class is always part of the primary
  /// key.  But, you can create a composite primary key by passing true to
  /// multiple database members.
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
  /// Use this to represent an Enum.
  ///
  /// The first parameter is the column name for this data member.
  ///
  /// The second parameter is the initial data member value.
  ///
  /// The third parameter indicates if this column is part of the primary
  /// key.  The first member of the Entity class is always part of the primary
  /// key.  But, you can create a composite primary key by passing true to
  /// multiple database members.
  EnumDBMember(String key, T value, [primary = false])
      : super(key, value.index, primary);
}

class BoolDBMember extends DBMember<bool> {
  /// Use this to represent a bool.
  ///
  /// The first parameter is the column name for this data member.
  ///
  /// The second parameter is the initial data member value.
  ///
  /// The third parameter indicates if this column is part of the primary
  /// key.  The first member of the Entity class is always part of the primary
  /// key.  But, you can create a composite primary key by passing true to
  /// multiple database members.
  BoolDBMember(super.key, super.value, [super.primary = false]);

  @override
  void fromDB(dynamic v) => value = v == 1 ? true : false;

  @override
  dynamic toDB() => value ? 1 : 0;
}

class BinaryDBMember extends DBMember<Uint8List> {
  /// Use this to represent a Uint8List.
  ///
  /// The first parameter is the column name for this data member.
  ///
  /// The second parameter is the initial data member value.
  ///
  /// The third parameter indicates if this column is part of the primary
  /// key.  The first member of the Entity class is always part of the primary
  /// key.  But, you can create a composite primary key by passing true to
  /// multiple database members.
  BinaryDBMember(super.key, super.value, [super.primary = false]);

  @override
  String get type => "BLOB";
}

class DateTimeDBMember extends DBMember<DateTime> {
  /// Use this to represent an DateTime.
  ///
  /// The first parameter is the column name for this data member.
  ///
  /// The second parameter is the initial data member value.
  ///
  /// The third parameter indicates if this column is part of the primary
  /// key.  The first member of the Entity class is always part of the primary
  /// key.  But, you can create a composite primary key by passing true to
  /// multiple database members.
  DateTimeDBMember(super.key, super.value, [super.primary = false]);

  @override
  void fromDB(dynamic v) => value = DateTime.parse(v);

  @override
  dynamic toDB() => value.toIso8601String();
}

class DurationDBMember extends DBMember<Duration> {
  /// Use this to represent an Duration.
  ///
  /// The first parameter is the column name for this data member.
  ///
  /// The second parameter is the initial data member value.
  ///
  /// The third parameter indicates if this column is part of the primary
  /// key.  The first member of the Entity class is always part of the primary
  /// key.  But, you can create a composite primary key by passing true to
  /// multiple database members.
  DurationDBMember(super.key, super.value, [super.primary = false]);

  @override
  void fromDB(dynamic v) => value = Duration(microseconds: v);

  @override
  dynamic toDB() => value.inMicroseconds;

  @override
  String get type => "BIGINT";
}

class PrimitiveListDBMember<T> extends DBMember<List<T>> {
  /// Use this to represent a List of int, double, or String.
  ///
  /// The first parameter is the column name for this data member.
  ///
  /// The second parameter is the initial data member value.
  ///
  /// The third parameter indicates if this column is part of the primary
  /// key.  The first member of the Entity class is always part of the primary
  /// key.  But, you can create a composite primary key by passing true to
  /// multiple database members.
  PrimitiveListDBMember(super.key, super.value, [super.primary = false]);

  @override
  void fromDB(dynamic v) async {
    List<T> list = [];
    for (dynamic e in json.decode(v)) {
      final T item = e is String ? json.decode(e) : e;
      list.add(item);
    }
    value = list;
  }

  @override
  dynamic toDB() => json.encode(value.isNotEmpty && value.first is String
      ? value.map((e) => '"$e"').toList()
      : value);

  @override
  String get type => "STRING";
}

abstract class Serializable {
  /// Construct an object given the values stored within the database map.
  /// When your class implements this method, it will need to be marked async.
  Future fromJson(DatabaseMap map);

  /// Convert an object into a map of name/value pairs.
  DatabaseMap toJson();
}

class ListDBMember<T extends Serializable> extends PrimitiveListDBMember<T> {
  final T Function() _creator;

  /// Use this to represent a List of objects that extend Serializable.
  ///
  /// The first parameter is a function that will create an object of type T.
  ///
  /// The second parameter is the column name for this data member.
  ///
  /// The third parameter is the initial data member value.
  ///
  /// The fourth parameter indicates if this column is part of the primary
  /// key.  The first member of the Entity class is always part of the primary
  /// key.  But, you can create a composite primary key by passing true to
  /// multiple database members.
  ListDBMember(this._creator, super.key, super.value, [super.primary = false]);

  @override
  void fromDB(dynamic v) async {
    List<T> list = [];
    for (DatabaseMap e in json.decode(v)) {
      dynamic item = await _creator().fromJson(e);
      if (item != null) {
        list.add(item);
      }
    }
    value = list;
  }

  @override
  dynamic toDB() => json.encode(value.map((e) => e.toJson()).toList());
}

class ObjectDBMember<T extends Serializable> extends DBMember<T> {
  final T Function() _creator;

  /// Use this to represent a List of objects that extend Serializable.
  ///
  /// The first parameter is a function that will create an object of type T.
  ///
  /// The second parameter is the column name for this data member.
  ///
  /// The third parameter is the initial data member value.
  ///
  /// The fourth parameter indicates if this column is part of the primary
  /// key.  The first member of the Entity class is always part of the primary
  /// key.  But, you can create a composite primary key by passing true to
  /// multiple database members.
  ObjectDBMember(this._creator, super.key, super.value,
      [super.primary = false]);

  @override
  void fromDB(dynamic v) async {
    dynamic item = await _creator().fromJson(json.decode(v));
    if (item != null) {
      value = item;
    }
  }

  @override
  dynamic toDB() => json.encode(value);

  @override
  String get type => "STRING";
}

class Entity<T> extends Serializable {
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
      if (first || member.primary) {
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
  @override
  DatabaseMap toJson() {
    DatabaseMap map = {};
    for (var member in members) {
      map[member.key] = member.toDB();
    }
    return map;
  }

  /// Create a T object from the map retrieved from the database.
  @override
  Future<T> fromJson(DatabaseMap map) async {
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
