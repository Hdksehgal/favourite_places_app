import 'package:favourite_places_app/models/Place_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PlacesNotifier extends StateNotifier<List<Place>>{
  PlacesNotifier() : super([]);



  void addPlace (List<Place> places)
  {
    state = places;
  }
  // void addPlace (String title)
  // {
  //   final newPlace = Place(name: title);
  //   state = [...state , newPlace];
  // }
}

final PlacesProvider = StateNotifierProvider<PlacesNotifier, List<Place>>((ref) => PlacesNotifier());