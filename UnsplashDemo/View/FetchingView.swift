//
//  FetchingView.swift
//  UnsplashDemo
//
//  Created by Scott Carter on 6/27/20.
//  Copyright © 2020 Scott Carter. All rights reserved.
//

import UIKit

class FetchingView: UIView, NibLoadable {

    @IBOutlet private var containerView: UIView!
    @IBOutlet private var label: UILabel!
    @IBOutlet private var spinner: UIActivityIndicatorView!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    convenience init(frame: CGRect, withText text: String) {
        self.init(frame: frame)
        label.text = text
    }

    func commonInit() {
        setupFromNib()

        spinner?.color = Constants.ImageFetch.spinnerColor

        containerView.layer.cornerRadius = Constants.ImageList.loadingViewBorderCornerRadius
        containerView.layer.borderColor = Constants.ImageList.loadingViewBorderColor.cgColor
        containerView.layer.borderWidth = Constants.ImageList.loadingViewBorderWidth
    }
}
