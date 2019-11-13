import Foundation
import XCTest

class LayoutMeasurements : NSObject, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, JEKCollectionViewDelegateScrollableSectionLayout {
    var itemSize = CGSize(width: 10, height: 10)
    var headerSize = CGSize.zero
    var footerSize = CGSize.zero
    var sectionInsets = UIEdgeInsets.zero
    var interItemSpacing: CGFloat = 0
    var numberOfSections: Int = 1
    var numberOfItems: Int = 2
    var useFLowLayout = false
}

class Tests : XCTestCase {
    var layout: JEKScrollableSectionCollectionViewLayout!
    var collectionView: UICollectionView!
    var measurements: LayoutMeasurements!

    override func setUp() {
        layout = JEKScrollableSectionCollectionViewLayout()
        collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: 320, height: 100), collectionViewLayout: layout)
        measurements = LayoutMeasurements()
        collectionView.dataSource = self.measurements
        collectionView.delegate = self.measurements
    }

    func testInterItemSpacing() {
        measurements.interItemSpacing = 5
        layout.prepare()
        let expectedOrigin = CGPoint(x: measurements.itemSize.width + measurements.interItemSpacing, y: 0)
        let expectedFrame = CGRect(origin: expectedOrigin, size: measurements.itemSize)
        let attributes = layout.layoutAttributesForItem(at: IndexPath(item: 1, section: 0))
        XCTAssertEqual(attributes?.frame, expectedFrame)
    }

    func testSectionInsets() {
        measurements.sectionInsets = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 50)
        layout.prepare()
        let expectedOrigin = CGPoint(x: measurements.sectionInsets.left + measurements.itemSize.width,
                                     y: measurements.sectionInsets.top)
        let expectedFrame = CGRect(origin: expectedOrigin, size: measurements.itemSize)
        let attributes = layout.layoutAttributesForItem(at: IndexPath(row: 1, section: 0))
        XCTAssertEqual(attributes?.frame, expectedFrame)

        let expectedContentSize = CGSize(width: collectionView.frame.size.width,
                                         height: measurements.sectionInsets.top + measurements.itemSize.height + measurements.sectionInsets.bottom)
        XCTAssertEqual(layout.collectionViewContentSize, expectedContentSize)
    }

    func testFlowLayout() {
        measurements.useFLowLayout = true
        measurements.numberOfItems = 11
        measurements.itemSize = CGSize(width: 32, height: 32)
        layout.prepare()

        let expectedOrigin = CGPoint(x: measurements.sectionInsets.left,
                                     y: measurements.sectionInsets.top +
                                        measurements.interItemSpacing +
                                        measurements.itemSize.height)
        let expectedFrame = CGRect(origin: expectedOrigin, size: measurements.itemSize)
        let attributes = layout.layoutAttributesForItem(at: IndexPath(item: 10, section: 0))
        XCTAssertEqual(attributes?.frame, expectedFrame)

        let expectedContentSize = CGSize(width: collectionView.frame.size.width,
                                         height: measurements.sectionInsets.top +
                                            measurements.itemSize.height * 2 +
                                            measurements.interItemSpacing +
                                            measurements.sectionInsets.bottom)
        XCTAssertEqual(layout.collectionViewContentSize, expectedContentSize)
    }

    func testFlowLayoutInterItemSpacing() {
        measurements.useFLowLayout = true
        measurements.numberOfItems = 10
        measurements.itemSize = CGSize(width: 32, height: 32)
        measurements.interItemSpacing = 1
        layout.prepare()

        let expectedOrigin = CGPoint(x: measurements.sectionInsets.left,
                                     y: measurements.sectionInsets.top +
                                        measurements.interItemSpacing +
                                        measurements.itemSize.height)
        let expectedFrame = CGRect(origin: expectedOrigin, size: measurements.itemSize)
        let attributes = layout.layoutAttributesForItem(at: IndexPath(item: 9, section: 0))
        XCTAssertEqual(attributes?.frame, expectedFrame)

        let expectedContentSize = CGSize(width: collectionView.frame.size.width,
                                         height: measurements.sectionInsets.top +
                                            measurements.itemSize.height * 2 +
                                            measurements.interItemSpacing +
                                            measurements.sectionInsets.bottom)
        XCTAssertEqual(layout.collectionViewContentSize, expectedContentSize)
    }

    func testFlowLayoutSectionInsets() {
        measurements.useFLowLayout = true
        measurements.numberOfItems = 10
        measurements.itemSize = CGSize(width: 32, height: 32)
        measurements.interItemSpacing = 1
        measurements.sectionInsets = UIEdgeInsets(top: 10, left: 20, bottom: 30, right: 50)
        layout.prepare()

        let expectedOrigin = CGPoint(x: measurements.sectionInsets.left,
                                     y: measurements.sectionInsets.top +
                                        measurements.interItemSpacing +
                                        measurements.itemSize.height)
        let expectedFrame = CGRect(origin: expectedOrigin, size: measurements.itemSize)
        // Index 7 (item no 8) should be first item on second row:
        // Available space in CollectionView: 320 - 20 - 50 = 250
        // 7 items take up 7x32 + 6 = 230
        // --> 8th item (index 7) must be first item on second row
        let attributes = layout.layoutAttributesForItem(at: IndexPath(item: 7, section: 0))
        XCTAssertEqual(attributes?.frame, expectedFrame)

        let expectedContentSize = CGSize(width: collectionView.frame.size.width,
                                         height: measurements.sectionInsets.top +
                                            measurements.itemSize.height * 2 +
                                            measurements.interItemSpacing +
                                            measurements.sectionInsets.bottom)
        XCTAssertEqual(layout.collectionViewContentSize, expectedContentSize)
    }

    func testHeaderViewLayout() {
        measurements.sectionInsets = UIEdgeInsets(top: 5, left: 5, bottom: 0, right: 0)
        measurements.headerSize = CGSize(width: 10, height: 25)
        layout.prepare()
        let headerAttributes = layout.layoutAttributesForSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, at: IndexPath(index: 0))
        XCTAssertEqual(headerAttributes?.representedElementKind, UICollectionView.elementKindSectionHeader)

        let expectedFrame = CGRect(x: 0, y: 0, width: collectionView.frame.size.width, height: measurements.headerSize.height)
        XCTAssertEqual(headerAttributes?.frame, expectedFrame)

        let itemAttributes = layout.layoutAttributesForItem(at: IndexPath(row: 0, section: 0))
        XCTAssertEqual(itemAttributes?.frame.origin.y, measurements.headerSize.height + measurements.sectionInsets.top)
    }

    func testFooterViewLayout() {
        measurements.sectionInsets = UIEdgeInsets(top: 5, left: 5, bottom: 25, right: 0)
        measurements.footerSize = CGSize(width: 10, height: 25)
        layout.prepare()
        let footerAttributes = layout.layoutAttributesForSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, at: IndexPath(index: 0))
        XCTAssertEqual(footerAttributes?.representedElementKind, UICollectionView.elementKindSectionFooter)

        let expectedFrame = CGRect(x: 0,
                                   y: measurements.sectionInsets.top + measurements.itemSize.height + measurements.sectionInsets.bottom,
                                   width: collectionView.frame.size.width,
                                   height: measurements.footerSize.height)
        XCTAssertEqual(footerAttributes?.frame, expectedFrame)
        XCTAssertEqual(layout.collectionViewContentSize.height, measurements.sectionInsets.top + measurements.itemSize.height + measurements.sectionInsets.bottom + measurements.footerSize.height);
    }

    func testBackgroundViewLayout() {
        layout.showsSectionBackgrounds = true;
        layout.prepare()
        let backgroundViewAttributes = layout.layoutAttributesForSupplementaryView(ofKind: JEKCollectionElementKindSectionBackground, at: IndexPath(index: 0))
        XCTAssertEqual(backgroundViewAttributes?.representedElementKind, JEKCollectionElementKindSectionBackground)
        let expectedFrame = CGRect(x: 0, y: 0, width: collectionView.frame.size.width, height: measurements.itemSize.height)
        XCTAssertEqual(backgroundViewAttributes?.frame, expectedFrame)
    }

    func testThatBackgroundViewsExtendBehindHeadersAndFooters() {
        layout.showsSectionBackgrounds = true;
        measurements.headerSize = CGSize(width: 10, height: 25)
        measurements.footerSize = CGSize(width: 10, height: 25)
        layout.prepare()

        let backgroundViewAttributes = layout.layoutAttributesForSupplementaryView(ofKind: JEKCollectionElementKindSectionBackground, at: IndexPath(index: 0))
        let expectedFrame = CGRect(x: 0, y: 0, width: collectionView.frame.size.width, height: measurements.itemSize.height + measurements.headerSize.height + measurements.footerSize.height)
        XCTAssertEqual(backgroundViewAttributes?.frame, expectedFrame)

        let headerViewAttributes = layout.layoutAttributesForSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, at: IndexPath(index: 0))
        let footerViewAttributes = layout.layoutAttributesForSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, at: IndexPath(index: 0))
        XCTAssertTrue(backgroundViewAttributes!.zIndex < headerViewAttributes!.zIndex)
        XCTAssertTrue(backgroundViewAttributes!.zIndex < footerViewAttributes!.zIndex)
    }
}

extension LayoutMeasurements {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return numberOfSections
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfItems
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return itemSize
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return interItemSpacing
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return headerSize
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return footerSize
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: JEKScrollableSectionCollectionViewLayout, shouldUseFlowLayoutInSection section: Int) -> Bool {
        return useFLowLayout
    }
}
