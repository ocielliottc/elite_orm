// Repository Pattern
//
// Decouple the data access layer from the business access layer of the
// application so that the operations (such as adding, updating, deleting,
// and selecting items from the collection) are done through straightforward
// methods without dealing with database concerns.
//
import "dao.dart";
import "entity.dart";

class Repository<T extends Entity> {
  final Dao<T> _dao;

  /// The DAO really indicates the type of object handled by this repository.
  Repository(this._dao);

  /// Get all objects of type T.
  Future<List<T>> get() => _dao.get();

  /// Creates a new object in the database.
  Future<int> create(T obj) => _dao.create(obj);

  /// Updates an existing object in the database.
  Future<int> update(T obj) => _dao.update(obj);

  /// Deletes one or more objects from the database.
  /// Target can be either a primary key or an object of type T.
  Future<int> delete(dynamic target) => _dao.delete(target);

  /// Deletes all objects of type T from the database.
  Future<int> deleteAll() => _dao.deleteAll();
}
