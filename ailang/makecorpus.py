import nltk
import sys

fileName = sys.argv[1]
text = open(fileName).read()
tags = nltk.pos_tag(nltk.word_tokenize(text))
a = map(lambda x: x[0] + "/" + x[1], tags)
out = reduce(lambda x, y: x + " " + y, a)
print(out)
