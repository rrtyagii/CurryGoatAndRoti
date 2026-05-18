//
//  TopicPrefixMap.swift
//  Infomatic
//
//  Created by Rishabh Tyagi on 5/14/26.
//

import Foundation

struct PrefixMapType: Codable {
    let prefix: String
    let words: Set<String>
    
    init(prefix: String, words: Set<String>){
        self.prefix = prefix
        self.words = words
    }
}

struct TopicPrefixMap {
    private let MINIMUM_LENGTH = 2
    private let MAXIMUM_LENGTH = 5
    
    static let DOCUMENT_URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    let INFOMATIC_RESOURCES_URL = TopicPrefixMap.DOCUMENT_URL.appendingPathComponent("Infomatic/Resources")
    
    private var vocabulary: [String]
    var prefixMap: [ PrefixMapType ]
    
    init(with vocabulary: [String]) {
        self.vocabulary = vocabulary
        self.prefixMap = []
        readJsonData()
    }
    
    private func writeJsonData(to filename:String, with data: [PrefixMapType]) -> Void {
        do {
            /// grabbing the first item from the list and boldly telling the compiler that it isn't empty so open it.
            /// FileManager.default.urls(for: .documentDirectory, in: .userDomainMask) return an Array of URLs.
            /// ! is forced Unwrap.
            try FileManager.default.createDirectory(at: INFOMATIC_RESOURCES_URL, withIntermediateDirectories: true)
            
            var fileNameUrl = INFOMATIC_RESOURCES_URL.appendingPathComponent(filename)
        
            if fileNameUrl.pathExtension != "json"{
                fileNameUrl = fileNameUrl.appendingPathExtension("json")
            }
            
            let jsonEncoder = JSONEncoder()
            let jsonData = try jsonEncoder.encode(data)
            
            try jsonData.write(to: fileNameUrl)
            
        } catch {
            print("Error while writingJsonData to \(filename): \(error)")
        }
    }
    
    private mutating func readJsonData(){
        let filename: URL = INFOMATIC_RESOURCES_URL.appendingPathComponent("prefix_map.json")
        
        do {
            let jsonData = try Data(contentsOf: filename)
            let jsonDecoder = JSONDecoder()
            let readingData = try jsonDecoder.decode([PrefixMapType].self, from: jsonData)
            self.prefixMap = readingData
        } catch {
            print("Error while readingJsonData from \(filename): \(error)")
            self.prefixMap = self.computePrefix()
            self.writeJsonData(to: "prefix_map.json", with: self.prefixMap)
        }
    }
    
    private func computePrefix () -> [ PrefixMapType ]{
        var prefixMap : [String: Set<String>] = [:]
        var result : [ PrefixMapType ] = []
        
        for word in self.vocabulary {
            for position in MINIMUM_LENGTH...MAXIMUM_LENGTH {
                if (position > word.count) {
                    continue
                }
                let current_prefix = String(word.prefix(position)).lowercased()
                prefixMap[current_prefix, default: []].insert(word)
            }
        }
        
        for(key, value) in prefixMap {
            result.append(PrefixMapType(prefix: key, words: value))
        }
    
        return result
    }
}
