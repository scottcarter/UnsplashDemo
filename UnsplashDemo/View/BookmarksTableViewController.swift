//
//  BookmarksTableViewController.swift
//  UnsplashDemo
//
//  Created by Scott Carter on 7/5/20.
//  Copyright © 2020 Scott Carter. All rights reserved.
//

import Combine
import UIKit

class BookmarksTableViewController: UITableViewController {

    // MARK: - Variable Properties

    var bookmarksViewModel: BookmarksViewModel!
    private var disposables = Set<AnyCancellable>()

    private var viewInitiallyAppeared = false

    // MARK: - Lifecycle

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let imageViewController = segue.destination as? ImageViewController,
            let indexPath = tableView.indexPathForSelectedRow {
            imageViewController.sourceFromBookmarks = true
            imageViewController.imageTitle = bookmarksViewModel.imageTitle(for: indexPath.row)
            imageViewController.imageRegularSizeURL = bookmarksViewModel.imageRegularSizeURL(for: indexPath.row)
            imageViewController.imageLargeThumbSizeURL = bookmarksViewModel.imageLargeThumbSizeURL(for: indexPath.row)
        }
    }

    // Prevent segues when we are in editing mode with multiple selections enabled.
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if tableView.isEditing {
            return false
        }
        return true
    }

    // Control the addition/removal of delete button based on editing mode,
    // but only if swipe to delete was not active.
    //
    // If swipe to delete was active, but is no longer so (editing is false),
    // mark as inactive and restore edit button.
    // See also tableView(_:willBeginEditingRowAt)
    override func setEditing(_ editing: Bool, animated: Bool) {

        if !bookmarksViewModel.swipeToDeleteActive {
            super.setEditing(editing, animated: animated)

            if editing {
                navigationItem.rightBarButtonItem = UIBarButtonItem(
                    title: "Delete",
                    style: .plain,
                    target: self,
                    action: #selector(deleteBookmarks))
            } else {
                navigationItem.rightBarButtonItem = nil
            }
        } else if !editing {
            // Ended swipe to delete - add Edit button
            self.navigationItem.leftBarButtonItem = editButtonItem
            bookmarksViewModel.swipeToDeleteActive = false
        }
    }

    @objc func deleteBookmarks() {
        if let selectedRows = tableView.indexPathsForSelectedRows {
            bookmarksViewModel.deleteBookmarks(for: selectedRows, using: tableView)
        }

    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Bookmarks"
        navigationItem.leftBarButtonItem = editButtonItem

        tableView.allowsMultipleSelectionDuringEditing = true // Support batch delete

        if self.bookmarksViewModel.imageCount == 0 {
            self.editButtonItem.isEnabled = false
        }

        // Subscribe to changes in our view model.
        bookmarksViewModel.bookmarksChanged
            .sink { [weak self] bookmarkChange in
                guard let self = self else {
                    return
                }

                // If there are no images bookmarked after changes are completed,
                // turn off editing mode and disable edit button.
                if bookmarkChange.change == .endChanges {
                    if self.bookmarksViewModel.imageCount == 0 {
                        self.isEditing = false
                        self.editButtonItem.isEnabled = false
                    } else {
                        self.editButtonItem.isEnabled = true
                    }
                }

                // If the table view is not in the window hierarchy (i.e. tab controller showing
                // a different tab), then we should not be making changes to the view.
                if self.tableView.window == nil {
                    return
                }

                switch bookmarkChange.change {
                case .insert:
                    assertionFailure("Insertions not currently supported from this view controller")
                case .delete:
                    if let indexPath = bookmarkChange.indexPath {
                        self.tableView.deleteRows(at: [indexPath], with: .automatic)
                    }
                case .startChanges:
                    self.tableView.beginUpdates()
                case .endChanges:
                    self.tableView.endUpdates()
                }
        }
        .store(in: &disposables)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // If view has already appeared, subsequent appearances will cause a reload of tableview.
        // This handles additions/deletions of bookmarks when this view is not present.
        if viewInitiallyAppeared {
            tableView.reloadData()
        } else {
            viewInitiallyAppeared = true
        }
    }

}

// MARK: UITableViewDelegate
extension BookmarksTableViewController {

    override func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {

        // Started swipe to delete - remove Edit button
        self.navigationItem.leftBarButtonItem = nil
        bookmarksViewModel.swipeToDeleteActive = true
    }
}

// MARK: UITableViewDataSource protocol
extension BookmarksTableViewController {

    enum CellIdentifiers {
        static let bookmarksCell = "BookmarksTableViewCell"
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bookmarksViewModel.imageCount
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: CellIdentifiers.bookmarksCell,
            for: indexPath
            ) as? BookmarksTableViewCell else {
                assertionFailure("Can't dequeue BookmarksTableViewCell")
                return UITableViewCell()
        }

        bookmarksViewModel.configure(cell, for: indexPath)

        return cell
    }

    // Implementing this method gives us swipe to delete functionality.
    override func tableView(
        _ tableView: UITableView,
        commit editingStyle: UITableViewCell.EditingStyle,
        forRowAt indexPath: IndexPath) {

        if editingStyle == .delete {
            bookmarksViewModel.deleteBookmark(for: indexPath, using: tableView)
        }
    }

}
