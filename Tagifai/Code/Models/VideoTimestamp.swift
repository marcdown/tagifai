//
//  VideoTimestamp.swift
//  Tagifai
//
//  Created by Marc Brown on 10/1/15.
//  Copyright © 2015 creative mess. All rights reserved.
//

class VideoTimestamp: NSObject {
    var timestamp: NSNumber
    var videoTags: [VideoTag]
    
    init(timestamp: NSNumber, tags: [String], probabilities: [Double]) {
        self.timestamp = timestamp
        self.videoTags = [VideoTag]()
        
        for (var i = 0; i < tags.count; i++) {
            let videoTag = VideoTag(name: tags[i], probability: probabilities[i])
            self.videoTags.append(videoTag)
        }
        
        // Sort tags by probability (high -> low)
        self.videoTags.sortInPlace({$0.probability >= $1.probability})
        
        super.init()
    }
}
