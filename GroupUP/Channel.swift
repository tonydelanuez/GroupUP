//
//  Channel.swift
//  GroupUP
//
//  Created by Eric Goodman on 4/5/17.
//  Copyright © 2017 GroupUP. All rights reserved.
//

import Foundation

// Inspiration from https://www.raywenderlich.com/140836/firebase-tutorial-real-time-chat-2
class Channel {
    
    var id: String
    var name: String
    
    init(id: String, name: String) {
        self.id = id
        self.name = name
    }
    
}
