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

  Repository(this._dao);

  Future<List<T>> get() => _dao.get();

  Future<int> create(T obj) => _dao.create(obj);

  Future<int> update(T obj) => _dao.update(obj);

  Future<int> delete(dynamic id) => _dao.delete(id);

  Future<int> deleteAll() => _dao.deleteAll();
}
