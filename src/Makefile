SRC_FILES = $(wildcard *.rb)
EXEC_LOC = ../Gorilla.app/Contents/MacOS/

all:
	macrubyc $(SRC_FILES) -o gorilla
	-rm $(EXEC_LOC)gorilla
	mv gorilla $(EXEC_LOC)

open:
	-killall -9 gorilla
	open ../Gorilla.app

run: all open
	