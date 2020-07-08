//
//  BookmarksModel.swift
//  UnsplashDemo
//
//  Created by Scott Carter on 7/5/20.
//  Copyright © 2020 Scott Carter. All rights reserved.
//

import Combine
import CoreData
import Foundation
import UIKit

// To conform to NSFetchedResultsControllerDelegate, we must inherit from NSObject
class BookmarksModel: NSObject {

    // MARK: - Variable Properties

    var bookmarksChanged = PassthroughSubject<BookmarkChange, Never>()

    private var fetchedResultsController: NSFetchedResultsController<ImageDisplay>?

    var images = [ImageDisplay]()

    // MARK: - Initializers

    override init() {
        super.init()

        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }

        let context = appDelegate.persistentContainer.viewContext

        let request = ImageDisplay.fetchRequest() as NSFetchRequest<ImageDisplay>

        // A sort descriptor is required.
        let sort = NSSortDescriptor(keyPath: \ImageDisplay.regularSizeURL, ascending: true)
        request.sortDescriptors = [sort]

        do {
            fetchedResultsController = NSFetchedResultsController(
                fetchRequest: request,
                managedObjectContext: context,
                sectionNameKeyPath: nil,
                cacheName: nil
            )

            fetchedResultsController?.delegate = self
            try fetchedResultsController?.performFetch()

            images = fetchedResultsController?.fetchedObjects ?? []
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }

    }

    // MARK: - Functions

    func deleteBookmark(for indexPath: IndexPath) {
        removeBookmark(for: indexPath)
        saveContext()
    }

    func deleteBookmarks(for indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            removeBookmark(for: indexPath)
        }
        saveContext()
    }

}

// MARK: NSFetchedResultsControllerDelegate
extension BookmarksModel: NSFetchedResultsControllerDelegate {

    // We indicate to view models (and from there to views) that
    // changes are about to occur, so that any views can surround them
    // with tableView.beginUpdates(), tableView.endUpdates()
    // https://stackoverflow.com/a/47684794/1949877
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.bookmarksChanged.send(BookmarkChange(change: .startChanges))
    }

    func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange anObject: Any,
        at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType,
        newIndexPath: IndexPath?) {

        switch type {

        case .insert:
            self.bookmarksChanged.send(BookmarkChange(change: .insert, indexPath: newIndexPath))
        case .delete:
            self.bookmarksChanged.send(BookmarkChange(change: .delete, indexPath: indexPath))
        default:
            break
        }
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        images = fetchedResultsController?.fetchedObjects ?? []
        self.bookmarksChanged.send(BookmarkChange(change: .endChanges))
    }

}

private extension BookmarksModel {
    func removeBookmark(for indexPath: IndexPath) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate,
            let fetchedResultsController = fetchedResultsController else {
                return
        }

        let context = appDelegate.persistentContainer.viewContext
        let image = fetchedResultsController.object(at: indexPath)
        context.delete(image)
    }

    func saveContext() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        appDelegate.saveContext()
    }
}
