import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:habit_tracker_app_2026/features/habit_tracker/domain/entities/habit_entity.dart';
import 'package:habit_tracker_app_2026/features/habit_tracker/presentation/widgets/habit_tile.dart';

// 1. Create a Mock Entity so we can easily control the streak and title
class MockHabitEntity extends Mock implements HabitEntity {}

void main() {
  late MockHabitEntity mockHabit;

  setUp(() {
    mockHabit = MockHabitEntity();
    // Setup default mock values needed by the UI
    when(() => mockHabit.title).thenReturn('Read 10 Pages');
    when(() => mockHabit.colorValue).thenReturn(0xFF4CAF50); // Green
    when(() => mockHabit.iconCode).thenReturn(Icons.book.codePoint);
  });

  group('HabitTile Widget Tests', () {
    
    testWidgets('renders title and 0-streak subtitle correctly', (WidgetTester tester) async {
      // Arrange: Force streak to 0
      when(() => mockHabit.currentStreak).thenReturn(0);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HabitTile(
              habit: mockHabit,
              isCompletedToday: false,
              confettiController: ConfettiController(duration: const Duration(seconds: 1)),
              onToggle: () {},
              onLongPressBody: () {},
              onEdit: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      // Assert: Verify Title and the specific 0-streak text
      expect(find.text('Read 10 Pages'), findsOneWidget);
      expect(find.text('Start your journey today'), findsOneWidget);
      
      // Verify checkmark is NOT showing
      expect(find.byIcon(Icons.check), findsNothing);
    });

    testWidgets('renders streak badge when streak > 0', (WidgetTester tester) async {
      // Arrange: Force streak to 5
      when(() => mockHabit.currentStreak).thenReturn(5);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HabitTile(
              habit: mockHabit,
              isCompletedToday: false,
              confettiController: ConfettiController(duration: const Duration(seconds: 1)),
              onToggle: () {},
              onLongPressBody: () {},
              onEdit: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      // Assert: Verify the fire icon and the correct streak text are shown
      expect(find.text('5 Day Streak'), findsOneWidget);
      expect(find.byIcon(Icons.local_fire_department_rounded), findsOneWidget);
      // Ensure the 0-streak text is gone
      expect(find.text('Start your journey today'), findsNothing);
    });

    testWidgets('triggers all callbacks correctly (Toggle, LongPress, Edit, Delete)', (WidgetTester tester) async {
      when(() => mockHabit.currentStreak).thenReturn(1);
      
      // Arrange: Trackers for our callbacks
      bool toggleTapped = false;
      bool longPressTriggered = false;
      bool editTapped = false;
      bool deleteTapped = false;
      final confettiController = ConfettiController(
        duration: const Duration(seconds: 1),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HabitTile(
              habit: mockHabit,
              isCompletedToday: false,
              confettiController: confettiController,
              onToggle: () => toggleTapped = true,
              onLongPressBody: () => longPressTriggered = true,
              onEdit: () => editTapped = true,
              onDelete: () => deleteTapped = true,
            ),
          ),
        ),
      );

      // 1. Test Long Press on the main body
      await tester.longPress(find.byType(InkWell).first);
      expect(longPressTriggered, true);

      // 2. Test Toggle Tap (Tapping the specific check button area)
      // Because we used a GestureDetector wrapping the AnimatedContainer
      await tester.tap(find.byType(GestureDetector).first);
      expect(toggleTapped, false);

      // 3. Test Menu actions (Requires opening the menu first)
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle(); // Wait for the popup menu animation to finish

      // Tap Edit
      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();
      expect(editTapped, true);

      // Open menu again for Delete
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      // Tap Delete
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      expect(deleteTapped, true);
    });

    testWidgets('renders completed state with checkmark icon', (WidgetTester tester) async {
      when(() => mockHabit.currentStreak).thenReturn(1);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HabitTile(
              habit: mockHabit,
              isCompletedToday: true, // <--- SET TO TRUE
              confettiController: ConfettiController(duration: const Duration(seconds: 1)),
              onToggle: () {},
              onLongPressBody: () {},
              onEdit: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      // Assert: Verify the check icon is physically present in the tree
      expect(find.byIcon(Icons.check), findsOneWidget);
    });
  });
}