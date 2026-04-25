//
//  Item.swift
//  BPM_Counter
//
//  Created by Ghost Buster on 4/25/26.
//

import Foundation
import SwiftData

@Model
final class Item {
    var songName: String
    var bpm: Double
    var timestamp: Date
    
    init(songName: String, bpm:Double) {
        self.songName = songName
        self.bpm = bpm
        self.timestamp = Date()
    }
}
