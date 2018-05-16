.PHONY = build static-build release clean help run

.DEFAULT_GOAL = help

PROJECT_NAME ?= $(shell grep "^name" njusko-hs.cabal | cut -d " " -f17)
VERSION ?= $(shell grep "^version:" njusko-hs.cabal | cut -d " " -f14)
RESOLVER ?= $(shell grep "^resolver:" stack.yaml | cut -d " " -f2)
GHC_VERSION ?= $(shell stack ghc -- --version | cut -d " " -f8)
ARCH=$(shell uname -m)


export BINARY_ROOT = $(shell stack path --local-install-root)
export BINARY_PATH = $(shell echo ${BINARY_ROOT}/bin/${PROJECT_NAME})

## Build project
build:
	@stack build
	@echo "\nBinary available at:\n"
	@echo ${BINARY_PATH}


# TODO: Doesn't work. Fix it.
# static-build: clean
# 	@mkdir -p release/build
# 	@stack ghc -- \
# 	app/Main.hs \
# 	src/Network/Njusko/Lib.hs \
# 	src/Network/Njusko/Options.hs \
# 	src/Network/Njusko/Types.hs \
# 	-static \
# 	-rtsopts=all \
# 	-optl-pthread \
# 	-optl-static \
# 	-O2 \
# 	-threaded \
# 	-odir release/build \
# 	-hidir release/build \
# 	-o release/${PROJECT_NAME}-${VERSION}-linux-${ARCH}

## Clean
clean:
	@rm -rf release

## Cut new release
release:
	@git tag ${VERSION} && git push --tags

## Helper for running locally once built
run:
	@${BINARY_PATH} \
		--url-file urls.txt \
		--type APT \
		--notify fake.email@example.com \
		--debug

## Show help screen.
help:
	@echo "Please use \`make <target>' where <target> is one of\n\n"
	@awk '/^[a-zA-Z\-\_0-9]+:/ { \
		helpMessage = match(lastLine, /^## (.*)/); \
		if (helpMessage) { \
			helpCommand = substr($$1, 0, index($$1, ":")-1); \
			helpMessage = substr(lastLine, RSTART + 3, RLENGTH); \
			printf "%-30s %s\n", helpCommand, helpMessage; \
		} \
	} \
	{ lastLine = $$0 }' $(MAKEFILE_LIST)

