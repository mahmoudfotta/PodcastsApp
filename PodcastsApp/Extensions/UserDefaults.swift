//
//  UserDefaults.swift
//  PodcastsApp
//
//  Created by mahmoud gamal on 10/3/18.
//  Copyright © 2018 mahmoud gamal. All rights reserved.
//

import Foundation

extension UserDefaults {
    
    static let favoritedPodcastKey = "favoritedPodcastKey"
    
    func savedPodcasts() -> [Podcast] {
        guard let savedPodcastData = UserDefaults.standard.data(forKey: UserDefaults.favoritedPodcastKey) else {return []}
        guard let savedPodcasts = NSKeyedUnarchiver.unarchiveObject(with: savedPodcastData) as? [Podcast] else {return []}
        return savedPodcasts
    }
    
    func deletePodcast(podcast: Podcast) {
        let podcasts = savedPodcasts()
        let filteredPodcasts = podcasts.filter { (p) -> Bool in
            return p.trackName != podcast.trackName && p.artistName != podcast.artistName
        }
        let data = NSKeyedArchiver.archivedData(withRootObject: filteredPodcasts)
        UserDefaults.standard.set(data, forKey: UserDefaults.favoritedPodcastKey)
    }
}
