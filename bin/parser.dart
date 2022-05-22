import 'parsers/eda_ru.dart';
import 'model/recipe.dart';

const spaghettiLink =
    'https://eda.ru/recepty/pasta-picca/spagetti-karbonara-s-krasnym-lukom-17614';
const brownieLink =
    'https://eda.ru/recepty/vypechka-deserty/brauni-brownie-20955';

void main(List<String> arguments) async {
  final recipe = await EdaRuParser(link: spaghettiLink).parseRecipe();
  if (recipe is Recipe) {
    print(recipe.images);
    print(recipe.title);
    print(recipe.time);
    print(recipe.calories);
    print(recipe.description);
    print(recipe.link);
    print(recipe.portions);
    print(recipe.ingredients);
    print(recipe.steps);
  }
}

class Parser {
  final String link;
  
  Parser({required this.link});
  
  Future<ParseResult> parse() async {
    if (link.contains('eda.ru')) {
      return await EdaRuParser(link: link).parseRecipe();
    }
    return ParseError(error: 'We do not have parser for this site');
  }
}

