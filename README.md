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

[![ListView with images demo](http://img.youtube.com/vi/71pDlfC9pxU/0.jpg)](http://www.youtube.com/watch?v=71pDlfC9pxU "ListView with images demo")
[![ListView demo](http://img.youtube.com/vi/2kNr3fW0nP8/0.jpg)](http://www.youtube.com/watch?v=2kNr3fW0nP8 "ListView demo")
[![PageView demo](http://img.youtube.com/vi/6nZhJXVwkvU/0.jpg)](http://www.youtube.com/watch?v=6nZhJXVwkvU "PageView demo")
[![SingleChildScrollView demo](http://img.youtube.com/vi/0CJKyvr7fT4/0.jpg)](http://www.youtube.com/watch?v=0CJKyvr7fT4 "SingleChildScrollView demo")
