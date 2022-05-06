# $@ : the current target
# $^ : the current prerequisites
# $< : the first current prerequisite

CC=gcc
CFLAGS=-c -Wall
LDFLAGS=-lfl -ly
LEX=flex
YACC=bison
EXEC=tpcas
OBJ=obj/tree.o obj/parser.tab.o obj/lexer.yy.o 
SRC=src/
BIN=bin/
OBJD=obj/

$(BIN)$(EXEC): $(OBJ)
	$(CC) -o $@ $^ $(LDFLAGS)

$(SRC)parser.tab.c: $(SRC)parser.y $(SRC)tree.h
	$(YACC) -do $(SRC)parser.tab.c $<

$(SRC)lexer.yy.c: $(SRC)lexer.lex $(SRC)parser.tab.h $(SRC)tree.h
	$(LEX) -o $@ $<

$(OBJD)%.o: $(SRC)%.c $(SRC)parser.tab.h 
	$(CC) -o $@ $< $(CFLAGS)

$(OBJD)tree.o: $(SRC)tree.c
	$(CC) -o $@ -c $< $(CFLAGS)





.PHONY: clean

clean:
	rm -f $(OBJD)*.o $(SRC)lexer.yy.c $(SRC)parser.tab.[ch]
