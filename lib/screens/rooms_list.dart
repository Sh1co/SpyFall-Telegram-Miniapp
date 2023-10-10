import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';

import 'package:soar_quest/soar_quest.dart';
import 'package:soar_quest/firebase.dart';
import 'lobby.dart';

/// A screen that displays a list of rooms from a Firestore collection.
///
/// The [RoomsListScreen] class is a [CollectionScreen] that displays a list
/// of rooms from a Firestore collection. It inherits properties and methods
/// from the [CollectionScreen] class and customizes them to display rooms.
class RoomsListScreen extends CollectionScreen {
  RoomsListScreen({
    required super.collection,
    required this.rooms,
    required this.locations,
  });

  /// The Firestore collections for rooms and locations.
  late final FirestoreCollection rooms, locations;

  @override
  Future<void> goToDocScreen(Screen docScreen) =>
      navigateTo(LobbyScreen(rooms, locations, (docScreen as DocScreen).doc));

  /// Generates the UI for displaying the collection of rooms.
  ///
  /// This method generates the user interface for displaying a collection of
  /// rooms. It includes a title, a list of rooms, and their associated details.
  @override
  Widget collectionDisplay(List<SQDoc> docs) => Center(
        child: Column(
          children: [
            const Text(
              'Rooms',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w900,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 30),
            ListView(
              shrinkWrap: true,
              children: docs.map(docDisplay).toList(),
            ),
          ],
        ),
      );

  /// Generates the UI for displaying a single room document.
  ///
  /// This method generates the user interface for displaying a single room
  /// document. It includes the room's name and details.
  ///
  /// [doc]: The room document to display.
  @override
  Widget docDisplay(SQDoc doc) {
    final docImageLabel = doc.imageLabel;
    final secondaryLabel = doc.secondaryLabel;
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey), // Add border here
      ),
      child: ListTile(
        title: Center(
          child: Text(
            'Room: $doc',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        onTap: () async => goToDocScreen(docScreen(doc)),
      ),
    );
  }

  /// Returns the floating action button widget for the screen.
  ///
  /// This method returns the floating action button widget for the screen,
  /// or `null` if there is no floating action button.
  @override
  FloatingActionButton? floatingActionButton() => null;
}
