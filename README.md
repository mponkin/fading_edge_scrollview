# fading_edge_scrollview

Package providing FadingEdgeScrollView which allows you to build scrollable views with fading edges

## Usage

Create FadingEdgeScrollView by calling one of constructors depending on your scroll view class.
Unfortunately scrollable view don't share same interface so there are separate constructors for:
* ScrollView (most scrollable views inherit from this class) `FadingEdgeScrollView.fromScrollView`
* SingleChildScrollView `FadingEdgeScrollView.fromSingleChildScrollView`
* PageView`FadingEdgeScrollView.fromPageView`
* AnimatedList`FadingEdgeScrollView.fromAnimatedList`
* ListWheelScrollView`FadingEdgeScrollView.fromListWheelScrollView`

View passed as child **MUST** have `controller` set. If you want this controller to be disposed when FadingEdgeScrollView is disposed you can pass `shouldDisposeScrollController` flag set as true to widget constructor.

See documentation and example folder for more information

## Flutter web support problems

Unfortunately this lib has problems working with flutter web. It does not have any platform related code, however it uses `ShaderMask`. `ShaderMask` support for web was recently added to flutter dev channel, and it works not as well as I expect it to.
I will get back to this question when `ShaderMask` for web will work in stable channel.

## Demo

Click to see on Youtube:  
[![ListView with images demo](https://img.youtube.com/vi/71pDlfC9pxU/0.jpg)](https://www.youtube.com/watch?v=71pDlfC9pxU "ListView with images demo")
[![ListView demo](https://img.youtube.com/vi/2kNr3fW0nP8/0.jpg)](https://www.youtube.com/watch?v=2kNr3fW0nP8 "ListView demo")
[![PageView demo](https://img.youtube.com/vi/6nZhJXVwkvU/0.jpg)](https://www.youtube.com/watch?v=6nZhJXVwkvU "PageView demo")
[![SingleChildScrollView demo](https://img.youtube.com/vi/0CJKyvr7fT4/0.jpg)](https://www.youtube.com/watch?v=0CJKyvr7fT4 "SingleChildScrollView demo")
