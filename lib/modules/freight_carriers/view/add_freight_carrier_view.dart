import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/widgets/common_loader.dart';
import '../../home/widgets/app_drawer.dart';
import '../../home/widgets/dashboard_app_bar.dart';
import '../../item_cost_list/widgets/success_dialog.dart';
import '../controller/freight_carriers_controller.dart';

class AddFreightCarrierView extends StatefulWidget {
  final bool isEdit;

  const AddFreightCarrierView({super.key, this.isEdit = false});

  @override
  State<AddFreightCarrierView> createState() => _AddFreightCarrierViewState();
}

class _AddFreightCarrierViewState extends State<AddFreightCarrierView> {
  final _nameController = TextEditingController(text: 'Ironhaul Logistics');
  final _idController = TextEditingController(text: 'DLV-2026-10482');
  final _phoneController = TextEditingController(text: '000-000-0000');
  final _emailController = TextEditingController(text: 'emmawatson@email.com');

  final _streetController = TextEditingController(
    text: 'Palm Residency, MG Road',
  );
  final _placeController = TextEditingController(text: 'Flat 402');
  final _postalController = TextEditingController(text: '411001');

  // Fleet Capacity Controllers
  final _totalVehicleController = TextEditingController(text: '32');
  final _maxCapacityController = TextEditingController(text: '800000 lbs');
  final _avgAgeController = TextEditingController(text: '4.2');

  // Internal Notes Controller
  final _notesController = TextEditingController(
    text:
        'Client requested work completion before Friday inspection. Ensure safety compliance checklist is completed before closure.',
  );

  String _selectedCountry = 'India';
  String _selectedState = 'Maharashtra';
  String _selectedCity = 'Pune';
  String _selectedCountryCode = '+1';

  // Dynamic Fleet Equipment List
  final List<Map<String, dynamic>> _equipmentList = [
    {
      'equipment': 'Flatbed trucks',
      'quantity': TextEditingController(text: '5'),
    },
    {'equipment': 'Dry Vans', 'quantity': TextEditingController(text: '8')},
  ];

  // Collapsible section states
  bool _isCarrierInfoExpanded = true;
  bool _isAddressInfoExpanded = true;
  bool _isFleetEquipmentExpanded = true;
  bool _isFleetCapacityExpanded = true;
  bool _isInternalNotesExpanded = true;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<FreightCarriersController>();

    return Scaffold(
      backgroundColor: const Color(0xFFEFF6FF),
      drawer: const AppDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            const DashboardAppBar(),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const CommonLoader();
                }

                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Toolbar
                      _buildHeaderToolbar(context),

                      const SizedBox(height: 20),

                      // Section 1: Carriers Information
                      _buildCarriersInformationCard(),

                      const SizedBox(height: 20),

                      // Section 2: Address Information
                      _buildAddressInformationCard(),

                      const SizedBox(height: 20),

                      // Section 3: Fleet & Equipment Details
                      _buildFleetEquipmentDetailsCard(),

                      const SizedBox(height: 20),

                      // Section 4: Fleet Capacity
                      _buildFleetCapacityCard(),

                      const SizedBox(height: 20),

                      // Section 5: Upload Documents
                      _buildUploadDocumentsCard(),

                      const SizedBox(height: 20),

                      // Section 6: Internal Notes
                      _buildInternalNotesCard(),

                      const SizedBox(height: 32),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderToolbar(BuildContext context) {
    final titleText = widget.isEdit
        ? 'Edit Freight Carried'
        : 'Add New Freight Carried';
    final buttonText = widget.isEdit ? 'Save Changes' : 'Add Freight Carrier';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            IconButton(
              onPressed: () => Get.back(),
              icon: const Icon(
                Icons.arrow_back,
                size: 20,
                color: Color(0xFF0F172A),
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            const SizedBox(width: 10),
            Text(
              titleText,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
          ],
        ),
        ElevatedButton.icon(
          onPressed: _onSaveCarrier,
          icon: const Icon(
            Icons.visibility_outlined,
            size: 16,
            color: Colors.white,
          ),
          label: Text(
            buttonText,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2563EB),
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _onSaveCarrier() async {
    final controller = Get.find<FreightCarriersController>();
    if (_nameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty) {
      Get.snackbar('Required fields', 'Carrier name and email are required.');
      return;
    }
    try {
      final maxCapacity =
          num.tryParse(
            _maxCapacityController.text.replaceAll(RegExp(r'[^0-9.]'), ''),
          ) ??
          0;
      await controller.saveCarrier(
        id: widget.isEdit ? controller.selectedCarrier.value?.id : null,
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        contactName: '',
        serviceType: 'flatbed',
        serviceArea: [
          _selectedCity,
          _selectedState,
          _selectedCountry,
        ].where((value) => value.isNotEmpty).join(', '),
        totalVehicles: int.tryParse(_totalVehicleController.text) ?? 0,
        maximumLoadCapacity: maxCapacity,
        equipmentTypes: _equipmentList
            .map((item) => (item['equipment'] ?? '').toString())
            .where((value) => value.isNotEmpty)
            .toList(),
      );
    } catch (error) {
      Get.snackbar('Unable to save carrier', error.toString());
      return;
    }
    final title = widget.isEdit
        ? 'Freight Carrier Updated Successfully'
        : 'New Freight Carrier Added Successfully';

    if (!mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => SuccessDialog(
        title: title,
        buttonText: 'Ok',
        onPressed: () {
          Navigator.of(ctx).pop();
          Get.back();
        },
      ),
    );
  }

  Widget _buildCarriersInformationCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(
              () => _isCarrierInfoExpanded = !_isCarrierInfoExpanded,
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: const Color(0xFFCCFBF1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.info_outline,
                      size: 16,
                      color: Color(0xFF0D9488),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Carriers Information',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    _isCarrierInfoExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: const Color(0xFF64748B),
                  ),
                ],
              ),
            ),
          ),

