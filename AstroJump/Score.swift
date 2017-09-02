//
//  Score.swift
//  AstroJump
//
//  Created by James Ly on 6/4/17.
//  Copyright © 2017 cpe436. All rights reserved.
//

import Foundation
import Firebase

class Score: NSObject {
    var player: String
    var coins: Int
    let ref: DatabaseReference?
    
    init(player: String, score: Int) {
        self.player = player
        self.coins = score
        ref = nil
    }

    init(snapshot: DataSnapshot) {
        player = snapshot.key
        let snapvalues = snapshot.value as! [String: AnyObject]
        coins = snapvalues["coins"] as! Int
        ref = snapshot.ref
    }
    
    func toAnyObject() -> Any {
        return ["player": player,
                "coins": coins]
    }
}
