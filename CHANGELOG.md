## [4.1.1] - 25.02.2024

* Updated example to set controller to PageView

## [4.1.0] - 25.02.2024

* Added check for nullable controller in constructor for PageView 

## [4.0.0] - 27.11.2023.

* Removed `shouldDisposeScrollController` field
* Fixed fading effect not appearing on child rebuilds (issue [#19][i19], thanks to CoolDude53, felixwoestmann)
* Fixed error when scrollController is attached to multiple views (issue [#20][i20], thanks to scris)

## [3.0.0] - 30.05.2022.

* Flutter 3.0 compatibility (issue [#16][i16], thanks to ruslic19)

## [2.0.1] - 20.09.2021.

* Fixed an issue caused by usage of controller without proper content dimensions ([#15][i15])

## [2.0.0] - 13.03.2021.

* Added support for null-safety
* Added option to use ListWheelScrollView as a child (thanks to moda20)

## [1.1.4] - 29.06.2020.

* Fixed bug which happened when view is disposed earlier than PostFrameCallback happened

## [1.1.3] - 19.06.2020.

* Added support for right to left text direction

## [1.1.2] - 19.06.2020.

* Hiding fade if content too small to be scrollable (thanks to georgeherby and dannyalbuquerque)

## [1.1.1] - 20.05.2020.

* Fixed unwanted scroll controller disposal. Added flag 'shouldDisposeScrollController' if it's still required 

## [1.1.0] - 13.01.2020.

* Added support for AnimatedList (thanks to davidmartos96)

## [1.0.2] - 06.08.2019.

* documentation fixes

## [1.0.1] - 06.08.2019.

* Fixed bug for situations where scroll controller was not attached to scrollview
* added more examples

## [1.0.0] - 20.07.2019.

* Initial publication

[i15]: https://github.com/mponkin/fading_edge_scrollview/issues/15
[i16]: https://github.com/mponkin/fading_edge_scrollview/issues/16
[i19]: https://github.com/mponkin/fading_edge_scrollview/issues/19
[i20]: https://github.com/mponkin/fading_edge_scrollview/issues/20