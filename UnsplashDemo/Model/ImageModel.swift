//
//  ImageModel.swift
//  UnsplashDemo
//
//  Created by Scott Carter on 7/6/20.
//  Copyright © 2020 Scott Carter. All rights reserved.
//

import Combine
import CoreData
import Foundation
import UIKit

// To conform to NSFetchedResultsControllerDelegate, we must inherit from NSObject
class ImageModel: NSObject {

    // MARK: - Variable Properties

    var bookmarksChanged = PassthroughSubject<BookmarkChange, Never>()

    private var fetchedResultsController: NSFetchedResultsController<ImageDisplay>?

    // MARK: - Initializers

    init(for imageRegularSizeURL: String?) {

        super.init()

        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate,
             let imageRegularSizeURL = imageRegularSizeURL
             else {
                 return
         }

        let context = appDelegate.persistentContainer.viewContext

        let request = ImageDisplay.fetchRequest() as NSFetchRequest<ImageDisplay>

        request.predicate = NSPredicate(format: "regularSizeURL CONTAINS %@", imageRegularSizeURL)

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

        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }

    }

    // MARK: - Functions

    func bookmarkImage(
        title imageTitle: String?,
        regularSizeURL imageRegularSizeURL: String?,
        largeThumbSizeURL imageLargeThumbSizeURL: String?
        ) {

        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate
             else {
                 return
         }

         let context = appDelegate.persistentContainer.viewContext
         let image = ImageDisplay(entity: ImageDisplay.entity(), insertInto: context)

         image.title = imageTitle
         image.regularSizeURL = imageRegularSizeURL
         image.largeThumbSizeURL = imageLargeThumbSizeURL

         appDelegate.saveContext()
    }

    func imageIsStored(for imageRegularSizeURL: String?) -> Bool {
        let fetchedObjects = fetchedResultsController?.fetchedObjects ?? []
        return fetchedObjects.count != 0
    }
}

// MARK: NSFetchedResultsControllerDelegate
extension ImageModel: NSFetchedResultsControllerDelegate {

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

}
