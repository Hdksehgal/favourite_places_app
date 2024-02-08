import 'package:favourite_places_app/Providers/Places_list_Provider.dart';
import 'package:favourite_places_app/models/Place_model.dart';
import 'package:favourite_places_app/widgets/image_input.dart';
import 'package:favourite_places_app/widgets/input_location.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:path_provider/path_provider.dart' as syspath;
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart' as sql;
import 'package:sqflite/sqlite_api.dart';

class AddPlacesScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<AddPlacesScreen> createState() => _AddPlacesScreenState();
}

class _AddPlacesScreenState extends ConsumerState<AddPlacesScreen> {
  final _formKey = GlobalKey<FormState>();
  var _namePlace = '';
  PlaceLocation? _selectedLocation;
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
  }

  Future<List> _getLocationAddress(double longitude, double latitude) async {
    List<geo.Placemark> placemarkAddress =
        await geo.placemarkFromCoordinates(latitude, longitude);
    return placemarkAddress;
  }

  void _saveLocation(double longitude, double latitude) async {
    final addressData = await _getLocationAddress(longitude, latitude);
    final street = addressData[0].street;
    final postalcode = addressData[0].postalCode;
    final locality = addressData[0].locality;
    final country = addressData[0].country;
    final String address = '$street ,$postalcode, $locality, $country';

    setState(() {
      _selectedLocation = PlaceLocation(
          longitude: longitude, latitude: latitude, address: address);
    });
  }

  void _savePlace() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final placeslist = ref.watch(PlacesProvider);
      List<Place> dummy = placeslist;

      if (_selectedImage == null || _selectedLocation == null) {
        return;
      }

      final appdir = await syspath.getApplicationDocumentsDirectory();
      final filename = path.basename(_selectedImage!.path);
      final copiedImage = await _selectedImage!.copy('${appdir.path}/$filename');
      final newPlace = Place(
          name: _namePlace, image: copiedImage, location: _selectedLocation!);

      dummy.add(newPlace);

      final dbpath = await sql.getDatabasesPath();
      final db = await await sql.openDatabase(
        path.join(dbpath, 'places.db'),
        onCreate: (db, version) {
          return db.execute(
              'CREATE TABLE user_places(id TEXT PRIMARY KEY, title TEXT, image TEXT , lat REAL, lng REAL, address TEXT)');
        },
        version: 1,
      );

      db.insert('user_places', {
        'id' : newPlace.id,
        'title' : newPlace.name,
        'image' : newPlace.image.path,
        'lat' : newPlace.location.latitude,
        'lng' : newPlace.location.latitude,
        'address' : newPlace.location.address,
      });


      ref.read(PlacesProvider.notifier).addPlace(dummy);
      Navigator.of(context).pop(placeslist);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add new place"),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(25),
            child: Column(
              children: [
                TextFormField(
                  decoration: const InputDecoration(
                    label: Text("Title"),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                  ),
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onBackground),
                  maxLength: 50,
                  initialValue: _namePlace,
                  validator: (val) {
                    if (val == null ||
                        val.length == 0 ||
                        val.trim().length <= 1 ||
                        val.trim().length > 50) {
                      return "No. of characters must be between 2 to 50";
                    }
                  },
                  onSaved: (val) {
                    _namePlace = val!;
                  },
                ),
                const SizedBox(
                  height: 15,
                ),
                ImageInput(
                  onPickImage: (image) {
                    _selectedImage = image;
                  },
                ),
                const SizedBox(
                  height: 15,
                ),
                InputLocation(onSelectLocation: (location) {
                  _selectedLocation = location;
                }),
                const SizedBox(
                  height: 15,
                ),
                ElevatedButton.icon(
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: _savePlace,
                    label: Text("Add Place"))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
