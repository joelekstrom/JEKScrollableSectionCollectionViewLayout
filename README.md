# JEKScrollableSectionCollectionViewLayout

A drop-in replacement of `UICollectionViewFlowLayout` which allows horizontally scrolling sections.
Uses UICollectionViewDelegateFlowLayout to query layout information, so usually no code changes
are needed to replace your current flow layout with this one.

Note however that this is _not_ a subclass of `UICollectionViewFlowLayout`, so it might not respond
to certain messages, for example `estimatedItemSize` which is not implemented (yet). This also
means that it will not read measurements set in interface builder on a `UICollectionViewFlowLayout`,
and you have to set the measurements in code. Check the example project for a full setup.

![Animated example](example.gif)

## Features
- Properly supports inserts/deletes/moves (even between different sections)
  - ... since it does not create multiple `UICollectionView`s like this problem is normally solved
- (almost) drop in replacement for `UICollectionViewFlowLayout`
- A simple layout object - doesn't need to subclass or modify `UICollectionView` in any way
  - ... leading to efficient reuse of cells and support for prefetching

## Installation
- CocoaPods: `pod 'JEKScrollableSectionCollectionViewLayout'`
- Simply copy `JEKScrollableSectionCollectionViewLayout.h/.m` into your project

## Planned features
- Support for `sectionHeadersPinToVisibleBounds`
- Support for multiple rows in single section
