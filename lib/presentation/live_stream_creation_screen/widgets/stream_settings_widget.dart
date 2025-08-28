import 'package:flutter/material.dart';

class StreamSettingsWidget extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final String selectedDuration;
  final bool isPublic;
  final Function(String) onDurationChanged;
  final Function(bool) onVisibilityChanged;

  const StreamSettingsWidget({
    Key? key,
    required this.titleController,
    required this.descriptionController,
    required this.selectedDuration,
    required this.isPublic,
    required this.onDurationChanged,
    required this.onVisibilityChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Stream Settings',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),

        // Stream title
        TextField(
          controller: titleController,
          decoration: const InputDecoration(
            labelText: 'Stream Title *',
            hintText: 'Enter a catchy title for your live auction',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.title),
          ),
          maxLength: 100,
        ),

        const SizedBox(height: 16),

        // Stream description
        TextField(
          controller: descriptionController,
          decoration: const InputDecoration(
            labelText: 'Description (Optional)',
            hintText: 'Describe your auction item and bidding rules',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.description),
          ),
          maxLines: 3,
          maxLength: 500,
        ),

        const SizedBox(height: 20),

        // Duration selector
        const Text(
          'Stream Duration',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),

        Row(
          children: [
            Expanded(
              child: _DurationChip(
                label: '15 min',
                value: '15min',
                isSelected: selectedDuration == '15min',
                onTap: () => onDurationChanged('15min'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _DurationChip(
                label: '30 min',
                value: '30min',
                isSelected: selectedDuration == '30min',
                onTap: () => onDurationChanged('30min'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _DurationChip(
                label: '1 hr',
                value: '1hr',
                isSelected: selectedDuration == '1hr',
                onTap: () => onDurationChanged('1hr'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _DurationChip(
                label: '2 hr',
                value: '2hr',
                isSelected: selectedDuration == '2hr',
                onTap: () => onDurationChanged('2hr'),
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Visibility settings
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Stream Visibility',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<bool>(
                      title: const Text('Public'),
                      subtitle: const Text('Anyone can discover and join'),
                      value: true,
                      groupValue: isPublic,
                      onChanged: (value) => onVisibilityChanged(value ?? true),
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<bool>(
                      title: const Text('Private'),
                      subtitle: const Text('Only invited users can join'),
                      value: false,
                      groupValue: isPublic,
                      onChanged: (value) => onVisibilityChanged(value ?? false),
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DurationChip extends StatelessWidget {
  final String label;
  final String value;
  final bool isSelected;
  final VoidCallback onTap;

  const _DurationChip({
    required this.label,
    required this.value,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey[400]!,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
