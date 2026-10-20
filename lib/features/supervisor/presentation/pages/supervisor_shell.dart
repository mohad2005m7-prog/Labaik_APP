import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/supervisor_repository.dart';
import '../cubits/supervisor_shell_cubit.dart';
import '../supervisor_scope.dart';
import '../widgets/supervisor_tab_bar.dart';
import '../widgets/supervisor_widgets.dart';
import 'supervisor_announcements_screen.dart';
import 'supervisor_chats_screen.dart';
import 'supervisor_groups_screen.dart';
import 'supervisor_home_screen.dart';
import 'supervisor_profile_screen.dart';

// -------------------------------------------------------------
// واجهة المشرف بعد الدخول: 5 تبويبات (الرئيسية، الدردشات، المجموعة، الإعلانات، الملف الشخصي)
// كل تبويب بينبني أول مرة بيفتحه (مش الكل مرة وحدة) وبعدها بيحافظ على حالته
// آخر تبويب بينحفظ (حفظ التقدم) — [initialTab] بيجي من AuthController.homeScreen
// -------------------------------------------------------------
class SupervisorShell extends StatelessWidget {
  final int initialTab;
  final SupervisorRepository? repository;

  const SupervisorShell({super.key, this.initialTab = 0, this.repository});

  @override
  Widget build(BuildContext context) {
    return SupervisorScope(initialTab: initialTab, repository: repository, child: const _ShellView());
  }
}

class _ShellView extends StatefulWidget {
  const _ShellView();

  @override
  State<_ShellView> createState() => _ShellViewState();
}

class _ShellViewState extends State<_ShellView> {
  static const _pages = [
    SupervisorHomeScreen(),
    SupervisorChatsScreen(),
    SupervisorGroupsScreen(),
    SupervisorAnnouncementsScreen(),
    SupervisorProfileScreen(),
  ];

  final _built = <int>{};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _warmUpImages());
  }

  // بعد أول إطار: الصور الثابتة (أيقونات الشريط العادية والمعبّاة، صورة الرئيسية، الشعار) بتنفك بالخلفية
  // فأول ضغطة على أي تبويب ما بتستنى فك صورة
  void _warmUpImages() {
    if (!mounted) return;
    for (final asset in SupervisorTabBar.iconAssets) {
      precacheImage(AssetImage(asset), context);
    }
    precacheImage(ResizeImage(const AssetImage(SupervisorHomeScreen.heroAsset), width: SupervisorHomeScreen.heroCacheWidth(context)), context);
    precacheImage(const AssetImage('$supAssets/logo.png'), context);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SupervisorShellCubit, int>(
      builder: (context, tab) {
        _built.add(tab);
        return Scaffold(
          backgroundColor: Colors.white,
          // الكيبورد ما بيصغّر الشاشة (مقاسات Figma ثابتة)
          resizeToAvoidBottomInset: false,
          body: Stack(
            children: [
              Positioned.fill(
                child: IndexedStack(
                  index: tab,
                  children: [for (var i = 0; i < _pages.length; i++) _built.contains(i) ? _pages[i] : const SizedBox.shrink()],
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: SupervisorTabBar(index: tab, onTap: context.read<SupervisorShellCubit>().select),
              ),
            ],
          ),
        );
      },
    );
  }
}
