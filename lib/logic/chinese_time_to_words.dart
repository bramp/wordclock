import 'package:wordclock/logic/time_to_words.dart';

/// Base implementation for Chinese language.
abstract class _BaseChineseTimeToWords implements TimeToWords {
  final bool isTraditional;
  final bool isReference;

  const _BaseChineseTimeToWords({
    required this.isTraditional,
    required this.isReference,
  });

  String get point => isTraditional ? '點' : '点';
  String get two =>
      isTraditional ? (isReference ? '二' : '兩') : (isReference ? '二' : '两');
  String get zero => isTraditional ? '零' : '零';
  String get minute => isTraditional ? '分' : '分';
  String get half => isTraditional ? '半' : '半';
  String get whole => isTraditional ? '整' : '整';

  String getHour(int h) {
    h = h % 12;
    if (h == 0) h = 12;
    final name = switch (h) {
      1 => isTraditional ? '一' : '一',
      2 => two,
      3 => isTraditional ? '三' : '三',
      4 => isTraditional ? '四' : '四',
      5 => isTraditional ? '五' : '五',
      6 => isTraditional ? '六' : '六',
      7 => isTraditional ? '七' : '七',
      8 => isTraditional ? '八' : '八',
      9 => isTraditional ? '九' : '九',
      10 => isTraditional ? '十' : '十',
      11 => isTraditional ? '十一' : '十一',
      12 => isTraditional ? '十二' : '十二',
      _ => '',
    };
    return '$name$point';
  }

  String getPeriod(int h) {
    if (h == 0) return isTraditional ? '午夜' : '午夜';
    if (isReference) {
      return h < 12
          ? (isTraditional ? '上午' : '上午')
          : (isTraditional ? '下午' : '下午');
    }
    // Standard periods
    if (h == 12) return isTraditional ? '中午' : '中午';
    if (h < 6) return isTraditional ? '凌晨' : '凌晨';
    if (h < 12) return isTraditional ? '上午' : '上午';
    if (h < 18) return isTraditional ? '下午' : '下午';
    return isTraditional ? '晚上' : '晚上';
  }

  String getMinute(int m, int h) {
    if (m == 0) return isReference ? '' : whole;
    if (m == 5) return '$zero${isTraditional ? '五' : '五'}$minute';
    if (m == 30) {
      if (isReference) {
        // Reference uses alternating 'Half' / '30 minutes'
        return (h % 2 != 0 || h == 0 || h == 12)
            ? half
            : '${isTraditional ? '三十' : '三十'}$minute';
      }
      return half;
    }
    final tens = m ~/ 10;
    final units = m % 10;
    final tensStr = switch (tens) {
      1 => isTraditional ? '十' : '十',
      2 => isTraditional ? '二十' : '二十',
      3 => isTraditional ? '三十' : '三十',
      4 => isTraditional ? '四十' : '四十',
      5 => isTraditional ? '五十' : '五十',
      _ => '',
    };
    final unitsStr = units == 0
        ? ''
        : switch (units) {
            5 => isTraditional ? '五' : '五',
            _ => '',
          };
    return '$tensStr$unitsStr$minute';
  }

  @override
  String convert(DateTime time) {
    int m = (time.minute ~/ 5) * 5;
    int h = time.hour;

    final intro = isReference
        ? (isTraditional ? '現在 時間' : '现在 时间')
        : (isTraditional ? '現在是' : '现在是');

    if (isReference && h == 0) {
      // Reference midnight logic
      final mPhrase = switch (m) {
        0 => isTraditional ? '十二點' : '十二点',
        5 => isTraditional ? '十二點 零五分' : '十二点 零五分',
        10 => isTraditional ? '十二點 十分' : '十二点 十分',
        30 => isTraditional ? '十二點半' : '十二点半',
        _ => null,
      };
      if (mPhrase != null) {
        return '$intro ${isTraditional ? '午夜' : '午夜'} $mPhrase';
      }
    }

    if (!isReference && h == 0) {
      // Standard midnight logic
      String zeroHour = isTraditional ? '零點' : '零点';
      String mStr = getMinute(m, h);
      return '$intro $zeroHour $mStr'.replaceAll('  ', ' ').trim();
    }

    final period = getPeriod(h);
    final hStr = getHour(h);
    final mStr = getMinute(m, h);

    final List<int> splitHours = [2, 4, 6, 10];
    final separator = (isReference && m == 30 && !splitHours.contains(h % 12))
        ? ''
        : ' ';

    return '$intro $period $hStr$separator$mStr'.trim().replaceAll('  ', ' ');
  }
}

/// Chinese Simplified (CS) Reference implementation.
class ReferenceChineseSimplifiedTimeToWords extends _BaseChineseTimeToWords {
  const ReferenceChineseSimplifiedTimeToWords()
    : super(isTraditional: false, isReference: true);
}

/// Chinese Traditional (CT) Reference implementation.
class ReferenceChineseTraditionalTimeToWords extends _BaseChineseTimeToWords {
  const ReferenceChineseTraditionalTimeToWords()
    : super(isTraditional: true, isReference: true);
}

/// Chinese Simplified implementation.
class ChineseSimplifiedTimeToWords extends _BaseChineseTimeToWords {
  const ChineseSimplifiedTimeToWords()
    : super(isTraditional: false, isReference: false);
}

/// Chinese Traditional implementation.
class ChineseTraditionalTimeToWords extends _BaseChineseTimeToWords {
  const ChineseTraditionalTimeToWords()
    : super(isTraditional: true, isReference: false);
}
