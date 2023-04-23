# elite_orm

[![Version](https://img.shields.io/pub/v/elite_orm)](https://pub.dev/packages/elite_orm)
[![License](https://img.shields.io/github/license/ocielliottc/elite_orm)](https://github.com/elliottc/elite_orm)

A simple and easy-to-use ORM built with [sqflite](https://pub.dev/packages/sqflite) in mind.

## Getting Started

In your flutter project add the dependency:

```yml
dependencies:
  ...
  elite_orm:
```

## Usage example



Import `elite_orm.dart`

```dart
import 'package:elite_orm/elite_orm.dart';
```

### Creating a Model

Your model class will extend the `Entity` class in the following manner.

```dart
class Supplement extends Entity<Supplement> {
  // The constructor for your object has to be callable
  // with no parameters if you pass new to the super.
  Supplement([name = "", count = 0, DateTime? expire]) : super(Supplement.new) {
    // The first data member must be a unique identifier.
    // It will be the primary key.
    members.add(DBMember<String>("name", name));
    members.add(DBMember<int>("count", count));
    members.add(DateTimeDBMember("expire", expire ?? DateTime.now()));
  }

  // These are not necessary for storing your model in the database.
  // But, they are recommended to give easy access to the data members.
  String get name => members[0].value;
  int get count => members[1].value;
  DateTime get expire => members[2].value;
}
```
### Creating a DatabaseProvider
Once your model is defined, you will need a database provider to actually store data to the database.  This library was written with sqflite in mind.  Here is an example of how you could create your database provider.
```dart
import 'dart:io';  
import 'package:path/path.dart';  
import 'package:path_provider/path_provider.dart';  
import 'package:sqflite/sqflite.dart';  
import '../model/supplement.dart';

List<String> getTableDescriptions() {  
  return [  
    Supplement().describeTable(),  
  ];  
}
  
class DatabaseProvider {
  static final Future<Database> database = _createDatabase();

  static Future<Database> _createDatabase() async {
    final Directory documentsDirectory =
        await getApplicationDocumentsDirectory();
    final String path = join(documentsDirectory.path, "stored.db");
    return await openDatabase(
      path,
      version: 1,
      onCreate: (database, version) async {
        for (String description in getTableDescriptions()) {
          await database.execute("CREATE TABLE $description");
        }
      },
    );
  }
}
```
### Using the BLoC
At this point, you are ready to create a BLoC for each model object.  The BLoC will be the way that you interact with the database.
```dart
import 'package:elite_orm/elite_orm.dart';
import '../model/supplement.dart';
import '../database/database.dart';

final supplementBloc = Bloc(Supplement(), DatabaseProvider.database);
```
Create an object in the database.
```dart
Supplement supplement = Supplement("Wonder Supplement", 50);
supplementBloc.create(supplement);
```
Get a list of all of the supplement objects from the database.
```dart
List<Supplement> supplementList = [];  
StreamSubscription subscription = supplementBloc.all.listen((supplements) {  
  supplementList = supplements;  
});
```
Delete an object from the database.
```dart
supplementBloc.delete(supplement.name);
```

Click [here](https://github.com/ocielliottc/elite_orm/tree/main/example/lib) to see a more detailed example.

### The DBMember Classes

#### DBMember
This is the base class for all database members.  It is a name/value pair that can be used to represent `int`, `double`, and `Strings`.  It has an optional boolean parameter that indicates if it is to be used as part of a composite primary key.

#### EnumDBMember
This class extends `DBMember`, expects an `Enum` type as the value parameter, and has parameters for construction that are different from DBMember.  The first parameter is the list of enum values.  The next two parameters are the name/value pair.  The value going to and coming from the database is the integer index into the `Enum` type.

#### BoolDBMember
This class extends `DBMember` and expects a `bool` as the value parameter.  The value going to and coming from the database is the integer representation of true or false.

#### BinaryDBMember
This class extends `DBMember` and expects a `Uint8List` as the value parameter.  The value going to and coming from the database is a BLOB.

#### DateTimeDBMember
This class extends `DBMember` and expects a `DateTime` as the value parameter.  The value going to and coming from the database is a string.

#### DurationDBMember
This class extends `DBMember` and expects a `Duration` as the value parameter.  The value going to and coming from the database is a BIGINT representing the duration in microseconds.

#### PrimitiveListDBMember
This class extends `DBMember` and expects a `List<T>` as the value parameter, where T is `int`, `double`, or `String`.  The value going to and coming from the database is a jSON string.

#### ListDBMember
This class extends `PrimativeListDBMember` and has parameters for construction that are different from DBMember.  The first parameter is a function that can create an object of type T, where T is the template type and must extend `Serializable`.  The next two parameters are the name/value pair, where value is a List<T>.  The last, optional, parameter is a boolean that indicates if it is to be used as part of a composite primary key.  The value going to and coming from the database is a jSON string.

#### ObjectDBMember
This class extends `DBMember` and has parameters for construction that are different from DBMember.  The first parameter is a function that can create an object of type T, where T is the template type and must extend `Serializable`.  The next two parameters are the name/value pair, where value is of type T.  The last, optional, parameter is a boolean that indicates if it is to be used as part of a composite primary key.  The value going to and coming from the database is a jSON string.

### The Bloc class

The `Bloc` is the interface with which you interact with the database.  Any exceptions thrown by the underlying database implementation are allowed to propagate out of these class methods.

Construction of a `Bloc` requires an instance of the model class to which this `Bloc` is tied and a database provider, which can be taken word-for-word from the [Creating a DatabaseProvider](#creating-a-databaseprovider) section.

```dart
import 'package:elite_orm/elite_orm.dart';
import '../model/eighties_metal.dart';
import '../database/database.dart';

final bloc = Bloc(EightiesMetal(), DatabaseProvider.database);
```
#### Constructor
`Bloc(T instance, Future db)`

Creates a Bloc object.

The `instance` is not stored in the database; it is used for access to class methods.

#### Properties
`all` &rarr; `Stream<List<T>>`

An instance of a Dart asynchronous stream containing a list of all of the database objects of type T.

#### Methods
`get()` &rarr; `Future<void>`

Gets all of the database objects of type `T` and adds them to the stream controller.

`create(T obj)` &rarr; `Future<int>`

Adds `obj` of type `T` to the database.

`update(T obj)` &rarr; `Future<int>`

Replaces the object with the matching primary key in the database with `obj`.

`delete(dynamic target)`  &rarr; `Future<int>`

Delete the object that matches the target from the database, where target can either be the primary key or an object of type `T` which can be useful when your model has a composite primary key.

If your model has a composite primary key and you pass in a single aspect of the primary key, you can delete all objects that match that aspect. 

`deleteAll()` &rarr; `Future<int>`

Delete all of the objects of type `T` from the database.

`dispose()` &rarr; `void`

Closes the stream controller.
