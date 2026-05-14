import 'package:flutter/material.dart';

class PreferencesEditor extends StatelessWidget {
  final List<String> allStyles;
  final List<String> preferredStyles;
  final List<String> avoidOptions;
  final List<String> avoidSubcategories;

  final List<String> fitOptions;
  final List<String> bodyShapeOptions;

  final String preferredFit;
  final String bodyShape;

  final ValueChanged<List<String>> onStylesChanged;
  final ValueChanged<List<String>> onAvoidChanged;
  final ValueChanged<String> onFitChanged;
  final ValueChanged<String> onBodyShapeChanged;
  final VoidCallback onSave;

  const PreferencesEditor({
    super.key,
    required this.allStyles,
    required this.preferredStyles,
    required this.avoidOptions,
    required this.avoidSubcategories,
    required this.fitOptions,
    required this.bodyShapeOptions,
    required this.preferredFit,
    required this.bodyShape,
    required this.onStylesChanged,
    required this.onAvoidChanged,
    required this.onFitChanged,
    required this.onBodyShapeChanged,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Edit Preferences",
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            const Text(
              "These affect future outfit generation",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),

            const SizedBox(height: 16),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: allStyles.map((style) {
                final selected = preferredStyles.contains(style);

                return FilterChip(
                  label: Text(style),
                  selected: selected,
                  onSelected: (val) {
                    final updated = List<String>.from(preferredStyles);

                    if (val) {
                      if (!updated.contains(style)) updated.add(style);
                    } else {
                      updated.remove(style);
                    }

                    onStylesChanged(updated);
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 18),

            DropdownButtonFormField<String>(
              value: preferredFit,
              decoration: const InputDecoration(
                labelText: "Preferred fit",
                border: OutlineInputBorder(),
              ),
              items: fitOptions
                  .map((e) => DropdownMenuItem(
                value: e,
                child: Text(e),
              ))
                  .toList(),
              onChanged: (v) => onFitChanged(v ?? preferredFit),
            ),

            const SizedBox(height: 18),

            DropdownButtonFormField<String>(
              value: bodyShape,
              decoration: const InputDecoration(
                labelText: "Body shape",
                border: OutlineInputBorder(),
              ),
              items: bodyShapeOptions
                  .map((e) => DropdownMenuItem(
                value: e,
                child: Text(e),
              ))
                  .toList(),
              onChanged: (v) => onBodyShapeChanged(v ?? bodyShape),
            ),

            const SizedBox(height: 18),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: avoidOptions.map((item) {
                final selected = avoidSubcategories.contains(item);

                return FilterChip(
                  label: Text(item),
                  selected: selected,
                  onSelected: (val) {
                    final updated = List<String>.from(avoidSubcategories);

                    if (val) {
                      if (!updated.contains(item)) updated.add(item);
                    } else {
                      updated.remove(item);
                    }

                    onAvoidChanged(updated);
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text("Save Preferences"),
                onPressed: onSave,
              ),
            ),
          ],
        ),
      ),
    );
  }
}