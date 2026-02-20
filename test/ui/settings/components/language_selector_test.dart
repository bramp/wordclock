import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wordclock/ui/settings/components/language_selector.dart';

void main() {
  testWidgets('LanguageSelector displays label and secondary label correctly', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LanguageSelector<String>(
            currentSelection: 'A',
            availableOptions: const ['A', 'B'],
            onSelected: (_) {},
            labelBuilder: (val) => 'Label $val',
            secondaryLabelBuilder: (val) => val == 'A' ? 'Secondary A' : null,
          ),
        ),
      ),
    );

    // Verify main label is displayed
    expect(
      find.byWidgetPredicate((widget) {
        if (widget is! RichText) return false;
        return widget.text.toPlainText().contains('Label A');
      }),
      findsOneWidget,
    );

    // Verify secondary label is displayed
    expect(
      find.byWidgetPredicate((widget) {
        if (widget is! RichText) return false;
        return widget.text.toPlainText().contains('Secondary A');
      }),
      findsOneWidget,
    );

    // Verify 'Label B' is not visible yet
    expect(find.text('Label B'), findsNothing);
  });

  testWidgets('LanguageSelector applies styles correctly', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LanguageSelector<String>(
            currentSelection: 'A',
            availableOptions: const ['A'],
            onSelected: (_) {},
            labelBuilder: (val) => 'Main',
            secondaryLabelBuilder: (val) => 'Secondary',
            styleBuilder: (val) => const TextStyle(color: Colors.red),
          ),
        ),
      ),
    );

    // Find the specific RichText widget we are interested in
    final richTextFinder = find.byWidgetPredicate((widget) {
      if (widget is! RichText) return false;
      final text = widget.text.toPlainText();
      return text.contains('Main') && text.contains('Secondary');
    });
    expect(richTextFinder, findsOneWidget);

    final richText = tester.widget<RichText>(richTextFinder);
    final textSpan = richText.text as TextSpan;

    // Check children structure
    // We expect: [TextSpan('Main', style: red), TextSpan(' (Secondary)', style: Noto Sans)]
    expect(textSpan.children, hasLength(2));

    // Child 0: Main label
    final span0 = textSpan.children![0] as TextSpan;
    expect(span0.text, 'Main');
    expect(span0.style?.color, Colors.red);

    // Child 1: Secondary label
    final span1 = textSpan.children![1] as TextSpan;
    expect(span1.text, ' (Secondary)');
    expect(span1.style?.fontFamily, 'Noto Sans');
  });
}
