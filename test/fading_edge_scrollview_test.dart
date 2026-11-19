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

  group('FadingEdgeScrollView.fromScrollable', () {
    test('asserts parameter bounds and mutual exclusion', () {
      expect(
        () => FadingEdgeScrollView.fromScrollable(
          startExtent: -1,
          child: ListView(),
        ),
        throwsAssertionError,
      );
      expect(
        () => FadingEdgeScrollView.fromScrollable(
          endExtent: -1,
          child: ListView(),
        ),
        throwsAssertionError,
      );
      expect(
        () => FadingEdgeScrollView.fromScrollable(
          gradientFractionOnStart: -0.1,
          child: ListView(),
        ),
        throwsAssertionError,
      );
      expect(
        () => FadingEdgeScrollView.fromScrollable(
          gradientFractionOnEnd: 1.1,
          child: ListView(),
        ),
        throwsAssertionError,
      );
      expect(
        () => FadingEdgeScrollView.fromScrollable(
          startExtent: 16,
          gradientFractionOnStart: 0.1,
          child: ListView(),
        ),
        throwsAssertionError,
      );
      expect(
        () => FadingEdgeScrollView.fromScrollable(
          endExtent: 16,
          gradientFractionOnEnd: 0.1,
          child: ListView(),
        ),
        throwsAssertionError,
      );
    });

    testWidgets('list that fits gets no fade and skips ShaderMaskLayer',
        (tester) async {
      final boundaryKey = GlobalKey();

      await tester.pumpWidget(
        _wrapApp(
          RepaintBoundary(
            key: boundaryKey,
            child: FadingEdgeScrollView.fromScrollable(
              child: ListView(
                children: const [
                  SizedBox(height: 100, child: ColoredBox(color: _red)),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(tester.layers.whereType<ShaderMaskLayer>(), isEmpty);
      expect(await sampleAlpha(tester, boundaryKey, 100, 0), 255);
      expect(await sampleAlpha(tester, boundaryKey, 100, 99), 255);
    });

    testWidgets(
        'fades end at top, both in middle, start at bottom without controller',
        (tester) async {
      final boundaryKey = GlobalKey();

      await tester.pumpWidget(
        _wrapApp(
          RepaintBoundary(
            key: boundaryKey,
            child: FadingEdgeScrollView.fromScrollable(
              child: ListView(
                children: const [
                  SizedBox(height: 600, child: ColoredBox(color: _red)),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      // At top: start is sharp, end is faded (32 px), ShaderMaskLayer pushed.
      expect(tester.layers.whereType<ShaderMaskLayer>(), hasLength(1));
      expect(await sampleAlpha(tester, boundaryKey, 100, 0), 255);
      expect(await sampleAlpha(tester, boundaryKey, 100, 100), 255);
      expect(await sampleAlpha(tester, boundaryKey, 100, 199), lessThan(20));

      // Scroll to middle: both edges faded.
      await tester.drag(find.byType(ListView), const Offset(0, -200));
      await tester.pump();
      expect(await sampleAlpha(tester, boundaryKey, 100, 0), lessThan(20));
      expect(await sampleAlpha(tester, boundaryKey, 100, 100), 255);
      expect(await sampleAlpha(tester, boundaryKey, 100, 199), lessThan(20));

      // Scroll to bottom: start is faded, end is sharp.
      await tester.drag(find.byType(ListView), const Offset(0, -300));
      await tester.pump();
      expect(await sampleAlpha(tester, boundaryKey, 100, 0), lessThan(20));
      expect(await sampleAlpha(tester, boundaryKey, 100, 199), 255);
    });

    testWidgets(
        'fade height grows smoothly with scroll while edge stays transparent',
        (tester) async {
      final boundaryKey = GlobalKey();

      await tester.pumpWidget(
        _wrapApp(
          RepaintBoundary(
            key: boundaryKey,
            child: FadingEdgeScrollView.fromScrollable(
              startExtent: 32,
              endExtent: 32,
              child: ListView(
                children: const [
                  SizedBox(height: 600, child: ColoredBox(color: _blue)),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      // Drag 16 px (half of extent=32).
      await tester.drag(find.byType(ListView), const Offset(0, -16));
      await tester.pump();

      // The edge itself is fully transparent (not an alpha ramp).
      expect(await sampleAlpha(tester, boundaryKey, 100, 0), lessThan(20));
      // Halfway through the 16 px fade (y=8) is roughly half alpha.
      expect(
        await sampleAlpha(tester, boundaryKey, 100, 8),
        inInclusiveRange(95, 165),
      );
      // Past 16 px (y=20) is already fully opaque even though max extent is 32.
      expect(await sampleAlpha(tester, boundaryKey, 100, 20), 255);

      // Drag further so extentBefore >= 32.
      await tester.drag(find.byType(ListView), const Offset(0, -84));
      await tester.pump();

      // Now y=16 is halfway through the full 32 px fade, and y=36 is opaque.
      expect(await sampleAlpha(tester, boundaryKey, 100, 0), lessThan(20));
      expect(
        await sampleAlpha(tester, boundaryKey, 100, 16),
        inInclusiveRange(95, 165),
      );
      expect(await sampleAlpha(tester, boundaryKey, 100, 36), 255);
    });

    testWidgets('supports zero extent to disable an edge and custom extents',
        (tester) async {
      final boundaryKey = GlobalKey();

      await tester.pumpWidget(
        _wrapApp(
          RepaintBoundary(
            key: boundaryKey,
            child: FadingEdgeScrollView.fromScrollable(
              startExtent: 0,
              endExtent: 64,
              child: ListView(
                children: const [
                  SizedBox(height: 600, child: ColoredBox(color: _green)),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      await tester.drag(find.byType(ListView), const Offset(0, -150));
      await tester.pump();

      // Start disabled -> sharp at top.
      expect(await sampleAlpha(tester, boundaryKey, 100, 0), 255);
      // End fade is 64 px tall -> halfway at y=168 (200 - 32).
      expect(await sampleAlpha(tester, boundaryKey, 100, 199), lessThan(20));
      expect(
        await sampleAlpha(tester, boundaryKey, 100, 168),
        inInclusiveRange(95, 165),
      );
      expect(await sampleAlpha(tester, boundaryKey, 100, 130), 255);
    });

    testWidgets('updates fade when extent properties change on rebuild',
        (tester) async {
      final boundaryKey = GlobalKey();

      Widget buildWidget(double endExtent) => _wrapApp(
            RepaintBoundary(
              key: boundaryKey,
              child: FadingEdgeScrollView.fromScrollable(
                startExtent: 0,
                endExtent: endExtent,
                child: ListView(
                  children: const [
                    SizedBox(height: 600, child: ColoredBox(color: _teal)),
                  ],
                ),
              ),
            ),
          );

      await tester.pumpWidget(buildWidget(32));
      await tester.pump();
      expect(await sampleAlpha(tester, boundaryKey, 100, 199), lessThan(20));
      expect(tester.layers.whereType<ShaderMaskLayer>(), hasLength(1));

      await tester.pumpWidget(buildWidget(0));
      await tester.pump();
      expect(await sampleAlpha(tester, boundaryKey, 100, 199), 255);
      expect(tester.layers.whereType<ShaderMaskLayer>(), isEmpty);
    });

    testWidgets('supports fraction-based sizing on fromScrollable',
        (tester) async {
      final boundaryKey = GlobalKey();

      await tester.pumpWidget(
        _wrapApp(
          RepaintBoundary(
            key: boundaryKey,
            child: FadingEdgeScrollView.fromScrollable(
              gradientFractionOnStart: 0.4,
              gradientFractionOnEnd: 0.4,
              child: ListView(
                children: const [
                  SizedBox(height: 600, child: ColoredBox(color: _indigo)),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      // Viewport height is 200; 0.4 * 0.5 = 0.2 -> 40 px fade at bottom.
      expect(await sampleAlpha(tester, boundaryKey, 100, 0), 255);
      expect(await sampleAlpha(tester, boundaryKey, 100, 199), lessThan(20));
      // Halfway through 40 px fade (y=180) should be roughly half alpha.
      expect(
        await sampleAlpha(tester, boundaryKey, 100, 180),
        inInclusiveRange(95, 165),
      );
      expect(await sampleAlpha(tester, boundaryKey, 100, 155), 255);
    });

    testWidgets('follows reversed vertical list', (tester) async {
      final boundaryKey = GlobalKey();

      await tester.pumpWidget(
        _wrapApp(
          RepaintBoundary(
            key: boundaryKey,
            child: FadingEdgeScrollView.fromScrollable(
              child: ListView(
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

      // Reversed list starts at bottom (sharp) and fades top (end).
      expect(await sampleAlpha(tester, boundaryKey, 100, 0), lessThan(20));
      expect(await sampleAlpha(tester, boundaryKey, 100, 199), 255);
    });

    testWidgets('supports horizontal LTR and RTL lists', (tester) async {
      final ltrKey = GlobalKey();
      await tester.pumpWidget(
        _wrapApp(
          RepaintBoundary(
            key: ltrKey,
            child: FadingEdgeScrollView.fromScrollable(
              child: ListView(
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

      final rtlKey = GlobalKey();
      await tester.pumpWidget(
        _wrapApp(
          RepaintBoundary(
            key: rtlKey,
            child: FadingEdgeScrollView.fromScrollable(
              child: ListView(
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

    testWidgets('ignores nested scroll views', (tester) async {
      final boundaryKey = GlobalKey();

      await tester.pumpWidget(
        _wrapApp(
          RepaintBoundary(
            key: boundaryKey,
            child: FadingEdgeScrollView.fromScrollable(
              child: ListView(
                children: [
                  SizedBox(
                    height: 80,
                    child: ListView(
                      key: const Key('inner'),
                      scrollDirection: Axis.horizontal,
                      children: const [
                        SizedBox(width: 600, child: ColoredBox(color: _amber)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      await tester.drag(find.byKey(const Key('inner')), const Offset(-100, 0));
      await tester.pump();

      // Outer vertical list fits, so no ShaderMaskLayer should be pushed.
      expect(tester.layers.whereType<ShaderMaskLayer>(), isEmpty);
      expect(await sampleAlpha(tester, boundaryKey, 100, 40), 255);
    });

    testWidgets('updates when content grows and shrinks after first layout',
        (tester) async {
      final boundaryKey = GlobalKey();

      Widget buildWithHeight(double height) => _wrapApp(
            RepaintBoundary(
              key: boundaryKey,
              child: FadingEdgeScrollView.fromScrollable(
                child: ListView(
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
      expect(tester.layers.whereType<ShaderMaskLayer>(), isEmpty);

      await tester.pumpWidget(buildWithHeight(600));
      await tester.pump();
      expect(tester.layers.whereType<ShaderMaskLayer>(), hasLength(1));
      expect(await sampleAlpha(tester, boundaryKey, 100, 199), lessThan(20));

      await tester.pumpWidget(buildWithHeight(100));
      await tester.pump();
      expect(tester.layers.whereType<ShaderMaskLayer>(), isEmpty);
    });

    testWidgets('repaints without rebuilding widgets while scrolling',
        (tester) async {
      final boundaryKey = GlobalKey();
      var builds = 0;

      await tester.pumpWidget(
        _wrapApp(
          RepaintBoundary(
            key: boundaryKey,
            child: FadingEdgeScrollView.fromScrollable(
              child: Builder(
                builder: (context) {
                  builds++;
                  return ListView(
                    children: const [
                      SizedBox(height: 600, child: ColoredBox(color: _red)),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      builds = 0;

      await tester.drag(find.byType(ListView), const Offset(0, -100));
      await tester.pump();

      expect(builds, 0);
      expect(await sampleAlpha(tester, boundaryKey, 100, 0), lessThan(20));
    });

    testWidgets('caps fades at half the viewport so they never cross',
        (tester) async {
      final boundaryKey = GlobalKey();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: MediaQuery(
            data: const MediaQueryData(size: Size(200, 40)),
            child: Center(
              child: SizedBox(
                width: 200,
                height: 40,
                child: RepaintBoundary(
                  key: boundaryKey,
                  child: FadingEdgeScrollView.fromScrollable(
                    startExtent: 32,
                    endExtent: 32,
                    child: ListView(
                      children: const [
                        SizedBox(height: 200, child: ColoredBox(color: _blue)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      await tester.drag(find.byType(ListView), const Offset(0, -60));
      await tester.pump();

      // Both edges faded, and the exact midpoint (y=20) remains opaque.
      expect(await sampleAlpha(tester, boundaryKey, 100, 0), lessThan(20));
      expect(
        await sampleAlpha(tester, boundaryKey, 100, 20),
        greaterThanOrEqualTo(240),
      );
      expect(await sampleAlpha(tester, boundaryKey, 100, 39), lessThan(20));
    });

    testWidgets('works with SingleChildScrollView, CustomScrollView, PageView',
        (tester) async {
      final singleKey = GlobalKey();
      await tester.pumpWidget(
        _wrapApp(
          RepaintBoundary(
            key: singleKey,
            child: const FadingEdgeScrollView.fromScrollable(
              child: SingleChildScrollView(
                child: SizedBox(
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
      expect(await sampleAlpha(tester, singleKey, 100, 0), 255);
      expect(await sampleAlpha(tester, singleKey, 100, 199), lessThan(20));

      final customKey = GlobalKey();
      await tester.pumpWidget(
        _wrapApp(
          RepaintBoundary(
            key: customKey,
            child: const FadingEdgeScrollView.fromScrollable(
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 600,
                      child: ColoredBox(color: _indigo),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(await sampleAlpha(tester, customKey, 100, 0), 255);
      expect(await sampleAlpha(tester, customKey, 100, 199), lessThan(20));

      final pageKey = GlobalKey();
      await tester.pumpWidget(
        _wrapApp(
          RepaintBoundary(
            key: pageKey,
            child: FadingEdgeScrollView.fromScrollable(
              child: PageView(
                children: const [
                  ColoredBox(color: _red),
                  ColoredBox(color: _green),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(await sampleAlpha(tester, pageKey, 0, 100), 255);
      expect(await sampleAlpha(tester, pageKey, 199, 100), lessThan(20));
    });
  });
}
