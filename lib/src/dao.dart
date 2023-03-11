// Data Access Object
//
// Provides an abstract interface to some type of persistence mechanism. By
// mapping application calls to the persistence layer, the DAO provides data
// operations without exposing database details.
//
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
    List<DatabaseMap> result =
        await db.query(_entity.table, columns: columns);

    List<T> objects = [];
    for (var item in result) {
      objects.add(await _entity.fromJson(item));
    }
    return objects;
  }

  /// Update a record in the table.
  Future<int> update(T obj) async {
    final db = await _db;
    return await db.update(_entity.table, obj.toJson(),
        where: "${_entity.idColumn} = ?", whereArgs: [obj.id]);
  }

  /// Delete records from the table.
  Future<int> delete(dynamic id) async {
    final db = await _db;
    return await db.delete(_entity.table,
        where: "${_entity.idColumn} = ?", whereArgs: [id]);
  }

  /// Delete all records from the table.
  Future<int> deleteAll() async {
    final db = await _db;
    return await db.delete(_entity.table);
  }
}
