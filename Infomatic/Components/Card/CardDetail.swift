//
//  CardDetail.swift
//  Infomatic
//
//  Created by Rishabh Tyagi on 2/21/26.
//
import SwiftUI

struct CardDetail: Identifiable {
    let id = UUID()
    var isBookmark: Bool;
    var tags: [String];
    var title: String;
    var content: String;
    var image: Image;
    var theme: Theme;
}
