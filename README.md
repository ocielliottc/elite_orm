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
  // Required function to create a Supplement object
  static Supplement _create() => Supplement();

  // The constructor for your object must be able to be called
  // with no parameters.
  Supplement([name = "", count = 0]) : super(_create) {
    // The first data member must be a unique identifier
    members.add(DBMember<String>("name", name, true));
    members.add(DBMember<int>("count", count));
  }

  // These are not necessary for storing your model in the database.
  // But, they are recommended to give easy access to the data members.
  String get name => members[0].value;
  int get count => members[1].value;
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
      onCreate: (Database database, int version) async {
        for (var description in getTableDescriptions()) {
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
Get a list of all of the supplement objects.
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
