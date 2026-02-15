import 'package:wordclock/logic/time_to_words.dart';

/// Sindarin Elvish time telling.
///
/// Uses "Hour Minute" format.
/// Hours: 1-12 (Min, Tad, Neled, Canad, Leben, Eneg, Odo, Toloth, Neder, Pae, Minib, Imp)
/// Minutes: 0-55 (5 minute steps).
///
/// Vocabulary based on Neo-Sindarin reconstructions.
/// Reference: https://www.elfdict.com/
class ElvishTimeToWords extends TimeToWords {
  @override
  String convert(DateTime time) {
    int hour = time.hour;
    int minute = time.minute;

    // Round down to the nearest 5 minute increment
    minute = minute - (minute % 5);

    if (hour > 12) hour -= 12;
    if (hour == 0) hour = 12;

    final hourWord = _getNumber(hour);

    final buffer = StringBuffer();
    // "LÛ" = Time/Hour (Contextual).
    // Word: LÛ
    // L (Lambe) 
    // Û (Long U) -> Long Carrier  + U-curl (Left Curl) 
    const lWord = ''; // Lambe, Long Carrier, Left Curl

    buffer.write('$hourWord $lWord');

    if (minute != 0) {
      final minuteWord = _getMinuteNumber(minute);
      buffer.write(' $minuteWord');
    }

    return buffer.toString();
  }

  String _getNumber(int n) => switch (n) {
    1 => '', // MIN: Malta , Numen , Dot 
    2 => '', // TAD: Tinco , Ando , ThreeDots 
    3 => '', // NELED: Numen , Lambe , Acute , Ando , Acute 
    4 => '', // CANAD: Quesse , Numen , ThreeDots , Ando , ThreeDots 
    5 => '', // LEBEN: Lambe , Umbar , Acute , Numen , Acute 
    6 => '', // ENEG: Numen , Acute , Ungwe , Acute 
    7 => '', // ODO: Ando , RightCurl , ShortCarrier , RightCurl 
    8 => '', // TOLOTH: Tinco , Lambe , RightCurl , Sule , RightCurl 
    9 => '', // NEDER: Numen , Ando , Acute , Oore , Acute 
    10 => '', // PAE: Parma , Yanta , ThreeDots 
    11 => '', // MINIB: Malta , Numen , Dot , Umbar , Dot 
    12 => '', // IMP: Malta , Dot , Parma 
    _ => '',
  };

  String _getMinuteNumber(int n) {
    if (n < 10) return _getNumber(n);
    final leben = _getNumber(5);
    return switch (n) {
      10 => _getNumber(10), // PAE
      15 => '${_getNumber(10)}$leben', // PAELEBEN
      20 => '', // TAPHAE
      25 => ' $leben', // TAPHAE LEBEN
      30 => '', // NELPHAE
      35 => ' $leben', // NELPHAE LEBEN
      40 => '', // CANAPHAE
      45 => ' $leben', // CANAPHAE LEBEN
      50 => '', // LEPHAE
      55 => ' $leben', // LEPHAE LEBEN
      _ => '',
    };
  }
}
