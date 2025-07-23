// lib/models/expense.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'expense.freezed.dart';
part 'expense.g.dart';

@freezed
class Expense with _$Expense {
  factory Expense({
    required int id,
    required DateTime date,
    required String category,
    required double amount,
    String? description,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Expense;

  factory Expense.fromJson(Map<String, dynamic> json) => _$ExpenseFromJson(json);
}

@freezed
class ExpenseCreate with _$ExpenseCreate {
  factory ExpenseCreate({
    required DateTime date,
    required String category,
    required double amount,
    String? description,
  }) = _ExpenseCreate;

  factory ExpenseCreate.fromJson(Map<String, dynamic> json) => _$ExpenseCreateFromJson(json);
}