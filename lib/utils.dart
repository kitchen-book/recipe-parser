class Utils {
  static List<String> units = [
    'кг',
    'г',
    'л',
    'дл',
    'мл',
    'ст',
    'ст.л',
    'д.л',
    'ч.л',
    'шт',
    'по вкусу',
  ];

  static int? convertTime(String rawTime) {
    try {
      int time = 0;
      List listTime = rawTime.split(' ');
      listTime.removeWhere((time) => time == '');
      if (rawTime.contains('час')) {
        final hours = int.parse(listTime.first);
        listTime = listTime.sublist(2);
        time += hours * 60;
      }
      if (rawTime.contains('мин')) {
        final minutes = int.parse(listTime.first);
        time += minutes;
      }

      return time.ceil();
    } catch (e) {
      return null;
    }
  }
}
