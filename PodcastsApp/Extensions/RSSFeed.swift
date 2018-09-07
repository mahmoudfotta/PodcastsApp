//
//  RSSFeed.swift
//  PodcastsApp
//
//  Created by mahmoud gamal on 9/7/18.
//  Copyright © 2018 mahmoud gamal. All rights reserved.
//

import FeedKit

extension RSSFeed {
    
    func toEpisodes() -> [Episode] {
        
        var episodes = [Episode]()
        let imageUrl = iTunes?.iTunesImage?.attributes?.href
        items?.forEach({ (feedItem) in
            var episode = Episode(feedItem: feedItem)
            if episode.imageUrl == nil {
                episode.imageUrl = imageUrl
            }
            episodes.append(episode)
        })
        
        return episodes
    }
    
}
