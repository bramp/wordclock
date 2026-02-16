import 'package:wordclock/logic/time_to_words.dart';

/// Quenya Elvish time telling.
///
/// Uses "Hour ar Minute" format.
/// Hours: 1-12 (Min, Atta, Nelde, Canta, Lempe, Enque, Otso, Toldo, Nerte, Quean, Minque, Yunque)
/// Minutes: 0-55 (5 minute steps).
///
/// Vocabulary based on Neo-Quenya reconstructions.
class QuenyaTimeToWords extends TimeToWords {
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
    // "LÚME" = Time/Hour.
    // L (Lambe) 
    // Ú (Long U) -> Long Carrier  + U-curl (Left Curl) 
    // M (Malta) 
    // E (Acute)  (over Malta)
    const lumeWord = '';

    buffer.write('$hourWord $lumeWord');

    if (minute != 0) {
      // "ar" = and (connecting hours and minutes)
      // a over short carrier , r (Ore) 
      const arWord = '';
      final minuteWord = _getMinuteNumber(minute);
      buffer.write(' $arWord $minuteWord');
    }

    return buffer.toString();
  }

  String _getNumber(int n) => switch (n) {
    1 => '', // MIN: Malta , Dot  (over Malta), Numen 
    2 =>
      '', // ATTA: ShortCarrier , ThreeDots , Tinco , BarUnder , ThreeDots 
    3 => '', // NELDE: Numen , Acute , Lambe , Ando , Acute 
    4 => '', // CANTA: Quesse , ThreeDots , Numen , Tinco , ThreeDots 
    5 => '', // LEMPE: Lambe , Acute , Malta , Parma , Acute 
    6 => '', // ENQUE: ShortCarrier , Acute , Numen , Qu , Acute 
    7 =>
      '', // OTSO: ShortCarrier , RightCurl , Tinco , Silme , RightCurl 
    8 => '', // TOLDO: Tinco , RightCurl , Lambe , Ando , RightCurl 
    9 => '', // NERTE: Numen , Acute , Ore , Tinco , Acute 
    10 => '', // QUËAN: Qu , Acute , ShortCarrier , ThreeDots , Numen 
    11 => '', // MINQUE: Malta , Dot , Numen , Qu , Acute 
    12 => '', // YUNQUE: Yanta , LeftCurl , Numen , Qu , Acute 
    _ => '',
  };

  String _getMinuteNumber(int n) {
    if (n < 10) return _getNumber(n);
    final lempe = _getNumber(5);
    const arWord = '';
    return switch (n) {
      10 => _getNumber(10), // QUËAN
      15 => '', // LEPENQUE (Lambe-e Parma-e Numen Qu-e)
      20 => '', // YUQUAIN (Yanta-u Qu-a-i)
      25 => ' $arWord $lempe',
      30 => '', // NELQUAIN
      35 => ' $arWord $lempe',
      40 => '', // CANQUAIN
      45 => ' $arWord $lempe',
      50 => '', // LEPENQUAIN
      55 => ' $arWord $lempe',
      _ => '',
    };
  }
}
