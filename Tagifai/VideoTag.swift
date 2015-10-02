//
//  VideoTag.swift
//  Tagifai
//
//  Created by Marc Brown on 10/1/15.
//  Copyright © 2015 creative mess. All rights reserved.
//

class VideoTag: NSObject {
    var name: String
    var probability: Double
    
    init(name: String, probability: Double) {
        self.name = name
        self.probability = probability
        
        super.init()
    }
}
