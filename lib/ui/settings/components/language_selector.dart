import 'package:flutter/material.dart';

/// A generic widget to select a language (or any item) from a list.
///
/// Displays the currently selected item and behaves like a button that opens
/// a modal bottom sheet with a searchable list of options.
class LanguageSelector<T> extends StatelessWidget {
  /// The currently selected item.
  final T currentSelection;

  /// The list of items to choose from.
  final List<T> availableOptions;

  /// Callback when an item is selected.
  final void Function(T) onSelected;

  /// Returns the main display label for an item.
  final String Function(T) labelBuilder;

  /// Returns an optional subtitle for an item description.
  final String? Function(T)? subtitleBuilder;

  /// Returns a secondary label to display alongside the main label (e.g. English name).
  /// This label is NOT styled by [styleBuilder], ensuring it remains readable.
  final String? Function(T)? secondaryLabelBuilder;

  final String Function(T)? searchKeywordsBuilder;

  /// Returns a specific [TextStyle] for an item (e.g. to use a specific font).
  final TextStyle? Function(T)? styleBuilder;

  /// Icon to display in the selector button.
  final IconData icon;

  /// Prefix for the accessibility label.
  final String? semanticsLabelPrefix;

  const LanguageSelector({
    super.key,
    required this.currentSelection,
    required this.availableOptions,
    required this.onSelected,
    required this.labelBuilder,
    this.subtitleBuilder,
    this.secondaryLabelBuilder,
    this.searchKeywordsBuilder,
    this.styleBuilder,
    this.icon = Icons.language,
    this.semanticsLabelPrefix,
  });

  @override
  Widget build(BuildContext context) {
    final displayName = labelBuilder(currentSelection);
    final description = subtitleBuilder?.call(currentSelection);
    final secondaryLabel = secondaryLabelBuilder?.call(currentSelection);

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
                    _LanguageItemTitle(
                      label: displayName,
                      secondaryLabel: secondaryLabel,
                      isSelected: false,
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
          secondaryLabelBuilder: secondaryLabelBuilder,
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

  final String Function(T) labelBuilder;
  final String? Function(T)? subtitleBuilder;
  final String? Function(T)? secondaryLabelBuilder;
  final String Function(T)? searchKeywordsBuilder;
  final void Function(T) onSelected;
  final TextStyle? Function(T)? styleBuilder;

  const _LanguagePickerSheet({
    required this.currentSelection,
    required this.availableOptions,
    required this.labelBuilder,
    required this.onSelected,
    this.subtitleBuilder,
    this.secondaryLabelBuilder,
    this.searchKeywordsBuilder,
    this.styleBuilder,
  });

  @override
  State<_LanguagePickerSheet<T>> createState() =>
      _LanguagePickerSheetState<T>();
}

class _LanguagePickerSheetState<T> extends State<_LanguagePickerSheet<T>> {
  String _searchQuery = '';

  List<T> _getFilteredItems() {
    return widget.availableOptions.where((item) {
      if (_searchQuery.isEmpty) return true;
      final query = _searchQuery.toLowerCase();
      final label = widget.labelBuilder(item).toLowerCase();
      final subtitle = widget.subtitleBuilder?.call(item)?.toLowerCase() ?? '';
      final secondary =
          widget.secondaryLabelBuilder?.call(item)?.toLowerCase() ?? '';
      final keywords =
          widget.searchKeywordsBuilder?.call(item).toLowerCase() ?? '';

      return label.contains(query) ||
          subtitle.contains(query) ||
          secondary.contains(query) ||
          keywords.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredItems = _getFilteredItems();

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            _PickerHeader(
              onSearchChanged: (value) => setState(() => _searchQuery = value),
            ),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: filteredItems.length,
                itemBuilder: (context, index) =>
                    _buildListItem(context, filteredItems[index]),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildListItem(BuildContext context, T item) {
    final isSelected = item == widget.currentSelection;
    final label = widget.labelBuilder(item);
    final subtitle = widget.subtitleBuilder?.call(item);
    final secondaryLabel = widget.secondaryLabelBuilder?.call(item);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      title: _LanguageItemTitle(
        label: label,
        secondaryLabel: secondaryLabel,
        isSelected: isSelected,
        style: widget.styleBuilder?.call(item),
      ),
      subtitle: subtitle != null
          ? Text(subtitle, style: Theme.of(context).textTheme.bodySmall)
          : null,
      trailing: isSelected
          ? const Icon(Icons.check, color: Colors.blueAccent)
          : null,
      onTap: () {
        widget.onSelected(item);
        Navigator.pop(context);
      },
    );
  }
}

/// Displays the language title, potentially split into two parts with different fonts.
///
/// This is crucial for Conlangs (like Aurebesh) where the [label] is rendered in
/// a custom, potentially unreadable font, while the [secondaryLabel] (e.g., English name)
/// is rendered in a standard readable font (Noto Sans).
class _LanguageItemTitle extends StatelessWidget {
  final String label;
  final String? secondaryLabel;
  final bool isSelected;
  final TextStyle? style;

  const _LanguageItemTitle({
    required this.label,
    required this.isSelected,
    this.secondaryLabel,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: DefaultTextStyle.of(context).style.copyWith(
          color: isSelected ? Colors.blueAccent : null,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        children: [
          TextSpan(text: label, style: style),
          if (secondaryLabel != null)
            TextSpan(
              text: ' ($secondaryLabel)',
              style: const TextStyle(fontFamily: 'Noto Sans'),
            ),
        ],
      ),
    );
  }
}

class _PickerHeader extends StatelessWidget {
  final ValueChanged<String> onSearchChanged;

  const _PickerHeader({required this.onSearchChanged});

  @override
  Widget build(BuildContext context) {
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
            onChanged: onSearchChanged,
          ),
        ),
      ],
    );
  }
}
