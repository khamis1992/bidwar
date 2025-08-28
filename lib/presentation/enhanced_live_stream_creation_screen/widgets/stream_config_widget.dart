import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StreamConfigWidget extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final String selectedDuration;
  final String startingPriceMode;
  final int customStartingPrice;
  final int bidIncrement;
  final bool acceptCommissionTerms;
  final Function(String) onDurationChanged;
  final Function(String) onStartingPriceModeChanged;
  final Function(int) onCustomStartingPriceChanged;
  final Function(int) onBidIncrementChanged;
  final Function(bool) onCommissionTermsChanged;

  const StreamConfigWidget({
    Key? key,
    required this.titleController,
    required this.descriptionController,
    required this.selectedDuration,
    required this.startingPriceMode,
    required this.customStartingPrice,
    required this.bidIncrement,
    required this.acceptCommissionTerms,
    required this.onDurationChanged,
    required this.onStartingPriceModeChanged,
    required this.onCustomStartingPriceChanged,
    required this.onBidIncrementChanged,
    required this.onCommissionTermsChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Stream Configuration',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),

        // Stream Title
        _buildTextField(
          controller: titleController,
          label: 'Stream Title',
          hint: 'Enter stream title',
          maxLines: 1,
        ),
        const SizedBox(height: 16),

        // Stream Description
        _buildTextField(
          controller: descriptionController,
          label: 'Description (Optional)',
          hint: 'Describe your auction stream',
          maxLines: 3,
        ),
        const SizedBox(height: 16),

        // Duration Selection
        _buildSectionTitle('Auction Duration'),
        const SizedBox(height: 8),
        _buildDurationSelector(),
        const SizedBox(height: 16),

        // Starting Price Configuration
        _buildSectionTitle('Starting Price'),
        const SizedBox(height: 8),
        _buildStartingPriceConfig(),
        const SizedBox(height: 16),

        // Bid Increment
        _buildSectionTitle('Bid Increment'),
        const SizedBox(height: 8),
        _buildBidIncrementSelector(),
        const SizedBox(height: 16),

        // Commission Terms
        _buildCommissionTermsCheckbox(),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(
              color: Colors.grey.shade400,
              fontSize: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.blue, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Colors.grey.shade700,
      ),
    );
  }

  Widget _buildDurationSelector() {
    final durations = [
      {'value': '15min', 'label': '15 Minutes'},
      {'value': '30min', 'label': '30 Minutes'},
      {'value': '1hour', 'label': '1 Hour'},
      {'value': '2hours', 'label': '2 Hours'},
    ];

    return Wrap(
      spacing: 8,
      children: durations.map((duration) {
        final isSelected = selectedDuration == duration['value'];
        return ChoiceChip(
          label: Text(duration['label']!),
          selected: isSelected,
          onSelected: (selected) {
            if (selected) {
              onDurationChanged(duration['value']!);
            }
          },
          labelStyle: GoogleFonts.inter(
            fontSize: 12,
            color: isSelected ? Colors.white : Colors.grey.shade700,
            fontWeight: FontWeight.w500,
          ),
          backgroundColor: Colors.grey.shade100,
          selectedColor: Colors.blue,
        );
      }).toList(),
    );
  }

  Widget _buildStartingPriceConfig() {
    return Column(
      children: [
        RadioListTile<String>(
          title: Text(
            'Use Product Default',
            style: GoogleFonts.inter(fontSize: 14),
          ),
          subtitle: Text(
            'Recommended starting price based on product value',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          value: 'auto',
          groupValue: startingPriceMode,
          onChanged: (value) => onStartingPriceModeChanged(value!),
          contentPadding: EdgeInsets.zero,
        ),
        RadioListTile<String>(
          title: Text(
            'Custom Starting Price',
            style: GoogleFonts.inter(fontSize: 14),
          ),
          value: 'custom',
          groupValue: startingPriceMode,
          onChanged: (value) => onStartingPriceModeChanged(value!),
          contentPadding: EdgeInsets.zero,
        ),
        if (startingPriceMode == 'custom') ...[
          const SizedBox(height: 8),
          TextFormField(
            initialValue: (customStartingPrice / 100).toStringAsFixed(2),
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Custom Starting Price (\$)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              prefixText: '\$',
            ),
            onChanged: (value) {
              final price = (double.tryParse(value) ?? 0) * 100;
              onCustomStartingPriceChanged(price.round());
            },
          ),
        ],
      ],
    );
  }

  Widget _buildBidIncrementSelector() {
    final increments = [
      {'value': 50, 'label': '\$0.50'},
      {'value': 100, 'label': '\$1.00'},
      {'value': 200, 'label': '\$2.00'},
      {'value': 500, 'label': '\$5.00'},
      {'value': 1000, 'label': '\$10.00'},
    ];

    return Wrap(
      spacing: 8,
      children: increments.map((increment) {
        final isSelected = bidIncrement == increment['value'];
        return ChoiceChip(
          label: Text(increment['label'] as String),
          selected: isSelected,
          onSelected: (selected) {
            if (selected) {
              onBidIncrementChanged(increment['value'] as int);
            }
          },
          labelStyle: GoogleFonts.inter(
            fontSize: 12,
            color: isSelected ? Colors.white : Colors.grey.shade700,
            fontWeight: FontWeight.w500,
          ),
          backgroundColor: Colors.grey.shade100,
          selectedColor: Colors.blue,
        );
      }).toList(),
    );
  }

  Widget _buildCommissionTermsCheckbox() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Checkbox(
            value: acceptCommissionTerms,
            onChanged: (value) => onCommissionTermsChanged(value ?? false),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Accept Commission Terms',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.blue.shade700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'I understand that I will receive commission based on the final sale price of the selected product. Commission will be processed within 24 hours of auction completion.',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.blue.shade600,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}