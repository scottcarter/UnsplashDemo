//
//  ImageListViewModel.swift
//  UnsplashDemo
//
//  Created by Scott Carter on 6/18/20.
//  Copyright © 2020 Scott Carter. All rights reserved.
//

import Foundation
import UIKit

class ImageListViewModel: ImageGroupViewModel {

    // MARK: - Public Functions

    func configure(_ loadingView: UIView, containing spinner: UIActivityIndicatorView?) {
        spinner?.color = Constants.ImageFetch.spinnerColor
        spinner?.startAnimating()

        loadingView.layer.cornerRadius = Constants.ImageList.loadingViewBorderCornerRadius
        loadingView.layer.borderColor = Constants.ImageList.loadingViewBorderColor.cgColor
        loadingView.layer.borderWidth = Constants.ImageList.loadingViewBorderWidth
    }

    func configure(_ cell: ImageListTableViewCell, for indexPath: IndexPath) {
        setSmallThumbImage(for: cell.imageThumbnail, at: indexPath.row)

        cell.imageTitle?.text = imageTitle(for: indexPath.row)
    }

    func initialImageLoad(
        with loadingView: UIView,
        completion: @escaping () -> Void) {

        imagesLoading = true

        loadImages(page: 1, perPage: Constants.ImageFetch.imagesToFetch) {
            loadingView.isHidden = true
            completion()
        }
    }

    func processRefresh(
        _ refreshControl: UIRefreshControl,
        with loadingView: UIView,
        completion: @escaping () -> Void
    ) {
        if imagesLoading {
            refreshControl.endRefreshing()
            return
        }

        loadingView.isHidden = false

        imagesLoading = true

        loadImages(page: 1, perPage: Constants.ImageFetch.imagesToFetch) {
            refreshControl.endRefreshing()
            loadingView.isHidden = true
            completion()
        }
    }

    // Update positioning of loadingView.
    //
    // Note that in place of the Scene dock view used for loadingView, we could
    // also have used the UIWindow approach used with showWindowFetchingView() which is more flexible.
    //
    // The scene dock approach was used to showcase an alternative.  It is only appropriate though
    // for showing a loading view when the table view is displaying content which includes the first
    // row (initial load or refresh).  When scrolling near the bottom of table view content,
    // the constraints are not such that the loading view would be visible.
    func updatePosition(for loadingView: UIView, containedWithin view: UIView) {

        // Remove any existing contraints on loadingView before adding/updating
        view.constraints.forEach { constraint in
            if constraint.identifier == "loadingViewCenterX" ||  constraint.identifier == "loadingViewCenterY" {
                constraint.isActive = false
            }
        }

        loadingView.translatesAutoresizingMaskIntoConstraints = false

        let centerX = loadingView.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0.0)
        centerX.identifier = "loadingViewCenterX"

        // Presence of status bar (and navigation bar if visible) will shift the tableview's center Y anchor down
        // (and the bounds will have a negative Y offset, a negative content offset).
        // We need to compensate with a negative offset for loadingView of half of the
        // shift = view.safeAreaInsets.top/2.0
        //
        // The addition of a bottom tab bar (and home bar on iPhone X and later) does not affect the
        // tableview's center Y anchor. We need to compensate for reduction in visible table
        // view (between navigation bar and tab bar) with a negative offset for loadingView of
        // half of the shift = view.safeAreaInsets.bottom/2.0
        let centerYOffset = -view.safeAreaInsets.bottom/2.0 - view.safeAreaInsets.top/2.0

        let centerY = loadingView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: centerYOffset)
        centerY.identifier = "loadingViewCenterY"

        NSLayoutConstraint.activate([centerX, centerY])
    }

}
