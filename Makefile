# Calciu Alexandru 331CC
all: build

build: main.l
	flex main.l
	gcc -o exec lex.yy.c -lfl

clean:
	rm lex.yy.c exec