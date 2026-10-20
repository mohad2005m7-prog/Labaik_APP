import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/design_scale.dart';
import '../../../../core/utils/figma_canvas.dart';
import '../../domain/repositories/company_repository.dart';
import '../controllers/company_controller.dart';
import '../cubits/company_groups_cubit.dart';
import '../cubits/company_home_cubit.dart';
import '../cubits/company_trips_cubit.dart';
import '../widgets/company_tab_bar.dart';
import 'company_groups_screen.dart';
import 'company_home_screen.dart';
import 'company_profile_screen.dart';
import 'company_trips_screen.dart';

// -------------------------------------------------------------
// واجهة الشركة بعد الدخول: "نافبار الشركة" بأربع تبويبات
// التبويب بينبني أول مرة بيفتحه وبعدها بيحافظ على حالته
// -------------------------------------------------------------
class CompanyShell extends StatefulWidget {
  final CompanyRepository? repository;

  const CompanyShell({super.key, this.repository});

  @override
  State<CompanyShell> createState() => _CompanyShellState();
}

class _CompanyShellState extends State<CompanyShell> {
  late final CompanyRepository _repository = widget.repository ?? CompanyController.repository();
  late final _home = CompanyHomeCubit(_repository)..load();
  late final _trips = CompanyTripsCubit(_repository)..load();
  late final _groups = CompanyGroupsCubit(_repository)..load();

  var _tab = CompanyTab.home;
  final _built = <CompanyTab>{CompanyTab.home};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _warmUpImages());
  }

  void _warmUpImages() {
    if (!mounted) return;
    for (final asset in CompanyTabBar.iconAssets) {
      precacheImage(AssetImage(asset), context);
    }
    precacheImage(ResizeImage(const AssetImage(CompanyHomeScreen.heroAsset), width: CompanyHomeScreen.heroCacheWidth(context)), context);
  }

  void _select(CompanyTab tab) {
    // الرجوع لتبويب مفتوح من قبل بيحدّث بياناته من السيرفر (اللي تغيّر من جهاز تاني أو من المشرف)
    if (_built.contains(tab)) {
      switch (tab) {
        case CompanyTab.home:
          _home.load();
        case CompanyTab.trips:
          _trips.load();
        case CompanyTab.groups:
          _groups.load();
        case CompanyTab.profile:
          break;
      }
    }
    setState(() {
      _tab = tab;
      _built.add(tab);
    });
  }

  @override
  void dispose() {
    _home.close();
    _trips.close();
    _groups.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = FigmaCanvas(DesignScale.of(context));
    return RepositoryProvider.value(
      value: _repository,
      child: MultiBlocProvider(
        providers: [BlocProvider.value(value: _home), BlocProvider.value(value: _trips), BlocProvider.value(value: _groups)],
        child: Scaffold(
          backgroundColor: Colors.white,
          resizeToAvoidBottomInset: false,
          body: Stack(
            children: [
              Positioned.fill(
                child: IndexedStack(
                  index: _tabIndex(_tab),
                  children: [
                    const CompanyHomeScreen(),
                    _built.contains(CompanyTab.trips) ? const CompanyTripsScreen() : const SizedBox.shrink(),
                    _built.contains(CompanyTab.groups) ? const CompanyGroupsScreen() : const SizedBox.shrink(),
                    _built.contains(CompanyTab.profile) ? const CompanyProfileScreen() : const SizedBox.shrink(),
                  ],
                ),
              ),
              Positioned.fill(child: SafeArea(child: Stack(clipBehavior: Clip.none, children: [CompanyTabBar(c: c, selected: _tab, onTab: _select)]))),
            ],
          ),
        ),
      ),
    );
  }

  static int _tabIndex(CompanyTab tab) => switch (tab) {
        CompanyTab.home => 0,
        CompanyTab.trips => 1,
        CompanyTab.groups => 2,
        CompanyTab.profile => 3,
      };
}
