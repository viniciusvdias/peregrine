ROOT_DIR:=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
LDFLAGS=-L $(ROOT_DIR)/core/bliss-0.73/ -lbliss -L/usr/local/lib -lpthread -latomic -L$(LD_LIBRARY_PATH) -ltbb
CFLAGS=-O3 -std=c++2a -Wall -Wextra -Wpedantic -fPIC -fconcepts -I$(ROOT_DIR)/core/
OBJ=core/DataGraph.o core/PO.o core/utils.o core/PatternGenerator.o $(ROOT_DIR)/core/showg.o
OUTDIR=bin/
CC=g++

all: bliss fsm count test existence-query convert_data

core/roaring.o: core/roaring/roaring.c
	gcc -c core/roaring/roaring.c -o $@ -O3 -Wall -Wextra -Wpedantic -fPIC 

%.o: %.cc
	$(CC) -c $? -o $@ $(CFLAGS)

fsm: apps/fsm.cc $(OBJ) core/roaring.o bliss
	$(CC) apps/fsm.cc $(OBJ) core/roaring.o -o $(OUTDIR)/$@ $(LDFLAGS) $(CFLAGS)

existence-query: apps/existence-query.cc $(OBJ) bliss
	$(CC) apps/existence-query.cc $(OBJ) -o $(OUTDIR)/$@ $(LDFLAGS) $(CFLAGS)

count: apps/count.cc $(OBJ) bliss
	$(CC) apps/count.cc $(OBJ) -o $(OUTDIR)/$@ $(LDFLAGS) $(CFLAGS)

test: core/test.cc $(OBJ) core/DataConverter.o core/roaring.o bliss
	$(CC) core/test.cc -DTESTING $(OBJ) core/DataConverter.o core/roaring.o -o $(OUTDIR)/$@ $(LDFLAGS) -lUnitTest++ $(CFLAGS)

convert_data: core/convert_data.cc core/DataConverter.o core/utils.o
	$(CC) -o $(OUTDIR)/$@ $? -L/usr/local/lib -lpthread -latomic -L$(LD_LIBRARY_PATH) -ltbb $(CFLAGS)

bliss:
	make -C ./core/bliss-0.73

clean:
	make -C ./core/bliss-0.73 clean
	rm -f core/*.o bin/*
