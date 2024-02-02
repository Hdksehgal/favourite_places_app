import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:favourite_places_app/models/Place_model.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:favourite_places_app/widgets/map.dart';


class InputLocation extends StatefulWidget {
  const InputLocation({super.key, required this.onSelectLocation});
  final void Function(PlaceLocation location) onSelectLocation;
  @override
  State<InputLocation> createState() {
    // TODO: implement createState
    return _InputLocationState();
  }
}

class _InputLocationState extends State<InputLocation> {
  var _isGettingLocation = false;
  PlaceLocation? _pickedLocation;
  late final MapController mapController;

  @override
  void initState() {
    mapController = MapController();
    super.initState();
  }

  Future<List> getLocationAddress(double latitude, double longitude) async {
    List<geo.Placemark> placemark =
    await geo.placemarkFromCoordinates(latitude, longitude);
    return placemark;
  }


  Future<void> _savePlace(double latitude, double longitude) async {
    final addressData = await getLocationAddress(latitude, longitude);

    final String street = addressData[0].street;
    final String postalcode = addressData[0].postalCode;
    final String locality = addressData[0].locality;
    final String country = addressData[0].country;
    final String address = '$street, $postalcode, $locality, $country';

    setState(() {
      _pickedLocation = PlaceLocation(
        latitude: latitude,
        longitude: longitude,
        address: address,
      );
      _isGettingLocation = false;
    });

    widget.onSelectLocation(_pickedLocation!);
  }

  void _getCurrentLocation() async{
    Location location = Location();

    bool serviceEnabled;
    PermissionStatus permissionGranted;
    LocationData locationData;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    setState(() {
      _isGettingLocation = true;
    });

    locationData = await location.getLocation();
    final lat = locationData.latitude;
    final lng = locationData.longitude;
    // cause this location.getLocation() will take time to get the
    // current location that is why we have set the setstate before and
    // after this

    if (lat == null || lng == null) {
      return;
    }

    setState(() {
      _isGettingLocation = false;
    });

    _savePlace(lat, lng);
  }

  Future<void> _selectOnMap() async {
    final pickedLocation = await Navigator.of(context).push<LatLng>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (ctx) => const MapScreen(isSelecting: true,),
      ),
    );

    if (pickedLocation == null) {
      return;
    }

    _savePlace(pickedLocation.latitude, pickedLocation.longitude);
  }

  @override
  void dispose() {
    mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget previewContent = Text(
      'No location chosen',
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
        color: Theme.of(context).colorScheme.onBackground,
      ),
    );

    if (_pickedLocation != null) {
      previewContent = FlutterMap(
        mapController: mapController,
        options: MapOptions(
          interactiveFlags: InteractiveFlag.none,
          center: LatLng(_pickedLocation!.latitude, _pickedLocation!.longitude),
          zoom: 13.0,
        ),
        children: [
          TileLayer(
            urlTemplate:
            'https://{s}.google.com/vt/lyrs=m&hl={hl}&x={x}&y={y}&z={z}',
            additionalOptions: const {'hl': 'en'},
            subdomains: const ['mt0', 'mt1', 'mt2', 'mt3'],
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: LatLng(
                    _pickedLocation!.latitude, _pickedLocation!.longitude),
                builder: (context) => const Icon(
                  Icons.location_on,
                  size: 25,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
        ],
      );
    }

    if(_isGettingLocation){
      previewContent = CircularProgressIndicator();
    }

    return Column(children: [
      Container(
        decoration: BoxDecoration(
            border: Border.all(
                width: 1,
                color: Theme.of(context).colorScheme.primary.withOpacity(.3))),
        alignment: Alignment.center,
        height: 170,
        width: double.infinity,
        child: previewContent
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          TextButton.icon(
            icon: Icon(Icons.location_on_outlined),
            label: Text("Get current location"),
            onPressed: _getCurrentLocation,
          ),
          TextButton.icon(
            icon: Icon(Icons.map),
            label: Text("Select location Manually"),
            onPressed: _selectOnMap,
          ),
        ],
      )
    ]);
  }
}
