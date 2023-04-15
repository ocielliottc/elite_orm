// Data Access Object
//
// Provides an abstract interface to some type of persistence mechanism. By
// mapping application calls to the persistence layer, the DAO provides data
// operations without exposing database details.
//
import 'db_type.dart';
import 'entity.dart';

class Dao<T extends Entity> {
  final T _entity;
  final Future _db;

  /// Provide an object of the type that this data access object will handle.
  /// The second parameter is the Future<Database> to call into.
  Dao(this._entity, this._db);

  /// Creates new records in the table.
  Future<int> create(T obj) async {
    final db = await _db;
    return db.insert(_entity.table, obj.toJson());
  }

  /// Get all items from the table.
  Future<List<T>> get({List<String>? columns}) async {
    final db = await _db;
    final List<DatabaseMap> result =
        await db.query(_entity.table, columns: columns);

    final List<T> objects = [];
    for (var item in result) {
      objects.add(await _entity.fromJson(item));
    }
    return objects;
  }

  /// Update a record in the table.
  Future<int> update(T obj) async {
    final db = await _db;
    final List whereArgs = [];
    String where = "";
    bool first = true;
    for (var m in obj.members) {
      if (first || m.primary) {
        first = false;
        if (where.isNotEmpty) {
          where += " AND ";
        }
        where += "${m.key} = ?";
        whereArgs.add(m.toDB());
      }
    }
    final int result = await db.update(_entity.table, obj.toJson(),
        where: where, whereArgs: whereArgs);
    if (result <= 0) {
      throw Exception("Unable to update the object: $whereArgs");
    }
    return result;
  }

  /// Delete records from the table.
  Future<int> delete(dynamic target) async {
    final db = await _db;
    final List whereArgs = [];
    String where = "";
    if (target is T) {
      bool first = true;
      for (var m in target.members) {
        if (first || m.primary) {
          first = false;
          if (where.isNotEmpty) {
            where += " AND ";
          }
          where += "${m.key} = ?";
          whereArgs.add(m.toDB());
        }
      }
    } else {
      where = "${_entity.idColumn} = ?";
      whereArgs.add(target);
    }

    // If the number of items deleted was zero or less, throw an exception
    // so that the caller knows nothing was deleted.
    final int result =
        await db.delete(_entity.table, where: where, whereArgs: whereArgs);
    if (result <= 0) {
      throw Exception("Unable to delete the object: $whereArgs");
    }
    return result;
  }

  /// Delete all records from the table.
  Future<int> deleteAll() async {
    final db = await _db;
    return await db.delete(_entity.table);
  }
}
