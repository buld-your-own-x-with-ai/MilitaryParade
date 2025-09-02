//
//  Item.swift
//  MilitaryParade
//
//  Created by i on 2025/9/2.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
