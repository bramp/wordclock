import 'package:wordclock/logic/time_to_words.dart';

class ReferenceChineseSimplifiedTimeToWords implements TimeToWords {
  const ReferenceChineseSimplifiedTimeToWords();
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

class ReferenceChineseTraditionalTimeToWords implements TimeToWords {
  const ReferenceChineseTraditionalTimeToWords();
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

/// Chinese Simplified implementation that differs from [ReferenceChineseSimplifiedTimeToWords] by:
/// - Using "现在是" (Now is) instead of "现在 时间" (Now time) as intro.
/// - Using more natural period markers: "凌晨" (0-6), "上午" (6-12), "中午" (12), "下午" (12-18), "晚上" (18-24).
/// - Using "零点" for midnight (0:xx) instead of "午夜 十二点".
/// - Consistently using "半" for 30 minutes.
/// - Using "两点" instead of "二点" for 2 o'clock.
class ChineseSimplifiedTimeToWords
    extends ReferenceChineseSimplifiedTimeToWords {
  const ChineseSimplifiedTimeToWords();

  @override
  String convert(DateTime time) {
    int m = (time.minute ~/ 5) * 5;
    int h = time.hour;

    String intro = '现在是';

    String period = '';
    if (h == 0) {
      // Midnight is special
      String mStr = _minutes(m);
      return '$intro 零点 $mStr'.replaceAll('  ', ' ').trim();
    } else if (h == 12) {
      period = '中午';
    } else if (h < 12) {
      if (h < 6)
        period = '凌晨';
      else
        period = '上午';
    } else {
      if (h < 18)
        period = '下午';
      else
        period = '晚上';
    }

    String hStr = _hours(h % 12 == 0 ? 12 : h % 12);
    String mStr = _minutes(m);

    return '$intro $period $hStr $mStr'.replaceAll('  ', ' ').trim();
  }

  String _hours(int h) {
    return switch (h) {
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
      12 => '十二点',
      _ => '',
    };
  }

  String _minutes(int m) {
    return switch (m) {
      0 => '整',
      5 => '零五分',
      10 => '十分',
      15 => '十五分',
      20 => '二十分',
      25 => '二十五分',
      30 => '半',
      35 => '三十五分',
      40 => '四十分',
      45 => '四十五分',
      50 => '五十分',
      55 => '五十五分',
      _ => '',
    };
  }
}

/// Chinese Traditional implementation that differs from [ReferenceChineseTraditionalTimeToWords] by:
/// - Using "現在是" (Now is) instead of "現在 時間" (Now time) as intro.
/// - Using more natural period markers: "凌晨" (0-6), "上午" (6-12), "中午" (12), "下午" (12-18), "晚上" (18-24).
/// - Using "零點" for midnight (0:xx) instead of "午夜 十二點".
/// - Consistently using "半" for 30 minutes.
/// - Using "兩點" instead of "二點" for 2 o'clock.
class ChineseTraditionalTimeToWords
    extends ReferenceChineseTraditionalTimeToWords {
  const ChineseTraditionalTimeToWords();

  @override
  String convert(DateTime time) {
    int m = (time.minute ~/ 5) * 5;
    int h = time.hour;

    String intro = '現在是';

    String period = '';
    if (h == 0) {
      // Midnight is special
      String mStr = _minutes(m);
      return '$intro 零點 $mStr'.replaceAll('  ', ' ').trim();
    } else if (h == 12) {
      period = '中午';
    } else if (h < 12) {
      if (h < 6)
        period = '凌晨';
      else
        period = '上午';
    } else {
      if (h < 18)
        period = '下午';
      else
        period = '晚上';
    }

    String hStr = _hours(h % 12 == 0 ? 12 : h % 12);
    String mStr = _minutes(m);

    return '$intro $period $hStr $mStr'.replaceAll('  ', ' ').trim();
  }

  String _hours(int h) {
    return switch (h) {
      1 => '一點',
      2 => '兩點',
      3 => '三點',
      4 => '四點',
      5 => '五點',
      6 => '六點',
      7 => '七點',
      8 => '八點',
      9 => '九點',
      10 => '十點',
      11 => '十一點',
      12 => '十二點',
      _ => '',
    };
  }

  String _minutes(int m) {
    return switch (m) {
      0 => '整',
      5 => '零五分',
      10 => '十分',
      15 => '十五分',
      20 => '二十分',
      25 => '二十五分',
      30 => '半',
      35 => '三十五分',
      40 => '四十分',
      45 => '四十五分',
      50 => '五十分',
      55 => '五十五分',
      _ => '',
    };
  }
}
