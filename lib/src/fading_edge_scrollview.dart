import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// How tall (or wide) each edge's fade is, in logical pixels, and which way
/// the scroll view runs. `0` is a sharp edge.
typedef _EdgeFades = ({AxisDirection direction, double start, double end});

/// Flutter widget for displaying fading edge at start/end of scroll views
class FadingEdgeScrollView extends StatefulWidget {
  /// Default fade extent in logical pixels used by
  /// [FadingEdgeScrollView.fromScrollable].
  static const double defaultExtent = 32.0;

  /// child widget
  final Widget child;

  /// scroll controller of child widget, or `null` when created with
  /// [FadingEdgeScrollView.fromScrollable]
  ///
  /// Look for more documentation at [ScrollView.controller]
  final ScrollController? scrollController;

  /// Whether the scroll view scrolls in the reading direction.
  ///
  /// Look for more documentation at [ScrollView.reverse]
  final bool reverse;

  /// The axis along which child view scrolls
  ///
  /// Look for more documentation at [ScrollView.scrollDirection]
  final Axis scrollDirection;

  /// what part of screen on start half should be covered by fading edge gradient
  /// [gradientFractionOnStart] must be 0 <= [gradientFractionOnStart] <= 1
  /// 0 means no gradient,
  /// 1 means gradients on start half of widget fully covers it
  final double gradientFractionOnStart;

  /// what part of screen on end half should be covered by fading edge gradient
  /// [gradientFractionOnEnd] must be 0 <= [gradientFractionOnEnd] <= 1
  /// 0 means no gradient,
  /// 1 means gradients on end half of widget fully covers it
  final double gradientFractionOnEnd;

  /// Fixed fade size at the start edge in logical pixels, when using
  /// [FadingEdgeScrollView.fromScrollable].
  ///
  /// `null` when fraction-based sizing ([gradientFractionOnStart]) is used.
  final double? startExtent;

  /// Fixed fade size at the end edge in logical pixels, when using
  /// [FadingEdgeScrollView.fromScrollable].
  ///
  /// `null` when fraction-based sizing ([gradientFractionOnEnd]) is used.
  final double? endExtent;

  final bool _useNotifications;

  const FadingEdgeScrollView._internal({
    super.key,
    required this.child,
    required ScrollController this.scrollController,
    required this.reverse,
    required this.scrollDirection,
    required this.gradientFractionOnStart,
    required this.gradientFractionOnEnd,
  })  : assert(gradientFractionOnStart >= 0 && gradientFractionOnStart <= 1),
        assert(gradientFractionOnEnd >= 0 && gradientFractionOnEnd <= 1),
        startExtent = null,
        endExtent = null,
        _useNotifications = false;

  /// Constructor for creating [FadingEdgeScrollView] around any scrollable
  /// widget without requiring a [ScrollController].
  ///
  /// Listens to [ScrollMetricsNotification] and [ScrollUpdateNotification]
  /// from the direct scrollable child (`depth == 0`), automatically inferring
  /// scroll axis, reverse order, and text direction from the scroll metrics.
  ///
  /// Each edge's fade grows smoothly with the scrolled distance up to
  /// [startExtent] / [endExtent] in logical pixels (defaulting to
  /// [defaultExtent]), or up to [gradientFractionOnStart] /
  /// [gradientFractionOnEnd] if fraction-based sizing is provided instead.
  /// Pass `0` for either edge to disable its fade.
  ///
  /// Scrolling repaints only the fade mask without rebuilding widgets.
  const FadingEdgeScrollView.fromScrollable({
    super.key,
    required this.child,
    double? startExtent,
    double? endExtent,
    double? gradientFractionOnStart,
    double? gradientFractionOnEnd,
  })  : assert(
          startExtent == null || gradientFractionOnStart == null,
          'Cannot specify both startExtent and gradientFractionOnStart',
        ),
        assert(
          endExtent == null || gradientFractionOnEnd == null,
          'Cannot specify both endExtent and gradientFractionOnEnd',
        ),
        assert(
          startExtent == null || startExtent >= 0,
          'startExtent must be non-negative',
        ),
        assert(
          endExtent == null || endExtent >= 0,
          'endExtent must be non-negative',
        ),
        assert(
          gradientFractionOnStart == null ||
              (gradientFractionOnStart >= 0 && gradientFractionOnStart <= 1),
          'gradientFractionOnStart must be between 0 and 1',
        ),
        assert(
          gradientFractionOnEnd == null ||
              (gradientFractionOnEnd >= 0 && gradientFractionOnEnd <= 1),
          'gradientFractionOnEnd must be between 0 and 1',
        ),
        scrollController = null,
        reverse = false,
        scrollDirection = Axis.vertical,
        startExtent = gradientFractionOnStart == null
            ? (startExtent ?? defaultExtent)
            : null,
        endExtent = gradientFractionOnEnd == null
            ? (endExtent ?? defaultExtent)
            : null,
        gradientFractionOnStart = gradientFractionOnStart ?? 0,
        gradientFractionOnEnd = gradientFractionOnEnd ?? 0,
        _useNotifications = true;

