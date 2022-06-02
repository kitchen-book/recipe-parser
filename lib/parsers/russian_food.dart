import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:beautiful_soup_dart/beautiful_soup.dart';
import 'package:enough_convert/enough_convert.dart';
import 'package:http/http.dart';

import '../models/ingredient.dart';
import '../models/recipe.dart';
import '../utils.dart';

const codec = Windows1251Codec(allowInvalid: false);

class RussianFoodParser {
  final Response response;
  final String link;

  RussianFoodParser({
    required this.response,
    required this.link,
  });

  Future<Recipe> parseRecipe() async {
    final soup = BeautifulSoup(
      codec.decode(response.bodyBytes),
    );

    final image = soup.find('a', class_: 'tozoom')?.attributes['href'];

    final uint8List = (image != null)
        ? await get(
            Uri.parse(image.contains('https:') ? image : 'https:' + image),
          ).then((value) => value.bodyBytes)
        : Uint8List.fromList([]);

    final title = soup.find('h1', class_: 'title')?.text;

    final subInfo = soup.findAll('span', class_: 'hl');
    final time = (subInfo.length > 1) ? subInfo[1].text : '';

    final description = soup
        .find('td', class_: 'padding_l padding_r')
        ?.findAll('div')
        .last
        .text;

    final portions =
        (subInfo.isNotEmpty) ? int.tryParse(subInfo[0].text) : null;

    final ingredientsName = soup
        .findAll('td', class_: 'padding_l padding_r', attrs: {'colspan': '3'})
        .map(
          (ingredient) => ingredient.text
              .substring(
                  0,
                  (ingredient.text.contains('—')
                      ? ingredient.text.indexOf('—')
                      : ingredient.text.indexOf('-')))
              .trim(),
        )
        .toList();

    final numberOfIngredient = soup.findAll('td',
        class_: 'padding_l padding_r', attrs: {'colspan': '3'}).map(
      (ingredient) {
        final rawNumber =
            ingredient.text.substring(ingredient.text.indexOf('—') + 1);

        return (rawNumber.contains('('))
            ? rawNumber.substring(0, rawNumber.indexOf('(')).trim()
            : rawNumber.trim();
      },
    ).toList();

    List<Ingredient> ingredients = [];
    for (var pair in IterableZip([ingredientsName, numberOfIngredient])) {
      ingredients.add(
        _createIngredient(pair[0], pair[1]),
      );
    }

    final steps = soup
        .findAll('div', class_: 'step_n')
        .map((step) => step.find('p')?.text)
        .whereNotNull()
        .toList();

    return Recipe(
      images: [uint8List],
      title: title ?? '',
      time: Utils.convertTime(time) ?? 0,
      calories: null,
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
      number: number ?? 1,
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
    if (parsedUnit.contains('с. ложки')) {
      return 'ст.л';
    }
    if (parsedUnit.contains('ч. ложки')) {
      return 'ч.л';
    }
    return 'шт';
  }
}
