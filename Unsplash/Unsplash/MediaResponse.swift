//
//  MediaResponse.swift
//  Unsplash
//
//  Created by SWY on 2021/12/13.
//

import Foundation

struct MediaResponse: Codable {
    let results: [Result]
}

struct Result: Codable, Identifiable {
    let id: String
    let urls : URLS
    let user: Username
}

struct URLS: Codable {
    let regular: String
}

struct Username: Codable {
    let name: String
}
