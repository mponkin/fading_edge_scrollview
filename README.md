# fading_edge_scrollview

Package providing FadingEdgeScrollView which allows you to build scrollable views with fading edges

## Usage

Create FadingEdgeScrollView by calling one of constructors depending on your scroll view class.
Unfortunately scrollable view don't share same interface so there are separate constructors for:
* ScrollView (most scrollable views inherit from this class) `FadingEdgeScrollView.fromScrollView`
* SingleChildScrollView `FadingEdgeScrollView.fromSingleChildScrollView`
* PageView`FadingEdgeScrollView.fromPageView`

View passed as child **MUST** have `controller` set

See documentation and example folder for more information

## Demo

![Demo](https://ponkin.dev/fading_edge_scrollview_demo.gif)

