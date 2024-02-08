import 'dart:io';

import 'package:favourite_places_app/models/Place_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart' as syspath;
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart' as sql;
import 'package:sqflite/sqlite_api.dart';

Future<Database> getDatabase() async {
  final dbpath = await sql.getDatabasesPath();
  final db = await sql.openDatabase(
    path.join(dbpath, 'places.db'),
    onCreate: (db, version) {
      return db.execute(
          'CREATE TABLE user_places(id TEXT PRIMARY KEY, title TEXT, image TEXT , lat REAL, lng REAL, address TEXT)');
    },
    version: 1,
  );
  return db;
}

class PlacesNotifier extends StateNotifier<List<Place>> {
  PlacesNotifier() : super([]);

  Future<void> loadPlaces() async {
    final db = await getDatabase();
    final data = await db.query('user_places');
    final places = data
        .map((row) => Place(
            id: row['id'] as String,
            name: row['title'] as String,
            image: File(row['image'] as String),
            location: PlaceLocation(
                longitude: row['lng'] as double,
                latitude: row['lat'] as double,
                address: row['address'] as String)))
        .toList();

    state = places;
  }

  void addPlace(List<Place> places) {
    state = places;
  }
  // void addPlace (String title)
  // {
  //   final newPlace = Place(name: title);
  //   state = [...state , newPlace];
  // }
}

final PlacesProvider = StateNotifierProvider<PlacesNotifier, List<Place>>(
    (ref) => PlacesNotifier());
