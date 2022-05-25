import 'dart:convert';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:beautiful_soup_dart/beautiful_soup.dart';
import 'package:http/http.dart';

import '../models/ingredient.dart';
import '../models/recipe.dart';
import '../utils.dart';

class EdaRuParser {
  final Response response;
  final String link;

  EdaRuParser({
    required this.response,
    required this.link,
  });

  Future<Recipe> parseRecipe() async {
    final soup = BeautifulSoup(
      utf8.decode(response.bodyBytes),
    );

    final image = soup
        .find('img', attrs: {'alt': 'Изображение материала'})
        ?.attributes['src']
        ?.replaceAll('c88x88', '900x-');
    final uint8List = (image != null)
        ? await get(Uri.parse(image)).then((value) => value.bodyBytes)
        : Uint8List.fromList([]);

    final title = soup.find('h1', class_: 'emotion-gl52ge')?.text;

    final time = soup.find('div', class_: 'emotion-my9yfq')?.text;

    final calories = int.tryParse(
        soup.find('span', attrs: {'itemprop': 'calories'})?.text ?? '');

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

    return Recipe(
      images: [uint8List],
      title: title ?? '',
      time: Utils.convertTime(time ?? ''),
      calories: calories ?? 0,
      description: description ?? '',
      link: link,
      portions: portions ?? 0,
      ingredients: ingredients,
      steps: steps,
    );
  }

  Ingredient _createIngredient(String ingredient, String rawNumber) {
    final listNumber = rawNumber.split(' ');
    final number = double.tryParse(listNumber.first.replaceFirst(',', '.'));
    final unit = (number == null)
        ? _getUnit(rawNumber)
        : _getUnit(listNumber.sublist(1).join(' '));
    return Ingredient(
      title: ingredient,
      number: number,
      unit: unit,
    );
  }

  String _getUnit(String parsedUnit) {
    if (Utils.units.contains(parsedUnit)) {
      return parsedUnit;
    }
    if (parsedUnit.contains('щепот')) {
      return 'щепот.';
    }
    if (parsedUnit.contains('столов')) {
      return 'ст.л';
    }
    if (parsedUnit.contains('чайн')) {
      return 'ч.л';
    }
    return 'шт';
  }
}
