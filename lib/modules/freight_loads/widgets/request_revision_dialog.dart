import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RequestRevisionDialog extends StatefulWidget {
  final String carrierName;
  final String currentBidAmount;

  const RequestRevisionDialog({
    super.key,
    this.carrierName = 'QuickFreight Solutions',
    this.currentBidAmount = r'$2,850',
  });

  @override
  State<RequestRevisionDialog> createState() => _RequestRevisionDialogState();
}

class _RequestRevisionDialogState extends State<RequestRevisionDialog> {
  final TextEditingController targetAmountController =
      TextEditingController(text: r'$ 2,500');
  final TextEditingController messageController = TextEditingController(
    text:
        "We appreciate your bid. Can you match the lowest bid of \$2,850? We're looking to award this load quickly.",
  );
  bool allowCounterOffer = false;
  bool isSuccess = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Container(
        width: 520,
        padding: const EdgeInsets.all(24),
        child: isSuccess ? _buildSuccessState() : _buildFormState(),
      ),
    );
  }

  Widget _buildFormState() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFFFEF3C7),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.autorenew,
                color: Color(0xFFD97706),
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Request Revision',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),

        // Carrier Box
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFFEFCE8),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFFDE68A)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Carrier',
                    style: TextStyle(fontSize: 11, color: Color(0xFFB45309)),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.carrierName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: const [
                      Icon(Icons.star, size: 12, color: Color(0xFFF59E0B)),
                      SizedBox(width: 4),
                      Text(
                        '4.8 rating',
                        style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Current Bid Amount',
                    style: TextStyle(fontSize: 11, color: Color(0xFFB45309)),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.currentBidAmount,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFD97706),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Send revision request info box
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFBFDBFE)),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline, size: 14, color: Color(0xFF2563EB)),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Ready to Send Revision',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E40AF),
                      ),
                    ),
                    Text(
                      'This will send a revision request to ${widget.carrierName} with the specified target amount and message.',
                      style: const TextStyle(fontSize: 10, color: Color(0xFF1D4ED8)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Input 1: Target Bid Amount
        const Text(
          'Target Bid Amount (Optional)',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF334155),
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: targetAmountController,
          style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A)),
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
            ),
            hintText: r'$ 2,500',
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Specify your target price for the revised bid',
          style: TextStyle(fontSize: 10, color: Color(0xFF64748B)),
        ),
        const SizedBox(height: 12),

        // Input 2: Revision Message
        const Text(
          'Revision Message *',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF334155),
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: messageController,
          maxLines: 3,
          style: const TextStyle(fontSize: 12, color: Color(0xFF0F172A)),
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.all(12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
            ),
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          "Explain what changes you'd like the carrier to consider",
          style: TextStyle(fontSize: 10, color: Color(0xFF64748B)),
        ),
        const SizedBox(height: 10),

        // Checkbox: Allow counter-offer
        Row(
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: allowCounterOffer,
                onChanged: (val) => setState(() => allowCounterOffer = val ?? false),
                activeColor: const Color(0xFFD97706),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'Allow carrier to counter-offer',
              style: TextStyle(fontSize: 12, color: Color(0xFF475569)),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Bottom Actions
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 44,
                child: ElevatedButton.icon(
                  onPressed: () => setState(() => isSuccess = true),
                  icon: const Icon(Icons.autorenew, size: 16, color: Colors.white),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB45309),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  label: const Text(
                    'Send Revision Request',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            OutlinedButton(
              onPressed: () => Get.back(),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFCBD5E1)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF64748B),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSuccessState() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Success Header Icon & Title
        Row(
          children: [
            Image.asset(
              'assets/icons/ic_successfully.png',
              width: 44,
              height: 44,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Revision request sent to ${widget.carrierName}!',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Key Value Data Rows
        _buildSuccessRow('Target Amount:', targetAmountController.text),
        const SizedBox(height: 10),
        _buildSuccessRow('Message:', messageController.text),
        const SizedBox(height: 18),

        // Carrier Notification Note
        const Text(
          'The carrier will be notified and can submit a revised bid.',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 24),

        // OK Button
        SizedBox(
          width: double.infinity,
          height: 44,
          child: ElevatedButton(
            onPressed: () => Get.back(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B82F6),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Ok',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF475569),
          ),
        ),
      ],
    );
  }
}
