//
//  Podcast.swift
//  PodcastsApp
//
//  Created by mahmoud gamal on 9/2/18.
//  Copyright © 2018 mahmoud gamal. All rights reserved.
//

import Foundation

class Podcast: NSObject, Decodable, NSCoding {
    func encode(with aCoder: NSCoder) {
        aCoder.encode(trackName, forKey: "trackNameKey")
        aCoder.encode(artistName, forKey: "artistNameKey")
        aCoder.encode(artworkUrl600, forKey: "artworkUrl600Key")
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.trackName = aDecoder.decodeObject(forKey: "trackNameKey") as? String
        self.artistName = aDecoder.decodeObject(forKey: "artistNameKey") as? String
        self.artworkUrl600 = aDecoder.decodeObject(forKey: "artworkUrl600Key") as? String
    }
    
    var trackName: String?
    var artistName: String?
    var artworkUrl600: String?
    var trackCount: Int?
    var feedUrl: String?
}
