import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/company_overview.dart';
import '../../domain/repositories/company_repository.dart';

// -------------------------------------------------------------
// رئيسية الشركة: الترحيب والأرقام
// -------------------------------------------------------------
class CompanyHomeCubit extends Cubit<CompanyOverview> {
  CompanyHomeCubit(this._repository) : super(CompanyOverview.empty);

  final CompanyRepository _repository;

  Future<void> load() async {
    try {
      final overview = await _repository.overview();
      if (!isClosed) emit(overview);
    } catch (_) {
      // بنضل على الموجود
    }
  }
}
