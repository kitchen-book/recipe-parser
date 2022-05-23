class Ingredient {
  final String ingredient;
  final double? number;
  final String unit;

  Ingredient({
    required this.ingredient,
    this.number,
    required this.unit,
  });

  @override
  String toString() {
    return '$ingredient $number $unit';
  }
}