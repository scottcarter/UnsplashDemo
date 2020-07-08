//
//  ImageListTableViewController.swift
//  UnsplashDemo
//
//  Created by Scott Carter on 6/18/20.
//  Copyright © 2020 Scott Carter. All rights reserved.
//

import UIKit

class ImageListTableViewController: UITableViewController {

    // MARK: - Variable Properties

    var imageListViewModel: ImageListViewModel!

    // MARK: - Interface Builder Outlets

    @IBOutlet private var loadingView: UIView!
    @IBOutlet private weak var spinner: UIActivityIndicatorView?

    // MARK: - Lifecycle

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let imageViewController = segue.destination as? ImageViewController,
            let indexPath = tableView.indexPathForSelectedRow {
            imageViewController.imageTitle = imageListViewModel.imageTitle(for: indexPath.row)
            imageViewController.imageRegularSizeURL = imageListViewModel.imageRegularSizeURL(for: indexPath.row)
            imageViewController.imageLargeThumbSizeURL = imageListViewModel.imageLargeThumbSizeURL(for: indexPath.row)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.prefersLargeTitles = true

        navigationItem.title = "Recent Photos"

        // Or enable refreshing for Table View Controller in Storyboard using Attributes Inspector.
        refreshControl = UIRefreshControl()
        refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl?.addTarget(self,
                                  action: #selector(handleRefresh(refreshControl:)),
                                  for: UIControl.Event.valueChanged)

        // Display a loading view with spinner while the table data loads.
        view.addSubview(loadingView)
        imageListViewModel.configure(loadingView, containing: spinner)

        imageListViewModel.initialImageLoad(with: loadingView) { [weak self] in
            self?.tableView.reloadData()
        }
    }

    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()

        imageListViewModel.updatePosition(for: loadingView, containedWithin: view)
    }

}

private extension ImageListTableViewController {

    @objc func handleRefresh(refreshControl: UIRefreshControl) {
        imageListViewModel.processRefresh(refreshControl, with: loadingView) { [weak self] in
            self?.tableView.reloadData()
        }
    }
}

// MARK: UITableViewDataSource protocol
extension ImageListTableViewController {

    enum CellIdentifiers {
        static let imageListCell = "ImageListCell"
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return imageListViewModel.imageCount
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: CellIdentifiers.imageListCell,
            for: indexPath
            ) as? ImageListTableViewCell else {
                assertionFailure("Can't dequeue ImageListTableViewCell")
                return UITableViewCell()
        }

        imageListViewModel.configure(cell, for: indexPath)

        return cell
    }
}

// MARK: UITableViewDelegate protocol
extension ImageListTableViewController {

    override func tableView(
        _ tableView: UITableView,
        willDisplay cell: UITableViewCell,
        forRowAt indexPath: IndexPath
    ) {

        imageListViewModel.conditionallyLoadImages(indexPath, using: view) { indexPaths in
            tableView.beginUpdates()
            tableView.insertRows(at: indexPaths, with: .automatic)
            tableView.endUpdates()
        }
    }
}
