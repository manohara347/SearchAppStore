//
//  Track.swift
//  SearchAppStore
//
//  Created by manohara reddy p on 10/10/17.
//  Copyright © 2017 manohara reddy p. All rights reserved.
//

import Foundation
import Cocoa

class Track: NSObject {
    
    @objc dynamic let name: String
    @objc dynamic let artist: String
    @objc dynamic let country:String
    @objc dynamic var artWorkImage: NSImage?
    let trackID:Int
    let artworkURL:String
    init(name: String, artist: String, country:String,trackID:Int,artworkURL:String ) {
        self.name = name
        self.artist = artist
        self.country = country
        self.trackID = trackID
        self.artworkURL = artworkURL
    }
    
    // Load Image for artworkURL
    func loadImage() {
        
        guard artWorkImage == nil else { return }
        QueryService.downloadImage(artworkURL) { (image) -> Void in
            DispatchQueue.main.async{
                self.artWorkImage = image
            }
        }
    }
}

extension Track {
    
    convenience init?(dictionary:JSONDictionary) {
        guard  let name = dictionary["trackName"] as? String,
            let artist = dictionary["artistName"] as? String,
            let country = dictionary["country"] as? String,
            let trackId = dictionary["trackId"] as? Int,
            let artworkURL = dictionary["artworkUrl60"] as? String else { return nil }
        self.init(name: name, artist: artist, country: country, trackID: trackId,artworkURL: artworkURL)
    }
}
