import 'dart:typed_data';
import 'package:elite_orm/elite_orm.dart';
import 'package:flutter/material.dart';

enum MetalSubGenre { death, thrash, speed, hair, doom, sludge }

class Album extends Entity<Album> {
  /// This is our model representative of an album.
  Album([name = "", DateTime? release, Duration? length]) : super(Album.new) {
    members.add(DBMember<String>("name", name));
    members.add(DateTimeDBMember("release", release ?? DateTime.now()));
    members.add(DurationDBMember("length", length ?? const Duration()));
  }

  /// The name of the album.
  String get name => members[0].value;
  /// The release date of the album.
  DateTime get release => members[1].value;
  /// The length of the album.
  Duration get length => members[2].value;
}

/// An example of how to write a class that implements Serializable.  This would
/// actually be simpler to implement by extending Entity and using
/// DateTimeDBMember.
class DBDateTimeRange extends DateTimeRange with Serializable {
  /// A database representation of flutter's DateTimeRange
  DBDateTimeRange([DateTime? start, DateTime? end])
      : super(start: start ?? DateTime.now(), end: end ?? DateTime.now());

  /// Construct an object given the values stored within the database map.
  @override
  Future fromJson(DatabaseMap map) async {
    return DBDateTimeRange(
        DateTime.parse(map["start"]), DateTime.parse(map["end"]));
  }

  /// Convert an object into a map of name/value pairs.
  @override
  DatabaseMap toJson() {
    return {"start": start.toIso8601String(), "end": end.toIso8601String()};
  }
}

class EightiesMetal extends Entity<EightiesMetal> {
  /// Represent information about an 80s metal band.
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
    members.add(EnumDBMember<MetalSubGenre>(MetalSubGenre.values, "type", genre));
    members.add(BoolDBMember("defunct", defunct));
    members.add(DateTimeDBMember("formed", formed ?? DateTime.now()));
    members.add(
        ListDBMember<DBDateTimeRange>(DBDateTimeRange.new, "active", active));
    members.add(PrimitiveListDBMember<String>("members", bandMembers));
    members
        .add(PrimitiveListDBMember<int>("studioAlbumYears", studioAlbumYears));
    members.add(BinaryDBMember("logo", logo ?? Uint8List(0)));
  }

  /// The name of the band.
  String get name => members[0].value;
  /// The name of the album.
  Album get album => members[1].value;

  /// The genre of the band.
  MetalSubGenre get genre => members[2].value;
  /// Allow the caller to change the genre.
  set genre(MetalSubGenre genre) => members[2].value = genre;

  /// Has the band broken up?
  bool get defunct => members[3].value;
  /// The date the band was formed.
  DateTime get formed => members[4].value;
  /// The date time ranges of band activity.
  List<DateTimeRange> get active => members[5].value;
  /// A list of band members.
  List<String> get bandMembers => members[6].value;
  /// A list of years during which studio albums were released.
  List<int> get studioAlbumYears => members[7].value;
  /// A png representation of the band logo.
  Uint8List get logo => members[8].value;
}
