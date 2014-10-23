import Foundation

func groupBy(wordSplits: [[String]]) -> [String: [String]] {
    var wordClass = [String:[String]]()
    for wordSplit in wordSplits.filter({$0.count == 2}) {
        let word = wordSplit[0].lowercaseString
        let wClass = wordSplit[1]
        if !contains(wordClass.keys, wClass) {
            wordClass[wordSplit[1]] = [String]()
        }
        wordClass[wClass]!.append(word)
    }
    return wordClass
}

func readWordClassFile(fileName: String) -> [String: [String]] {
    var err: NSError?
    var sw = String(contentsOfFile: fileName, encoding: NSUTF8StringEncoding, error: &err)!
    return groupBy(sw.stringByReplacingOccurrencesOfString("\n|\t", withString: " ", options: NSStringCompareOptions.RegularExpressionSearch, range: nil).componentsSeparatedByString(" ").map { $0.componentsSeparatedByString("/") })
}

func readSentenceStructures(fileName: String) -> [String] {
    var err: NSError?
    var sw = String(contentsOfFile: fileName, encoding: NSUTF8StringEncoding, error: &err)!
    return sw.componentsSeparatedByString("./").map({
        $0.componentsSeparatedByString(" ").map({
            let split = $0.componentsSeparatedByString("/")
            if split.count == 2 {
                return split[1]
            }
            return ""
        }).reduce("", { $0 + $1 + " "})
    })
}

extension Array {
    func randomElement() -> T {
        let index = Int(arc4random()) % self.count
        return self[index]
    }
}

extension String {
    func trim() -> String {
        return self.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: " "))
    }
    
    func capitalize() -> String {
        return String(Array(self.uppercaseString)[0]) + String(Array(self)[1..<countElements(self)])
    }
}

func randomSentence(sentenceStructure: String, wordClass: [String: [String]]) -> String {
    println(sentenceStructure.trim().componentsSeparatedByString(" "))
    return sentenceStructure.trim().componentsSeparatedByString(" ").reduce("", {
        $0 + wordClass[$1]!.randomElement() + " " }).trim().capitalize() + "."
}

func randomSentence2(sentenceStructure: String, wordClass: [String: [String]], input: [String: [String]]) -> String {
    var sentence = ""
    for c in sentenceStructure.trim().componentsSeparatedByString(" ").filter({ $0 != ""}) {
        sentence += (input[c]?.randomElement() ?? wordClass[c]!.randomElement()) + " "
    }
    return sentence.trim().capitalize() + "."
}

func angryText(name: String) -> String {
    var text = ""
    var wordClass = [String:[String]]()
    
    
    
    for fileName in ["cl10.txt", "ch05.txt", "ch21.txt", "ca02.txt", "cg19.txt", "cj27.txt", "cr06.txt"] {
        let wc = readWordClassFile(fileName)
        for (key, value) in wc {
            wordClass[key] = (wordClass[key] ?? [String]()) + value
        }
    }
    var sentenceStructures = readSentenceStructures("cl10.txt").filter { !contains($0, "`") && !contains($0, ",")}
    let sentenceStructure = sentenceStructures.randomElement()
    var sentenceProbability = [String: Double]()
    
    let input = [
        "nn": ["motherfucker", "hell", "bitch"],
        "jj": ["angry", "mad", "crazy", "wrong", "ugly", "burn"],
        "ppo": ["you"]
    ]
    
    var wantedSentenceStructures = [String]()
    for structure in sentenceStructures {
        var isWanted = true
        for key in input.keys {
            if !contains(structure.componentsSeparatedByString(" "), key) {
                isWanted = false
            }
        }
        if isWanted {
            wantedSentenceStructures.append(structure)
        }
    }
    
//    
//    var maxSentence = ""
//    var maxProbability = 0.0
//    for sentence in sentenceStructures {
//        sentenceProbability[sentence] = (sentenceProbability[sentence] ?? 0) + 1
//        if sentenceProbability[sentence]! > maxProbability {
//            maxProbability = sentenceProbability[sentence]!
//            maxSentence = sentence
//        }
//    }
//    for sentence in sentenceStructures {
//        println(sentence + ": \(sentenceProbability[sentence]!)")
//        sentenceProbability[sentence] = sentenceProbability[sentence]! / Double(sentenceStructures.count)
//    }
//    
    if (wantedSentenceStructures.count == 0) {
        println("NO WANTED SENTENCES FOUND")
        exit(0)
    }
    
    for i in 1..<10 {
        let structure = wantedSentenceStructures.randomElement()
        if countElements(structure) < 40 && countElements(structure) > 5 {
            text += randomSentence2(structure, wordClass, input) + " "
        }
    }
    return text
}

println(angryText("Paul"))
