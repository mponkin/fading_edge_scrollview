import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// Builds a striped list using solid colored bands (no fonts/text) so golden
/// images render deterministically across environments.
ListView _stripedList({
  required ScrollController controller,
  int count = 12,
  Axis scrollDirection = Axis.vertical,
  bool reverse = false,
}) {
  const palette = [
    Color(0xFF1E88E5),
    Color(0xFF43A047),
    Color(0xFFFB8C00),
    Color(0xFF8E24AA),
  ];
  return ListView.builder(
    controller: controller,
    scrollDirection: scrollDirection,
    reverse: reverse,
    itemCount: count,
    itemBuilder: (context, index) => SizedBox(
      width: 40,
      height: 40,
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: ColoredBox(color: palette[index % palette.length]),
      ),
    ),
  );
}

Widget _goldenFrame(
  Widget child, {
  TextDirection textDirection = TextDirection.ltr,
}) {
  return Directionality(
    textDirection: textDirection,
    child: MediaQuery(
      data: const MediaQueryData(size: Size(200, 200)),
      child: Center(
        child: RepaintBoundary(
          child: ColoredBox(
            color: const Color(0xFFF5F5F5),
            child: SizedBox.square(
              dimension: 200,
              child: child,
            ),
          ),
        ),
      ),
    ),
  );
}

void main() {
  group('FadingEdgeScrollView goldens (existing factories)', () {
    testWidgets('vertical list at start, middle, and end', (tester) async {
      final controller = ScrollController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        _goldenFrame(
          FadingEdgeScrollView.fromScrollView(
            gradientFractionOnStart: 0.4,
            gradientFractionOnEnd: 0.4,
            child: _stripedList(controller: controller),
          ),
        ),
      );
      await tester.pump();
      await expectLater(
        find.byType(RepaintBoundary).first,
        matchesGoldenFile('goldens/from_scroll_view_start.png'),
      );

      controller.jumpTo(140);
      await tester.pump();
      await expectLater(
        find.byType(RepaintBoundary).first,
        matchesGoldenFile('goldens/from_scroll_view_middle.png'),
      );

      controller.jumpTo(controller.position.maxScrollExtent);
      await tester.pump();
      await expectLater(
        find.byType(RepaintBoundary).first,
        matchesGoldenFile('goldens/from_scroll_view_end.png'),
      );
    });

    testWidgets('non-scrollable list that fits', (tester) async {
      final controller = ScrollController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        _goldenFrame(
          FadingEdgeScrollView.fromScrollView(
            gradientFractionOnStart: 0.4,
            gradientFractionOnEnd: 0.4,
            child: _stripedList(controller: controller, count: 3),
          ),
        ),
      );
      await tester.pump();
      await expectLater(
        find.byType(RepaintBoundary).first,
        matchesGoldenFile('goldens/from_scroll_view_fits.png'),
      );
    });

    testWidgets('horizontal LTR list in middle', (tester) async {
      final controller = ScrollController(initialScrollOffset: 140);
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        _goldenFrame(
          FadingEdgeScrollView.fromScrollView(
            gradientFractionOnStart: 0.4,
            gradientFractionOnEnd: 0.4,
            child: _stripedList(
              controller: controller,
              scrollDirection: Axis.horizontal,
            ),
          ),
        ),
      );
      await tester.pump();
      await expectLater(
        find.byType(RepaintBoundary).first,
        matchesGoldenFile('goldens/from_scroll_view_horizontal_middle.png'),
      );
    });
  });
}
