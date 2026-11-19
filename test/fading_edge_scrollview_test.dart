import 'dart:ui' as ui;

import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

const _red = Color(0xFFF44336);
const _blue = Color(0xFF2196F3);
const _green = Color(0xFF4CAF50);
const _orange = Color(0xFFFF9800);
const _purple = Color(0xFF9C27B0);
const _teal = Color(0xFF009688);
const _indigo = Color(0xFF3F51B5);
const _amber = Color(0xFFFFC107);

/// Reads the alpha channel (0–255) at logical coordinate ([x], [y]) from the
/// rendered [RepaintBoundary] identified by [boundaryKey].
Future<int> sampleAlpha(
  WidgetTester tester,
  GlobalKey boundaryKey,
  int x,
  int y,
) async {
  final boundary =
      boundaryKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  final image = await tester.runAsync(() => boundary.toImage());
  final byteData = await tester.runAsync(
    () => image!.toByteData(format: ui.ImageByteFormat.rawRgba),
  );
  final width = image!.width;
  image.dispose();

  final offset = (y * width + x) * 4;
  return byteData!.getUint8(offset + 3);
}

Widget _wrapApp(
  Widget child, {
  TextDirection textDirection = TextDirection.ltr,
}) {
  return Directionality(
    textDirection: textDirection,
    child: MediaQuery(
      data: const MediaQueryData(size: Size(200, 200)),
      child: Center(
        child: SizedBox.square(
          dimension: 200,
          child: child,
        ),
      ),
    ),
  );
}

