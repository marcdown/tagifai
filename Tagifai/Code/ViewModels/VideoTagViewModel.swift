//
//  VideoTagViewModel.swift
//  Tagifai
//
//  Created by Marc Brown on 10/1/15.
//  Copyright © 2015 creative mess. All rights reserved.
//

class VideoTagViewModel: NSObject {
    var model: VideoTag
    var displayName: String
    var displayProbability: String
    
    init(model: VideoTag) {
        self.model = model
        self.displayName = self.model.name.uppercaseString
        let probPercent = NSString(format: "%.1f", self.model.probability * 100)
        self.displayProbability = "\(probPercent)%"
        
        super.init()
    }
}
