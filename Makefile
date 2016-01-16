.PHONY = build static-build release clean

VERSION=0.1.0.0
ARCH=$(shell uname -m)
NAME=njusko-hs

build:
	@stack build
	@echo "\nBinary available at:\n"
	@echo "`pwd`/.stack-work/install/${ARCH}-linux/lts-3.16/7.10.2/bin/${NAME}-exe"


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
# 	-o release/${NAME}-${VERSION}-linux-${ARCH}

clean:
	@rm -rf release

release: build
	# @echo "\n\nRelease available at:\n"
	# @echo "STATIC BINARY: `pwd`/release/${NAME}-${VERSION}-linux-${ARCH}\n"

run:
	@`pwd`/.stack-work/install/${ARCH}-linux/lts-3.16/7.10.2/bin/${NAME}-exe \
		--url-file urls.txt \
		--type APT \
		--notify fake.email@example.com \
		--debug

