//
//  Character+isEmoji.swift
//  ShopSmart
//
//  Created by Alimkhan Yergebayev on 1/5/2025.
//

import Foundation

extension Character {
    var isEmoji: Bool {
        self.unicodeScalars.contains { scalar in
            let scalarValue = scalar.value
            return (scalarValue >= 0x1F600 && scalarValue <= 0x1F64F) ||   // Emoticons
            (scalarValue >= 0x1F300 && scalarValue <= 0x1F5FF) ||   // Misc Symbols and Pictographs
            (scalarValue >= 0x1F680 && scalarValue <= 0x1F6FF) ||   // Transport & Map
            (scalarValue >= 0x2600 && scalarValue <= 0x26FF) ||     // Misc Symbols
            (scalarValue >= 0x2700 && scalarValue <= 0x27BF) ||     // Dingbats
            (scalarValue >= 0x1F900 && scalarValue <= 0x1F9FF) ||   // Supplemental Symbols
            (scalarValue >= 0x1F1E6 && scalarValue <= 0x1F1FF)      // Flags
        }
    }
}
