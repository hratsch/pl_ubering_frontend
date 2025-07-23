// lib/models/trip.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'trip.freezed.dart';
part 'trip.g.dart';

@freezed
class Trip with _$Trip {
  factory Trip({
    required int id,
    required DateTime date,
    required double grossEarnings,
    double? milesDriven,
    double? hoursWorked,
    double? gasCost,
    double? tolls,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Trip;

  factory Trip.fromJson(Map<String, dynamic> json) => _$TripFromJson(json);
}

@freezed
class TripCreate with _$TripCreate {
  factory TripCreate({
    required DateTime date,
    required double grossEarnings,
    double? milesDriven,
    double? hoursWorked,
    double? gasCost,
    double? tolls,
  }) = _TripCreate;

  factory TripCreate.fromJson(Map<String, dynamic> json) => _$TripCreateFromJson(json);
}