//
//  Photo.swift
//  UnsplashDemo
//
//  Created by Scott Carter on 6/26/20.
//  Copyright © 2020 Scott Carter. All rights reserved.
//

import Foundation

struct Photo: Decodable {
    let photoDescription: String?
    let photoUrl: PhotoURL

    enum CodingKeys: String, CodingKey {
        case photoDescription = "alt_description"
        case photoUrl = "urls"
    }
}
