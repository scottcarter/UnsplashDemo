//
//  BookmarksViewModel.swift
//  UnsplashDemo
//
//  Created by Scott Carter on 7/5/20.
//  Copyright © 2020 Scott Carter. All rights reserved.
//

import AlamofireImage
import Combine
import Foundation
import UIKit

class BookmarksViewModel {

    // MARK: - Constants

    let bookmarksModel: BookmarksModel

    // MARK: - Variable Properties

    private var disposables = Set<AnyCancellable>()

    var images = [ImageDisplay]()

    var bookmarksChanged = PassthroughSubject<BookmarkChange, Never>()

    // Monitor swipe to delete functionality so that we can override
    // setEditing meaningfully (handling this case) in view controller.
    // https://stackoverflow.com/a/15693465/1949877
    var swipeToDeleteActive = false

    // MARK: - Initializers

    init(bookmarksModel: BookmarksModel) {
        self.bookmarksModel = bookmarksModel

        self.images = bookmarksModel.images

        // Subscribe to changes in our model.
        bookmarksModel.bookmarksChanged
            .sink { [weak self] bookmarkChange in
                guard let self = self else {
                    return
                }

                switch bookmarkChange.change {
                case .insert, .delete, .startChanges:
                    self.bookmarksChanged.send(bookmarkChange)
                case .endChanges:
                    self.images = bookmarksModel.images
                    self.bookmarksChanged.send(bookmarkChange)
                }
        }
        .store(in: &disposables)
    }

    // MARK: - Public Functions

    func configure(_ cell: BookmarksTableViewCell, for indexPath: IndexPath) {
        let imageLargeThumbSizeURL = image(for: indexPath.row)?.largeThumbSizeURL

        cell.imageTitle?.text = imageTitle(for: indexPath.row)

        if let imageThumbSizeURL = imageLargeThumbSizeURL,
            let url =  URL(string: imageThumbSizeURL) {

            let placeholder = UIImage.init(systemName: "photo")?
            .withTintColor(Constants.ImageDisplay.placeholderTintColor, renderingMode: .alwaysOriginal)

            cell.imageThumbnail?.af.setImage(withURL: url, placeholderImage: placeholder)
        }
    }

    func deleteBookmark(for indexPath: IndexPath, using tableView: UITableView) {
        bookmarksModel.deleteBookmark(for: indexPath)
    }

    func deleteBookmarks(for indexPaths: [IndexPath], using tableView: UITableView) {
         bookmarksModel.deleteBookmarks(for: indexPaths)
     }

    func imageRegularSizeURL(for index: Int) -> String {
        guard let url = image(for: index)?.regularSizeURL else {
            return ""
        }
        return url
    }

    func imageLargeThumbSizeURL(for index: Int) -> String {
        guard let url = image(for: index)?.largeThumbSizeURL else {
            return ""
        }
        return url
    }

    func imageTitle(for index: Int) -> String {
        guard let title = image(for: index)?.title else {
            return ""
        }
        return title
    }

    // MARK: - Computed Properties

    var imageCount: Int {
        return images.count
    }
}

private extension BookmarksViewModel {

    func image(for index: Int) -> ImageDisplay? {
        if index >= images.count {
            return nil
        }
        return images[index]
    }

}
