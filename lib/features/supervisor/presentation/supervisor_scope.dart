import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/l10n/app_language.dart';
import '../data/repositories/supervisor_repository_impl.dart';
import '../domain/repositories/supervisor_repository.dart';
import 'cubits/announcements_cubit.dart';
import 'cubits/supervisor_content_cubits.dart';
import 'cubits/supervisor_profile_cubit.dart';
import 'cubits/supervisor_settings_cubit.dart';
import 'cubits/supervisor_shell_cubit.dart';

// -------------------------------------------------------------
// SupervisorScope — حقن الاعتماديات لواجهة المشرف:
// الـ Repository والـ Cubits المشتركة بتنعمل مرة وحدة هون وبتعيش طول ما المشرف جوّا التطبيق
// (التبويبات والشاشات الفرعية كلها بتشوف نفس البيانات — تعديل الملف أو إرسال إعلان بيبيّن بكل مكان فوراً)
// لما تتغير لغة التطبيق المحتوى بيرجع ينحمل باللغة الجديدة.
// -------------------------------------------------------------
class SupervisorScope extends StatefulWidget {
  final Widget child;
  final int initialTab;

  /// للاختبارات (أو لما يتبدل بـ API حقيقي)
  final SupervisorRepository? repository;

  const SupervisorScope({super.key, required this.child, this.initialTab = 0, this.repository});

  /// الشاشات الفرعية بتنفتح بـ Navigator (برا شجرة الـ Scope) — فبننقل نفس الـ Cubits إلها
  static Widget Function(Widget child) capture(BuildContext context) {
    final repository = context.read<SupervisorRepository>();
    final providers = [
      BlocProvider.value(value: context.read<SupervisorShellCubit>()),
      BlocProvider.value(value: context.read<SupervisorProfileCubit>()),
      BlocProvider.value(value: context.read<SupervisorGroupsCubit>()),
      BlocProvider.value(value: context.read<AnnouncementsCubit>()),
      BlocProvider.value(value: context.read<AnnouncementFormCubit>()),
      BlocProvider.value(value: context.read<SupervisorChatsCubit>()),
      BlocProvider.value(value: context.read<SupervisorNotificationsCubit>()),
      BlocProvider.value(value: context.read<SupervisorSettingsCubit>()),
    ];
    return (child) => RepositoryProvider.value(value: repository, child: MultiBlocProvider(providers: providers, child: child));
  }

  @override
  State<SupervisorScope> createState() => _SupervisorScopeState();
}

class _SupervisorScopeState extends State<SupervisorScope> {
  late final SupervisorRepository _repository = widget.repository ?? SupervisorRepositoryImpl();
  late final _shell = SupervisorShellCubit(_repository, initialTab: widget.initialTab);
  late final _profile = SupervisorProfileCubit(_repository)..load();
  late final _groups = SupervisorGroupsCubit(_repository)..load();
  late final _announcements = AnnouncementsCubit(_repository)..load();
  late final _form = AnnouncementFormCubit(_repository, _announcements)..restore();
  late final _chats = SupervisorChatsCubit(_repository)
    ..load()
    ..watch(_repository.chatsChanged());
  late final _notifications = SupervisorNotificationsCubit(_repository)
    ..load()
    ..watch(_repository.notificationsChanged());
  late final _settings = SupervisorSettingsCubit(_repository)..load();

  @override
  void initState() {
    super.initState();
    AppLanguage.notifier.addListener(_reloadContent);
  }

  void _reloadContent() {
    _groups.load();
    _announcements.load();
    _chats.load();
    _notifications.load();
  }

  @override
  void dispose() {
    AppLanguage.notifier.removeListener(_reloadContent);
    for (final cubit in [_shell, _profile, _groups, _announcements, _form, _chats, _notifications, _settings]) {
      cubit.close();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider.value(
      value: _repository,
      child: MultiBlocProvider(
        providers: [
          BlocProvider.value(value: _shell),
          BlocProvider.value(value: _profile),
          BlocProvider.value(value: _groups),
          BlocProvider.value(value: _announcements),
          BlocProvider.value(value: _form),
          BlocProvider.value(value: _chats),
          BlocProvider.value(value: _notifications),
          BlocProvider.value(value: _settings),
        ],
        child: widget.child,
      ),
    );
  }
}