          if (_isCarrierInfoExpanded) ...[
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildFormField(
                          label: 'Carriers Name *',
                          controller: _nameController,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: _buildFormField(
                          label: 'Carriers ID (Auto-generated + Editable) *',
                          controller: _idController,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Phone Number *',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              height: 44,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              alignment: Alignment.centerLeft,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: const Color(0xFFE2E8F0),
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Text(
                                    '🇺🇸',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  const SizedBox(width: 4),
                                  DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: _selectedCountryCode,
                                      isDense: true,
                                      alignment: Alignment.centerLeft,
                                      icon: const Icon(
                                        Icons.keyboard_arrow_down,
                                        size: 16,
                                        color: Color(0xFF64748B),
                                      ),
                                      items: const [
                                        DropdownMenuItem(
                                          value: '+1',
                                          child: Text(
                                            '+1',
                                            style: TextStyle(fontSize: 13),
                                          ),
                                        ),
                                        DropdownMenuItem(
                                          value: '+91',
                                          child: Text(
                                            '+91',
                                            style: TextStyle(fontSize: 13),
                                          ),
                                        ),
                                        DropdownMenuItem(
                                          value: '+44',
                                          child: Text(
                                            '+44',
                                            style: TextStyle(fontSize: 13),
                                          ),
                                        ),
                                      ],
                                      onChanged: (val) => setState(
                                        () => _selectedCountryCode = val!,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const VerticalDivider(
                                    width: 1,
                                    indent: 8,
                                    endIndent: 8,
                                    color: Color(0xFFCBD5E1),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: TextField(
                                      controller: _phoneController,
                                      textAlignVertical:
                                          TextAlignVertical.center,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFF0F172A),
                                      ),
                                      decoration: const InputDecoration(
                                        border: InputBorder.none,
                                        isDense: true,
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: _buildFormField(
                          label: 'Email Address *',
                          controller: _emailController,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAddressInformationCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(
              () => _isAddressInfoExpanded = !_isAddressInfoExpanded,
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: const Color(0xFFCCFBF1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.info_outline,
                      size: 16,
                      color: Color(0xFF0D9488),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Address Information',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    _isAddressInfoExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: const Color(0xFF64748B),
                  ),
                ],
              ),
            ),
          ),

          if (_isAddressInfoExpanded) ...[
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildDropdownField(
                          label: 'Country *',
                          value: _selectedCountry,
                          items: ['India', 'USA', 'UK', 'Canada'],
                          onChanged: (val) =>
                              setState(() => _selectedCountry = val!),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildDropdownField(
                          label: 'State *',
                          value: _selectedState,
                          items: [
                            'Maharashtra',
                            'Gujarat',
                            'Texas',
                            'California',
                          ],
                          onChanged: (val) =>
                              setState(() => _selectedState = val!),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildDropdownField(
                          label: 'City *',
                          value: _selectedCity,
                          items: ['Pune', 'Mumbai', 'Houston', 'Dallas'],
                          onChanged: (val) =>
                              setState(() => _selectedCity = val!),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _buildFormField(
                          label: 'Street Address *',
                          controller: _streetController,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: _buildFormField(
                          label: 'Place Number',
                          controller: _placeController,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: 320,
                    child: _buildFormField(
                      label: 'Postal Code *',
                      controller: _postalController,
                    ),
                  ),
                  const SizedBox(height: 24),

                  Container(
                    height: 160,
                    width: double.infinity,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Stack(
                      children: [
                        Image.asset(
                          'assets/images/map_preview.png',
                          width: double.infinity,
                          height: 160,
                          fit: BoxFit.cover,
                          errorBuilder: (ctx, err, stack) => CustomPaint(
                            size: const Size(double.infinity, 160),
                            painter: MapPatternPainter(),
                          ),
                        ),
                        Positioned(
                          top: 14,
                          left: 14,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(6),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: const Text(
                              'Map Preview',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ),
                        ),
                        Center(
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFF93C5FD,
                              ).withValues(alpha: 0.6),
                              shape: BoxShape.circle,
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2563EB),
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFF2563EB,
                                    ).withValues(alpha: 0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.apartment,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFleetEquipmentDetailsCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(
              () => _isFleetEquipmentExpanded = !_isFleetEquipmentExpanded,
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: const Color(0xFFCCFBF1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.info_outline,
                      size: 16,
                      color: Color(0xFF0D9488),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Fleet & Equipment Details',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    _isFleetEquipmentExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: const Color(0xFF64748B),
                  ),
                ],
              ),
            ),
          ),

          if (_isFleetEquipmentExpanded) ...[
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...List.generate(_equipmentList.length, (index) {
                    final item = _equipmentList[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildDropdownField(
                              label: 'Select Equipment',
                              value: item['equipment'],
                              items: [
                                'Flatbed trucks',
                                'Dry Vans',
                                'Heavy Haul',
                                'Step Deck',
                              ],
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() => item['equipment'] = val);
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: _buildFormField(
                              label: 'Add Quantity',
                              controller: item['quantity'],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 4),
                  InkWell(
                    onTap: () {
                      setState(() {
                        _equipmentList.add({
                          'equipment': 'Flatbed trucks',
                          'quantity': TextEditingController(text: '1'),
                        });
                      });
                    },
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFFBFDBFE),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Color(0xFF2563EB),
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFleetCapacityCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(
              () => _isFleetCapacityExpanded = !_isFleetCapacityExpanded,
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: const Color(0xFFCCFBF1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.info_outline,
                      size: 16,
                      color: Color(0xFF0D9488),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Fleet Capacity',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    _isFleetCapacityExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: const Color(0xFF64748B),
                  ),
                ],
              ),
            ),
          ),

          if (_isFleetCapacityExpanded) ...[
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  Expanded(
                    child: _buildFormField(
                      label: 'Total Vehicle *',
                      controller: _totalVehicleController,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildFormField(
                      label: 'Maximum Load Capacity *',
                      controller: _maxCapacityController,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildFormField(
                      label: 'Average Fleet Age *',
                      controller: _avgAgeController,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildUploadDocumentsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Upload Documents',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 16),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drop zone container
              Container(
                width: 260,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF93C5FD),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Upload Documents & Files',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Add your documents here, and you can u...',
                      style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2563EB),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.folder,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        side: const BorderSide(color: Color(0xFF2563EB)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: const Text(
                        'Browse files',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2563EB),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Only support .jpg, .png and .svg and zip fi...',
                      style: TextStyle(fontSize: 9, color: Color(0xFF94A3B8)),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 16),

              // Uploaded File Card
              Container(
                width: 230,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'PDF',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Insurance.pdf',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 2),
                          Text(
                            '5.3MB',
                            style: TextStyle(
                              fontSize: 10,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.cancel_outlined,
                      size: 16,
                      color: Color(0xFF94A3B8),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInternalNotesCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(
              () => _isInternalNotesExpanded = !_isInternalNotesExpanded,
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: const Color(0xFFCCFBF1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.info_outline,
                      size: 16,
                      color: Color(0xFF0D9488),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Internal Notes',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    _isInternalNotesExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: const Color(0xFF64748B),
                  ),
                ],
              ),
            ),
          ),

          if (_isInternalNotesExpanded) ...[
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: TextField(
                  controller: _notesController,
                  maxLines: 3,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF0F172A),
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
  }) {
    final bool isRequired = label.contains('*');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF0F172A),
              fontWeight: FontWeight.bold,
            ),
            children: [
              TextSpan(text: label.replaceAll(' *', '')),
              if (isRequired)
                const TextSpan(
                  text: ' *',
                  style: TextStyle(color: Color(0xFFEF4444)),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: TextField(
            controller: controller,
            textAlignVertical: TextAlignVertical.center,
            style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A)),
            decoration: const InputDecoration(
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    final bool isRequired = label.contains('*');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF0F172A),
              fontWeight: FontWeight.bold,
            ),
            children: [
              TextSpan(text: label.replaceAll(' *', '')),
              if (isRequired)
                const TextSpan(
                  text: ' *',
                  style: TextStyle(color: Color(0xFFEF4444)),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              alignment: Alignment.centerLeft,
              icon: const Icon(
                Icons.keyboard_arrow_down,
                color: Color(0xFF64748B),
              ),
              items: items.map((item) {
                return DropdownMenuItem<String>(
                  value: item,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    item,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}

class MapPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFCBD5E1)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    const step = 30.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
