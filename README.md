# fading_edge_scrollview

Package providing FadingEdgeScrollView which allows you to build scrollable views with fading edges

## Usage

Create FadingEdgeScrollView by calling one of constructors depending on your scroll view class.
Unfortunately scrollable view don't share same interface so there are separate constructors for:
* ScrollView (most scrollable views inherit from this class) `FadingEdgeScrollView.fromScrollView`
* SingleChildScrollView `FadingEdgeScrollView.fromSingleChildScrollView`
* PageView`FadingEdgeScrollView.fromPageView`

View passed as child **MUST** have `controller` set. If you want this controller to be disposed when FadingEdgeScrollView is disposed you can pass `shouldDisposeScrollController` flag set as true to widget constructor.

See documentation and example folder for more information

## Flutter web support

Unfortunately this lib does not support flutter web. 
It does not have any platform related code, however it uses `ShaderMask` widget which is not support for Flutter web yet.
You can get more info about the problem on [this page](https://github.com/flutter/flutter/issues/44152)

## Demo

Click to see on Youtube:  
[![ListView with images demo](https://img.youtube.com/vi/71pDlfC9pxU/0.jpg)](https://www.youtube.com/watch?v=71pDlfC9pxU "ListView with images demo")
[![ListView demo](https://img.youtube.com/vi/2kNr3fW0nP8/0.jpg)](https://www.youtube.com/watch?v=2kNr3fW0nP8 "ListView demo")
[![PageView demo](https://img.youtube.com/vi/6nZhJXVwkvU/0.jpg)](https://www.youtube.com/watch?v=6nZhJXVwkvU "PageView demo")
[![SingleChildScrollView demo](https://img.youtube.com/vi/0CJKyvr7fT4/0.jpg)](https://www.youtube.com/watch?v=0CJKyvr7fT4 "SingleChildScrollView demo")
