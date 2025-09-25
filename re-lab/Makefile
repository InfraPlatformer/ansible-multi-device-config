SHELL := /bin/bash

CC := gcc
CFLAGS := -O2 -fno-stack-protector -no-pie -s

GO := go
PY := python3

all: build-c build-go build-py

build-c:
	@mkdir -p build/c
	$(CC) $(CFLAGS) samples/c/crackme1.c -o build/c/crackme1

build-go:
	@mkdir -p build/go
	cd samples/go/obf && $(GO) build -ldflags="-s -w" -o ../../build/go/obf

build-py:
	@mkdir -p build/python
	$(PY) -m py_compile samples/python/sample.py
	@cp -r __pycache__ build/python || true

clean:
	rm -rf build __pycache__

.PHONY: all build-c build-go build-py clean
