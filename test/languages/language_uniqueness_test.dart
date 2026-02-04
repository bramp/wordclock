import 'package:flutter_test/flutter_test.dart';
import 'package:wordclock/languages/all.dart';

void main() {
  test('All languages have unique languageCode', () {
    final languageCodes = <String>{};
    for (final language in WordClockLanguages.all) {
      final isUnique = languageCodes.add(language.languageCode);
      expect(
        isUnique,
        isTrue,
        reason:
            'Duplicate languageCode found: ${language.languageCode} in ${language.id}',
      );
    }
  });
}
