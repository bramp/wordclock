import 'package:flutter/material.dart';

import 'package:wordclock/ui/font_styles.dart';

class FontDebugger extends StatelessWidget {
  const FontDebugger({super.key});

  @override
  Widget build(BuildContext context) {
    final languageSamples = [
      (const Locale('en'), 'The quick brown fox jumps over the lazy dog.'),
      (const Locale('ta'), 'தமிழ் - பாவாணர்'),
      (const Locale('ja'), '日本語 - 漢字、ひらがな、カタカナ'),
      (const Locale('zh', 'Hans'), '简体中文 - 你好'),
      (const Locale('zh', 'Hant'), '繁體中文 - 你好'),
      (const Locale('tlh', 'pIqaD'), '   (Klingon Sample)'),
      (const Locale('sjn'), '  (Elvish Sample)'),
    ];

    final weights = [
      FontWeight.w100,
      FontWeight.w300,
      FontWeight.w400,
      FontWeight.w500,
      FontWeight.w700,
      FontWeight.w900,
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Font Debugger'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      backgroundColor: const Color(0xFF121212),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: languageSamples.length,
        itemBuilder: (context, index) {
          final locale = languageSamples[index].$1;
          final sample = languageSamples[index].$2;

          // Get the base style to find the family name
          final baseStyle = FontStyles.getStyleForLocale(locale);
          final familyName = baseStyle.fontFamily ?? 'Unknown Family';

          return Card(
            color: const Color(0xFF1E1E1E),
            margin: const EdgeInsets.only(bottom: 24),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '$familyName (${locale.toLanguageTag()})',
                        style: const TextStyle(
                          color: Colors.blueAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  const Divider(color: Colors.white24),
                  const SizedBox(height: 8),
                  for (final weight in weights)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 50,
                            child: Text(
                              weight.value.toString(),
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Builder(
                              builder: (context) {
                                final style = FontStyles.getStyleForLocale(
                                  locale,
                                  fontWeight: weight,
                                  color: Colors.white,
                                  fontSize: 20,
                                );

                                return Text(sample, style: style);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
