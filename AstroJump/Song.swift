//
//  Song.swift
//  AstroJump
//
//  Created by James Ly on 5/21/17.
//  Copyright © 2017 cpe436. All rights reserved.
//

import Foundation

class Song {
    var title: String
    var artist: String
    var videoId: String
    
    init(title: String, artist: String, videoId: String) {
        self.title = title
        self.artist = artist
        self.videoId = videoId
    }
}
