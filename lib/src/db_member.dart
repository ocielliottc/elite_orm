import 'dart:convert';
import 'dart:typed_data';
import 'db_type.dart';

class DBMember<T> {
  /// This is the name of the database member.  It is used as the column name
  /// in the database.
  final String key;

  /// The value of the database member.
  T value;

  /// Indicates that this database member is part of the primary key.
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

  /// Check equality of the data members and the database type.
  @override
  bool operator ==(covariant DBMember<T> other) {
    return type == other.type &&
        primary == other.primary &&
        key == other.key &&
        value == other.value;
  }

  /// Hash the data members and the database type.
  @override
  int get hashCode => Object.hash(key, value, primary, type);
}

class EnumDBMember<T extends Enum> extends DBMember<T> {
  /// The list of enum values as provided by the constructor.  It should be
  /// equivalent to T.values.
  final List<T> values;

  /// Use this to represent an Enum.
  ///
  /// The first parameter is the list of enum values.
  ///
  /// The second parameter is the column name for this data member.
  ///
  /// The third parameter is the initial data member value.
  ///
  /// The fourth parameter indicates if this column is part of the primary
  /// key.  The first member of the Entity class is always part of the primary
  /// key.  But, you can create a composite primary key by passing true to
  /// multiple database members.
  EnumDBMember(this.values, String key, T value, [primary = false])
      : super(key, value, primary);

  /// This method is used when creating the data member from the database map.
  @override
  void fromDB(dynamic v) => value = values[v];

  /// This method is used when sending this data member to the database map.
  @override
  dynamic toDB() => value.index;

  /// This method is used when describing the table to which this data member
  /// belongs.
  @override
  String get type => 'INT';
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

  /// This method is used when creating the data member from the database map.
  @override
  void fromDB(dynamic v) => value = v == 0 ? false : true;

  /// This method is used when sending this data member to the database map.
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

  /// Binary data members are represented as BLOB's.
  @override
  String get type => "BLOB";
}

class DateTimeDBMember extends DBMember<DateTime> {
  /// Use this to represent a DateTime.
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

  /// This method is used when creating the data member from the database map.
  @override
  void fromDB(dynamic v) => value = DateTime.parse(v);

  /// This method is used when sending this data member to the database map.
  @override
  dynamic toDB() => value.toIso8601String();
}

class DurationDBMember extends DBMember<Duration> {
  /// Use this to represent a Duration.
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

  /// This method is used when creating the data member from the database map.
  @override
  void fromDB(dynamic v) => value = Duration(microseconds: v);

  /// This method is used when sending this data member to the database map.
  @override
  dynamic toDB() => value.inMicroseconds;

  /// Durations are represented as microseconds; we use BIGINT to handle them.
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
  PrimitiveListDBMember(super.key, super.value, [super.primary = false]) {
    // We make a copy because the value passed in could be const and, therefore,
    // immutable.  In order to allow elite_orm_editor to modify an Entity
    // in-place, the list must be modifiable.
    value = <T>[...value];
  }

  /// This method is used when creating the data member from the database map.
  @override
  void fromDB(dynamic v) async {
    final List<T> list = [];
    for (dynamic e in json.decode(v)) {
      list.add(e);
    }
    value = list;
  }

  /// This method is used when sending this data member to the database map.
  @override
  dynamic toDB() => json.encode(value);

  /// Lists are encoded as jSON strings.
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

  /// This method is used when creating the data member from the database map.
  @override
  void fromDB(dynamic v) async {
    final List<T> list = [];
    final T obj = _creator();
    for (DatabaseMap e in json.decode(v)) {
      dynamic item = await obj.fromJson(e);
      if (item != null) {
        list.add(item);
      }
    }
    value = list;
  }

  /// This method is used when sending this data member to the database map.
  @override
  dynamic toDB() => json.encode(value.map((e) => e.toJson()).toList());
}

class ObjectDBMember<T extends Serializable> extends DBMember<T> {
  final T Function() _creator;

  /// Use this to represent an object that extends Serializable.
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

  /// This method is used when creating the data member from the database map.
  @override
  void fromDB(dynamic v) async {
    dynamic item = await _creator().fromJson(json.decode(v));
    if (item != null) {
      value = item;
    }
  }

  /// This method is used when sending this data member to the database map.
  @override
  dynamic toDB() => json.encode(value);

  /// Lists are encoded as jSON strings.
  @override
  String get type => "STRING";
}
