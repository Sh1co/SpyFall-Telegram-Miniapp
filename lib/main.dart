import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:soar_quest/firebase.dart';
import 'package:soar_quest/soar_quest.dart';

import '../firebase_options.dart';
import 'screens/how_to_play.dart';
import 'screens/lobby.dart';
import 'screens/rooms_list.dart';

late final FirestoreCollection rooms, locations;

void main() async {
  /*

  Initialize Soar Quest and Firebase
  
  */
  await SQApp.init('Spyfall');

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await SQFirebaseAuth.init(generateTokenUrl: 'URL HERE');

  /*

  Setup database architecture
  
  */
  rooms = FirestoreCollection(
      id: 'Rooms',
      fields: [
        SQStringField('Code')..editable = false,
        SQCreatedByField('Owner')
          ..hasNavigateAction = false
          ..editable = false,
        SQListField(
            SQRefField('Players', collection: SQFirebaseAuth.usersCollection))
          ..editable = false,
        SQListField(
            SQRefField('Spies', collection: SQFirebaseAuth.usersCollection))
          ..editable = false,
        SQBoolField('Game Running')
          ..editable = false
          ..defaultValue = false,
        SQIntField('Spy Count')..defaultValue = 1,
      ],
      isLive: true);

  locations = FirestoreCollection(id: 'Locations', fields: [
    SQStringField('Name'),
  ]);

  rooms.fields
      .add(SQRefField('Location', collection: locations)..editable = false);

  await locations.loadCollection();

  /*

  Set Miniapp settings
  
  */

  MiniApp.enableClosingConfirmation();
  MiniApp.expand();

  /*

  Start running the project from the main screen
  
  */

  SQApp.run([
    SpyfallMainScreen(),
  ],
      themeData: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
      ));
}

class SpyfallMainScreen extends Screen {
  SpyfallMainScreen() : super('Spyfall');

  /// Generates a new room with a unique code and navigates the user to the lobby.
  ///
  /// This function generates a new room with a unique code, assigns the current
  /// user as the owner of the room, and saves the room to the database. After
  /// creating the room, it navigates the user to the lobby screen associated with
  /// the newly created room.
  ///
  /// Note: Ensure that the user is authenticated and [SQFirebaseAuth.userDoc] is
  /// initialized before calling this function.
  ///
  /// Example usage:
  /// ```dart
  /// await generateRoom();
  /// ```
  Future<void> generateRoom() async {
    final roomCode = rooms.newDocId().toLowerCase().substring(0, 5);
    final owner = SQFirebaseAuth.userDoc?.ref;
    final newRoom = rooms.newDoc(source: {
      'Code': roomCode,
      'Owner': owner,
    }, id: roomCode);
    await rooms.saveDoc(newRoom);
    await navigateTo(LobbyScreen(rooms, locations, newRoom));
  }

  /// Navigates the user to the rooms list screen for viewing available rooms.
  ///
  /// This function navigates the user to the "Rooms List" screen, where they can
  /// view and select available rooms to join. It initializes the screen with the
  /// necessary data, including the `rooms` collection and `locations`.
  ///
  /// Example usage:
  /// ```dart
  /// await viewRooms();
  /// ```
  Future<void> viewRooms() async {
    await navigateTo(
        RoomsListScreen(collection: rooms, rooms: rooms, locations: locations));
  }

  /// Navigates the user to the "How to Play" screen for instructions.
  ///
  /// This function navigates the user to the "How to Play" screen, where they can
  /// find instructions and guidelines on how to play the game or use the
  /// application. The screen typically provides helpful information for users who
  /// are new to the application or need guidance on using its features.
  ///
  /// Example usage:
  /// ```dart
  /// await viewHowToPlay();
  /// ```
  Future<void> viewHowToPlay() async {
    await navigateTo(HowToPlayScreen());
  }

  /// Defines the body of the main screen for the SpyFall application.
  @override
  Widget screenBody() => Column(
        children: [
          Center(
              child: Column(
            children: [
              const Text(
                'SpyFall',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 50),
              sfButton('Create New Room', generateRoom),
              const SizedBox(height: 10),
              sfButton('Show Rooms', viewRooms),
              const SizedBox(height: 10),
              sfBorderlessButton('How To Play', viewHowToPlay),
              const SizedBox(height: 150),
              const Text(
                'Developed By Sh1co',
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.normal,
                  color: Colors.grey,
                ),
              ),
              const Text(
                'Powered By Soar Quest',
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.normal,
                  color: Colors.grey,
                ),
              ),
              const Text(
                'Inspired By spyfall.app',
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.normal,
                  color: Colors.grey,
                ),
              ),
            ],
          )),
        ],
      );

  /// Creates an ElevatedButton with custom styling and functionality.
  ElevatedButton sfButton(String text, void Function() onPressedFunction) =>
      ElevatedButton(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Colors.white),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
              side: const BorderSide(color: Colors.red),
            ),
          ),
        ),
        onPressed: onPressedFunction,
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.red,
            fontSize: 16,
          ),
        ),
      );

  /// Creates an ElevatedButton with custom styling and functionality.
  TextButton sfBorderlessButton(
          String text, void Function() onPressedFunction) =>
      TextButton(
        onPressed: onPressedFunction,
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.red,
            fontSize: 16,
          ),
        ),
      );
}
