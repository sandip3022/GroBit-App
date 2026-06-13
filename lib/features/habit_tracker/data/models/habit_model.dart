import 'package:hive/hive.dart';
import '../../domain/entities/habit_entity.dart';

part 'habit_model.g.dart';

@HiveType(typeId: 0)
class HabitModel extends HabitEntity {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String title;
  @HiveField(2)
  final int iconCode;
  @HiveField(3)
  final int colorValue;
  @HiveField(4)
  final List<DateTime> completedDates;
  @HiveField(5)
  final int frequencyIndex; // Store Enum as Int
  @HiveField(6)
  final List<int> targetDays;
  @HiveField(7) 
  final DateTime? createdAt;

  HabitModel({
    required this.id,
    required this.title,
    required this.iconCode,
    required this.colorValue,
    required this.completedDates,
    required this.frequencyIndex,
    required this.targetDays,
    this.createdAt,
  }) : super(
          id: id,
          title: title,
          iconCode: iconCode,
          colorValue: colorValue,
          completedDates: completedDates,
          frequency: HabitFrequency.values.length > frequencyIndex 
    ? HabitFrequency.values[frequencyIndex] 
    : HabitFrequency.daily, 
          targetDays: targetDays,
          createdAt: createdAt,
        );

  factory HabitModel.fromEntity(HabitEntity entity) {
    return HabitModel(
      id: entity.id,
      title: entity.title,
      iconCode: entity.iconCode,
      colorValue: entity.colorValue,
      completedDates: entity.completedDates,
      frequencyIndex: entity.frequency.index, 
      targetDays: entity.targetDays,
      createdAt: entity.createdAt,
    );
  }

  HabitEntity toEntity() {
    return HabitEntity(
      id: id,
      title: title,
      iconCode: iconCode,
      colorValue: colorValue,
      completedDates: completedDates,
      frequency: frequency,
      targetDays: targetDays,
      createdAt: createdAt,
    );
  }
}