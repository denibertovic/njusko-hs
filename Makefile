.PHONY = build static-build release clean

PROJECT_NAME ?= $(shell grep "^name" njusko-hs.cabal | cut -d " " -f17)
VERSION ?= $(shell grep "^version:" njusko-hs.cabal | cut -d " " -f14)
RESOLVER ?= $(shell grep "^resolver:" stack.yaml | cut -d " " -f2)
GHC_VERSION ?= $(shell stack ghc -- --version | cut -d " " -f8)
ARCH=$(shell uname -m)

export BINARY_ROOT = $(shell stack path --local-install-root)
export BINARY_PATH = $(shell echo ${BINARY_ROOT}/bin/${PROJECT_NAME}-exe)

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

clean:
	@rm -rf release

release: build
	# @echo "\n\nRelease available at:\n"
	# @echo "STATIC BINARY: `pwd`/release/${NAME}-${VERSION}-linux-${ARCH}\n"

run:
	@${BINARY_PATH} \
		--url-file urls.txt \
		--type APT \
		--notify fake.email@example.com \
		--debug