  /// Constructor for creating [FadingEdgeScrollView] with [ScrollView] as child
  /// child must have [ScrollView.controller] set
  factory FadingEdgeScrollView.fromScrollView({
    Key? key,
    required ScrollView child,
    double gradientFractionOnStart = 0.1,
    double gradientFractionOnEnd = 0.1,
  }) {
    final controller = child.controller;
    if (controller == null) {
      throw Exception("Child must have controller set");
    }

    return FadingEdgeScrollView._internal(
      key: key,
      scrollController: controller,
      scrollDirection: child.scrollDirection,
      reverse: child.reverse,
      gradientFractionOnStart: gradientFractionOnStart,
      gradientFractionOnEnd: gradientFractionOnEnd,
      child: child,
    );
  }

  /// Constructor for creating [FadingEdgeScrollView] with [SingleChildScrollView] as child
  /// child must have [SingleChildScrollView.controller] set
  factory FadingEdgeScrollView.fromSingleChildScrollView({
    Key? key,
    required SingleChildScrollView child,
    double gradientFractionOnStart = 0.1,
    double gradientFractionOnEnd = 0.1,
  }) {
    final controller = child.controller;
    if (controller == null) {
      throw Exception("Child must have controller set");
    }

    return FadingEdgeScrollView._internal(
      key: key,
      scrollController: controller,
      scrollDirection: child.scrollDirection,
      reverse: child.reverse,
      gradientFractionOnStart: gradientFractionOnStart,
      gradientFractionOnEnd: gradientFractionOnEnd,
      child: child,
    );
  }

  /// Constructor for creating [FadingEdgeScrollView] with [PageView] as child
  /// child must have [PageView.controller] set
  factory FadingEdgeScrollView.fromPageView({
    Key? key,
    required PageView child,
    double gradientFractionOnStart = 0.1,
    double gradientFractionOnEnd = 0.1,
  }) {
    final controller = child.controller;
    //ignore: unnecessary_null_comparison
    if (controller == null) {
      throw Exception("Child must have controller set");
    }

    return FadingEdgeScrollView._internal(
      key: key,
      scrollController: controller,
      scrollDirection: child.scrollDirection,
      reverse: child.reverse,
      gradientFractionOnStart: gradientFractionOnStart,
      gradientFractionOnEnd: gradientFractionOnEnd,
      child: child,
    );
  }

  /// Constructor for creating [FadingEdgeScrollView] with [AnimatedList] as child
  /// child must have [AnimatedList.controller] set
  factory FadingEdgeScrollView.fromAnimatedList({
    Key? key,
    required AnimatedList child,
    double gradientFractionOnStart = 0.1,
    double gradientFractionOnEnd = 0.1,
  }) {
    final controller = child.controller;
    if (controller == null) {
      throw Exception("Child must have controller set");
    }

    return FadingEdgeScrollView._internal(
      key: key,
      scrollController: controller,
      scrollDirection: child.scrollDirection,
      reverse: child.reverse,
      gradientFractionOnStart: gradientFractionOnStart,
      gradientFractionOnEnd: gradientFractionOnEnd,
      child: child,
    );
  }

  /// Constructor for creating [FadingEdgeScrollView] with [ScrollView] as child
  /// child must have [ScrollView.controller] set
  factory FadingEdgeScrollView.fromListWheelScrollView({
    Key? key,
    required ListWheelScrollView child,
    double gradientFractionOnStart = 0.1,
    double gradientFractionOnEnd = 0.1,
  }) {
    final controller = child.controller;
    if (controller == null) {
      throw Exception("Child must have controller set");
    }

    return FadingEdgeScrollView._internal(
      key: key,
      scrollController: controller,
      scrollDirection: Axis.vertical,
      reverse: false,
      gradientFractionOnStart: gradientFractionOnStart,
      gradientFractionOnEnd: gradientFractionOnEnd,
      child: child,
    );
  }

  @override
  FadingEdgeScrollViewState createState() => FadingEdgeScrollViewState();
}

