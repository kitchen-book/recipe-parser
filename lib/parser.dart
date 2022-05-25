library parser;

import 'dart:async';
import 'dart:io';

import 'parsers/eda_ru.dart';
import 'models/recipe.dart';
import 'package:http/http.dart' as http;

const spaghettiLink =
    'https://eda.ru/recepty/salaty/ostry-salat-iz-kvashenno-kapusty-s-chesnokom-152311';
const brownieLink =
    'https://eda.ru/recepty/vypechka-deserty/brauni-brownie-20955';

const availableSites = ['eda.ru'];

void main(List<String> arguments) async {
  const link = spaghettiLink;
  final result = await Parser(link: link).parse();
  if (result.recipe != null) {
    final recipe = result.recipe!;
    // print(recipe.images);
    print(recipe.title);
    print(recipe.time);
    print(recipe.calories);
    print(recipe.description);
    print(recipe.link);
    print(recipe.portions);
    print(recipe.ingredients);
    print(recipe.steps);
  } else {
    print(result.error);
  }
}

class Parser {
  final String link;

  Parser({required this.link});

  Future<ParseResult> parse() async {
    if (availableSites.any((site) => link.contains(site))) {
      try {
        final response =
            await http.get(Uri.parse(link));
        if (response.statusCode == 200) {
          if (link.contains('eda.ru')) {
            return ParseResult(
              recipe: await EdaRuParser(
                response: response,
                link: link,
              ).parseRecipe(),
            );
          }
        } else {
          return ParseResult(
              error: 'Невозможно получить данные.\nПопробуйте позже.');
        }
      } on TimeoutException catch (_) {
        return ParseResult(
            error: 'Истекло время ожидания сайта.\nПопробуйте позже.');
      } on SocketException catch (_) {
        return ParseResult(
            error:
                'Для загрузки рецепта нужен интернет.\nВключите его в настройках.');
      } catch (_) {
        return ParseResult(error: 'Что-то пошло не так.\nПопробуйте позже.');
      }
    }
    return ParseResult(error: 'У нас нет парсера для этого сайта.');
  }
}
