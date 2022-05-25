import 'package:parser/models/recipe.dart';

class ParseResult {
  final Error? error;
  final Recipe? recipe;

  ParseResult({this.error, this.recipe});
}

class Error {
  final String title;
  final String? content;

  Error({required this.title, this.content});
}