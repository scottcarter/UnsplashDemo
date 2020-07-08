//
//  ImageTilesViewModel.swift
//  UnsplashDemo
//
//  Created by Scott Carter on 7/2/20.
//  Copyright © 2020 Scott Carter. All rights reserved.
//

import Foundation
import UIKit

class ImageTilesViewModel: ImageGroupViewModel {

    // MARK: - Variable Properties

    // Precalculated cell dimensions (used in layout) for performance.
    var cellDimension = [CGSize]()

    // MARK: - Public Functions

    func configure(_ cell: ImageTilesCollectionViewCell, for indexPath: IndexPath) {
        setLargeThumbImage(for: cell.imageThumbnail, at: indexPath.item)

        // Properties affecting image rendering
        //
        cell.imageThumbnail.layer.masksToBounds = true

        // Express the corner radius as a percentage of width.  50% of width will yield a circle,
        // assuming that image constraints on all 4 side are equal (we are dealing with square images).
        //
        let imageLeftConstraint = cell.imageViewLeftConstraint.constant
        let imageRightConstraint = cell.imageViewRightConstraint.constant
        let cellWidth = cell.frame.size.width
        let imageCornerRadiusWidthPercentage = CGFloat(50.0)
        let imageWidth = cellWidth - imageLeftConstraint - imageRightConstraint

        cell.imageThumbnail.layer.cornerRadius = imageWidth * imageCornerRadiusWidthPercentage/100

        // Properties affecting tile rendering
        cell.contentView.layer.cornerRadius = cellWidth * CGFloat(50.0)/100
        cell.contentView.layer.borderColor =  UIColor.systemYellow.cgColor
        cell.contentView.layer.borderWidth = CGFloat(2.0)
    }

    func configure(_ collectionViewLayout: UICollectionViewLayout) {
        let layout = collectionViewLayout as? UICollectionViewFlowLayout

        // We aren't using self sizing cells that call preferredLayoutAttributesFitting(_:) method
        // so set this to CGSize.zero.  Alternatively set on Storyboard:
        // ImageTilesCollectionViewController -> Collection View Flow Layout
        // Size Inspector:  Estimate size = None
        layout?.estimatedItemSize = CGSize.zero

        layout?.sectionInset = UIEdgeInsets(
            top: Constants.ImageTiles.edgeInsetDimension,
            left: Constants.ImageTiles.edgeInsetDimension,
            bottom: Constants.ImageTiles.edgeInsetDimension,
            right: Constants.ImageTiles.edgeInsetDimension
        )

        layout?.minimumInteritemSpacing = Constants.ImageTiles.minimumInteritemSpacing
        layout?.minimumLineSpacing = Constants.ImageTiles.minimumLineSpacing

        layout?.scrollDirection = Constants.ImageTiles.scrollDirection

    }

    func initialImageLoad(using view: UIView, completion: @escaping () -> Void) {

        imagesLoading = true
        showWindowFetchingView(for: view)

        loadImages(page: 1, perPage: Constants.ImageFetch.imagesToFetch) { [weak self] in
            self?.dismissWindowFetchingView()
            completion()
        }
    }

    func processRefresh(
        _ refreshControl: UIRefreshControl,
        using view: UIView,
        completion: @escaping () -> Void
    ) {
        if imagesLoading {
            refreshControl.endRefreshing()
            return
        }

        imagesLoading = true
        showWindowFetchingView(for: view)

        loadImages(page: 1, perPage: Constants.ImageFetch.imagesToFetch) { [weak self] in
            refreshControl.endRefreshing()
            self?.dismissWindowFetchingView()
            completion()
        }
    }

    func size(
        forItemAt indexPath: IndexPath,
        withCollectionView view: UIView
    ) -> CGSize {

        let numTileElements = Constants.ImageTiles.numTileElementsInDirection
        let positionInRow: Int = indexPath.item % numTileElements

        return cellSize(for: positionInRow, withCollectionView: view)
    }

}

private extension ImageTilesViewModel {

    func calculateDimensions(withCollectionView view: UIView) -> [CGSize] {

        var size = [CGSize]()

        let numTileElements = Constants.ImageTiles.numTileElementsInDirection
        let totalSpacing = (CGFloat(numTileElements) - 1.0) * CGFloat(Constants.ImageTiles.minimumInteritemSpacing)

        for positionInRow in 0..<numTileElements {

            var elementWidth: CGFloat = 0.0
            var elementHeight: CGFloat = 0.0

            if Constants.ImageTiles.scrollDirection == .vertical {
                // What width are we working with?
                let viewWidth = view.bounds.size.width - Constants.ImageTiles.edgeInsetDimension * 2

                elementWidth = dimension(
                    forPosition: positionInRow,
                    numElements: numTileElements,
                    dimensionTotal: (viewWidth - totalSpacing)
                )

                // Assuming square images.
                // The width might vary by a point (to squeeze in all numTileElements),
                // but the height must remain constant! Use a height equal to the width of the first position.
                elementHeight = dimension(
                    forPosition: 0,
                    numElements: numTileElements,
                    dimensionTotal: (viewWidth - totalSpacing)
                )
            } else {
                // What height are we working with?
                let viewHeight = view.bounds.size.height - Constants.ImageTiles.edgeInsetDimension * 2

                elementHeight = dimension(
                    forPosition: positionInRow,
                    numElements: numTileElements,
                    dimensionTotal: (viewHeight - totalSpacing)
                )

                elementWidth = dimension(
                    forPosition: 0,
                    numElements: numTileElements,
                    dimensionTotal: (viewHeight - totalSpacing)
                )
            }

            size.append(CGSize(width: CGFloat(elementWidth), height: CGFloat(elementHeight)))

        }

        return size
    }

    func cellSize(for item: Int, withCollectionView view: UIView) -> CGSize {

        // Populate cellDimension array on first use
        if cellDimension.count == 0 {
            cellDimension = calculateDimensions(withCollectionView: view)
        }

        guard cellDimension.count > item else {
            assertionFailure("Did not precalculate cell dimensions correctly")
            return CGSize.zero
        }

        return cellDimension[item]
    }

    // Calculate element width (vertical scroll) or height (horizontal scroll) so
    // that all dimensions are non-fractional.   Fractional dimensions can result
    // in a gap between elements.
    //
    // Example sequences using width=320 and either 3 or 6 elements in non-scrolling direction.
    //
    // 320/3 =  106.666   107, 107, 106
    // 320/6 =  53.333   53, 53, 54, 53, 54, 53
    //
    // dimensionTotal = view available - total spacing
    //
    func dimension(forPosition position: Int, numElements: Int, dimensionTotal: CGFloat) -> CGFloat {
        var dimensionUsed: CGFloat = 0.0
        var dimension: CGFloat = 0.0

        for index in 0..<numElements {
            let dimensionRemaining: CGFloat = dimensionTotal - dimensionUsed

            // Last elements?
            if index == (numElements - 1) {
                dimension = dimensionRemaining
                break
            }

            let elementsRemaining: Int = numElements - index

            // We round dimension to nearest integer.  Half-way rounds up.
            dimension = round(dimensionRemaining / CGFloat(elementsRemaining))

            if index == position {
                break
            }

            dimensionUsed += dimension
        }

        return dimension
    }

}
