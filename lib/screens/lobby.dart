import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:soar_quest/soar_quest.dart';
import 'package:soar_quest/firebase.dart';

class LobbyScreen extends DocScreen {
  LobbyScreen(this.rooms, this.locations, super.doc);

  late final FirestoreCollection rooms, locations;

  final thisRef = SQFirebaseAuth.userDoc!.ref;

  bool get isOwner => doc.getValue<SQRef>('Owner') == thisRef;

  bool get isRunning => doc.getValue<bool>('Game Running') ?? false;

  late TextEditingController spiesCountController;

  bool get isSpy =>
      (doc.getValue<List<SQRef?>>('Spies') ?? []).contains(thisRef);

  /// Transfers ownership of the current room to another player.
  ///
  /// This method allows the owner of the current room to transfer ownership to
  /// another player. It retrieves the list of players in the room, removes the
  /// current owner from the list if present, assigns the new owner as the first
  /// player in the list, and updates the room's owner and player list.
  ///
  /// Example usage:
  /// ```dart
  /// await transferOwnership();
  /// ```
  Future<void> transferOwnership() async {
    final players = doc.getValue<List<SQRef?>>('Players') ?? [];

    if (players.contains(thisRef)) players.remove(thisRef);
    doc
      ..setValue('Owner', players[0])
      ..setValue('Players', players);
    await rooms.saveDoc(doc);
  }

  /// Deletes the current room document from the Firestore collection.
  ///
  /// Example usage:
  /// ```dart
  /// await deleteRoom();
  /// ```
  Future<void> deleteRoom() async {
    await rooms.deleteDoc(doc);
  }

  /// Handles the back button press to exit the room or transfer ownership.
  ///
  /// This method is called when the user presses the back button to exit the room.
  /// It displays a confirmation dialog to confirm the exit. If the user confirms,
  /// it checks the number of players in the room. If there's only one player, the
  /// room is deleted; otherwise, ownership is transferred to another player, and
  /// the user exits the room.
  ///
  /// Example usage:
  /// ```dart
  /// await backButtonCallback();
  /// ```
  Future<void> backButtonCallback() async {
    // Display a confirmation dialog to confirm the exit
    final confirmedExit =
        await MiniApp.showConfirm('Are you sure you want to leave the room?');

    if (confirmedExit) {
      final players = doc.getValue<List<SQRef?>>('Players') ?? [];

      // If there's only one player, delete the room; otherwise, transfer ownership
      if (players.length == 1) {
        await deleteRoom();
      } else {
        await transferOwnership();
      }

      // Exit the screen
      exitScreen();
    }
  }

  /// Adds the current user to the list of players in the room.
  ///
  /// This method adds the current user to the list of players in the room document.
  /// It retrieves the current list of players, checks if the user is already in the
  /// list, and adds them if not. After adding the user, it updates the 'Players' field
  /// of the room document and saves the changes to the database. Additionally, it
  /// triggers a refresh to update the user interface.
  ///
  /// Example usage:
  /// ```dart
  /// await addUserToPlayers();
  /// ```
  Future<void> addUserToPlayers() async {
    final players = doc.getValue<List<SQRef?>>('Players') ?? [];
    final thisRef = SQFirebaseAuth.userDoc!.ref;
    if (!players.contains(thisRef)) players.add(thisRef);
    debugPrint('new players $players');
    debugPrint(doc.collection.getField('Players')?.parse(players).toString());
    doc.setValue('Players', players);
    await rooms.saveDoc(doc);
    refresh();
  }

  /// Initiates the start of a game within the room.
  ///
  /// This method initiates the start of a game within the room by assigning roles
  /// to players, setting the game as running, and selecting a random location for
  /// the game. It randomly assigns a certain number of players as spies from the
  /// list of players and marks the game as running. It also selects a random location
  /// from the available locations and assigns it to the room.
  ///
  /// Example usage:
  /// ```dart
  /// await startGame();
  /// ```
  Future<void> startGame() async {
    // Retrieve the current list of players
    final players = doc.getValue<List<SQRef?>>('Players') ?? [];

    // Create a copy of players for role assignment
    final remainingPlayers = players.map((e) => e).toList();

    // Retrieve the number of spies for the game (default is 1)
    final spyCount = doc.getValue<int>('Spy Count') ?? 1;

    // Initialize a list to store the spies
    final spies = <SQRef>[];

    // Randomly assign spies from remaining players
    for (var i = 0; i < spyCount; i += 1) {
      final index = Random().nextInt(remainingPlayers.length);
      spies.add(remainingPlayers[index]!);
      remainingPlayers.removeAt(index);
    }

    // Update the room document with spies, game status, and location
    doc
      ..setValue('Spies', spies)
      ..setValue('Game Running', true);

    // Select a random location for the game
    final locationIndex = Random().nextInt(locations.docs.length);
    final roomLocation = locations.docs[locationIndex];
    doc.setValue('Location', roomLocation.ref);

    // Debug print the selected location
    debugPrint(roomLocation.toString());

    // Save the updated room document
    await rooms.saveDoc(doc);
  }

