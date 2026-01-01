import 'package:flutter/material.dart';

class SeedSelector extends StatelessWidget {
  final int? value;
  final ValueChanged<int?> onChanged;

  const SeedSelector({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.remove, color: Colors.white),
            onPressed: () {
              final current = value ?? 0;
              onChanged(current - 1);
            },
          ),
          Expanded(
            child: InkWell(
              onTap: () async {
                final result = await showDialog<String>(
                  context: context,
                  builder: (c) {
                    final textController = TextEditingController(
                      text: value?.toString() ?? '',
                    );
                    return AlertDialog(
                      title: const Text('Enter Grid Seed'),
                      content: TextField(
                        controller: textController,
                        keyboardType: TextInputType.number,
                        autofocus: true,
                        decoration: const InputDecoration(
                          hintText: 'Leave empty for default',
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(c),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () =>
                              Navigator.pop(c, textController.text),
                          child: const Text('OK'),
                        ),
                      ],
                    );
                  },
                );
                if (result != null) {
                  if (result.isEmpty) {
                    onChanged(null);
                  } else {
                    final s = int.tryParse(result);
                    if (s != null) {
                      onChanged(s);
                    }
                  }
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                alignment: Alignment.center,
                child: Text(
                  value?.toString() ?? 'Default',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () {
              final current = value ?? 0;
              onChanged(current + 1);
            },
          ),
          Container(width: 1, height: 24, color: Colors.white24),
          IconButton(
            icon: const Icon(Icons.shuffle, color: Colors.orangeAccent),
            onPressed: () {
              onChanged(DateTime.now().millisecondsSinceEpoch);
            },
          ),
        ],
      ),
    );
  }
}
