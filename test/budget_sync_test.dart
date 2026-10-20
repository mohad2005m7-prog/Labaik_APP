import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:labaik/core/network/api_client.dart';
import 'package:labaik/features/budget/data/repositories/budget_repository_impl.dart';
import 'package:labaik/features/budget/data/sources/budget_api.dart';
import 'package:labaik/features/budget/data/sources/budget_local_source.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// سيرفر ميزانية وهمي: [stored] = اللي عليه — [online] false = بلا نت
class _Server {
  Map<String, dynamic>? stored;
  bool online = true;
  int puts = 0;

  ApiClient client() => ApiClient(
        baseUrl: 'https://api.test/api/v1',
        accessToken: () async => 'tok',
        refreshToken: () async => null,
        client: MockClient((r) async {
          if (!online) throw http.ClientException('offline');
          if (r.method == 'PUT') {
            puts++;
            stored = jsonDecode(r.body) as Map<String, dynamic>;
            return http.Response(jsonEncode(stored), 200, headers: {'content-type': 'application/json'});
          }
          return http.Response(jsonEncode(stored ?? {'totalAmount': 0, 'currency': 'SAR', 'expenses': []}), 200, headers: {'content-type': 'application/json'});
        }),
      );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<void> settle() => Future<void>.delayed(const Duration(milliseconds: 10));

  test('every change is saved on the device and pushed to /me/budget (title → category)', () async {
    final server = _Server();
    final repo = BudgetRepositoryImpl(api: BudgetApi(server.client()));
    await repo.setTotal(5000);
    await repo.addExpense(title: 'طعام', amount: 120);
    await settle();
    expect(server.stored!['totalAmount'], 5000);
    expect((server.stored!['expenses'] as List).single, containsPair('category', 'طعام'));
    expect(await BudgetLocalSource().isDirty(), isFalse);
  });

  test('offline changes stay on the device and are pushed when the screen opens again', () async {
    final server = _Server()..online = false;
    final repo = BudgetRepositoryImpl(api: BudgetApi(server.client()));
    await repo.setTotal(3000);
    await settle();
    expect(await BudgetLocalSource().isDirty(), isTrue);
    expect((await repo.load()).total, 3000); // بلا نت: اللي على الجهاز
    server.online = true;
    expect((await repo.load()).total, 3000);
    expect(server.stored!['totalAmount'], 3000);
    expect(await BudgetLocalSource().isDirty(), isFalse);
  });

  test('a new device gets the budget from the server', () async {
    final server = _Server()
      ..stored = {
        'totalAmount': 4000,
        'currency': 'SAR',
        'expenses': [
          {'id': 'e1', 'amount': 50, 'category': 'مواصلات', 'note': null, 'spentAtUtc': '2026-10-20T10:00:00Z'},
          {'id': 'e2', 'amount': 80, 'category': 'هدايا', 'note': null, 'spentAtUtc': '2026-10-21T10:00:00Z'},
        ],
      };
    final budget = await BudgetRepositoryImpl(api: BudgetApi(server.client())).load();
    expect(budget.total, 4000);
    expect(budget.expenses.map((e) => e.title), ['هدايا', 'مواصلات']); // الأحدث أول
    expect(budget.spent, 130);
    expect(server.puts, 0);
  });
}
