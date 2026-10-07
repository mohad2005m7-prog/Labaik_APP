import 'package:flutter/material.dart';

import '../../data/models/account_type.dart';
import '../../data/models/trip_setup_data.dart';
import '../widgets/icon_option_card.dart';
import '../widgets/primary_button.dart';
import '../widgets/setup_header.dart';
import 'trip_type_screen.dart';

// -------------------------------------------------------------
// شاشة "نوع الحساب" — مطابقة لـ Figma (393×852)
// معتمر/حاج → نوع الرحلة | مشرف المجموعة → قريباً
// -------------------------------------------------------------
class AccountTypeScreen extends StatefulWidget {
  const AccountTypeScreen({super.key});

  @override
  State<AccountTypeScreen> createState() => _AccountTypeScreenState();
}

class _AccountTypeScreenState extends State<AccountTypeScreen> {
  final _data = TripSetupData.instance;

  void _onContinuePressed() {
    final selected = _data.accountType;

    if (selected == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى اختيار نوع الحساب للمتابعة')),
      );
      return;
    }

    // شاشات مشرف المجموعة لسا ما انصممت
    if (selected == AccountType.groupSupervisor) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('قريباً')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const TripTypeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SetupHeader(title: 'نوع الحساب'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 19, 16, 24),
                child: Column(
                  children: [
                    IconOptionCard(
                      label: 'معتمر/حاج',
                      icon: Icons.person_outline,
                      selected: _data.accountType == AccountType.pilgrim,
                      onTap: () => setState(() => _data.accountType = AccountType.pilgrim),
                    ),
                    const SizedBox(height: 16),
                    IconOptionCard(
                      label: 'مشرف المجموعة',
                      icon: Icons.manage_accounts_outlined,
                      selected: _data.accountType == AccountType.groupSupervisor,
                      onTap: () => setState(() => _data.accountType = AccountType.groupSupervisor),
                    ),
                    const SizedBox(height: 32),
                    PrimaryButton(label: 'متابعة', onPressed: _onContinuePressed),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
