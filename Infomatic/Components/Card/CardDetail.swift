//
//  CardDetail.swift
//  Infomatic
//
//  Created by Rishabh Tyagi on 2/21/26.
//
//import SwiftUI

import Foundation

struct CardDetail: Identifiable, Decodable {
    static let bookmarkContentType = "card"

    let id: String
    var tags: [String]
    var title: String
    var preview: String
    var contentFile: String
    var source: String
    var theme: Theme

    var bookmarkContentId: String {
        id
    }

    var bookmarkType: String {
        Self.bookmarkContentType
    }
    
    enum CodingKeys: String, CodingKey {
        case id, tags, title, preview, source
        case contentFile = "content_file"
    }
    
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(String.self, forKey: .id)
        title = try c.decode(String.self, forKey: .title)
        preview = try c.decode(String.self, forKey: .preview)
        contentFile = try c.decode(String.self, forKey: .contentFile)
        source = try c.decodeIfPresent(String.self, forKey: .source) ?? "Wikipedia"
        tags = try c.decodeIfPresent([String].self, forKey: .tags) ?? []
        theme = .standard
    }
}
