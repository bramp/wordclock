import 'package:flutter/material.dart';

/// A generic widget to select a language (or any item) from a list.
///
/// Displays the currently selected item and behaves like a button that opens
/// a modal bottom sheet with a searchable list of options.
class LanguageSelector<T> extends StatelessWidget {
  final T currentSelection;
  final List<T> availableOptions;
  final String Function(T) labelBuilder;
  final String? Function(T)? subtitleBuilder;
  final String Function(T)? searchKeywordsBuilder;
  final void Function(T) onSelected;
  final IconData icon;
  final String? semanticsLabelPrefix;
  final TextStyle? Function(T)? styleBuilder;

  const LanguageSelector({
    super.key,
    required this.currentSelection,
    required this.availableOptions,
    required this.labelBuilder,
    required this.onSelected,
    this.subtitleBuilder,
    this.searchKeywordsBuilder,
    this.icon = Icons.language,
    this.semanticsLabelPrefix,
    this.styleBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final displayName = labelBuilder(currentSelection);
    final description = subtitleBuilder?.call(currentSelection);

    return Semantics(
      label: semanticsLabelPrefix != null
          ? '$semanticsLabelPrefix: Change $displayName language'
          : 'Change $displayName language',
      button: true,
      hint: 'Opens a language selection menu',
      excludeSemantics: true,
      child: InkWell(
        onTap: () => _showLanguagePicker(context),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.white70, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ).merge(styleBuilder?.call(currentSelection)),
                    ),
                    if (description != null)
                      Text(
                        description,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                  ],
                ),
              ),
              Icon(
                Icons.keyboard_arrow_down,
                color: Colors.white.withValues(alpha: 0.3),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLanguagePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return _LanguagePickerSheet<T>(
          currentSelection: currentSelection,
          availableOptions: availableOptions,
          labelBuilder: labelBuilder,
          subtitleBuilder: subtitleBuilder,
          searchKeywordsBuilder: searchKeywordsBuilder,
          onSelected: onSelected,
          styleBuilder: styleBuilder,
        );
      },
    );
  }
}

class _LanguagePickerSheet<T> extends StatefulWidget {
  final T currentSelection;
  final List<T> availableOptions;

  // TODO We have a lot of builders here. Is it better to have a single builder,
  // that returns the widget for the row?
  final String Function(T) labelBuilder;
  final String? Function(T)? subtitleBuilder;
  final String Function(T)? searchKeywordsBuilder;
  final void Function(T) onSelected;
  final TextStyle? Function(T)? styleBuilder;

  const _LanguagePickerSheet({
    required this.currentSelection,
    required this.availableOptions,
    required this.labelBuilder,
    required this.onSelected,
    this.subtitleBuilder,
    this.searchKeywordsBuilder,
    this.styleBuilder,
  });

  @override
  State<_LanguagePickerSheet<T>> createState() =>
      _LanguagePickerSheetState<T>();
}

class _LanguagePickerSheetState<T> extends State<_LanguagePickerSheet<T>> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final filteredItems = widget.availableOptions.where((item) {
      if (_searchQuery.isEmpty) return true;
      final query = _searchQuery.toLowerCase();
      final label = widget.labelBuilder(item).toLowerCase();
      final subtitle = widget.subtitleBuilder?.call(item)?.toLowerCase() ?? '';
      final keywords =
          widget.searchKeywordsBuilder?.call(item).toLowerCase() ?? '';

      return label.contains(query) ||
          subtitle.contains(query) ||
          keywords.contains(query);
    }).toList();

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Search...',
                  hintStyle: const TextStyle(color: Colors.white24),
                  prefixIcon: const Icon(Icons.search, color: Colors.white54),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.05),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: filteredItems.length,
                itemBuilder: (context, index) {
                  final item = filteredItems[index];
                  final isSelected = item == widget.currentSelection;
                  final label = widget.labelBuilder(item);
                  final subtitle = widget.subtitleBuilder?.call(item);
                  final keywords = widget.searchKeywordsBuilder?.call(item);

                  // Construct a rich label if keywords are available and distinct
                  // (e.g. "日本語 (Japanese)")
                  final displayLabel =
                      (keywords != null &&
                          keywords.isNotEmpty &&
                          keywords != label)
                      ? '$label ($keywords)'
                      : label;

                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 4,
                    ),
                    title: Text(
                      displayLabel,
                      style: TextStyle(
                        color: isSelected ? Colors.blueAccent : null,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ).merge(widget.styleBuilder?.call(item)),
                    ),
                    subtitle: subtitle != null
                        ? Text(
                            subtitle,
                            style: Theme.of(context).textTheme.bodySmall,
                          )
                        : null,
                    trailing: isSelected
                        ? const Icon(Icons.check, color: Colors.blueAccent)
                        : null,
                    onTap: () {
                      widget.onSelected(item);
                      // Depending on implementation, parent might pop or we pop here
                      // Usually picker implies selection and close
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
