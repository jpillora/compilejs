PHONY: build
build:
	coffee -o dist/ -c src/
watch:
	coffee -w -o dist/ -c src/
