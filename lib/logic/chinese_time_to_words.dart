import 'package:wordclock/logic/time_to_words.dart';

class ChineseSimplifiedTimeToWords implements TimeToWords {
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

    String hStr = switch (h) {
      0 => '午夜 十二点', // Midnight
      12 => '下午 十二点', // Noon (Prefix Afternoon as per 12:00 failure)
      1 => '上午 一点', // 1 AM
      2 => '上午 二点', // 2 AM
      3 => '上午 三点', // 3 AM
      4 => '上午 四点', // 4 AM
      5 => '上午 五点', // 5 AM
      6 => '上午 六点', // 6 AM
      7 => '上午 七点', // 7 AM
      8 => '上午 八点', // 8 AM
      9 => '上午 九点', // 9 AM
      10 => '上午 十点', // 10 AM
      11 => '上午 十一点', // 11 AM
      13 => '下午 一点', // 1 PM
      14 => '下午 二点', // 2 PM
      15 => '下午 三点', // 3 PM
      16 => '下午 四点', // 4 PM
      17 => '下午 五点', // 5 PM
      18 => '下午 六点', // 6 PM
      19 => '下午 七点', // 7 PM
      20 => '下午 八点', // 8 PM
      21 => '下午 九点', // 9 PM
      22 => '下午 十点', // 10 PM
      23 => '下午 十一点', // 11 PM
      _ => '',
    };
    // Fallback to %12 if needed (engine logic)
    if (hStr.isEmpty) {
      hStr = switch (h % 12) {
        0 => '十二点',
        1 => '一点',
        2 => '两点',
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
    }

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
    final List<int> splitHours = [2, 4, 6, 10];
    final separator = (m == 30 && !splitHours.contains(h % 12)) ? '' : ' ';
    return '$intro $hStr$separator$mStr'.trim().replaceAll('  ', ' ');
  }
}

class ChineseTraditionalTimeToWords implements TimeToWords {
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

    String hStr = switch (h) {
      0 => '午夜 十二點', // Midnight
      12 => '下午 十二點', // Noon
      1 => '上午 一點',
      2 => '上午 二點',
      3 => '上午 三點',
      4 => '上午 四點',
      5 => '上午 五點',
      6 => '上午 六點',
      7 => '上午 七點',
      8 => '上午 八點',
      9 => '上午 九點',
      10 => '上午 十點',
      11 => '上午 十一點',
      13 => '下午 一點',
      14 => '下午 二點',
      15 => '下午 三點',
      16 => '下午 四點',
      17 => '下午 五點',
      18 => '下午 六點',
      19 => '下午 七點',
      20 => '下午 八點',
      21 => '下午 九點',
      22 => '下午 十點',
      23 => '下午 十一點',
      _ => '',
    };
    if (hStr.isEmpty) {
      hStr = switch (h % 12) {
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
    }

    // Fix for 00:xx (h=0) normal case: needs '午夜 十二點' to match conditional/scriptable style?
    if (h == 0) hStr = '午夜 十二點';

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
