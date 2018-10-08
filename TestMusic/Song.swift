//
//  Song.swift
//  TestMusic
//
//  Created by Nikolay Taran on 06.10.18.
//  Copyright © 2018 Nikolay Taran. All rights reserved.
//

import Foundation
import UIKit

// Класс, содержащий информацию о песне
class Song {
    var artistName: String!
    var collectionName: String!
    var trackName: String!
    var previewURL: URL!
    var artworkURL: URL!
    var collectionPrice: String!
    var trackPrice: String!
    var releaseDate: String!
    var discCount: String!
    var discNumber: String!
    var trackCount: String!
    var trackNumber: String!
    var trackTimeMillis: String!
    var genre: String!
    
    var cellFont: UIFont!
    var info: String!
    var lineCount: Int!
    
    // Число строк, занимаемых строкой информации в mutiline UILabel
    func numberOfLines(string: String) -> Int {
        let requiredSize = NSString(string: string).boundingRect(with: CGSize(width: 320, height: DBL_MAX),
                                                                    options: NSStringDrawingOptions.usesLineFragmentOrigin,
                                                                    attributes: [NSFontAttributeName: cellFont],
                                                                    context: nil).size
        
        let charSize = lroundf(Float(cellFont.lineHeight));
        let rHeight = lroundf(Float(requiredSize.height));
        lineCount = rHeight / charSize;
        
        return lineCount
    }
    
    // Число строк, занимаемых строкой информации в mutiline UILabel при условии использования конкретного шрифта
    func numberOfLines(string: String, font: UIFont) -> Int {
        let requiredSize = NSString(string: string).boundingRect(with: CGSize(width: 320, height: DBL_MAX),
                                                                 options: NSStringDrawingOptions.usesLineFragmentOrigin,
                                                                 attributes: [NSFontAttributeName: font],
                                                                 context: nil).size
        
        let charSize = lroundf(Float(font.lineHeight));
        let rHeight = lroundf(Float(requiredSize.height));
        lineCount = rHeight / charSize;
        
        return lineCount
    }
}
