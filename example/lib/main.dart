import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:elite_orm/elite_orm.dart';

import '../model/eighties_metal.dart';
import '../database/database.dart';

final bloc = Bloc(Dao(EightiesMetal(), DatabaseProvider.database));

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EliteORM Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'EliteORM Example'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;

  const MyHomePage({super.key, required this.title});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // This is a contrived method of populating a database.  Usually, one would
  // take user input or some other method of collecting data.
  void _initialData() async {
    List<Uint8List> logos = [];
    List<String> urls = [
      "https://images.squarespace-cdn.com/content/v1/55ccf522e4b0fc9c2b651a5d/1439501203849-VHE9FD1TAJKZWUJPNTBA/Slayer_Logo_1000w.png",
      "https://upload.wikimedia.org/wikipedia/commons/thumb/e/ea/Metallica_wordmark.svg/1920px-Metallica_wordmark.svg.png",
      "https://megadeth.com/wp-content/uploads/2023/03/mega-tstsatd-logo-2048x391.png",
    ];
    for (var url in urls) {
      final response = await http.get(Uri.parse(url));
      logos.add(response.bodyBytes);
    }

    EightiesMetal slayer = EightiesMetal(
      "Slayer",
      Album("Show No Mercy", DateTime(1983, 12, 1),
          const Duration(minutes: 35, seconds: 2)),
      MetalSubGenre.thrash,
      true,
      DateTime(1981),
      [DBDateTimeRange(DateTime(1981), DateTime(2019))],
      ["Tom Araya", "Jeff Hanneman", "Kerry King", "Dave Lombardo"],
      [1983, 1985, 1986, 1988, 1990, 1994, 1996, 1998, 2001, 2006, 2009, 2015],
      logos[0],
    );
    EightiesMetal metallica = EightiesMetal(
      "Metallica",
      Album("Kill 'Em All", DateTime(1983, 7, 25),
          const Duration(minutes: 51, seconds: 20)),
      MetalSubGenre.thrash,
      false,
      DateTime(1981, 10, 28),
      [DBDateTimeRange(DateTime(1981))],
      ["Cliff Burton", "Kirk Hammet", "James Hetfield", "Lars Ulrich"],
      [1983, 1984, 1986, 1988, 1991, 1996, 1997, 2003, 2008, 2016, 2023],
      logos[1],
    );
    EightiesMetal megadeth = EightiesMetal(
      "Megadeth",
      Album("Killing Is My Business... and Business Is Good!",
          DateTime(1985, 6, 12), const Duration(minutes: 31, seconds: 10)),
      MetalSubGenre.speed,
      false,
      DateTime(1983, 7, 1),
      [
        DBDateTimeRange(DateTime(1983), DateTime(2002)),
        DBDateTimeRange(DateTime(2004))
      ],
      ["David Ellefson", "Dave Mustaine", "Chris Poland", "Gar Samuelson"],
      [
        1985,
        1986,
        1988,
        1990,
        1992,
        1994,
        1997,
        1999,
        2001,
        2004,
        2007,
        2009,
        2011,
        2013,
        2016,
        2022
      ],
      logos[2],
    );

    bloc.create(slayer);
    bloc.create(metallica);
    bloc.create(megadeth);
  }

  Widget _renderBand(EightiesMetal band) {
    return Card(
      margin: const EdgeInsets.all(10),
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: Theme.of(context).colorScheme.primaryContainer,
          width: 0.5,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: [
          Text(
            band.name,
            style: const TextStyle(
              fontSize: 16.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
              "${band.genre.toString().replaceAll("MetalSubGenre.", "")} metal"),
          Text(
              "Formed ${band.formed.toString().replaceAll("00:00:00.000", "")}${band.defunct ? " (disbanded)" : ""}"),
          const Text("Active:"),
          Column(
              children: band.active
                  .map((r) => Text("${r.start.year} - ${r.end.year}"))
                  .toList()),
          const Text("Studio Album Years:"),
          Column(
              children: band.studioAlbumYears.map((y) => Text("$y")).toList()),
          Text(band.album.name),
          Text(
              "${band.album.release.toString().replaceAll("00:00:00.000", "")} ${band.album.length}"),
          Text("${band.bandMembers}"),
          if (band.logo.isNotEmpty) Image.memory(band.logo, scale: 2),
        ],
      ),
    );
  }

  Widget _renderBands(AsyncSnapshot<List<EightiesMetal>> snapshot) {
    if (snapshot.hasData) {
      if (snapshot.data!.isEmpty) {
        return const SizedBox(width: double.infinity);
      } else {
        snapshot.data!.sort((a, b) => a.formed.compareTo(b.formed));
        return ListView.builder(
          shrinkWrap: true,
          itemCount: snapshot.data!.length,
          itemBuilder: (context, itemPosition) {
            return _renderBand(snapshot.data![itemPosition]);
          },
        );
      }
    } else {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const <Widget>[
            CircularProgressIndicator(),
            Text(
              "Loading...",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w500,
              ),
            )
          ],
        ),
      );
    }
  }

  Widget _renderBandsWidget() {
    return StreamBuilder(
      stream: bloc.all,
      builder:
          (BuildContext context, AsyncSnapshot<List<EightiesMetal>> snapshot) {
        return _renderBands(snapshot);
      },
    );
  }

  @override
  void initState() {
    super.initState();
    bloc.get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SafeArea(
        child: _renderBandsWidget(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _initialData,
        tooltip: 'Add static data',
        child: const Icon(Icons.add),
      ),
    );
  }

  @override
  dispose() {
    super.dispose();
    bloc.dispose();
  }
}
