//
//  ApiService.swift
//  PodcastsApp
//
//  Created by mahmoud gamal on 9/4/18.
//  Copyright © 2018 mahmoud gamal. All rights reserved.
//

import Foundation
import Alamofire
import FeedKit

class APIService {
    
    let baseitunesSearchUrl = "https://itunes.apple.com/search"

    static let shared = APIService()
    
    func fetchEpisodes(feedUrl: String, completionHandler: @escaping ([Episode])->()) {
        let secureFeedUrl = feedUrl.toSecureHTTPS()
        guard let url = URL(string: secureFeedUrl) else {return}
        let parser = FeedParser(URL: url)
        parser?.parseAsync(result: { (result) in
            
            if let err = result.error {
                print("failed to parse xml feed: ", err)
                return
            }
            
            guard let feed = result.rssFeed else {return}
            let episodes = feed.toEpisodes()
            completionHandler(episodes)
        })
    }
    
    func fetchPodcast(searchText: String, completionHandler: @escaping ([Podcast])->()) {
        let parameters = ["term": searchText, "media": "podcast"]
        
        Alamofire.request(baseitunesSearchUrl, method: .get, parameters: parameters, encoding: URLEncoding.default, headers: nil).responseData { (dataResponse) in
            if let err = dataResponse.error {
                print(err)
                return
            }
            guard let data = dataResponse.data else {return}
            do {
                let searchResult = try JSONDecoder().decode(SearchResult.self, from: data)
                completionHandler(searchResult.results)
            } catch let decodeErr {
                print("failed to decode: ", decodeErr)
            }
        }
    }
    
    struct SearchResult: Decodable {
        let resultCount: Int
        let results: [Podcast]
    }
}
