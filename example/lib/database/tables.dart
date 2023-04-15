import '../model/eighties_metal.dart';

/// Return a list of all table descriptions.
List<String> getTableDescriptions() {
  return [
    EightiesMetal().describeTable(),
  ];
}
