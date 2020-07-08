//
//  ImageGroupViewModel.swift
//  UnsplashDemo
//
//  Created by Scott Carter on 7/2/20.
//  Copyright © 2020 Scott Carter. All rights reserved.
//

import Foundation
import UIKit

class ImageGroupViewModel {

    // MARK: - Constants

     let imageGroupModel: ImageGroupModel

    // MARK: - Variable Properties

     private var currentWindow: UIWindow?
     private var fetchingWindow: UIWindow?

     var images = [ImageGroupModel.ImageResult]()

     // Flag to prevent multiple fetches to be outstanding.
     var imagesLoading = false

    // MARK: - Initializers

    init(imageGroupModel: ImageGroupModel) {
        self.imageGroupModel = imageGroupModel
    }

    // MARK: - Functions

    func conditionallyLoadImages(
        _ indexPath: IndexPath,
        using view: UIView,
        completion: @escaping ([IndexPath]) -> Void
    ) {

        // The index which will trigger a new fetch.
        let triggerIndex = Int(Double(imageCount) * 0.9)

        if (indexPath.item > triggerIndex)  && !imagesLoading {

            imagesLoading = true

            showWindowFetchingView(for: view, withText: "Fetching ...")

            // Figure out which page to fetch
            let pageToFetch = imageCount/Constants.ImageFetch.imagesToFetch + 1

            loadImages(page: pageToFetch, perPage: Constants.ImageFetch.imagesToFetch) { [weak self] in

                self?.dismissWindowFetchingView()

                let startItem = (pageToFetch - 1) * Constants.ImageFetch.imagesToFetch
                let endItem = (pageToFetch * Constants.ImageFetch.imagesToFetch) - 1

                // Get list of index paths we are inserting
                let indexPaths = Array(startItem...endItem).map { value -> IndexPath in
                    IndexPath(item: value, section: 0)
                }

                completion(indexPaths)
            }
        }
    }

    func dismissWindowFetchingView() {
        currentWindow?.makeKeyAndVisible()

        // Even though the newly presented UIWindow is currently only showing static content,
        // it is good practice to guard against the following:
        //
        // If a modal present occurred somewhere in the new window's hierarchy, then
        // you must call dismiss on the rootViewController or else our new window will not be released
        // (even after setting our reference to nil).
        fetchingWindow?.rootViewController?.dismiss(animated: false, completion: nil)

        fetchingWindow?.rootViewController = nil

        fetchingWindow?.windowScene = nil

        self.fetchingWindow = nil
    }

    func image(for index: Int) -> ImageGroupModel.ImageResult? {
        if index >= images.count {
            return nil
        }
        return images[index]
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
        guard let title = image(for: index)?.description else {
            return ""
        }
        return title
    }

    func loadImages(page: Int, perPage: Int, completion: @escaping () -> Void ) {

        // In Debug builds, it is useful to see the placement of the loading or fetching views.
        // (DEBUG defined in Build Settings, Active Compilation Conditions)
        #if DEBUG
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) {
            self.loadImagesDelayed(page: page, perPage: perPage, completion: completion)
        }
        #else
        self.loadImagesDelayed(page: page, perPage: perPage, completion: completion)
        #endif

    }

    func loadImagesDelayed(page: Int, perPage: Int, completion: @escaping () -> Void ) {

        imageGroupModel.images(page: page, perPage: perPage, orderBy: .latest) { [weak self] result in
            guard let self = self else {
                return
            }

            switch result {
            case .success(let value):
                if page == 1 {
                    self.images = value
                } else {
                    self.images.append(contentsOf: value)
                }
                completion()
            case .failure(let error):
                print("Failed to load images: \(error.localizedDescription)")
                completion()
            }

            self.imagesLoading = false
        }
    }

    func setImage(for imageView: UIImageView, using imageURL: String) {

        // Using a fetch from ImageGroupModel (using AlamoFire) to get image as an example.
        // Elsewhere (ImageViewController, BookmarksViewModel) we use the simpler AlamoFireImage
        // extension on UIImageView with af.setImage()
        imageGroupModel.data(for: imageURL) { result in
            switch result {
            case .success(let data):
                guard let image = UIImage(data: data) else {
                    print("Unable to convert data to UIImage for url \(imageURL)")
                    return
                }
                imageView.image = image
            case .failure(let error):
                print("Unable to retrieve data for url \(imageURL)  error: \(error)")
            }
        }
    }

    func setSmallThumbImage(for imageView: UIImageView?, at index: Int) {
        guard let imageView = imageView,
            let imageURL = image(for: index)?.smallThumbSizeURL else {
                return
        }

        setImage(for: imageView, using: imageURL)
    }

    func setLargeThumbImage(for imageView: UIImageView?, at index: Int) {
        guard let imageView = imageView,
            let imageURL = image(for: index)?.largeThumbSizeURL else {
                return
        }

        setImage(for: imageView, using: imageURL)
    }

    func showWindowFetchingView(for view: UIView, withText text: String = "Loading ...") {
        currentWindow = view.window

        let fetchingView = FetchingView(frame: CGRect(x: 0, y: 0, width: 200, height: 120), withText: text)
        let fetchingViewController = UIViewController()
        fetchingViewController.view.addSubview(fetchingView)

        // Note: It is not sufficient to create a UIWindow with frame and then
        //       assign the windowScene property.  There is an issue involving the
        //       new window's frame:
        //       - Start in Landscape
        //       - Create new window:
        //          fetchingWindow = UIWindow(frame: UIScreen.main.bounds)
        //          (fetchingWindow frame correctly reflects Landscape orientation)
        //       - Assign to window scene
        //          fetchingWindow?.windowScene = currentWindow?.windowScene
        //          (fetchingWindow frame has switched to Portrait orientation)

        guard let windowScene = currentWindow?.windowScene else {
            return
        }

        fetchingWindow = UIWindow(windowScene: windowScene)
        fetchingWindow?.backgroundColor = .clear  // Let root view controller control background color
        fetchingWindow?.rootViewController = fetchingViewController
        fetchingWindow?.makeKeyAndVisible()

        updateFetchingView()
    }

    func updateFetchingView() {

        guard let fetchingViewController = fetchingWindow?.rootViewController,
            let view = fetchingViewController.view,
            let fetchingView = view.subviews.first as? FetchingView else {
                return
        }

        // The fetchingViewController is created for each use, so no existing constraints to remove.

        fetchingView.translatesAutoresizingMaskIntoConstraints = false

        let centerX = fetchingView.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0.0)
        let centerY = fetchingView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 0.0)
        NSLayoutConstraint.activate([centerX, centerY])
    }

    // MARK: - Computed Properties

    var imageCount: Int {
        images.count
    }

}
