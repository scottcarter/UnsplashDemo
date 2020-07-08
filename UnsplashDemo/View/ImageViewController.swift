//
//  ImageViewController.swift
//  UnsplashDemo
//
//  Created by Scott Carter on 6/30/20.
//  Copyright © 2020 Scott Carter. All rights reserved.
//

import Combine
import UIKit

class ImageViewController: UIViewController {

    // MARK: - Variable Properties

    var sourceFromBookmarks = false
    var imageTitle: String?
    var imageRegularSizeURL: String?
    var imageLargeThumbSizeURL: String?

    private var disposables = Set<AnyCancellable>()

    private var imageViewModel: ImageViewModel!

    // MARK: - Interface Builder Outlets

    @IBOutlet private var addButton: UIBarButtonItem!
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var imageLabel: UILabel!

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        imageViewModel = ImageViewModel(for: imageRegularSizeURL)

        navigationItem.largeTitleDisplayMode = .never

        imageViewModel.configure(addButton, using: imageRegularSizeURL)
        imageViewModel.configure(imageView, using: imageRegularSizeURL)
        imageLabel.text = imageTitle

        // We don't show addButton if we arrived here from Bookmarks.
        if sourceFromBookmarks {
            navigationItem.rightBarButtonItems = []
        }

        // Subscribe to changes in our view model.
        imageViewModel.bookmarksChanged
            .sink { [weak self] bookmarkChange in
                guard let self = self else {
                    return
                }

                switch bookmarkChange.change {
                case .insert:
                    self.addButton.isEnabled = false // Bookmark added, so disable button
                case .delete:
                    self.addButton.isEnabled = true  // Bookmark deleted, so disable button
                default:
                    break
                }
        }
        .store(in: &disposables)
    }

    // MARK: - IBActions

    @IBAction func addAction(_ sender: UIBarButtonItem) {

        imageViewModel.bookmarkImage(
            title: imageTitle,
            regularSizeURL: imageRegularSizeURL,
            largeThumbSizeURL: imageLargeThumbSizeURL)

        let alertController = UIAlertController(title: "Added bookmark", message: "Success!", preferredStyle: .alert)
        let okAction = UIAlertAction(
            title: NSLocalizedString("OK",
                                     comment: "Alert OK button"),
            style: .default,
            handler: nil
        )
        alertController.addAction(okAction)
        present(alertController, animated: true) {() -> Void in }
    }
}
