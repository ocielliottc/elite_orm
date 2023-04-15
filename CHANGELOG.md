## 1.0.6

- Propagate database operations return value out to the bloc.

- Throw an exception on error when updating fails.

- Take the list of enum values when constructing the EnumDBMember to automate conversion to and from the int value.

## 1.0.5

- Added missing `await` in `Bloc.delete` and `Bloc.deleteAll`.

## 1.0.4

- Corrected serialization of primitive lists.

- Added an equality operator and hash function to `Entity` to allow child classes to automatically be able to be stored in a Set.

## 1.0.3

- Throw an exception when we fail to delete an object.

## 1.0.2

- Corrected the `update` method to accommodate composite primary keys.

## 1.0.1

- Simplified the definition of a model class.
- Simplified the construction of the Bloc class.
- Added the ability to delete an object from the database by passing a instance of the model.
- Added Bloc class documentation.

## 1.0.0

- Initial version.
