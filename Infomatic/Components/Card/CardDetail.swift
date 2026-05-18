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

    let id: String // id of type string
    var tags: [String] // tags of type array of srings
    var title: String
    var preview: String
    var contentFile: String
    var source: String
    var theme: Theme // theme of type Theme

    var bookmarkContentId: String {
        id
    }

    var bookmarkType: String { // this is not a closure
        Self.bookmarkContentType // this is a computer properties; meaning value is calculate on the fly when the property is accessed
    }

    init(
        id: String,
        tags: [String],
        title: String,
        preview: String,
        contentFile: String,
        source: String = "Wikipedia",
        theme: Theme = .standard
    ) {
        self.id = id
        self.tags = tags
        self.title = title
        self.preview = preview
        self.contentFile = contentFile
        self.source = source
        self.theme = theme
    }
    
    enum CodingKeys: String, CodingKey { // this is a special keyword that is useful for Decodable, Encodable or Codable structs. It tells the Swift Compiler that these are the sort of mapping instructions for the decoding
        case id, tags, title, preview, source
        case contentFile = "content_file"
    }
    
    // initiallise 'from' a decoder of type Decoder. If anything goes wrong "throw" an error back to whoever called it.
    init(from decoder: Decoder) throws {
        // lets try to reate a container that will be used to decode and create our object. The keymapping is detailed in the "CodingKeys".
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
