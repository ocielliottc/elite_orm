# elite_orm

A comprehensive ORM built with [sqflite](https://pub.dev/packages/sqflite) in mind.

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

final supplementBloc = Bloc(Dao(Supplement(), DatabaseProvider.database));
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
This class extends `DBMember` and expects an `Enum` type as the value parameter.  The value going to and coming from the database is the integer index into the `Enum` type.

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
This class extends `DBMember` and has parameters for construction that are different from DBMember.  The first parameter is a function that will create an object of type T, where T is the template type and must extend `Serializable`.  The next two parameters are the name/value pair, where value is a List<T>.  The last, optional, parameter is a boolean that indicates if it is to be used as part of a composite primary key.  The value going to and coming from the database is a jSON string.

#### ObjectDBMember
This class extends `DBMember` and has parameters for construction that are different from DBMember.  The first parameter is a function that will create an object of type T, where T is the template type and must extend `Serializable`.  The next two parameters are the name/value pair, where value is of type T.  The last, optional, parameter is a boolean that indicates if it is to be used as part of a composite primary key.  The value going to and coming from the database is a jSON string.
