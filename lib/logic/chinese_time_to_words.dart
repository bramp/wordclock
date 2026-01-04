import 'package:wordclock/logic/time_to_words.dart';

class ChineseSimplifiedTimeToWords implements TimeToWords {
  const ChineseSimplifiedTimeToWords();
  @override
  String convert(DateTime time) {
    int m = (time.minute ~/ 5) * 5;
    int h = time.hour;

    // CS intro is '现在 时间' (Now Time)
    final intro = '现在 时间';

    // 1. Conditionals (Midnight/Noon)
    String? conditional = switch (h) {
      0 => switch (m) {
        0 => '午夜 十二点', // midnight 12:00
        5 => '午夜 十二点 零五分', // midnight 12:05
        10 => '午夜 十二点 十分', // midnight 12:10
        30 => '午夜 十二点半', // midnight 12:30 (Half)
        _ => null,
      },
      _ => null,
    };
    if (conditional != null) return '$intro $conditional';

    String period = switch (h) {
      0 => '午夜',
      < 12 => '上午',
      _ => '下午',
    };

    String hStr = switch (h % 12) {
      0 => '十二点',
      1 => '一点',
      2 => '二点',
      3 => '三点',
      4 => '四点',
      5 => '五点',
      6 => '六点',
      7 => '七点',
      8 => '八点',
      9 => '九点',
      10 => '十点',
      11 => '十一点',
      _ => '',
    };
    hStr = '$period $hStr';

    String mStr = switch (m) {
      0 => '',
      5 => '零五分', // 05 minutes
      10 => '十分', // 10 minutes
      15 => '十五分', // 15 minutes
      20 => '二十分', // 20 minutes
      25 => '二十五分', // 25 minutes
      30 =>
        (h % 2 != 0 || h == 0 || h == 12)
            ? '半'
            : '三十分', // 30 minutes (Alternating)
      35 => '三十五分', // 35 minutes
      40 => '四十分', // 40 minutes
      45 => '四十五分', // 45 minutes
      50 => '五十分', // 50 minutes
      55 => '五十五分', // 55 minutes
      _ => '',
    };

    // Engine order is Intro -> Exact -> Delta
    // Hours 2, 4, 6, 10 are split in grid/conditionals -> Space. Others merged -> No Space.
    // TODO This seems odd, we should double check this is actualy needed.
    final List<int> splitHours = [2, 4, 6, 10];
    final separator = (m == 30 && !splitHours.contains(h % 12)) ? '' : ' ';
    return '$intro $hStr$separator$mStr'.trim().replaceAll('  ', ' ');
  }
}

class ChineseTraditionalTimeToWords implements TimeToWords {
  const ChineseTraditionalTimeToWords();
  @override
  String convert(DateTime time) {
    int m = (time.minute ~/ 5) * 5;
    int h = time.hour;

    // 1. Conditionals
    String? conditional = switch (h) {
      0 => switch (m) {
        0 => '午夜 十二點', // midnight 12:00
        30 => '午夜 十二點半', // midnight 12:30
        _ => null,
      },
      _ => null,
    };
    if (conditional != null) return '現在 時間 $conditional';

    String period = switch (h) {
      0 => '午夜',
      < 12 => '上午',
      _ => '下午',
    };

    String hStr = switch (h % 12) {
      0 => '十二點',
      1 => '一點',
      2 => '二點',
      3 => '三點',
      4 => '四點',
      5 => '五點',
      6 => '六點',
      7 => '七點',
      8 => '八點',
      9 => '九點',
      10 => '十點',
      11 => '十一點',
      _ => '',
    };
    hStr = '$period $hStr';

    String mStr = switch (m) {
      0 => '',
      5 => '零五分', // 05 minutes
      10 => '十分', // 10 minutes
      15 => '十五分', // 15 minutes
      20 => '二十分', // 20 minutes
      25 => '二十五分', // 25 minutes
      30 =>
        (h % 2 != 0 || h == 0 || h == 12)
            ? '半'
            : '三十分', // 30 minutes (Alternating)
      35 => '三十五分', // 35 minutes
      40 => '四十分', // 40 minutes
      45 => '四十五分', // 45 minutes
      50 => '五十分', // 50 minutes
      55 => '五十五分', // 55 minutes
      _ => '',
    };

    // For 'Half' (30) using character 'Half', no space. For '30 minutes', space?
    // Hours 2, 4, 6, 10 are split in grid/conditionals -> Space. Others merged -> No Space.
    final List<int> splitHours = [2, 4, 6, 10];
    final separator = (m == 30 && !splitHours.contains(h % 12)) ? '' : ' ';
    return '現在 時間 $hStr$separator$mStr'.trim().replaceAll('  ', ' ');
  }
}
