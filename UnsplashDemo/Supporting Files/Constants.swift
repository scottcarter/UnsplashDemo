//
//  Constants.swift
//  UnsplashDemo
//
//  Created by Scott Carter on 6/19/20.
//  Copyright © 2020 Scott Carter. All rights reserved.
//

import Foundation
import UIKit

enum Constants {

    enum ImageDisplay {

        static let placeholderTintColorLight: UIColor = .black
        static let placeholderTintColorDark: UIColor = .white

        // Dark mode support for color variation.  Once an element is assigned this color,
        // it will be dynamically updated as transitions occur between light and dark mode.
        static let placeholderTintColor = UIColor {(traitCollection: UITraitCollection) -> UIColor in
            if traitCollection.userInterfaceStyle == .dark {
                return placeholderTintColorDark
            } else {
                return placeholderTintColorLight
            }
        }
    }

    enum ImageFetch {

        // We will fetch 25 images, but not more than that allowed by API
        static let imagesToFetch = min(Unsplash.maxImagesPerFetch, 25)

        static let spinnerColorLight: UIColor = .systemBlue
        static let spinnerColorDark: UIColor = .systemYellow

        static let spinnerColor = UIColor {(traitCollection: UITraitCollection) -> UIColor in
            if traitCollection.userInterfaceStyle == .dark {
                return spinnerColorDark
            } else {
                return spinnerColorLight
            }
        }
    }

    enum ImageList {
        static let loadingViewBorderCornerRadius: CGFloat = 5.0
        static let loadingViewBorderColor: UIColor  = .systemGray
        static let loadingViewBorderWidth: CGFloat = 2.0
    }

    enum ImageTiles {
        static let edgeInsetDimension: CGFloat = 10.0
        static let minimumInteritemSpacing: CGFloat = 8.0
        static let minimumLineSpacing: CGFloat = 8.0
        static let numTileElementsInDirection = 2
        static let scrollDirection: UICollectionView.ScrollDirection = .vertical
    }

    // https://unsplash.com/documentation#list-photos
    enum Unsplash {
        static let accessToken = "Enter Unsplash API Key here"

        // Documentation does not specify a max page number, but values greater than
        // this take too long to fetch.
        static let maxPageNumber = 10000

        // Though not specified, the max number of photos that can be fetched per page is 30.  Any
        // value in request greater than this results in 30 photos being returned.
        static let maxImagesPerFetch = 30
    }

}
