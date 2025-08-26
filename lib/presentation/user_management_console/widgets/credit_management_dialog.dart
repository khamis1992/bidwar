import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../services/admin_user_service.dart';

class CreditManagementDialog extends StatefulWidget {
  final Map<String, dynamic> user;
  final Function(int, String) onCreditAdjustment;

  const CreditManagementDialog({
    Key? key,
    required this.user,
    required this.onCreditAdjustment,
  }) : super(key: key);

  @override
  State<CreditManagementDialog> createState() => _CreditManagementDialogState();
}

class _CreditManagementDialogState extends State<CreditManagementDialog> {
  final TextEditingController amountController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  List<Map<String, dynamic>> creditHistory = [];
  bool isLoadingHistory = true;
  bool isAdjusting = false;

  @override
  void initState() {
    super.initState();
    _loadCreditHistory();
  }

  @override
  void dispose() {
    amountController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadCreditHistory() async {
    try {
      final history =
          await AdminUserService.getUserCreditHistory(widget.user['id']);
      setState(() {
        creditHistory = history;
        isLoadingHistory = false;
      });
    } catch (e) {
      setState(() {
        isLoadingHistory = false;
      });
    }
  }

  Future<void> _adjustCredits(bool isAddition) async {
    if (amountController.text.isEmpty) return;

    setState(() {
      isAdjusting = true;
    });

    try {
      final amount = int.parse(amountController.text);
      final adjustmentAmount = isAddition ? amount : -amount;
      final description = descriptionController.text.isNotEmpty
          ? descriptionController.text
          : '${isAddition ? "Credit addition" : "Credit deduction"} by admin';

      widget.onCreditAdjustment(adjustmentAmount, description);
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid amount: ${e.toString()}')),
      );
    } finally {
      setState(() {
        isAdjusting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentBalance = widget.user['credit_balance'] ?? 0;

    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.6,
        constraints: const BoxConstraints(maxWidth: 800, maxHeight: 700),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Color(0xFFE5E7EB)),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.account_balance_wallet, color: Colors.green[600]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Credit Management',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${widget.user['full_name']} - Current Balance: $currentBalance credits',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Credit adjustment form
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Adjust Credits',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Amount input
                          TextField(
                            controller: amountController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            decoration: InputDecoration(
                              labelText: 'Amount',
                              hintText: 'Enter credit amount...',
                              prefixIcon: const Icon(Icons.payments),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              suffixText: 'credits',
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Description input
                          TextField(
                            controller: descriptionController,
                            maxLines: 3,
                            decoration: InputDecoration(
                              labelText: 'Description (Optional)',
                              hintText: 'Reason for adjustment...',
                              prefixIcon: const Icon(Icons.description),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              alignLabelWithHint: true,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Action buttons
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: isAdjusting ||
                                          amountController.text.isEmpty
                                      ? null
                                      : () => _adjustCredits(true),
                                  icon: const Icon(Icons.add,
                                      color: Colors.white),
                                  label: Text(
                                    'Add Credits',
                                    style:
                                        GoogleFonts.inter(color: Colors.white),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: isAdjusting ||
                                          amountController.text.isEmpty
                                      ? null
                                      : () => _adjustCredits(false),
                                  icon: const Icon(Icons.remove,
                                      color: Colors.white),
                                  label: Text(
                                    'Deduct Credits',
                                    style:
                                        GoogleFonts.inter(color: Colors.white),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          if (isAdjusting) ...[
                            const SizedBox(height: 16),
                            const Center(child: CircularProgressIndicator()),
                          ],
                        ],
                      ),
                    ),
                  ),

                  // Credit history
                  Expanded(
                    flex: 1,
                    child: Container(
                      decoration: const BoxDecoration(
                        border: Border(
                          left: BorderSide(color: Color(0xFFE5E7EB)),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Text(
                              'Transaction History',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Expanded(
                            child: isLoadingHistory
                                ? const Center(
                                    child: CircularProgressIndicator())
                                : creditHistory.isEmpty
                                    ? Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.history,
                                                size: 48,
                                                color: Colors.grey[400]),
                                            const SizedBox(height: 12),
                                            Text(
                                              'No transactions found',
                                              style: GoogleFonts.inter(
                                                  color: Colors.grey[600]),
                                            ),
                                          ],
                                        ),
                                      )
                                    : ListView.builder(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20),
                                        itemCount: creditHistory.length,
                                        itemBuilder: (context, index) {
                                          final transaction =
                                              creditHistory[index];
                                          return _buildTransactionItem(
                                              transaction);
                                        },
                                      ),
                          ),
                        ],
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
  }

  Widget _buildTransactionItem(Map<String, dynamic> transaction) {
    final amount = transaction['amount'] ?? 0;
    final type = transaction['transaction_type'] ?? '';
    final description = transaction['description'] ?? '';
    final date = _formatDate(transaction['created_at']);
    final isPositive = amount > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (isPositive ? Colors.green : Colors.red).withAlpha(26),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isPositive ? Icons.add : Icons.remove,
              color: isPositive ? Colors.green : Colors.red,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${isPositive ? "+" : ""}$amount credits',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isPositive ? Colors.green : Colors.red,
                  ),
                ),
                if (description.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
                const SizedBox(height: 2),
                Text(
                  date,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(dynamic dateStr) {
    if (dateStr == null) return 'Unknown';
    try {
      final date = DateTime.parse(dateStr.toString());
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'Unknown';
    }
  }
}
