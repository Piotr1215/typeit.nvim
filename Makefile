.PHONY: test
test:
	eval $$(luarocks path --bin) && vusted test

.PHONY: test-watch
test-watch:
	find . -name '*.lua' | entr -c make test
