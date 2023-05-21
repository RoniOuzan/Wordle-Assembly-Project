RANDOM_WORD_PATH         db "util/words/Word.txt" , 0
RANDOM_WORD_FLAG_PATH    db "util/words/Flag.txt" , 0
answersFilePath db 'util/words/Answers.txt'
randomGeneratedNumberHigh dw ?
randomGeneratedNumberLow dw ?

RndCurrentPos dw start