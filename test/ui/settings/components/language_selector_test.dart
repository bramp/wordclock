import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wordclock/ui/settings/components/language_selector.dart';

class TestLanguage {
  final String name;
  final String? subtitle;
  final String? hiddenKeyword;

  const TestLanguage(this.name, {this.subtitle, this.hiddenKeyword});
}

void main() {
  const languages = [
    TestLanguage('English'),
    TestLanguage('Español', subtitle: 'Spanish'),
    TestLanguage('Deutsch', subtitle: 'German'),
    TestLanguage('日本語', hiddenKeyword: 'Japanese'),
  ];

  testWidgets('LanguageSelector displays options and supports search', (
    WidgetTester tester,
  ) async {
    TestLanguage? selected = languages[0];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return LanguageSelector<TestLanguage>(
                currentSelection: selected!,
                availableOptions: languages,
                labelBuilder: (l) => l.name,
                subtitleBuilder: (l) => l.subtitle,
                searchKeywordsBuilder: (l) => l.hiddenKeyword ?? '',
                onSelected: (l) {
                  setState(() {
                    selected = l;
                  });
                },
              );
            },
          ),
        ),
      ),
    );

    // Initial display
    expect(find.text('English'), findsOneWidget);

    // Open picker
    await tester.tap(find.byType(LanguageSelector<TestLanguage>));
    await tester.pumpAndSettle();

    // Verify list items
    expect(find.text('English'), findsWidgets);
    expect(find.widgetWithText(ListTile, 'Español'), findsOneWidget);
    // Subtitle check
    expect(find.text('Spanish'), findsOneWidget);

    // Search by name
    await tester.enterText(find.byType(TextField), 'deut');
    await tester.pumpAndSettle();
    expect(find.widgetWithText(ListTile, 'Deutsch'), findsOneWidget);
    // Previously visible items should be filtered out
    expect(find.widgetWithText(ListTile, 'English'), findsNothing);

    // Search by subtitle
    await tester.enterText(find.byType(TextField), 'span');
    await tester.pumpAndSettle();
    expect(find.widgetWithText(ListTile, 'Español'), findsOneWidget);

    // Search by hidden keyword
    await tester.enterText(find.byType(TextField), 'japan');
    await tester.pumpAndSettle();

    // Verify rich label construction: "日本語 (Japanese)"
    expect(find.widgetWithText(ListTile, '日本語 (Japanese)'), findsOneWidget);

    // Select item
    await tester.tap(find.widgetWithText(ListTile, '日本語 (Japanese)'));
    await tester.pumpAndSettle();

    // Verify selection updated
    expect(selected?.name, '日本語');
    expect(find.text('日本語'), findsOneWidget);
  });
}
