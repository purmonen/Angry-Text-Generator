//
//  WordPredictor.swift
//  ailang
//
//  Created by Sami Purmonen on 30/10/14.
//  Copyright (c) 2014 Sami Purmonen. All rights reserved.
//

import Foundation

public class WordPredictor {
    
    private var nextWordDictionary: [String: String] = [String: String]()
    private var nextProbabilites: [String: [String:Int]] = [String: [String:Int]]()
    private var n: Int
    
    public init(corpus: String, n: Int = 2) {
        self.n = n
        
        nextProbabilites = nextWordProbabilities(corpus, n: n)
        nextWordDictionary = nextWords(corpus, n: n)
    }
    
    private func nextWordProbabilities(var text: String, n: Int) -> [String: [String:Int]] {
        text = text.lowercaseString
        var nextWords = [String: [String:Int]]()
        for words in text.toSentences() {
            
            if words.count < n {
                continue
            }
            for i in n..<words.count {
                var previousWord = "".fromWords(Array(words[i-n..<i]))
                let word = words[i]
                if nextWords[previousWord] == nil {
                    nextWords[previousWord] = [String:Int]()
                }
                nextWords[previousWord]![word] = (nextWords[previousWord]![word] ?? 0) + 1
            }
        }
        return nextWords
    }
    
    private func nextWords(var text: String, n: Int) -> [String: String] {
        var nextWord = [String: String]()
        for (key, value) in nextProbabilites {
            var maxWord = ""
            var maxOccurences = 0
            for (word, occurences) in value {
                if occurences > maxOccurences {
                    maxOccurences = occurences
                    maxWord = word
                }
            }
            nextWord[key] = maxWord
        }
        return nextWord
    }
    
    public func nextWord(text: String) -> String? {
        let key = keyFromText(text)!
        return nextWordDictionary[key]
    }
    
    public func keyFromText(text: String) -> String? {
        let words = text.lowercaseString.trim().toWords()
        if n  > words.count {
            return nil
        }
        return "".fromWords(Array(words[words.count - n ..< words.count]))
    }
    
    public func mostProbableNextWord(text: String, nextWords: [String]) -> String? {
        if keyFromText(text) == nil {
            return nil
        }
        let key = keyFromText(text)!
        var maxWord: String? = nil
        var maxOccurences = 0
        if let wordProbabilities = nextProbabilites[key] {
            for nextWord in nextWords {
                if let occurences = wordProbabilities[nextWord] {
                    if occurences > maxOccurences {
                        maxOccurences = occurences
                        maxWord = nextWord
                    }
                }
            }
        }
        return maxWord
    }
}
