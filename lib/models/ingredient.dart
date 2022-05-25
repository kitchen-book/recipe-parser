class Ingredient {
  final String title;
  final double? number;
  final String unit;

  Ingredient({
    required this.title,
    this.number,
    required this.unit,
  });

  @override
  String toString() {
    return '$title $number $unit';
  }
}