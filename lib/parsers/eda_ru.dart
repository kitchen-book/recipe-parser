import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:beautiful_soup_dart/beautiful_soup.dart';
import 'package:http/http.dart' as http;

import '../models/ingredient.dart';
import '../models/recipe.dart';
import '../utils.dart';

class EdaRuParser {
  final String link;

  EdaRuParser({required this.link});

  Future<ParseResult> parseRecipe() async {
    final response = await http.get(
      Uri.parse(link),
    );
    if (response.statusCode != 200) {
      return ParseResult(error: 'Failed request with response status code ${response.statusCode}');
    }

    final soup = BeautifulSoup(
      utf8.decode(response.bodyBytes),
    );

    final image = soup
        .find('img', attrs: {'alt': 'Изображение материала'})
        ?.attributes['src']
        ?.replaceAll('c88x88', '900x-');

    final title = soup.find('h1', class_: 'emotion-gl52ge')?.text;

    final time = soup.find('div', class_: 'emotion-my9yfq')?.text;

    final calories = int.tryParse(soup.find('span', attrs: {'itemprop': 'calories'})?.text ?? '');

    final description = soup.find('span', class_: 'emotion-1x1q7i2')?.text;

    final portions = int.tryParse(
        soup.find('span', attrs: {'itemprop': 'recipeYield'})?.text ?? '');

    final ingredientsName = soup
        .findAll('span', attrs: {'itemprop': 'recipeIngredient'})
        .map((ingredient) => ingredient.text)
        .toList();

    final numberOfIngredient = soup
        .findAll('span', class_: 'emotion-15im4d2')
        .map((number) => number.text)
        .toList();

    List<Ingredient> ingredients = [];
    for (var pair in IterableZip([ingredientsName, numberOfIngredient])) {
      ingredients.add(
        _createIngredient(pair[0], pair[1]),
      );
    }

    final steps = soup
        .findAll('span', attrs: {'itemprop': 'text'})
        .map((step) => step.text)
        .toList();


    return ParseResult(
      recipe: Recipe(
        images: image != null ? [image] : [],
        title: title ?? '',
        time: Utils.convertTime(time ?? ''),
        calories: calories ?? 0,
        description: description ?? '',
        link: link,
        portions: portions ?? 0,
        ingredients: ingredients,
        steps: steps,
      )
    );
  }

  Ingredient _createIngredient(String ingredient, String rawNumber) {
    final listNumber = rawNumber.split(' ');
    final number = double.tryParse(listNumber.first);
    if (number == null) {
      final unit = _getUnit(rawNumber);
      return Ingredient(ingredient: ingredient, unit: unit);
    }
    final unit = _getUnit(listNumber.sublist(1).join(' '));
    return Ingredient(
      ingredient: ingredient,
      number: number,
      unit: unit,
    );
  }

  String _getUnit(String parsedUnit) {
    if (Utils.units.contains(parsedUnit)) {
      return parsedUnit;
    }
    if (parsedUnit.contains('столов')) {
      return 'ст.л';
    }
    if (parsedUnit.contains('чайн')){
      return 'ч.л';
    }
    return 'шт';
  }
}
