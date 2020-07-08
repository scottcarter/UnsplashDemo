//
//  ImageGalleryCollectionViewController.swift
//  UnsplashDemo
//
//  Created by Scott Carter on 7/2/20.
//  Copyright © 2020 Scott Carter. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class ImageTilesCollectionViewController: UICollectionViewController {

    // MARK: - Variable Properties

    var imageTilesViewModel: ImageTilesViewModel!
    var processedInitialImageLoad = false

    // MARK: - Lifecycle

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let imageViewController = segue.destination as? ImageViewController,
            let indexPathArr = collectionView.indexPathsForSelectedItems,
            let indexPath = indexPathArr.first {
            imageViewController.imageTitle = imageTilesViewModel.imageTitle(for: indexPath.row)
            imageViewController.imageRegularSizeURL = imageTilesViewModel.imageRegularSizeURL(for: indexPath.row)
            imageViewController.imageLargeThumbSizeURL = imageTilesViewModel.imageLargeThumbSizeURL(for: indexPath.row)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // We already have a layout, so no need to create one.
        imageTilesViewModel.configure(collectionView.collectionViewLayout)

        // Refresh control for UICollectionViewController not available via Interface Builder
        let refreshControl = UIRefreshControl()
        let title = NSLocalizedString("Pull To Refresh", comment: "Pull to refresh")
        refreshControl.attributedTitle = NSAttributedString(string: title)
        refreshControl.addTarget(self,
                                 action: #selector(handleRefresh(refreshControl:)),
                                 for: .valueChanged)
        collectionView?.refreshControl = refreshControl
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // We defer loading until viewDidAppear since we need access to view's UIWindow to display
        // a loading screen.   Contrast to approach in ImageListTableViewController
        // where we displayed loading screen with an alterative approach using scene dock UIView.

        if !processedInitialImageLoad { // Only call initial load once
            imageTilesViewModel.initialImageLoad(using: view) { [weak self] in
                self?.processedInitialImageLoad = true
                self?.collectionView?.reloadData()
            }
        }
    }

}

private extension ImageTilesCollectionViewController {

    @objc func handleRefresh(refreshControl: UIRefreshControl) {
        imageTilesViewModel.processRefresh(refreshControl, using: view) { [weak self] in
            self?.collectionView.reloadData()
        }
    }
}

// MARK: UICollectionViewDataSource
extension ImageTilesCollectionViewController {

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageTilesViewModel.imageCount
    }

    override func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {

        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: reuseIdentifier,
            for: indexPath
            ) as? ImageTilesCollectionViewCell else {
                assertionFailure("Can't dequeue ImageTilesCollectionViewCell")
                return UICollectionViewCell()
        }

        imageTilesViewModel.configure(cell, for: indexPath)

        return cell
    }

}

// MARK: UICollectionViewDelegate
extension ImageTilesCollectionViewController {

    override func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {

        imageTilesViewModel.conditionallyLoadImages(indexPath, using: view) { indexPaths in

            collectionView.performBatchUpdates({
                collectionView.insertItems(at: indexPaths)
            }, completion: nil)

         }
    }

}

// UICollectionViewDelegateFlowLayout - must conform to this protocol to get delegate calls.
extension ImageTilesCollectionViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {

        guard let imageTilesViewModel = imageTilesViewModel else {
            assertionFailure("imageTilesViewModel was not set")
            return CGSize.zero
        }

        return imageTilesViewModel.size(forItemAt: indexPath, withCollectionView: view)
    }

}
