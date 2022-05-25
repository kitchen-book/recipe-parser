import 'package:parser/models/parse_error.dart';
import 'package:parser/models/recipe.dart';

class ParseResult {
  final ParseError? error;
  final Recipe? recipe;

  ParseResult({this.error, this.recipe});
}