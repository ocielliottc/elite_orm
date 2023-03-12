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

  Bloc(Dao<T> dao) {
    _repository = Repository<T>(dao);
  }

  Stream<List<T>> get all => _controller.stream;

  Future<void> get() async {
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

  Future<void> delete(dynamic target) async {
    _repository.delete(target);
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
