import 'package:favourite_places_app/Providers/Places_list_Provider.dart';
import 'package:favourite_places_app/Screens/Add_Places.dart';
import 'package:favourite_places_app/Screens/Place_detail.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:favourite_places_app/models/Place_model.dart';

class HomeScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  // List<Place> ListUsed = [];
  late Future<void> placesfuture;

  @override
  void initState() {
    super.initState();
    placesfuture = ref.read(PlacesProvider.notifier).loadPlaces();
  }

  @override
  Widget build(BuildContext context) {
    List<Place> placesList = ref.watch(PlacesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text("Your Places"),
        actions: [
          IconButton(
            icon: Icon(Icons.add_rounded),
            onPressed: () async {
              final list = await Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => AddPlacesScreen()));
              setState(() {
                placesList = list;
              });
            },
          ),
        ],
      ),
      body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: FutureBuilder(
            future: placesfuture,
            builder: (context, snapshot) => snapshot.connectionState ==
                    ConnectionState.waiting
                ? const Center(child: CircularProgressIndicator())
                : placesList.isEmpty
                    ? Center(
                        child: Text(
                        'No Places yet',
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
                            color: Theme.of(context).colorScheme.onBackground),
                      ))
                    : ListView.builder(
                        itemCount: placesList.length,
                        itemBuilder: (context, index) => ListTile(

                            leading: CircleAvatar(
                              backgroundImage:
                                  FileImage(placesList[index].image),
                              radius: 26,
                            ),
                            title: Text(
                              placesList[index].name,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium!
                                  .copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onBackground),
                            ),
                            subtitle: Text(
                              placesList[index].location.address,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall!
                                  .copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onBackground),
                            ),
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (ctx) => PlacesDetailScreen(
                                        place: placesList[index],
                                      )));
                            },

                        )),
          )),
    );
  }
}
