import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radarscholar/widgets/interactive_3d_name_card.dart';

void main() {
  group('Interactive3dNameCard Widget Tests', () {
    testWidgets('renders front face by default and responds to tap flip', (
      tester,
    ) async {
      bool? flippedState;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 360,
                height: 500,
                child: Interactive3dNameCard(
                  front: const Text('FRONT_FACE'),
                  back: const Text('BACK_FACE'),
                  onFlipChanged: (val) => flippedState = val,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('FRONT_FACE'), findsOneWidget);
      expect(find.text('BACK_FACE'), findsNothing);

      // Tap on card to trigger flip
      await tester.tap(find.text('FRONT_FACE'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      expect(flippedState, isTrue);
      expect(find.text('BACK_FACE'), findsOneWidget);
      expect(find.text('FRONT_FACE'), findsNothing);
    });

    testWidgets('renders back face when isFlipped is true initially', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 360,
                height: 500,
                child: Interactive3dNameCard(
                  isFlipped: true,
                  front: Text('FRONT_SIDE'),
                  back: Text('BACK_SIDE'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('BACK_SIDE'), findsOneWidget);
      expect(find.text('FRONT_SIDE'), findsNothing);
    });

    testWidgets('responds to horizontal drag gesture to flip side', (
      tester,
    ) async {
      bool? flippedState;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 360,
                height: 500,
                child: Interactive3dNameCard(
                  front: const Text('DRAG_FRONT'),
                  back: const Text('DRAG_BACK'),
                  onFlipChanged: (val) => flippedState = val,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('DRAG_FRONT'), findsOneWidget);

      // Drag across horizontally by 200px to spin around Y-axis
      await tester.drag(find.text('DRAG_FRONT'), const Offset(200, 0));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(flippedState, isTrue);
      expect(find.text('DRAG_BACK'), findsOneWidget);
    });
  });
}

