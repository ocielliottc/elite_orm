import 'db_member.dart';
import 'db_type.dart';

/// This is the bridge between the model and the database representation.
/// The model classes extend this interface and, by doing so, enable the
/// model class to represent database objects.
class Entity<T> extends Serializable {
  /// This stores the set of database members.  This will be set during
  /// construction and should not be modified afterward.  The values of the
  /// individual members can be modified, but the list itself should not be.
  final List<DBMember> members = [];
  final T Function() _creator;

  /// The _creator parameter is a function that constructs an object of type T
  /// and returns it.  This is used to construct objects from the database map
  /// values.  Typically, this will be T.new where T is your model class.
  Entity(this._creator);

  /// The first database member in the sub-class is always going to be part of
  /// the primary key.  This returns the name of only the first member.
  dynamic get idColumn => members.first.key;

  /// The dynamically determined runtime type of the sub-class is the table name.
  ///
  /// You may need to override this in your class if you intend on using
  /// obfuscation when building your application.
  String get table => runtimeType.toString();

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
    final DatabaseMap map = {};
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
        throw Exception("Unknown data member key: ${member.key}");
      }
    }
    return obj;
  }

  /// Check the equality of all of the database members.
  @override
  bool operator ==(covariant Entity<T> other) {
    if (runtimeType == other.runtimeType &&
        members.length == other.members.length) {
      for (int i = 0; i < members.length; i++) {
        if (members[i] != other.members[i]) {
          return false;
        }
      }
      return true;
    }
    return false;
  }

  /// Hash all of the database members.
  @override
  int get hashCode => Object.hashAll(members);
}
