import random
import os

flag_path = "C:/Wordle/util/words/FLAG.txt"
answers_path = "C:/Wordle/util/words/Answers.txt"
rand_word_path = "C:/Wordle/util/words/Word.txt"
words = []

with open(answers_path) as f:
    for line in f:
        words.append(line.strip())

run = True

while run:
    if (os.path.exists(flag_path)):
        print("Flag detected")

        rand_word = random.choice(words)
        print(f"Random word is: '{rand_word}'")

        with open(rand_word_path, "w") as f:
            f.write(rand_word)

        os.remove(flag_path)
        print("File removed")
