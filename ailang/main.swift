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

//func readSentenceStructures(fileName: String) -> [[String]] {
//    var err: NSError?
//    var sw = String(contentsOfFile: fileName, encoding: NSUTF8StringEncoding, error: &err)!
//    return sw.trim().componentsSeparatedByString("/.").map({
//        $0.componentsSeparatedByString(" ").map({
//            let split = $0.componentsSeparatedByString("/")
//            if split.count == 2 {
//                return split[1].trim()
//            }
//            return ""
//        }).filter({ $0 != "" })
//    }).filter({ $0.count > 0 && !contains($0, "``") && !contains($0, "''") && !contains($0, ".") && !contains($0, "--") }).filter({!contains($0, ",") })
//}

var sentenceStructureMap = [String: String]()

func readSentenceStructures(fileName: String) -> [[String]] {
    var err: NSError?
    var sw = String(contentsOfFile: fileName, encoding: NSUTF8StringEncoding, error: &err)!
    var sentenceStructures = [[String]]()
    for sentence in sw.componentsSeparatedByString("/.") {
        var sentenceStructure = [String]()
        var sentenceWords = [String]()
        for word in sentence.toWords() {
            let split = word.componentsSeparatedByString("/")
            if split.count == 2 {
                sentenceStructure.append(split[1].trim())
                sentenceWords.append(split[0].trim())
            }
        }
        //        println(sentenceWords.reduce("", combine: {$0 + " " + $1}))
        sentenceStructures.append(sentenceStructure)
        let key = sentenceStructure.reduce("", combine: {$0 + $1})
        let value = sentenceWords.reduce("", combine: {$0 + " " + $1}) + ". "
        sentenceStructureMap[key] = value
    }
    return sentenceStructures.filter({ $0.count > 0 && !contains($0, "``") && !contains($0, "''") && !contains($0, ".") && !contains($0, "--") && !contains($0, ",") })
}

func readText(fileName: String) -> String {
    var err: NSError?
    var sw = String(contentsOfFile: fileName, encoding: NSUTF8StringEncoding, error: &err)!
    return sw.componentsSeparatedByString("./").map({
        $0.trim().componentsSeparatedByString(" ").map({
            let split = $0.componentsSeparatedByString("/")
            if split.count == 2 {
                return split[0].trim()
            }
            return ""
        }).reduce("", { $0 + $1 + " "}).trim()
    }).reduce("", { $0 + $1})
}

func randomSentence(sentenceStructure: String, wordClass: [String: [String]]) -> String {
    return sentenceStructure.trim().componentsSeparatedByString(" ").reduce("", {
        $0 + (wordClass[$1]?.randomElement() ?? $1 + "_not_found") + " " }).trim().capitalize() + "."
}

func randomSentence2(sentenceStructure: String, wordClass: [String: [String]], input: [String: [String]]) -> String {
    var sentence = ""
    for c in sentenceStructure.toWords() {
        sentence += (input[c]?.randomElement() ?? wordClass[c]!.randomElement()) + " "
    }
    return sentence.trim().capitalize() + "."
}

func angryText(reason: String) -> String {
    
    var wordClass = [String:[String]]()
    var sentenceStructures = [[String]]()
    
    // "cl10.txt", "ch05.txt", "ch21.txt", "ca02.txt", "cg19.txt", "cj27.txt",
    var corpus = ""
    for fileName in ["cn16.txt"] {
        let wc = readWordClassFile(fileName)
        for (key, value) in wc {
            wordClass[key] = (wordClass[key] ?? [String]()) + value
        }
        corpus += readText(fileName)
        sentenceStructures += readSentenceStructures(fileName)
    }
    let wordPredictor1 = WordPredictor(corpus: corpus, n: 1)
    
    
    
    let wordPredictor2 = WordPredictor(corpus: corpus, n: 2)
    let wordPredictor3 = WordPredictor(corpus: corpus, n: 3)
    
    let sentenceStructure = sentenceStructures.randomElement()
    var sentenceProbability = [String: Double]()
    
    let input = [
        "nn": ["motherfucker", "hell", "bitch", "retard", "idiot", "asshole", "maggot", "dogshit", "rhino", "dinosaur"],
        "jj": ["angry", "mad", "crazy", "ugly", "stupid", "idiotic", "dumb", "retarded"],
        "ppo": ["you"]
    ]
    
    var wantedSentenceStructures = [[String]]()
    for structure in sentenceStructures {
        var isWanted = true
        for key in input.keys {
            if !contains(structure, key) {
                isWanted = false
            }
        }
        if isWanted {
            wantedSentenceStructures.append(structure)
        }
    }
    
    //    if (wantedSentenceStructures.count == 0) {
    //        println("NO WANTED SENTENCES FOUND")
    //        exit(0)
    //    }
    
    var text = "I hate you because you are \(reason). "
    var underlyingText = ""
    for i in 1..<3 {
        let structure = sentenceStructures.filter({ $0.count >= 4 && $0.count <= 9 }).randomElement()
        var sentence = wordClass[structure[0]]!.randomElement() + " "
        underlyingText += sentenceStructureMap[structure.reduce("", combine: {$0 + $1})]!
        for wc in structure[1..<structure.count] {
            if wordClass[wc] == nil {
                continue
            }
            
            var word: String? = nil
            
            let w = input[wc]?.randomElement()
            if w != nil && rand() % 100 > 50 {
                word = w!
            } else {
                if let w = wordPredictor3.mostProbableNextWord(sentence, nextWords: wordClass[wc]!) {
                    println(w + " 3")
                    word = w
                } else {
                    if let w = wordPredictor2.mostProbableNextWord(sentence, nextWords: wordClass[wc]!) {
                        println(w + " 2")
                        word = w
                    } else {
                        if let w = wordPredictor1.mostProbableNextWord(sentence, nextWords: wordClass[wc]!) {
                            println(w + " 1")
                            word = w
                        } else {
                            word = wordClass[wc]!.randomElement()
                            println(word! + "0")
                        }
                    }
                }
            }
            sentence += word! + " "
        }
        sentence = sentence.capitalize().trim() + ". "
        text += sentence
    }
    text += "So stop being \(reason)."
    println(underlyingText)
    println("-------")
    return text.stringByReplacingOccurrencesOfString(" ,", withString: ",", options: nil, range: nil)
}

println(angryText("late"))