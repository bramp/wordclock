import 'package:flutter/material.dart';

class FontDebugger extends StatelessWidget {
  const FontDebugger({super.key});

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
                              style: TextStyle(
                                fontFamily: family,
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
