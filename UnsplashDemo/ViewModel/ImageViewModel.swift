//
//  ImageViewModel.swift
//  UnsplashDemo
//
//  Created by Scott Carter on 7/6/20.
//  Copyright © 2020 Scott Carter. All rights reserved.
//

import AlamofireImage
import Combine
import Foundation
import UIKit

class ImageViewModel {

    // MARK: - Variable Properties

    private var disposables = Set<AnyCancellable>()

    var bookmarksChanged = PassthroughSubject<BookmarkChange, Never>()

    private let imageModel: ImageModel

    // MARK: - Initializers

    init(for imageRegularSizeURL: String?) {
        imageModel = ImageModel(for: imageRegularSizeURL)

        // Subscribe to changes in our model.
         imageModel.bookmarksChanged
             .sink { [weak self] bookmarkChange in
                 guard let self = self else {
                     return
                 }

                 switch bookmarkChange.change {
                 case .insert, .delete:
                     self.bookmarksChanged.send(bookmarkChange)
                 default:
                    break
                 }
         }
         .store(in: &disposables)
    }

    // MARK: - Functions

    func bookmarkImage(
        title imageTitle: String?,
        regularSizeURL imageRegularSizeURL: String?,
        largeThumbSizeURL imageLargeThumbSizeURL: String?
        ) {
        imageModel.bookmarkImage(
            title: imageTitle,
            regularSizeURL: imageRegularSizeURL,
            largeThumbSizeURL: imageLargeThumbSizeURL
        )
    }

    func configure(_ addButton: UIBarButtonItem, using imageRegularSizeURL: String?) {
        let imageBookmarked = imageModel.imageIsStored(for: imageRegularSizeURL)
        addButton.isEnabled = !imageBookmarked
    }

    func configure(_ imageView: UIImageView, using imageUrl: String?) {
        if let imageUrl = imageUrl,
            let url =  URL(string: imageUrl) {

            let placeholder = UIImage.init(systemName: "photo")?
            .withTintColor(Constants.ImageDisplay.placeholderTintColor, renderingMode: .alwaysOriginal)

            imageView.af.setImage(withURL: url, placeholderImage: placeholder)
        }
    }

}
