import 'package:flutter/material.dart';

import 'package:soar_quest/soar_quest.dart';

class HowToPlayScreen extends Screen {
  HowToPlayScreen() : super('How to Play');

  /// Defines the body of the "How To Play" screen for the SpyFall application.
  @override
  Widget screenBody() => Center(
        child: ListView(
          children: [
            const Center(
              child: Text(
                'How To Play',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  color: Colors.red,
                ),
              ),
            ),
            RichTextParagraph(
              text: playRules,
            ),
          ],
        ),
      );

  String playRules = '''
Spyfall is a social deduction game where players must either identify the spy among them or, if they are the spy, guess the location without being detected. To set up, each player receives a location, except for the spy, who simply sees the word "Spy." A timer is set for a few minutes, and players take turns asking each other questions about the location without directly revealing it. Answers must be given in a way that doesn't expose the location. Non-spy players aim to spot the spy, while the spy attempts to blend in and guess the location. Accusations can be made at any time, and a majority vote decides if the accused is the spy. The game ends when the spy is identified or when the timer runs out. Scoring is based on whether the non-spy players identify the spy or if the spy successfully guesses the location. You can play multiple rounds, with the player accumulating the most points winning the game. Spyfall is a game of deception, observation, and deduction, making it a fun and engaging party game for groups of friends or family.
              ''';
}

/// A widget for displaying rich text paragraphs with custom styling.
///
/// The [RichTextParagraph] class is a [StatelessWidget] that displays a
/// paragraph of text with custom styling. It is particularly useful when you
/// need to display text with different text styles within the same paragraph.
///
/// [text]: The text to be displayed in the paragraph.
///
/// Example usage:
/// ```dart
/// RichTextParagraph(
///   text: 'This is a rich-text paragraph with custom styling.',
/// )
/// ```
///
/// This class simplifies the rendering of rich text in your application by
/// allowing you to define custom text styles for specific portions of the text.
class RichTextParagraph extends StatelessWidget {
  const RichTextParagraph({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) => RichText(
        text: TextSpan(
          style: DefaultTextStyle.of(context).style,
          children: <TextSpan>[
            TextSpan(
              text: text,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
}
