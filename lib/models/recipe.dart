import 'dart:typed_data';

import 'ingredient.dart';

class ParseResult {
  final String? error;
  final Recipe? recipe;

  ParseResult({this.error, this.recipe});
}

class Recipe {
  final List<Uint8List?> images;
  final String title;
  final int? time;
  final int? calories;
  final String? description;
  final String link;

  final int portions;
  final List<Ingredient?> ingredients;

  final List<String?> steps;

  Recipe({
    required this.images,
    required this.title,
    this.time,
    this.calories,
    this.description,
    required this.link,
    required this.portions,
    required this.ingredients,
    required this.steps,
  });

  @override
  String toString() {
    return title;
  }
}
