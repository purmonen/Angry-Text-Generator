//
//  extensions.swift
//  ailang
//
//  Created by Sami Purmonen on 30/10/14.
//  Copyright (c) 2014 Sami Purmonen. All rights reserved.
//

import Foundation

extension Array {
    func randomElement() -> T {
        let index = Int(arc4random()) % self.count
        return self[index]
    }
}

extension String {
    func toWords() -> [String] {
        return self.trim().componentsSeparatedByString(" ").filter { $0 != "" }
    }
    
    func toSentences() -> [[String]] {
        return self.componentsSeparatedByString(".").map { $0.trim().toWords() }
    }
    
    func fromWords(words: [String]) -> String {
        return words.reduce("", combine: { $0 + $1 + " " }).trim()
    }
    
    func trim() -> String {
        return self.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
    }
    
    func capitalize() -> String {
        return String(Array(self.uppercaseString)[0]) + String(Array(self)[1..<countElements(self)])
    }
}