import 'package:equatable/equatable.dart';

// -------------------------------------------------------------
// مصروف سجّله المعتمر: شو اشترى، قديش دفع (ر.س)، وإيمتى
// -------------------------------------------------------------
class Expense extends Equatable {
  final String id;
  final String title;
  final double amount;
  final DateTime createdAt;

  const Expense({required this.id, required this.title, required this.amount, required this.createdAt});

  @override
  List<Object> get props => [id, title, amount, createdAt];
}
