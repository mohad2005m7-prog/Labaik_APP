import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../auth/data/account_registry.dart';

// -------------------------------------------------------------
// تثبيت المحادثات (اختيار المستخدم على جهازه، لكل حساب): chat_pins:<email> → { conversationId: true/false }
// المحادثة اللي ما إلها اختيار بتضل على الافتراضي (مجموعتي مثبّتة زي Figma)
// -------------------------------------------------------------
class ChatPins {
  Future<String> _key() async => 'chat_pins:${await AccountRegistry.currentEmail() ?? ''}';

  Future<Map<String, bool>> load() async {
    final raw = (await SharedPreferences.getInstance()).getString(await _key());
    if (raw == null) return {};
    try {
      return {for (final e in (jsonDecode(raw) as Map<String, dynamic>).entries) e.key: e.value == true};
    } catch (_) {
      return {};
    }
  }

  Future<void> set(String conversationId, bool pinned) async {
    final all = await load()..[conversationId] = pinned;
    await (await SharedPreferences.getInstance()).setString(await _key(), jsonEncode(all));
  }
}
