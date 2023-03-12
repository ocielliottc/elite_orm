import 'dart:typed_data';
import 'package:elite_orm/elite_orm.dart';
import 'package:flutter/material.dart';

enum MetalSubGenre { death, thrash, speed, hair, doom, sludge }

class Album extends Entity<Album> {
  Album([name = "", DateTime? release, Duration? length]) : super(Album.new) {
    members.add(DBMember<String>("name", name));
    members.add(DateTimeDBMember("release", release ?? DateTime.now()));
    members.add(DurationDBMember("length", length ?? const Duration()));
  }

  String get name => members[0].value;
  DateTime get release => members[1].value;
  Duration get length => members[2].value;
}

// An example of how to write a class that implements Serializable.  This would
// actually be simpler to implement by extending Entity and using
// DateTimeDBMember.
class DBDateTimeRange extends DateTimeRange with Serializable {
  DBDateTimeRange([DateTime? start, DateTime? end])
      : super(start: start ?? DateTime.now(), end: end ?? DateTime.now());

  @override
  Future fromJson(DatabaseMap map) async {
    return DBDateTimeRange(
        DateTime.parse(map["start"]), DateTime.parse(map["end"]));
  }

  @override
  DatabaseMap toJson() {
    return {"start": start.toIso8601String(), "end": end.toIso8601String()};
  }
}

class EightiesMetal extends Entity<EightiesMetal> {
  EightiesMetal([
    name = "",
    Album? album,
    genre = MetalSubGenre.thrash,
    bool defunct = false,
    DateTime? formed,
    List<DBDateTimeRange> active = const [],
    List<String> bandMembers = const [],
    List<int> studioAlbumYears = const [],
    Uint8List? logo,
  ]) : super(EightiesMetal.new) {
    // Because this member is first, it is the primary key.
    members.add(DBMember<String>("name", name));
    members.add(ObjectDBMember<Album>(Album.new, "album", album ?? Album()));
    members.add(EnumDBMember<MetalSubGenre>("type", genre));
    members.add(BoolDBMember("defunct", defunct));
    members.add(DateTimeDBMember("formed", formed ?? DateTime.now()));
    members.add(
        ListDBMember<DBDateTimeRange>(DBDateTimeRange.new, "active", active));
    members.add(PrimitiveListDBMember<String>("members", bandMembers));
    members
        .add(PrimitiveListDBMember<int>("studioAlbumYears", studioAlbumYears));
    members.add(BinaryDBMember("logo", logo ?? Uint8List(0)));
  }

  String get name => members[0].value;
  Album get album => members[1].value;

  // An enum will be stored as an int in the database.  Convert to and from
  // using the enum values and index.
  MetalSubGenre get genre => MetalSubGenre.values[members[2].value];
  set genre(MetalSubGenre genre) => members[2].value = genre.index;

  bool get defunct => members[3].value;
  DateTime get formed => members[4].value;
  List<DateTimeRange> get active => members[5].value;
  List<String> get bandMembers => members[6].value;
  List<int> get studioAlbumYears => members[7].value;
  Uint8List get logo => members[8].value;
}
