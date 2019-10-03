.PHONY: all c0c clean

all: c0c

src/Compile/Lexer.hs: src/Compile/Lex.x
	stack install --allow-different-user alex
	stack exec alex --allow-different-user -- -g src/Compile/Lex.x -o src/Compile/Lexer.hs

src/Compile/Parser.hs: src/Compile/Parse.y
	stack install --allow-different-user happy
	stack exec happy --allow-different-user -- -agc src/Compile/Parse.y -o src/Compile/Parser.hs

# only rebuilds the code generated lexer and parser if the file timestamp tag doesn't match c0c
c0c: src/Compile/Lexer.hs src/Compile/Parser.hs
	mkdir -p shellbins
	stack install --allow-different-user --install-ghc --local-bin-path shellbins
	mkdir -p ../bin
	cp -r shellbins/* ../bin/
	chmod +x ../bin/*

clean:
	rm -rf ../bin
	stack clean
	rm -rf shellbins
	rm -f src/Compile/Lexer.hs
	rm -f src/Compile/Parser.hs
