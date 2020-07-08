//
//  BookmarkChange.swift
//  UnsplashDemo
//
//  Created by Scott Carter on 7/7/20.
//  Copyright © 2020 Scott Carter. All rights reserved.
//

import Foundation

struct BookmarkChange {

    var change: ChangeType
    var indexPath: IndexPath?

    enum ChangeType {
        case insert
        case delete
        case startChanges
        case endChanges
    }
}

extension BookmarkChange {
    init(change: ChangeType) {
        self.change = change
    }
}
