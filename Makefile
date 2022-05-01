TestFiles = $(wildcard ./test/*.js)

all:
	truffle compile

clean:
	rm -rf build

test:$(TestFiles)
	truffle test