import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_config.dart';
import '../../../../core/utils/json_fields.dart';
import '../../../../core/utils/token_storage.dart';
import '../../../auth/data/token_refresher.dart';
import '../../domain/entities/budget.dart';
import '../../domain/entities/expense.dart';

// -------------------------------------------------------------
// الميزانية على سيرفر لبيك (حتى ترجع على أي جهاز):
//   GET /me/budget → { totalAmount, currency, expenses: [{ id, amount, category, note?, spentAtUtc }] }
//   PUT /me/budget → نفس الشكل (استبدال كامل — المصروف: amount > 0، category لحد 100 حرف)
// اسم المصروف بالتطبيق = category بالسيرفر
// -------------------------------------------------------------
class BudgetApi {
  final ApiClient _client;

  BudgetApi(this._client);

  factory BudgetApi.server() => BudgetApi(ApiClient(baseUrl: ApiConfig.baseUrl, accessToken: TokenStorage.getAccessToken, refreshToken: TokenRefresher.refresh, timeout: const Duration(seconds: 20)));

  Future<Budget> get() async => fromJson(unwrapData(await _client.getJson('/me/budget')));

  Future<void> put(Budget budget) => _client.putJson('/me/budget', body: toJson(budget));

  static Map<String, dynamic> toJson(Budget b) => {
        'totalAmount': b.total,
        'currency': 'SAR',
        'expenses': [
          for (final e in b.expenses)
            if (e.amount > 0)
              {
                'amount': e.amount,
                'category': e.title.trim().isEmpty ? '-' : (e.title.trim().length > 100 ? e.title.trim().substring(0, 100) : e.title.trim()),
                'spentAtUtc': e.createdAt.toUtc().toIso8601String(),
              },
        ],
      };

  static Budget fromJson(Object? data) {
    if (data is! Map<String, dynamic>) return Budget.empty;
    final expenses = [
      for (final e in (data['expenses'] as List? ?? const []).whereType<Map<String, dynamic>>())
        Expense(
          id: e['id']?.toString() ?? '',
          title: e['category']?.toString() ?? '',
          amount: (e['amount'] as num?)?.toDouble() ?? 0,
          createdAt: DateTime.tryParse(e['spentAtUtc']?.toString() ?? '')?.toLocal() ?? DateTime.now(),
        ),
    ]..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return Budget(total: (data['totalAmount'] as num?)?.toDouble() ?? 0, expenses: expenses);
  }
}
