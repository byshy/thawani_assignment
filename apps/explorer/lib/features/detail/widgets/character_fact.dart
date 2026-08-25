import 'package:flutter/material.dart';

class CharacterFact extends StatelessWidget {
  const CharacterFact({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ListTile(title: Text(label), subtitle: Text(value));
  }
}
