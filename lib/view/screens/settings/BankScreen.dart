import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:kb_driver/constants/app_colors.dart';
import 'package:kb_driver/core/data/models/user/bank_model.dart';
import 'package:kb_driver/core/data/presentation/controllers/user/bank_controller.dart';

import 'package:kb_driver/utils/message_manager.dart';
import 'package:kb_driver/utils/vibrate_manager.dart';

import 'package:kb_driver/view/components/app_input_field.dart';
import 'package:kb_driver/view/components/app_button.dart';
import 'package:kb_driver/view/components/cmp_app_bar.dart';

class BankScreen extends StatefulWidget {
  const BankScreen({super.key});

  @override
  State<BankScreen> createState() => _BankScreenState();
}

class _BankScreenState extends State<BankScreen> {
  final BankController _controller = Get.put(BankController());
  final VibrateManager _vibrateManager = VibrateManager();

  /// controllers
  final _holderName = TextEditingController();
  final _accountNumber = TextEditingController();
  final _ifsc = TextEditingController();
  final _bankName = TextEditingController();
  final _branch = TextEditingController();
  final _accountType = TextEditingController();

  bool _showAccountNumber = false;

  String status = '';
  bool isPrimary = false;
  String accountLast4 = '';

  @override
  void initState() {
    super.initState();
    _loadBank();
  }

  /// LOAD BANK
  Future<void> _loadBank() async {
    final res = await _controller.getBankDetails();

    if (res.isSuccess != true || res.data == null) return;

    Map<String, dynamic> data;

    if (res.data is List) {
      if (res.data.isEmpty) return;
      data = Map<String, dynamic>.from(res.data.first);
    } else {
      data = Map<String, dynamic>.from(res.data);
    }

    final bank = BankModel.fromJson(data);

    setState(() {
      _holderName.text = bank.accountHolderName;

      if (bank.accountNumber.isNotEmpty) {
        _accountNumber.text = bank.accountNumber;
      }

      accountLast4 = data['account_number_last4'] ?? '';

      _ifsc.text = bank.ifscCode;
      _bankName.text = bank.bankName;
      _branch.text = bank.branchName;
      _accountType.text = bank.accountType;

      status = data['status'] ?? '';
      isPrimary = data['is_primary'] ?? false;
    });
  }

  /// CONFIRM UPDATE
  void confirmUpdate() {
    if (_holderName.text.isEmpty ||
        _ifsc.text.isEmpty ||
        _bankName.text.isEmpty) {
      MessageManager.showError("Please fill required fields");
      return;
    }

    if (_accountNumber.text.isEmpty && accountLast4.isEmpty) {
      MessageManager.showError("Enter account number");
      return;
    }

    Get.dialog(
      AlertDialog(
        title: const Text("Update Bank Details"),
        content: const Text("Confirm update bank details?"),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("Cancel")),

          ElevatedButton(
            onPressed: () {
              Get.back();
              _updateBank();
            },
            child: const Text("Confirm"),
          ),
        ],
      ),
    );
  }

  /// UPDATE BANK
  void _updateBank() {
    _vibrateManager.vibrateButton();

    final bank = BankModel(
      accountHolderName: _holderName.text,
      accountNumber: _accountNumber.text,
      ifscCode: _ifsc.text,
      bankName: _bankName.text,
      branchName: _branch.text,
      accountType: _accountType.text,
    );

    _controller.updateBankDetails(bank);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(title: "Bank Details"),

      backgroundColor: const Color(0xFFF5F5F5),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),

          child: Column(
            children: [
              if (accountLast4.isNotEmpty) _existingAccountCard(),

              const SizedBox(height: 16),

              _bankFormCard(),
            ],
          ),
        ),
      ),
    );
  }

  /// EXISTING ACCOUNT CARD
  Widget _existingAccountCard() {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: const Color(0xFFEAF3FF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withOpacity(.3)),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Existing Bank Account",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 10),

          Text(
            "XXXX XXXX $accountLast4",
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              letterSpacing: 2,
            ),
          ),

          const SizedBox(height: 10),

          if (status.isNotEmpty)
            Row(
              children: [
                const Icon(Icons.verified, color: Colors.green, size: 18),
                const SizedBox(width: 6),
                Text(status),
              ],
            ),

          if (isPrimary)
            const Padding(
              padding: EdgeInsets.only(top: 6),
              child: Row(
                children: [
                  Icon(Icons.star, color: Colors.orange, size: 18),
                  SizedBox(width: 6),
                  Text("Primary Bank Account"),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// FORM CARD
  Widget _bankFormCard() {
    return Card(
      color: Colors.white,
      elevation: 2,

      child: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Update Bank Details",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            AppInputField(
              controller: _holderName,
              hint: "Account Holder Name *",
              prefixIcon: Icons.person,
            ),

            const SizedBox(height: 12),

            AppInputField(
              controller: _accountNumber,
              hint: "Enter Full Account Number",
              prefixIcon: Icons.lock,
              obscure: !_showAccountNumber,
              suffix: IconButton(
                icon: Icon(
                  _showAccountNumber ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _showAccountNumber = !_showAccountNumber;
                  });
                },
              ),
            ),

            const SizedBox(height: 12),

            AppInputField(
              controller: _ifsc,
              hint: "IFSC Code *",
              prefixIcon: Icons.account_balance,
            ),

            const SizedBox(height: 12),

            AppInputField(
              controller: _bankName,
              hint: "Bank Name *",
              prefixIcon: Icons.account_balance_wallet,
            ),

            const SizedBox(height: 12),

            AppInputField(
              controller: _branch,
              hint: "Branch Name",
              prefixIcon: Icons.location_city,
            ),

            const SizedBox(height: 12),

            AppInputField(
              controller: _accountType,
              hint: "Account Type (Savings/Current)",
              prefixIcon: Icons.credit_card,
            ),

            const SizedBox(height: 20),

            AppButton(
              title: "Update Bank Details",
              loading: _controller.isLoading.value,
              background: AppColors.primary,
              onPressed: confirmUpdate,
            ),
          ],
        ),
      ),
    );
  }
}
