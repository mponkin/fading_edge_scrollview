# fading_edge_scrollview

Package providing FadingEdgeScrollView which allows you to build scrollable views with fading edges

## Usage

### Controller-free (recommended)

Use `FadingEdgeScrollView.fromScrollable` to wrap any scrollable widget (`ListView`, `GridView`, `CustomScrollView`, `SingleChildScrollView`, `PageView`, etc.) without creating or managing a `ScrollController`:

```dart
FadingEdgeScrollView.fromScrollable(
  child: ListView.builder(
    itemCount: 30,
    itemBuilder: (context, index) => Text('Item #$index'),
  ),
)
```

`fromScrollable`:
* Automatically detects scroll axis, `reverse`, and `TextDirection` (LTR/RTL) from scroll notifications (`depth == 0`, ignoring nested scroll views).
* Smoothly grows each edge's fade height as you scroll, up to `startExtent` / `endExtent` in logical pixels (defaults to `32.0`, pass `0` to disable an edge).
* Also supports fraction-based sizing via `gradientFractionOnStart` / `gradientFractionOnEnd` when pixel extents are not specified.
* Repaints only the fade mask while scrolling without rebuilding widgets, and skips the mask layer entirely when nothing is faded.

### With an explicit `ScrollController`

You can also use the type-specific factory constructors with an explicit controller:
* ScrollView (most scrollable views inherit from this class) `FadingEdgeScrollView.fromScrollView`
* SingleChildScrollView `FadingEdgeScrollView.fromSingleChildScrollView`
* PageView `FadingEdgeScrollView.fromPageView`
* AnimatedList `FadingEdgeScrollView.fromAnimatedList`
* ListWheelScrollView `FadingEdgeScrollView.fromListWheelScrollView`

For these constructors, the view passed as child **MUST** have `controller` set.

See documentation and example folder for more information

## Breaking change in version 4.0.0

Field `shouldDisposeScrollController` was removed. I was not realizing how widgets should work when I added it.
If you were using it - move `scrollController` creation and disposal to some `StatefulWidget`.

## Demo

Click to see on Youtube:  
[![ListView with images demo](https://img.youtube.com/vi/71pDlfC9pxU/0.jpg)](https://www.youtube.com/watch?v=71pDlfC9pxU "ListView with images demo")
[![ListView demo](https://img.youtube.com/vi/2kNr3fW0nP8/0.jpg)](https://www.youtube.com/watch?v=2kNr3fW0nP8 "ListView demo")
[![PageView demo](https://img.youtube.com/vi/6nZhJXVwkvU/0.jpg)](https://www.youtube.com/watch?v=6nZhJXVwkvU "PageView demo")
[![SingleChildScrollView demo](https://img.youtube.com/vi/0CJKyvr7fT4/0.jpg)](https://www.youtube.com/watch?v=0CJKyvr7fT4 "SingleChildScrollView demo")
