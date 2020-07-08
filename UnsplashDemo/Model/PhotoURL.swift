//
//  PhotoURL.swift
//  UnsplashDemo
//
//  Created by Scott Carter on 6/26/20.
//  Copyright © 2020 Scott Carter. All rights reserved.
//

import Foundation

struct PhotoURL: Decodable {
    let rawURL: String

    enum CodingKeys: String, CodingKey {
        case rawURL = "raw"
    }
}