class FadingEdgeScrollViewState extends State<FadingEdgeScrollView>
    with WidgetsBindingObserver {
  ScrollController? _controller;
  _ScrollState _scrollState = _ScrollState.notScrollable;
  int lastScrollViewListLength = 0;

  final ValueNotifier<_EdgeFades> _fades = ValueNotifier<_EdgeFades>(
    (direction: AxisDirection.down, start: 0, end: 0),
  );
  ScrollMetrics? _lastMetrics;

  @override
  void initState() {
    super.initState();
    if (!widget._useNotifications) {
      _attachController(widget.scrollController!);
    }
  }

  void _attachController(ScrollController controller) {
    _controller = controller;
    controller.addListener(_updateScrollState);
    WidgetsBinding.instance.addObserver(this);
  }

  void _detachController() {
    final controller = _controller;
    if (controller != null) {
      WidgetsBinding.instance.removeObserver(this);
      controller.removeListener(_updateScrollState);
      _controller = null;
    }
  }

  @override
  void didUpdateWidget(FadingEdgeScrollView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget._useNotifications != oldWidget._useNotifications) {
      if (widget._useNotifications) {
        _detachController();
      } else {
        _lastMetrics = null;
        _attachController(widget.scrollController!);
      }
    } else if (!widget._useNotifications &&
        widget.scrollController != oldWidget.scrollController) {
      _detachController();
      _attachController(widget.scrollController!);
    } else if (widget._useNotifications && _lastMetrics != null) {
      _applyMetrics(_lastMetrics!);
    }
  }

  bool get _controllerIsReady {
    final controller = _controller;
    return controller != null &&
        controller.hasClients &&
        controller.positions.last.hasContentDimensions;
  }

  @override
  void dispose() {
    _detachController();
    _fades.dispose();
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    // Add the shading or remove it when the screen resize (web/desktop) or mobile is rotated
    _updateScrollState();
  }

  bool _onScrollMetrics(ScrollMetrics metrics, int depth) {
    if (depth == 0) {
      _lastMetrics = metrics;
      _applyMetrics(metrics);
    }
    return false;
  }

  void _applyMetrics(ScrollMetrics metrics) {
    final maxStart = widget.startExtent ??
        (metrics.viewportDimension * widget.gradientFractionOnStart * 0.5);
    final maxEnd = widget.endExtent ??
        (metrics.viewportDimension * widget.gradientFractionOnEnd * 0.5);
    _fades.value = (
      direction: metrics.axisDirection,
      start: _fadeAmount(metrics.extentBefore, maxStart),
      end: _fadeAmount(metrics.extentAfter, maxEnd),
    );
  }

  double _fadeAmount(double scrolledPast, double maxExtent) {
    if (scrolledPast <= 0 ||
        !scrolledPast.isFinite ||
        maxExtent <= 0 ||
        !maxExtent.isFinite) {
      return 0;
    }
    return clampDouble(scrolledPast, 0, maxExtent);
  }

  @override
  Widget build(BuildContext context) {
    if (widget._useNotifications) {
      return NotificationListener<ScrollMetricsNotification>(
        onNotification: (notification) =>
            _onScrollMetrics(notification.metrics, notification.depth),
        child: NotificationListener<ScrollUpdateNotification>(
          onNotification: (notification) =>
              _onScrollMetrics(notification.metrics, notification.depth),
          child: _FadeMask(
            fades: _fades,
            child: widget.child,
          ),
        ),
      );
    }

    return ShaderMask(
      shaderCallback: (bounds) => _createShaderGradient().createShader(
        bounds.shift(Offset(-bounds.left, -bounds.top)),
        textDirection: Directionality.of(context),
      ),
      blendMode: BlendMode.dstIn,
      // Catching ScrollMetricsNotifications from the Scrollable child.
      // This way we get notified if the size of the underlying list changes.
      // We then re-evaluate if Gradient should be shown.
      child: NotificationListener<ScrollMetricsNotification>(
        child: widget.child,
        onNotification: (_) {
          _updateScrollState();
          // Enable notification to still bubble up.
          return false;
        },
      ),
    );
  }

  Gradient _createShaderGradient() => LinearGradient(
        begin: _gradientStart,
        end: _gradientEnd,
        stops: [
          0,
          widget.gradientFractionOnStart * 0.5,
          1 - widget.gradientFractionOnEnd * 0.5,
          1,
        ],
        colors: _getColors(
            widget.gradientFractionOnStart > 0 &&
                _scrollState.isShowGradientAtStart,
            widget.gradientFractionOnEnd > 0 &&
                _scrollState.isShowGradientAtEnd),
      );

  AlignmentGeometry get _gradientStart =>
      widget.scrollDirection == Axis.vertical
          ? _verticalStart
          : _horizontalStart;

  AlignmentGeometry get _gradientEnd =>
      widget.scrollDirection == Axis.vertical ? _verticalEnd : _horizontalEnd;

  Alignment get _verticalStart =>
      widget.reverse ? Alignment.bottomCenter : Alignment.topCenter;

  Alignment get _verticalEnd =>
      widget.reverse ? Alignment.topCenter : Alignment.bottomCenter;

  AlignmentDirectional get _horizontalStart => widget.reverse
      ? AlignmentDirectional.centerEnd
      : AlignmentDirectional.centerStart;

  AlignmentDirectional get _horizontalEnd => widget.reverse
      ? AlignmentDirectional.centerStart
      : AlignmentDirectional.centerEnd;

  static const _opaque = Color(0xFFFFFFFF);
  static const _transparent = Color(0x00000000);

  List<Color> _getColors(bool showGradientAtStart, bool showGradientAtEnd) => [
        (showGradientAtStart ? _transparent : _opaque),
        _opaque,
        _opaque,
        (showGradientAtEnd ? _transparent : _opaque)
      ];

  void _updateScrollState() {
    if (!_controllerIsReady) {
      return;
    }

    final position = _controller!.positions.last;
    final offset = position.pixels;
    final minOffset = position.minScrollExtent;
    final maxOffset = position.maxScrollExtent;

    final isScrolledToEnd = offset >= maxOffset;
    final isScrolledToStart = offset <= minOffset;

    final scrollState = switch ((isScrolledToStart, isScrolledToEnd)) {
      (true, true) => _ScrollState.notScrollable,
      (true, false) => _ScrollState.scrollableAtStart,
      (false, true) => _ScrollState.scrollableAtEnd,
      (false, false) => _ScrollState.scrollableInTheMiddle
    };

    if (_scrollState != scrollState) {
      setState(() {
        _scrollState = scrollState;
      });
    }
  }
}