  /// Ends the current game in the room.
  ///
  /// This method ends the current game in the room by displaying an alert message,
  /// marking the game as not running, and saving the updated room document to the
  /// database. It is typically called when the game concludes or is manually ended.
  ///
  /// Example usage:
  /// ```dart
  /// await endGame();
  /// ```
  Future<void> endGame() async {
    // Display an alert message to indicate that the game has ended
    await MiniApp.showAlert('Game Ended');

    // Update the room document to mark the game as not running
    doc.setValue('Game Running', false);

    // Save the updated room document
    await rooms.saveDoc(doc);
  }

  /// Initializes the screen with initial data and configurations.
  ///
  /// Example usage:
  /// ```dart
  /// initScreen();
  /// ```
  @override
  void initScreen() {
    super.initScreen();
    // Initialize the spy count controller with the current spy count
    spiesCountController =
        TextEditingController(text: doc.getValue<int>('Spy Count').toString());

    // Add the current user to the list of players in the room
    unawaited(addUserToPlayers());
  }

  /// Determines the appropriate screen body based on game state.
  ///
  /// This method dynamically determines the appropriate screen body based on the
  /// current game state. If the game is not running, it displays the main screen.
  /// If the user is a spy, it displays the spy screen. Otherwise, it displays the
  /// location screen associated with the game's location.
  @override
  Widget screenBody() {
    // Check the game state and return the appropriate screen
    if (!isRunning) {
      return mainScreen();
    }
    if (isSpy) {
      return spyScreen();
    }
    final location = doc.getValue<SQRef>('Location');
    return locationScreen(location);
  }

  /// Generates a screen to display the current location.
  Widget locationScreen(SQRef? location) => Center(
          child: Column(
        children: [
          const Text(
            'Location is',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w900,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '$location',
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w900,
              color: Colors.black,
            ),
          ),
        ],
      ));

  /// Generates a screen to inform the user that they are the spy.
  Widget spyScreen() => Center(
          child: Column(
        children: [
          Image.asset('assets/spy.png'),
          const SizedBox(height: 10),
          const Text(
            'You are the Spy!',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w900,
              color: Colors.black,
            ),
          ),
        ],
      ));

  /// Generates the main screen for the room with game information.
  ///
  /// This method generates the main screen for the room, displaying game-related
  /// information such as the game code, spy count, player list, and details of
  /// the previous game if applicable. It formats this information within a column
  /// layout and allows users to interact with the spy count via a TextField.
  Widget mainScreen() {
    final spies = doc.getValue<List<SQRef?>>('Spies') ?? [];
    final showPrevGame = spies.isNotEmpty;
    final gameCode = doc.getValue<String>('Code');
    final playerList = doc.getValue<List<SQRef?>>('Players') ?? [];
    final location = doc.getValue<SQRef>('Location');

    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '$gameCode',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(
                width: 80,
              ),
              const Expanded(
                child: Text(
                  'Spies No.: ',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
              const SizedBox(
                width: 10, // Add spacing between widgets if needed
              ),
              Expanded(
                flex: 2, // The TextField takes up 2/3 of the available space
                child: TextField(
                  controller: spiesCountController,
                  onChanged: updateSpyCount,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: playerList.length,
              itemBuilder: (context, index) => ListTile(
                title: Text(
                  "${index + 1}. ${playerList[index]?.label! ?? 'null'}",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              shrinkWrap: true,
            ),
          ),
          SizedBox(height: 20),
          if (showPrevGame) Text('Previous Game:'),
          if (showPrevGame)
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Spies'),
                      ListView.builder(
                        itemCount: spies.length,
                        itemBuilder: (context, index) => Text(
                          "${index + 1}. ${spies[index]?.label! ?? 'null'}",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        shrinkWrap: true,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Location'),
                      Text('$location'),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  @override
  void refreshBackButton() {
    MiniApp.backButton.show();
    MiniApp.backButton.callback = backButtonCallback;
  }

  /// Refreshes the appearance and functionality of the main action button.
  @override
  void refreshMainButton() {
    if (isOwner) {
      if (!isRunning)
        MiniApp.mainButton
          ..show()
          ..callback = startGame
          ..setText('Start Game')
          ..setParams(color: Colors.red);
      else
        MiniApp.mainButton
          ..show()
          ..callback = endGame
          ..setText('End Game');
    } else
      MiniApp.mainButton.hide();
  }

  /// Updates the spy count for the current game.
  Future<void> updateSpyCount(String value) async {
    doc.setValue('Spy Count', int.parse(value));
    await collection.saveDoc(doc);
  }
}
