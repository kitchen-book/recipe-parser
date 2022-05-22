import 'ingredient.dart';

class ParseResult {}

class ParseError extends ParseResult{
  final String error;

  ParseError({required this.error});
}

class Recipe extends ParseResult{
  final List<String>? images;
  final String title;
  final int? time;
  final int? calories;
  final String? description;
  final String link;

  final int portions;
  final List<Ingredient>? ingredients;

  final List<String>? steps;

  Recipe({
    this.images,
    required this.title,
    this.time,
    this.calories,
    this.description,
    required this.link,
    required this.portions,
    this.ingredients,
    this.steps,
  });

  @override
  String toString() {
    return title;
  }
}
