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
    return sw.componentsSeparatedByString("/.").map({
        $0.trim().componentsSeparatedByString(" ").map({
            let split = $0.componentsSeparatedByString("/")
            if split.count == 2 {
                return split[0].trim()
            }
            return ""
        }).reduce("", { $0 + $1 + " "}).trim()
    }).reduce("", { $0 + $1 + ". "})
}

let corpusFileNames = ["angry.txt", "cn16.txt"]

func angryTextNGram(reson: String, sentencesCount: Int) -> String {
    var corpus = ""
    for fileName in corpusFileNames {
        corpus += readText(fileName)
    }

    let ngram = MultiGram(corpus: corpus, n: 3)
    var text = ""
    for j in 1...sentencesCount {
        var sentence = ngram.ngrams[ngram.ngrams.count-1].nextProbabilites.keys.array.randomElement()
        for i in 1...20 {
            if let newWord = ngram.nextWord(sentence) {
                sentence += " " + newWord
            }
        }
        sentence += ". "
        text += sentence.capitalize()
    }
    return text.stringByReplacingOccurrencesOfString(" ,", withString: ",", options: nil, range: nil)
}

func angryText(reason: String, sentencesCount: Int) -> String {
    var wordClass = [String:[String]]()
    var sentenceStructures = [[String]]()
    
    // "cl10.txt", "ch05.txt", "ch21.txt", "ca02.txt", "cg19.txt", "cj27.txt",
    var corpus = ""
    for fileName in corpusFileNames {
        let wc = readWordClassFile(fileName)
        for (key, value) in wc {
            wordClass[key] = (wordClass[key] ?? [String]()) + value
        }
        corpus += readText(fileName)
        sentenceStructures += readSentenceStructures(fileName)
    }
    let multiGram = MultiGram(corpus: corpus, n: 3)
    
    let sentenceStructure = sentenceStructures.randomElement()
    var sentenceProbability = [String: Double]()
    
    let input = [
//        "nn": [
//            "motherfucker", "hell", "bitch", "retard", "idiot", "asshole",
//            "maggot", "dogshit", "rhino", "dinosaur", "monkey"],
//        "jj": ["angry", "mad", "crazy", "ugly", "stupid", "idiotic", "dumb", "retarded"],
//        "np": ["paul"],
        "jj": [reason]
//        "ppo": ["you"]
    ]

    
    var text = "I hate you because you are \(reason). "
    var underlyingText = ""
    println("----")

    for i in 1...sentencesCount {
        let structure = sentenceStructures.filter({ $0.count >= 4 && $0.count <= 9 && !contains($0, "md") }).randomElement()
        var sentence = wordClass[structure[0]]!.randomElement() + " "
        underlyingText += sentenceStructureMap[structure.reduce("", combine: {$0 + $1})]!
        println(structure)
        for wc in structure[1..<structure.count] {
            if wordClass[wc] == nil {
                continue
            }
            var word: String? = nil
            let w = input[wc]?.randomElement()
            if w != nil && rand() % 100 > 0 {
                word = w!
            } else {
                if let w = multiGram.nextWord(sentence, nextWords: wordClass[wc]!) {
                    word = w
                } else {
                    word = wordClass[wc]!.randomElement()
                }
            }
            sentence += word! + " "
        }
        sentence = sentence.capitalize().trim() + ". "
        text += sentence
    }
    text += "So stop being \(reason)."
    println("----")
    println(underlyingText)
    println("----")
    return text.stringByReplacingOccurrencesOfString(" ,", withString: ",", options: nil, range: nil)
}


let sentencesCount = 3

println("Angry NGram text")
println(angryTextNGram("late", sentencesCount))

println()
println()

println("Angry improved text")
println(angryText("late", sentencesCount))