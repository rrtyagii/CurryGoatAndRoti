//
//  CardDetail.swift
//  Infomatic
//
//  Created by Rishabh Tyagi on 2/21/26.
//
//import SwiftUI

import Foundation

struct CardDetail: Identifiable, Decodable {
    let id: String
    var isBookmark: Bool
    var tags: [String]
    var title: String
    var preview: String
    var contentFile: String
    var source: String
    var theme: Theme
    
    enum CodingKeys: String, CodingKey {
        case id, tags, title, preview, source
        case contentFile = "content_file"
    }
    
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(String.self, forKey: .id)
        tags = try c.decode([String].self, forKey: .tags)
        title = try c.decode(String.self, forKey: .title)
        preview = try c.decode(String.self, forKey: .preview)
        contentFile = try c.decode(String.self, forKey: .contentFile)
        source = try c.decode(String.self, forKey: .source)

        isBookmark = false
        theme = .standard
    }
}

