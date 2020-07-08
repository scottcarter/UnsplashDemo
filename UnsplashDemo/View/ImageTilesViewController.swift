//
//  ImageGalleryViewController.swift
//  UnsplashDemo
//
//  Created by Scott Carter on 7/2/20.
//  Copyright © 2020 Scott Carter. All rights reserved.
//

import UIKit

class ImageTilesViewController: UIViewController {

    // MARK: - Variable Properties

    var imageTilesViewModel: ImageTilesViewModel!

    // MARK: - Lifecycle

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let imageTilesCollectionViewController = segue.destination as? ImageTilesCollectionViewController {
            imageTilesCollectionViewController.imageTilesViewModel = imageTilesViewModel
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Collection Images"
    }
}
