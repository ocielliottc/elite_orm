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

  // The stream controller is the 'Admin' that manages the state of our stream
  // of data like adding data, changes the state of the stream and broadcasts
  // it to observers/subscribers.
  final _controller = StreamController<List<T>>.broadcast();

  Stream<List<T>> get all => _controller.stream;

  Bloc(Dao<T> dao) {
    _repository = Repository<T>(dao);
  }

  Future<void> get() async {
    // sink is a way of adding data reactively to the stream
    // by registering a new event.
    _controller.sink.add(await _repository.get());
  }

  Future<void> create(T obj) async {
    await _repository.create(obj);
    get();
  }

  Future<void> update(T obj) async {
    await _repository.update(obj);
    get();
  }

  Future<void> delete(dynamic id) async {
    _repository.delete(id);
    get();
  }

  Future<void> deleteAll() async {
    _repository.deleteAll();
    get();
  }

  void dispose() {
    _controller.close();
  }
}