void main() {
  group('FadingEdgeScrollView (existing factories)', () {
    test('fromScrollView throws when controller is null', () {
      expect(
        () => FadingEdgeScrollView.fromScrollView(
          child: ListView(),
        ),
        throwsException,
      );
    });

    test('fromSingleChildScrollView throws when controller is null', () {
      expect(
        () => FadingEdgeScrollView.fromSingleChildScrollView(
          child: const SingleChildScrollView(),
        ),
        throwsException,
      );
    });

    test('fromPageView throws when controller is null', () {
      expect(
        () => FadingEdgeScrollView.fromPageView(
          child: PageView(controller: null),
        ),
        throwsException,
      );
    });

    test('fromAnimatedList throws when controller is null', () {
      expect(
        () => FadingEdgeScrollView.fromAnimatedList(
          child: AnimatedList(
            itemBuilder: (context, index, animation) => const SizedBox(),
          ),
        ),
        throwsException,
      );
    });

    test('fromListWheelScrollView throws when controller is null', () {
      expect(
        () => FadingEdgeScrollView.fromListWheelScrollView(
          child: ListWheelScrollView(
            itemExtent: 50,
            children: const [],
          ),
        ),
        throwsException,
      );
    });

    test('asserts gradientFraction bounds', () {
      final controller = ScrollController();
      addTearDown(controller.dispose);

      expect(
        () => FadingEdgeScrollView.fromScrollView(
          gradientFractionOnStart: -0.1,
          child: ListView(controller: controller),
        ),
        throwsAssertionError,
      );
      expect(
        () => FadingEdgeScrollView.fromScrollView(
          gradientFractionOnStart: 1.1,
          child: ListView(controller: controller),
        ),
        throwsAssertionError,
      );
      expect(
        () => FadingEdgeScrollView.fromScrollView(
          gradientFractionOnEnd: -0.1,
          child: ListView(controller: controller),
        ),
        throwsAssertionError,
      );
      expect(
        () => FadingEdgeScrollView.fromScrollView(
          gradientFractionOnEnd: 1.1,
          child: ListView(controller: controller),
        ),
        throwsAssertionError,
      );
    });

    testWidgets('non-scrollable list has no fade at start or end',
        (tester) async {
      final controller = ScrollController();
      addTearDown(controller.dispose);
      final boundaryKey = GlobalKey();

      await tester.pumpWidget(
        _wrapApp(
          RepaintBoundary(
            key: boundaryKey,
            child: FadingEdgeScrollView.fromScrollView(
              gradientFractionOnStart: 0.4,
              gradientFractionOnEnd: 0.4,
              child: ListView(
                controller: controller,
                children: const [
                  SizedBox(height: 100, child: ColoredBox(color: _red)),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(await sampleAlpha(tester, boundaryKey, 100, 1), 255);
      expect(await sampleAlpha(tester, boundaryKey, 100, 98), 255);
    });

    testWidgets(
        'fromScrollView fades end at top, both in middle, start at bottom',
        (tester) async {
      final controller = ScrollController();
      addTearDown(controller.dispose);
      final boundaryKey = GlobalKey();

      await tester.pumpWidget(
        _wrapApp(
          RepaintBoundary(
            key: boundaryKey,
            child: FadingEdgeScrollView.fromScrollView(
              gradientFractionOnStart: 0.4,
              gradientFractionOnEnd: 0.4,
              child: ListView(
                controller: controller,
                children: const [
                  SizedBox(height: 600, child: ColoredBox(color: _red)),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      // At top: start is sharp, end is faded.
      expect(await sampleAlpha(tester, boundaryKey, 100, 1), 255);
      expect(await sampleAlpha(tester, boundaryKey, 100, 100), 255);
      expect(await sampleAlpha(tester, boundaryKey, 100, 199), lessThan(20));

      // Scroll to middle: both start and end are faded.
      controller.jumpTo(200);
      await tester.pump();
      expect(await sampleAlpha(tester, boundaryKey, 100, 0), lessThan(20));
      expect(await sampleAlpha(tester, boundaryKey, 100, 100), 255);
      expect(await sampleAlpha(tester, boundaryKey, 100, 199), lessThan(20));

      // Scroll to bottom: start is faded, end is sharp.
      controller.jumpTo(400);
      await tester.pump();
      expect(await sampleAlpha(tester, boundaryKey, 100, 0), lessThan(20));
      expect(await sampleAlpha(tester, boundaryKey, 100, 198), 255);
    });

    testWidgets('respects zero gradientFraction on start or end',
        (tester) async {
      final controller = ScrollController(initialScrollOffset: 200);
      addTearDown(controller.dispose);
      final boundaryKey = GlobalKey();

      await tester.pumpWidget(
        _wrapApp(
          RepaintBoundary(
            key: boundaryKey,
            child: FadingEdgeScrollView.fromScrollView(
              gradientFractionOnStart: 0,
              gradientFractionOnEnd: 0.4,
              child: ListView(
                controller: controller,
                children: const [
                  SizedBox(height: 600, child: ColoredBox(color: _blue)),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(await sampleAlpha(tester, boundaryKey, 100, 0), 255);
      expect(await sampleAlpha(tester, boundaryKey, 100, 199), lessThan(20));
    });

    testWidgets('supports reversed vertical scroll view', (tester) async {
      final controller = ScrollController();
      addTearDown(controller.dispose);
      final boundaryKey = GlobalKey();

      await tester.pumpWidget(
        _wrapApp(
          RepaintBoundary(
            key: boundaryKey,
            child: FadingEdgeScrollView.fromScrollView(
              gradientFractionOnStart: 0.4,
              gradientFractionOnEnd: 0.4,
              child: ListView(
                controller: controller,
                reverse: true,
                children: const [
                  SizedBox(height: 600, child: ColoredBox(color: _green)),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      // Reversed list at offset 0: start is at bottom (sharp), end is at top (faded).
      expect(await sampleAlpha(tester, boundaryKey, 100, 0), lessThan(20));
      expect(await sampleAlpha(tester, boundaryKey, 100, 199), 255);
    });

    testWidgets('supports horizontal LTR and RTL scroll views', (tester) async {
      final ltrController = ScrollController();
      addTearDown(ltrController.dispose);
      final ltrKey = GlobalKey();

      await tester.pumpWidget(
        _wrapApp(
          RepaintBoundary(
            key: ltrKey,
            child: FadingEdgeScrollView.fromScrollView(
              gradientFractionOnStart: 0.4,
              gradientFractionOnEnd: 0.4,
              child: ListView(
                controller: ltrController,
                scrollDirection: Axis.horizontal,
                children: const [
                  SizedBox(width: 600, child: ColoredBox(color: _orange)),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(await sampleAlpha(tester, ltrKey, 0, 100), 255);
      expect(await sampleAlpha(tester, ltrKey, 199, 100), lessThan(20));

      final rtlController = ScrollController();
      addTearDown(rtlController.dispose);
      final rtlKey = GlobalKey();

      await tester.pumpWidget(
        _wrapApp(
          RepaintBoundary(
            key: rtlKey,
            child: FadingEdgeScrollView.fromScrollView(
              gradientFractionOnStart: 0.4,
              gradientFractionOnEnd: 0.4,
              child: ListView(
                controller: rtlController,
                scrollDirection: Axis.horizontal,
                children: const [
                  SizedBox(width: 600, child: ColoredBox(color: _orange)),
                ],
              ),
            ),
          ),
          textDirection: TextDirection.rtl,
        ),
      );
      await tester.pump();

      expect(await sampleAlpha(tester, rtlKey, 199, 100), 255);
      expect(await sampleAlpha(tester, rtlKey, 0, 100), lessThan(20));
    });

    testWidgets('updates fade when content grows after first layout',
        (tester) async {
      final controller = ScrollController();
      addTearDown(controller.dispose);
      final boundaryKey = GlobalKey();

      Widget buildWithHeight(double height) => _wrapApp(
            RepaintBoundary(
              key: boundaryKey,
              child: FadingEdgeScrollView.fromScrollView(
                gradientFractionOnStart: 0.4,
                gradientFractionOnEnd: 0.4,
                child: ListView(
                  controller: controller,
                  children: [
                    SizedBox(
                      height: height,
                      child: const ColoredBox(color: _purple),
                    ),
                  ],
                ),
              ),
            ),
          );

      await tester.pumpWidget(buildWithHeight(100));
      await tester.pump();
      expect(await sampleAlpha(tester, boundaryKey, 100, 98), 255);

      await tester.pumpWidget(buildWithHeight(600));
      await tester.pump();
      expect(await sampleAlpha(tester, boundaryKey, 100, 199), lessThan(20));
    });

    testWidgets('fromSingleChildScrollView fades scrollable content',
        (tester) async {
      final controller = ScrollController();
      addTearDown(controller.dispose);
      final boundaryKey = GlobalKey();

      await tester.pumpWidget(
        _wrapApp(
          RepaintBoundary(
            key: boundaryKey,
            child: FadingEdgeScrollView.fromSingleChildScrollView(
              gradientFractionOnStart: 0.4,
              gradientFractionOnEnd: 0.4,
              child: SingleChildScrollView(
                controller: controller,
                child: const SizedBox(
                  height: 600,
                  width: 200,
                  child: ColoredBox(color: _teal),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(await sampleAlpha(tester, boundaryKey, 100, 0), 255);
      expect(await sampleAlpha(tester, boundaryKey, 100, 199), lessThan(20));
    });

    testWidgets('fromPageView fades horizontal pages', (tester) async {
      final controller = PageController();
      addTearDown(controller.dispose);
      final boundaryKey = GlobalKey();

      await tester.pumpWidget(
        _wrapApp(
          RepaintBoundary(
            key: boundaryKey,
            child: FadingEdgeScrollView.fromPageView(
              gradientFractionOnStart: 0.4,
              gradientFractionOnEnd: 0.4,
              child: PageView(
                controller: controller,
                children: const [
                  ColoredBox(color: _red),
                  ColoredBox(color: _green),
                  ColoredBox(color: _blue),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(await sampleAlpha(tester, boundaryKey, 0, 100), 255);
      expect(await sampleAlpha(tester, boundaryKey, 199, 100), lessThan(20));
    });

    testWidgets('fromAnimatedList fades scrollable items', (tester) async {
      final controller = ScrollController();
      addTearDown(controller.dispose);
      final boundaryKey = GlobalKey();

      await tester.pumpWidget(
        _wrapApp(
          RepaintBoundary(
            key: boundaryKey,
            child: FadingEdgeScrollView.fromAnimatedList(
              gradientFractionOnStart: 0.4,
              gradientFractionOnEnd: 0.4,
              child: AnimatedList(
                controller: controller,
                initialItemCount: 10,
                itemBuilder: (context, index, animation) => const SizedBox(
                  height: 60,
                  child: ColoredBox(color: _indigo),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(await sampleAlpha(tester, boundaryKey, 100, 0), 255);
      expect(await sampleAlpha(tester, boundaryKey, 100, 199), lessThan(20));
    });

    testWidgets('fromListWheelScrollView fades scrollable wheel',
        (tester) async {
      final controller = FixedExtentScrollController();
      addTearDown(controller.dispose);
      final boundaryKey = GlobalKey();

      await tester.pumpWidget(
        _wrapApp(
          RepaintBoundary(
            key: boundaryKey,
            child: FadingEdgeScrollView.fromListWheelScrollView(
              gradientFractionOnStart: 0.4,
              gradientFractionOnEnd: 0.4,
              child: ListWheelScrollView(
                controller: controller,
                itemExtent: 60,
                children: List.generate(
                  10,
                  (_) => const ColoredBox(color: _amber),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(await sampleAlpha(tester, boundaryKey, 100, 199), lessThan(20));
    });
  });
}
