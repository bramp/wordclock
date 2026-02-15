import 'package:flutter/material.dart';

import 'package:wordclock/ui/font_styles.dart';

class FontDebugger extends StatelessWidget {
  const FontDebugger({super.key});

  /// Quick map for the debugger
  String _familyToLangCode(String family) {
    if (family.contains('Tamil')) return 'ta';
    if (family.contains('JP')) return 'ja';
    if (family.contains('SC')) return 'zh-Hans';
    if (family.contains('TC')) return 'zh-Hant';
    if (family.contains('Piqad')) {
      return 'tlh-pIqaD'; // Custom tag for Klingon pIqaD
    }
    if (family.contains('Tengwar')) return 'sjn';
    return 'en';
  }

  @override
  Widget build(BuildContext context) {
    final families = [
      ('Noto Sans', 'The quick brown fox jumps over the lazy dog.'),
      ('Noto Sans Tamil', 'தமிழ் - பாவாணர்'),
      ('Noto Sans JP', '日本語 - 漢字、ひらがな、カタカナ'),
      ('Noto Sans SC', '简体中文 - 你好'),
      ('Noto Sans TC', '繁體中文 - 你好'),
      ('KlingonPiqad', '   (Klingon Sample)'),
      ('AlcarinTengwar', '  (Elvish Sample)'),
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
        itemCount: families.length,
        itemBuilder: (context, index) {
          final family = families[index].$1;
          final sample = families[index].$2;

          return Card(
            color: const Color(0xFF1E1E1E),
            margin: const EdgeInsets.only(bottom: 24),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    family,
                    style: const TextStyle(
                      color: Colors.blueAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
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
                            child: Text(
                              sample,
                              style: FontStyles.getStyleForLanguage(
                                // Map display name back to language code if possible, or just family
                                // Here we cheat and map family to likely code for the sake of the debugger
                                _familyToLangCode(family),
                                fontWeight: weight,
                                color: Colors.white,
                                fontSize: 20,
                              ),
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
