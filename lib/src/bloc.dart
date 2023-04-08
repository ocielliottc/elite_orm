// BLoC Pattern
//
// Business Logic Components help separate logic from the user interface while
// maintaining the flutter reactive model of redrawing the UI when a state or
// stream changes.
//
import 'dart:async';

import 'repository.dart';
import 'dao.dart';
import 'entity.dart';

class Bloc<T extends Entity> {
  late Repository<T> _repository;
  final _controller = StreamController<List<T>>.broadcast();

  /// Provide an object of the type that this Bloc will handle.
  /// The second parameter is the Future<Database> to call into.
  Bloc(T instance, Future db) {
    _repository = Repository<T>(Dao<T>(instance, db));
  }

  /// Provide access to the stream from the stream controller.
  Stream<List<T>> get all => _controller.stream;

  /// Get all objects of type T and add them to the stream controller.
  /// Listeners to the stream will be updated with the object list.
  Future<void> get() async {
    _controller.sink.add(await _repository.get());
  }

  /// Creates a new object in the database.
  Future<void> create(T obj) async {
    await _repository.create(obj);
    get();
  }

  /// Updates an existing object in the database.
  Future<void> update(T obj) async {
    await _repository.update(obj);
    get();
  }

  /// Deletes one or more objects from the database.
  /// Target can be either a primary key or an object of type T.
  Future<void> delete(dynamic target) async {
    await _repository.delete(target);
    get();
  }

  /// Deletes all objects of type T from the database.
  Future<void> deleteAll() async {
    await _repository.deleteAll();
    get();
  }

  /// Closes the stream controller.
  void dispose() {
    _controller.close();
  }
}
