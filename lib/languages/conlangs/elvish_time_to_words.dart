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
    if (hour > 12) hour -= 12;
    if (hour == 0) hour = 12;

    final minute = time.minute;

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
    // 5-55
    if (n < 10) return _getNumber(n); // 5

    // PAE (10)
    final pae = _getNumber(10);
    if (n == 10) return pae;

    // LEBEN (5)
    final leben = _getNumber(5);

    // PAELEBEN (15) = PAE + LEBEN (compound? or separate?)
    // Usually combined as one word in phonetics but maybe visual separation is better?
    // Let's assume compound.
    // PAE: Parma, Yanta+A
    // LEBEN: Lambe, Umbar+E, Numen+E
    // Combined: Parma, Yanta+A, Lambe, Umbar+E, Numen+E
    final paeleben = '$pae$leben';
    if (n == 15) return paeleben;

    // TAPHAE (20)
    // TA: Tinco, Formen + A-mark ? (Ph starts next syl?)
    // PHAE: Formen, Yanta + A-mark
    // A on Ph?
    // TA-PHAE.
    // Tinco , Formen , ThreeDots , Yanta , ThreeDots 
    final taphae = '';
    if (n == 20) return taphae;

    if (n == 25) return '$taphae $leben';

    // NELPHAE (30)
    // NEL: Numen, Lambe + E-mark
    // PHAE: Formen, Yanta + A-mark
    // Numen , Lambe , Acute , Formen , Yanta , ThreeDots 
    final nelphae = '';
    if (n == 30) return nelphae;

    if (n == 35) return '$nelphae $leben';

    // CANAPHAE (40)
    // CAN: Quesse, Numen + A-mark
    // A: (from Cana) -> on Ph?
    // PHAE: Formen, Yanta+A
    // Quesse , Numen , ThreeDots , Formen , ThreeDots , Yanta , ThreeDots 
    final canaphae = '';
    if (n == 40) return canaphae;

    if (n == 45) return '$canaphae $leben';

    // LEPHAE (50)
    // LE: Lambe, Formen + E-mark
    // PHAE: Formen, Yanta + A-mark
    // Lambe \uE022, Formen \uE009, Acute \uE046, Yanta \uE02A, ThreeDots \uE040
    final lephae = '\uE022\uE009\uE046\uE02A\uE040';
    if (n == 50) return lephae;

    if (n == 55) return '$lephae $leben';

    return '';
  }
}
