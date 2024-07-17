# this nice makefile template was made by David Maor
# https://github.com/DavidMaor32/makeLexYacc
# HOW TO USE
# 0. copy this template to the project directory(folder)
# 1. create the lex file and yacc file
# 2. in the terminal
#	2.1 cd to the project directory(folder)
#	2.2 run the command 'make'
#	2.3 now the compiler has been generated
#	2.4 run 'make clean' to delete all generated files

#		EXAMPLE
# cd ./myProject	//change working directory to the project
# make			//generate the compiler
# ./myCompiler < text.t	//compile the source file 'text.t'
# make clean		//delete the compiler, lex.yy.c and y.tab.c

# lex source file name
LEX_SRC = scanner.l
LEX_TOKENIZER = tokenizer.l

# yacc source file name
YACC_SRC = parser.y

# compiler name
EXEC = compiler.exe

DEBUG = debugger.exe

TOKEN = tokenizer.exe

CC = gcc
FLAGS = -ll -Ly
FLAGS_DEBUG = --debug --verbose --graph -Wall
LEX = lex
YACC = yacc
LEX_OUT = lex.yy.c
YACC_OUT = y.tab.c

# default target
all: $(EXEC)


# how to build the executable(compiler)
$(EXEC): $(YACC_OUT) $(LEX_OUT)
	$(CC) -o $(EXEC) $(YACC_OUT) $(FLAGS)
	make clean

# how to generate lex output
$(LEX_OUT): $(LEX_SRC)
	$(LEX) $(LEX_SRC)

# how to generate yacc output
$(YACC_OUT): $(YACC_SRC)
	$(YACC) $(YACC_SRC)

# debug
debug: $(LEX_OUT)
	$(YACC) $(FLAGS_DEBUG) $(YACC_SRC)
	$(CC) -o $(DEBUG) -g $(YACC_OUT) $(FLAGS)
	@make clean

# tokenizer
token:
	$(LEX) $(LEX_TOKENIZER)
	$(CC) -o $(TOKEN) $(LEX_OUT) $(FLAGS)
	@make clean

# clean all generated files
clean:
	rm -f $(LEX_OUT) $(YACC_OUT) y.vcg *.c

.PHONY: all clean
