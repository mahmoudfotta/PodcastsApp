//
//  Episode.swift
//  PodcastsApp
//
//  Created by mahmoud gamal on 9/6/18.
//  Copyright © 2018 mahmoud gamal. All rights reserved.
//

import Foundation
import FeedKit

struct Episode {
    let title: String
    let pubDate: Date
    let description: String
    var imageUrl: String?
    let author: String
    let streamUrl: String
    init(feedItem: RSSFeedItem) {
        title = feedItem.title ?? ""
        pubDate = feedItem.pubDate ?? Date()
        description = feedItem.description ?? ""
        imageUrl = feedItem.iTunes?.iTunesImage?.attributes?.href
        author = feedItem.iTunes?.iTunesAuthor ?? ""
        streamUrl = feedItem.enclosure?.attributes?.url ?? ""
    }
}
