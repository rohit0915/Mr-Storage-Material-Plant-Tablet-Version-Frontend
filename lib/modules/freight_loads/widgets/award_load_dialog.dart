import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';

class AwardLoadDialog extends StatefulWidget {
  final String carrierName;
  final String awardAmount;
  final String project;
  final Future<bool> Function()? onConfirm;

  const AwardLoadDialog({
    super.key,
    this.carrierName = 'QuickFreight Solutions',
    this.awardAmount = r'$2,850',
    this.project = 'ABC Logistics Warehouse',
    this.onConfirm,
  });

  @override
  State<AwardLoadDialog> createState() => _AwardLoadDialogState();
}

class _AwardLoadDialogState extends State<AwardLoadDialog> {
  bool sendEmail = true;
  bool autoCreateDelivery = true;
  bool isSuccess = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Container(
        width: 500,
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
        // Title Header
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFFDCFCE7),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.workspace_premium,
                color: Color(0xFF16A34A),
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Award Load Confirmation',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),

        // Winning Carrier Box
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF0FDF4),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFBBF7D0)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Winning Carrier',
                    style: TextStyle(fontSize: 11, color: Color(0xFF15803D)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.carrierName,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: const [
                      Icon(Icons.star, size: 13, color: Color(0xFFF59E0B)),
                      SizedBox(width: 4),
                      Text(
                        '4.8 rating',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Award Amount',
                    style: TextStyle(fontSize: 11, color: Color(0xFF15803D)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.awardAmount,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF16A34A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'BEST RATE',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF166534),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Toggle 1
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildCustomSwitch(
              value: sendEmail,
              onChanged: (val) => setState(() => sendEmail = val),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Send award confirmation email to carrier',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    "Notify QuickFreight Solutions that they've been awarded the load",
                    style: TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Toggle 2
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildCustomSwitch(
              value: autoCreateDelivery,
              onChanged: (val) => setState(() => autoCreateDelivery = val),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Auto-create delivery from this freight request',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Automatically generate a delivery record with all details from this request',
                    style: TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Info Banner
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFBFDBFE)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(Icons.info_outline, size: 14, color: Color(0xFF2563EB)),
                  SizedBox(width: 6),
                  Text(
                    'Ready to Award',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E40AF),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'This will award the load to ${widget.carrierName} for ${widget.awardAmount} and create a delivery record automatically.',
                style: const TextStyle(fontSize: 11, color: Color(0xFF1D4ED8)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Bottom Action Buttons
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 44,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final success = await widget.onConfirm?.call() ?? true;
                    if (success && mounted) setState(() => isSuccess = true);
                  },
                  icon: const Icon(
                    Icons.workspace_premium,
                    size: 16,
                    color: Colors.white,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF16A34A),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  label: const Text(
                    'Confirm & Award Load',
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
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
                'Load awarded to ${widget.carrierName} for ${widget.awardAmount}!',
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
        _buildSuccessRow('Carrier:', widget.carrierName),
        const SizedBox(height: 6),
        _buildSuccessRow('Amount:', widget.awardAmount),
        const SizedBox(height: 6),
        _buildSuccessRow('Delivery created:', 'DEL-0997'),
        const Divider(height: 20, color: Color(0xFFE2E8F0)),

        _buildSuccessRow('Project:', widget.project),
        const SizedBox(height: 6),
        _buildSuccessRow('Delivery Company:', widget.carrierName),
        const SizedBox(height: 6),
        _buildSuccessRow('Date:', '04/04/2024 at 14:00'),
        const SizedBox(height: 6),
        _buildSuccessRow('POC:', 'John Site Manager'),
        const SizedBox(height: 6),
        _buildSuccessRow('Location:', 'Construction Site, Austin, TX'),
        const SizedBox(height: 16),

        // Link
        InkWell(
          onTap: () {
            Get.back();
            Get.toNamed(AppRoutes.deliveryDetails);
          },
          child: const Text(
            'View in Delivery Management -> Delivery List',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2563EB),
              decoration: TextDecoration.underline,
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Confirmation Note
        Text(
          'Confirmation email sent to ${widget.carrierName}.',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xFF16A34A),
          ),
        ),
        const SizedBox(height: 24),

        // OK Button
        SizedBox(
          width: double.infinity,
          height: 44,
          child: ElevatedButton(
            onPressed: () {
              Get.back();
              Get.toNamed(AppRoutes.deliveryDetails);
            },
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 140,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 12, color: Color(0xFF475569)),
          ),
        ),
      ],
    );
  }

  Widget _buildCustomSwitch({
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 44,
        height: 24,
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: value ? const Color(0xFF16A34A) : const Color(0xFFCBD5E1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 20,
            height: 20,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 2,
                  offset: Offset(0, 1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
