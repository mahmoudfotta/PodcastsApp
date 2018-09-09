//
//  CMTime.swift
//  PodcastsApp
//
//  Created by mahmoud gamal on 9/9/18.
//  Copyright © 2018 mahmoud gamal. All rights reserved.
//

import AVKit

extension CMTime {
    
    func toDisplayString() -> String {
        
        let totalSeconds = CMTimeGetSeconds(self)
        guard !(totalSeconds.isNaN || totalSeconds.isInfinite) else {
            return "--:--"
        }
        let intTotalSeconds = Int(CMTimeGetSeconds(self))
        let seconds = intTotalSeconds % 60
        let minutes = intTotalSeconds / 60
        //let houers = intTotalSeconds / (60*60)
        let timeFormatString = String(format: "%02d:%02d", minutes, seconds)
        return timeFormatString
    }
    
}
