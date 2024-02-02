import 'package:favourite_places_app/Providers/Places_list_Provider.dart';
import 'package:favourite_places_app/widgets/map.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:favourite_places_app/models/Place_model.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class PlacesDetailScreen extends StatefulWidget {
  const PlacesDetailScreen({super.key, required this.place});
  final Place place;

  @override
  State<PlacesDetailScreen> createState() => _PlacesDetailScreenState();
}

class _PlacesDetailScreenState extends State<PlacesDetailScreen> {
  late final MapController mapController;

  @override
  void initState() {
    mapController = MapController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.place.name),
      ),
      body: Stack(
        children: [
          Image.file(
            widget.place.image,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                        //borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                      color: Colors.black.withOpacity(.2),
                    )),
                    height: 200,
                    width: 200,
                    child: FlutterMap(
                      mapController: mapController,
                      options: MapOptions(
                        interactiveFlags: InteractiveFlag.pinchZoom,
                        center: LatLng(widget.place.location.latitude,
                            widget.place.location.longitude),
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
                              point: LatLng(widget.place.location.latitude,
                                  widget.place.location.longitude),
                              builder: (context) => const Icon(
                                Icons.location_on,
                                size: 25,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (ctx) => MapScreen(
                            isSelecting: false,
                            location: widget.place.location,
                              )));
                    },
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                          gradient: LinearGradient(
                        colors: [Colors.transparent, Colors.black54],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      )),
                      child: Text(
                        widget.place.location.address,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
                            color: Theme.of(context).colorScheme.onBackground),
                      ),
                    ),
                  )
                ],
              ))
        ],
      ),
    );
  }
}