enum _ScrollState {
  notScrollable,
  scrollableAtStart,
  scrollableAtEnd,
  scrollableInTheMiddle;

  bool get isShowGradientAtStart =>
      this == _ScrollState.scrollableAtEnd ||
      this == _ScrollState.scrollableInTheMiddle;

  bool get isShowGradientAtEnd =>
      this == _ScrollState.scrollableAtStart ||
      this == _ScrollState.scrollableInTheMiddle;
}

class _FadeMask extends SingleChildRenderObjectWidget {
  const _FadeMask({
    required this.fades,
    super.child,
  });

  final ValueListenable<_EdgeFades> fades;

  @override
  _RenderFadeMask createRenderObject(BuildContext context) =>
      _RenderFadeMask(fades);

  @override
  void updateRenderObject(BuildContext context, _RenderFadeMask renderObject) {
    renderObject.fades = fades;
  }
}

/// Paints its child through a gradient mask that fades it out at the edges
/// described by [fades], repainting directly without widget rebuilds.
class _RenderFadeMask extends RenderProxyBox {
  _RenderFadeMask(ValueListenable<_EdgeFades> fades) : _fades = fades;

  ValueListenable<_EdgeFades> _fades;

  set fades(ValueListenable<_EdgeFades> value) {
    if (_fades == value) return;
    if (attached) {
      _fades.removeListener(markNeedsPaint);
    }
    _fades = value;
    if (attached) {
      _fades.addListener(markNeedsPaint);
    }
    markNeedsPaint();
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _fades.addListener(markNeedsPaint);
  }

  @override
  void detach() {
    _fades.removeListener(markNeedsPaint);
    super.detach();
  }

  @override
  bool get alwaysNeedsCompositing => child != null;

  @override
  ShaderMaskLayer? get layer => super.layer as ShaderMaskLayer?;

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child == null) return;
    final value = _fades.value;
    if ((value.start == 0 && value.end == 0) || size.isEmpty) {
      layer = null;
      context.paintChild(child!, offset);
      return;
    }
    layer = (layer ?? ShaderMaskLayer())
      ..shader = _gradient(value).createShader(Offset.zero & size)
      ..maskRect = offset & size
      ..blendMode = BlendMode.dstIn;
    context.pushLayer(layer!, super.paint, offset);
  }

  LinearGradient _gradient(_EdgeFades value) {
    final length = axisDirectionToAxis(value.direction) == Axis.vertical
        ? size.height
        : size.width;
    // Cap each fade at half the viewport so start and end stops never cross.
    double stop(double fade) =>
        length == 0 ? 0.5 : clampDouble(fade / length, 0, 0.5);

    const opaque = Color(0xFF000000);
    const clear = Color(0x00000000);
    final (begin, end) = switch (value.direction) {
      AxisDirection.down => (Alignment.topCenter, Alignment.bottomCenter),
      AxisDirection.up => (Alignment.bottomCenter, Alignment.topCenter),
      AxisDirection.right => (Alignment.centerLeft, Alignment.centerRight),
      AxisDirection.left => (Alignment.centerRight, Alignment.centerLeft),
    };
    return LinearGradient(
      begin: begin,
      end: end,
      colors: [
        if (value.start > 0) clear else opaque,
        opaque,
        opaque,
        if (value.end > 0) clear else opaque,
      ],
      stops: [0, stop(value.start), 1 - stop(value.end), 1],
    );
  }
}
